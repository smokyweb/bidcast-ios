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
