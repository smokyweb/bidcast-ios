//
//  StripeCardViewModel.swift
//  BidCast
//
//  Created by JamTech on 30/12/25.
//

import SwiftUI
import Stripe
import Combine

// MARK: - Stripe Error Types
enum StripeError: LocalizedError {
    case invalidCardDetails
    case missingCardNumber
    case missingCVC
    case missingExpiration
    case tokenCreationFailed(String)
    case cardAddFailed(String)
    case cardUpdateFailed(String)
    case cardDeleteFailed(String)
    case cardFetchFailed(String)
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCardDetails:
            return "Please enter valid card details"
        case .missingCardNumber:
            return "Card number is required"
        case .missingCVC:
            return "CVC is required"
        case .missingExpiration:
            return "Expiration date is required"
        case .tokenCreationFailed(let message):
            return "Failed to create token: \(message)"
        case .cardAddFailed(let message):
            return "Failed to add card: \(message)"
        case .cardUpdateFailed(let message):
            return "Failed to update card: \(message)"
        case .cardDeleteFailed(let message):
            return "Failed to delete card: \(message)"
        case .cardFetchFailed(let message):
            return "Failed to fetch cards: \(message)"
        case .networkError:
            return "No internet connection"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - CardDataModel
struct CardDataModel: Codable {
    var cardID: String?
    var expYear, expMonth: Int?
    var last4, fingerprint, cardHolderName: String?
    var isDefault: Bool?
    
//    var expirationDisplay: String {
//        String(format: "%02d/%d", expMonth, expYear)
//    }
    
    enum CodingKeys: String, CodingKey {
        case cardID = "card_id"
        case expYear = "exp_year"
        case expMonth = "exp_month"
        case last4, fingerprint
        case cardHolderName = "card_holder_name"
        case isDefault = "is_default"
    }
}


// MARK: - DataClass
struct UpdatedDataModel: Codable {
//    var id, object, allowRedisplay: String?
//    var billingDetails: BillingDetails?
//    var card: Card?
//    var created: Int?
//    var customer: String?
//    var customerAccount: String?
//    var livemode: Bool?
//    var metadata: Metadata?
//    var type: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, object
//        case allowRedisplay = "allow_redisplay"
//        case billingDetails = "billing_details"
//        case card, created, customer
//        case customerAccount = "customer_account"
//        case livemode, metadata, type
//    }
}

// MARK: - Stripe Token Result
struct StripeTokenResult {
    let tokenId: String
    let cardBrand: String
    let last4: String
    let expirationMonth: UInt
    let expirationYear: UInt
}

// MARK: - Stripe Token Result
struct StripeRequest {
    let cardHolderName: String
    let cardNumber: String
    let expirationMonth: UInt
    let expirationYear: UInt
    let cvc: String
}

// MARK: - View State
enum ViewState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

// MARK: - Stripe Card ViewModel
@MainActor
class StripeCardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var cards: ResponseModelPaginate<[CardDataModel]>?
    @Published var selectedCard: CardDataModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var viewState: ViewState = .idle
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    @Published var addedCardDict = ResponseModel<[String?]>()
    @Published var deletedCardDict = ResponseModel<Int>()
    @Published var setDefaultCardDict = ResponseModel<[Int?]>()
  
    @Published var updatedCardDict = ResponseModel<UpdatedDataModel>()
    
    // MARK: - Private Properties
    private let apiClient = STPAPIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // Auto-clear error messages after 3 seconds
        $errorMessage
            .compactMap { $0 }
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
        
        // Auto-clear success messages after 3 seconds
        $successMessage
            .compactMap { $0 }
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.successMessage = nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Get Stripe Token
    func getStripeToken(from cardTextField: StripeRequest) async throws -> StripeTokenResult {
        // Validate card details
        try validateCardDetails(cardTextField)
        
        setLoading(true)
        defer { setLoading(false) }
        
        let cardParams = createCardParams(from: cardTextField)
        
        return try await withCheckedThrowingContinuation { continuation in
            apiClient.createToken(withCard: cardParams) { [weak self] token, error in
                Task { @MainActor in
                    if let error = error {
                        let stripeError = StripeError.tokenCreationFailed(error.localizedDescription)
                        self?.handleError(stripeError)
                        continuation.resume(throwing: stripeError)
                    } else if let token = token {
                        let result = StripeTokenResult(
                            tokenId: token.tokenId,
                            cardBrand: token.card?.brand.description ?? "Unknown",
                            last4: token.card?.last4 ?? "",
                            expirationMonth: UInt(token.card?.expMonth ?? 0),
                            expirationYear: UInt(token.card?.expYear ?? 0)
                        )
                        self?.handleSuccess("Token created successfully")
                        continuation.resume(returning: result)
                    } else {
                        let stripeError = StripeError.unknownError
                        self?.handleError(stripeError)
                        continuation.resume(throwing: stripeError)
                    }
                }
            }
        }
    }
    
    // MARK: - Add Card
    func addCard(request: AddCardRequest) async throws {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            if let response: ResponseModel<[String?]> = try await APIManager.shared.request(
                type: APIEndPoint.addCard(param: request),
                header: true) {
                self.addedCardDict = response
                handleSuccess("Card added successfully")
            }
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Get Cards
    func getCards() async throws {
        setLoading(true)
        defer { setLoading(false) }

        do {
            if let response: ResponseModelPaginate<[CardDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getCard,
                header: true) {
                self.cards = response
                handleSuccess("Cards loaded successfully")
            }
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Update Card
    func updateCard(request: UpdateCardRequest) async throws {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            if let response: ResponseModel<UpdatedDataModel> = try await APIManager.shared.request(
                type: APIEndPoint.updateCard(param: request),
                header: true) {
                updatedCardDict = response
            }
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Delete Card
    func deleteCard(request: DeleteCardRequest) async throws {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            if let response: ResponseModel<Int> = try await APIManager.shared.request(
                type: APIEndPoint.deleteCard(param: request),
                header: true) {
                deletedCardDict = response
            }
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
     //MARK: - Set Default Card
    func setDefaultCard(request: DeleteCardRequest) async throws {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            if let response: ResponseModel<[Int?]> = try await APIManager.shared.request(
                type: APIEndPoint.setDefaultCard(param: request),
                header: true) {
                setDefaultCardDict = response
            }
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Refresh Cards
    func refreshCards() async {
        do {
            _ = try await getCards()
        } catch {
            handleError(error as? StripeError ?? .unknownError)
        }
    }
    
    // MARK: - Select Card
    func selectCard(_ card: CardDataModel) {
        selectedCard = card
    }
    
    // MARK: - Clear Selection
    func clearSelection() {
        selectedCard = nil
    }
    
    // MARK: - Validate Card Details
    private func validateCardDetails(_ cardTextField: StripeRequest) throws {
        if cardTextField.cardNumber.isEmpty {
            throw StripeError.missingCardNumber
        }
        
        if cardTextField.cvc.isEmpty {
            throw StripeError.missingCVC
        }
        
        guard cardTextField.expirationMonth > 0, cardTextField.expirationYear > 0 else {
            throw StripeError.missingExpiration
        }
    }
    
    // MARK: - Create Card Parameters
    private func createCardParams(from cardTextField: StripeRequest) -> STPCardParams {
        let cardParams = STPCardParams()
        cardParams.number = cardTextField.cardNumber
        cardParams.expMonth = UInt(cardTextField.expirationMonth)
        cardParams.expYear = UInt(cardTextField.expirationYear)
        cardParams.cvc = cardTextField.cvc
        return cardParams
    }
    
    // MARK: - State Management
    private func setLoading(_ loading: Bool) {
        isLoading = loading
        viewState = loading ? .loading : .idle
    }
    
    private func handleError(_ error: StripeError) {
        errorMessage = error.localizedDescription
        viewState = .error(error.localizedDescription ?? "Unknown error")
        
        alertTitle = "Error"
        alertMessage = error.localizedDescription ?? "Unknown error"
        showAlert = true
    }
    
    private func handleSuccess(_ message: String) {
        successMessage = message
        viewState = .success
    }
    
    // MARK: - Clear Messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    // MARK: - Reset State
    func resetState() {
        isLoading = false
        errorMessage = nil
        successMessage = nil
        viewState = .idle
    }
}

// MARK: - Add Card View
//struct AddCardView: View {
//    @StateObject private var viewModel = StripeCardViewModel()
//    @Environment(\.dismiss) var dismiss
//    
//    @State private var cardNumber = ""
//    @State private var expirationMonth = ""
//    @State private var expirationYear = ""
//    @State private var cvc = ""
//    
//    var onCardAdded: ((CardDataModel) -> Void)?
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Card Preview
//                    CardPreviewView(
//                        cardNumber: cardNumber,
//                        expirationMonth: expirationMonth,
//                        expirationYear: expirationYear
//                    )
//                    .padding(.top, 20)
//                    
//                    // Card Input Fields
//                    VStack(spacing: 16) {
//                        CustomTextField(
//                            title: "Card Number",
//                            placeholder: "1234 5678 9012 3456",
//                            text: $cardNumber,
//                            keyboardType: .numberPad
//                        )
//                        
//                        HStack(spacing: 16) {
//                            CustomTextField(
//                                title: "MM",
//                                placeholder: "12",
//                                text: $expirationMonth,
//                                keyboardType: .numberPad
//                            )
//                            
//                            CustomTextField(
//                                title: "YY",
//                                placeholder: "25",
//                                text: $expirationYear,
//                                keyboardType: .numberPad
//                            )
//                            
//                            CustomTextField(
//                                title: "CVC",
//                                placeholder: "123",
//                                text: $cvc,
//                                keyboardType: .numberPad
//                            )
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    
//                    // Messages
//                    if let error = viewModel.errorMessage {
//                        MessageBanner(message: error, type: .error)
//                    }
//                    
//                    if let success = viewModel.successMessage {
//                        MessageBanner(message: success, type: .success)
//                    }
//                    
//                    // Add Button
//                    Button(action: addCard) {
//                        HStack {
//                            if viewModel.isLoading {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            } else {
//                                Text("Add Card")
//                                    .font(.custom(poppinsSemiBold, size: 16))
//                            }
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                        .background(Color.blue)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//                    .disabled(viewModel.isLoading || !isFormValid)
//                    .padding(.horizontal, 20)
//                }
//                .padding(.bottom, 40)
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationTitle("Add Card")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//    
//    private var isFormValid: Bool {
//        !cardNumber.isEmpty &&
//        !expirationMonth.isEmpty &&
//        !expirationYear.isEmpty &&
//        !cvc.isEmpty
//    }
//    
//    private func addCard() {
//        Task {
//            do {
//                // Create mock card text field
//                let cardTextField = STPPaymentCardTextField()
//                cardTextField.cardNumber = cardNumber
//                cardTextField.expirationMonth = UInt(expirationMonth) ?? 0
//                cardTextField.expirationYear = UInt("20\(expirationYear)") ?? 0
//                cardTextField.cvc = cvc
//                
//                // Get token
//                let token = try await viewModel.getStripeToken(from: cardTextField)
//                
//                // Add card
//                let card = try await viewModel.addCard(token: token.tokenId)
//                
//                // Callback
//                onCardAdded?(card)
//                
//                // Dismiss
//                dismiss()
//            } catch {
//                print("Error: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//// MARK: - Card List View
//struct CardListView: View {
//    @StateObject private var viewModel = StripeCardViewModel()
//    @State private var showAddCard = false
//    @State private var cardToDelete: CardDataModel?
//    @State private var showDeleteAlert = false
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if viewModel.isLoading && viewModel.cards.isEmpty {
//                    // Loading state
//                    ProgressView()
//                } else if viewModel.cards.isEmpty {
//                    // Empty state
//                    EmptyStateView(
//                        icon: "creditcard",
//                        title: "No Cards",
//                        message: "Add a payment method to get started"
//                    )
//                } else {
//                    // Cards list
//                    ScrollView {
//                        VStack(spacing: 16) {
//                            ForEach(viewModel.cards) { card in
//                                CardRow(
//                                    card: card,
//                                    onTap: {
//                                        viewModel.selectCard(card)
//                                    },
//                                    onSetDefault: {
//                                        setDefault(card: card)
//                                    },
//                                    onDelete: {
//                                        cardToDelete = card
//                                        showDeleteAlert = true
//                                    }
//                                )
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 20)
//                    }
//                }
//                
//                // Messages overlay
//                VStack {
//                    if let error = viewModel.errorMessage {
//                        MessageBanner(message: error, type: .error)
//                            .padding()
//                    }
//                    
//                    if let success = viewModel.successMessage {
//                        MessageBanner(message: success, type: .success)
//                            .padding()
//                    }
//                    
//                    Spacer()
//                }
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationTitle("Payment Methods")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showAddCard = true }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddCard) {
//                AddCardView { card in
//                    Task {
//                        await viewModel.refreshCards()
//                    }
//                }
//            }
//            .alert("Delete Card", isPresented: $showDeleteAlert) {
//                Button("Cancel", role: .cancel) { }
//                Button("Delete", role: .destructive) {
//                    if let card = cardToDelete {
//                        deleteCard(card)
//                    }
//                }
//            } message: {
//                if let card = cardToDelete {
//                    Text("Are you sure you want to delete \(card.displayName)?")
//                }
//            }
//            .task {
//                await viewModel.refreshCards()
//            }
//        }
//    }
//    
//    private func setDefault(card: CardDataModel) {
//        Task {
//            do {
//                _ = try await viewModel.setDefaultCard(cardId: card.id)
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
//    
//    private func deleteCard(_ card: CardDataModel) {
//        Task {
//            do {
//                _ = try await viewModel.deleteCard(cardId: card.id)
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - Card Row Component
//struct CardRow: View {
//    let card: CardDataModel
//    let onTap: () -> Void
//    let onSetDefault: () -> Void
//    let onDelete: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 16) {
//                // Card Icon
//                ZStack {
//                    Circle()
//                        .fill(Color.blue.opacity(0.1))
//                        .frame(width: 48, height: 48)
//                    
//                    Image(systemName: card.brandIcon)
//                        .font(.system(size: 20))
//                        .foregroundColor(.blue)
//                }
//                
//                // Card Info
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(card.displayName)
//                        .font(.custom(poppinsSemiBold, size: 16))
//                        .foregroundColor(.primary)
//                    
//                    Text("Expires \(card.expirationDisplay)")
//                        .font(.custom(poppinsRegular, size: 13))
//                        .foregroundColor(.secondary)
//                    
//                    if card.isDefault {
//                        Text("Default")
//                            .font(.custom(poppinsSemiBold, size: 11))
//                            .foregroundColor(.green)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(
//                                Capsule()
//                                    .fill(Color.green.opacity(0.1))
//                            )
//                    }
//                }
//                
//                Spacer()
//                
//                // Actions Menu
//                Menu {
//                    if !card.isDefault {
//                        Button(action: onSetDefault) {
//                            Label("Set as Default", systemImage: "checkmark.circle")
//                        }
//                    }
//                    
//                    Button(role: .destructive, action: onDelete) {
//                        Label("Delete", systemImage: "trash")
//                    }
//                } label: {
//                    Image(systemName: "ellipsis")
//                        .font(.system(size: 18))
//                        .foregroundColor(.secondary)
//                        .frame(width: 32, height: 32)
//                }
//            }
//            .padding(16)
//        }
//        .background(Color(.systemBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//    }
//}
//
//// MARK: - Card Preview Component
//struct CardPreviewView: View {
//    let cardNumber: String
//    let expirationMonth: String
//    let expirationYear: String
//    
//    var body: some View {
//        ZStack {
//            // Card background
//            RoundedRectangle(cornerRadius: 16)
//                .fill(
//                    LinearGradient(
//                        colors: [Color.blue, Color.purple],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .frame(height: 200)
//            
//            VStack(alignment: .leading, spacing: 20) {
//                // Card chip
//                Image(systemName: "checkmark.shield.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.white.opacity(0.8))
//                
//                Spacer()
//                
//                // Card number
//                Text(formatCardNumber(cardNumber))
//                    .font(.custom(poppinsSemiBold, size: 20))
//                    .foregroundColor(.white)
//                    .tracking(2)
//                
//                // Expiration
//                HStack {
//                    Text("VALID THRU")
//                        .font(.custom(poppinsRegular, size: 10))
//                        .foregroundColor(.white.opacity(0.7))
//                    
//                    Text("\(expirationMonth)/\(expirationYear)")
//                        .font(.custom(poppinsSemiBold, size: 14))
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(24)
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .frame(height: 200)
//        .padding(.horizontal, 20)
//    }
//    
//    private func formatCardNumber(_ number: String) -> String {
//        if number.isEmpty {
//            return "•••• •••• •••• ••••"
//        }
//        
//        let cleaned = number.replacingOccurrences(of: " ", with: "")
//        var formatted = ""
//        
//        for (index, char) in cleaned.enumerated() {
//            if index > 0 && index % 4 == 0 {
//                formatted += " "
//            }
//            formatted += String(char)
//        }
//        
//        // Fill remaining with bullets
//        let remaining = 16 - cleaned.count
//        if remaining > 0 {
//            formatted += String(repeating: "•", count: remaining)
//        }
//        
//        return formatted
//    }
//}
//
//// MARK: - Custom Text Field
//struct CustomTextField: View {
//    let title: String
//    let placeholder: String
//    @Binding var text: String
//    var keyboardType: UIKeyboardType = .default
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.custom(poppinsSemiBold, size: 13))
//                .foregroundColor(.secondary)
//            
//            TextField(placeholder, text: $text)
//                .font(.custom(poppinsRegular, size: 16))
//                .keyboardType(keyboardType)
//                .padding()
//                .background(Color(.systemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                )
//        }
//    }
//}
//
//// MARK: - Message Banner
//struct MessageBanner: View {
//    let message: String
//    let type: MessageType
//    
//    enum MessageType {
//        case success
//        case error
//        
//        var color: Color {
//            switch self {
//            case .success: return .green
//            case .error: return .red
//            }
//        }
//        
//        var icon: String {
//            switch self {
//            case .success: return "checkmark.circle.fill"
//            case .error: return "exclamationmark.triangle.fill"
//            }
//        }
//    }
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Image(systemName: type.icon)
//                .foregroundColor(type.color)
//            
//            Text(message)
//                .font(.custom(poppinsRegular, size: 14))
//                .foregroundColor(.primary)
//            
//            Spacer()
//        }
//        .padding()
//        .background(type.color.opacity(0.1))
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(type.color.opacity(0.3), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Empty State View
//struct EmptyStateView: View {
//    let icon: String
//    let title: String
//    let message: String
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Image(systemName: icon)
//                .font(.system(size: 60))
//                .foregroundColor(.gray.opacity(0.5))
//            
//            Text(title)
//                .font(.custom(poppinsBold, size: 20))
//                .foregroundColor(.primary)
//            
//            Text(message)
//                .font(.custom(poppinsRegular, size: 14))
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .padding(40)
//    }
//}
//
//// MARK: - Preview
//struct CardListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardListView()
//    }
//}
//
//struct AddCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddCardView()
//    }
//}
