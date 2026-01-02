//
//  BottomSheetHelper.swift
//  BidCast
//
//  Created by JamTech on 02/01/26.

import SwiftUI

// MARK: - Bottom Sheet Configuration
struct BottomSheetConfigModel {
    var height: CGFloat?
    var cornerRadius: CGFloat
    var showTopIndicator: Bool
    var backgroundColor: Color
    var dragToDismiss: Bool
    var tapOutsideToDismiss: Bool
    
    static let `default` = BottomSheetConfigModel(
        height: nil,
        cornerRadius: 32,
        showTopIndicator: true,
        backgroundColor: Color(.systemBackground),
        dragToDismiss: true,
        tapOutsideToDismiss: true
    )
}

// MARK: - Bottom Sheet Modifier
struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let height: CGFloat?
    let cornerRadius: CGFloat
    let showTopIndicator: Bool
    let backgroundColor: Color
    let onDismiss: (() -> Void)?
    let content: () -> SheetContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                BottomSheetContainer(
                    height: height,
                    cornerRadius: cornerRadius,
                    showTopIndicator: showTopIndicator,
                    backgroundColor: backgroundColor,
                    onDismiss: {
                        isPresented = false
                        onDismiss?()
                    },
                    content: self.content
                )
            }
    }
}

// MARK: - Bottom Sheet Container
struct BottomSheetContainer<Content: View>: View {
    let height: CGFloat?
    let cornerRadius: CGFloat
    let showTopIndicator: Bool
    let backgroundColor: Color
    let onDismiss: () -> Void
    let content: () -> Content
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Indicator
            if showTopIndicator {
                topIndicator
            }
            
            // Content
            if let height = height {
                content()
                    .frame(height: height)
            } else {
                content()
            }
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .presentationDetents(height != nil ? [.height(height! + 40)] : [.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(cornerRadius)
        .presentationBackground(backgroundColor)
    }
    
    private var topIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }
}

// MARK: - View Extension
extension View {
    /// Presents a customizable bottom sheet
    /// - Parameters:
    ///   - isPresented: Binding to control presentation
    ///   - height: Optional fixed height (nil for auto-sizing)
    ///   - cornerRadius: Corner radius of the sheet (default: 32)
    ///   - showTopIndicator: Show drag indicator (default: true)
    ///   - backgroundColor: Background color (default: systemBackground)
    ///   - onDismiss: Callback when sheet is dismissed
    ///   - content: Sheet content builder
    func bottomSheetView<Content: View>(
        isPresented: Binding<Bool>,
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 32,
        showTopIndicator: Bool = true,
        backgroundColor: Color = Color(.systemBackground),
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            BottomSheetModifier(
                isPresented: isPresented,
                height: height,
                cornerRadius: cornerRadius,
                showTopIndicator: showTopIndicator,
                backgroundColor: backgroundColor,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}

// MARK: - Common Bottom Sheet Types
enum BottomSheetTypeEnum {
    case alert(icon: String, title: String, message: String, primaryButton: String, secondaryButton: String?)
    case confirmation(title: String, message: String, confirmText: String, cancelText: String)
    case success(title: String, message: String)
    case error(title: String, message: String)
    case loading(message: String)
    case custom
}

// MARK: - Common Bottom Sheet View
struct CommonBottomSheetView: View {
    let type: BottomSheetTypeEnum
    let onPrimaryClick: () -> Void
    let onSecondaryClick: (() -> Void)?
    
    init(
        type: BottomSheetTypeEnum,
        onPrimaryClick: @escaping () -> Void,
        onSecondaryClick: (() -> Void)? = nil
    ) {
        self.type = type
        self.onPrimaryClick = onPrimaryClick
        self.onSecondaryClick = onSecondaryClick
    }
    
    var body: some View {
        VStack(spacing: 20) {
            switch type {
            case .alert(let icon, let title, let message, let primaryButton, let secondaryButton):
                alertContent(
                    icon: icon,
                    title: title,
                    message: message,
                    primaryButton: primaryButton,
                    secondaryButton: secondaryButton
                )
                
            case .confirmation(let title, let message, let confirmText, let cancelText):
                confirmationContent(
                    title: title,
                    message: message,
                    confirmText: confirmText,
                    cancelText: cancelText
                )
                
            case .success(let title, let message):
                successContent(title: title, message: message)
                
            case .error(let title, let message):
                errorContent(title: title, message: message)
                
            case .loading(let message):
                loadingContent(message: message)
                
            case .custom:
                EmptyView()
            }
        }
        .padding(24)
    }
    
    // MARK: - Alert Content
    private func alertContent(
        icon: String,
        title: String,
        message: String,
        primaryButton: String,
        secondaryButton: String?
    ) -> some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            // Title
            Text(title)
                .font(.custom(poppinsBold, size: 20))
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: onPrimaryClick) {
                    Text(primaryButton)
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if let secondaryButton = secondaryButton {
                    Button(action: { onSecondaryClick?() }) {
                        Text(secondaryButton)
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    // MARK: - Confirmation Content
    private func confirmationContent(
        title: String,
        message: String,
        confirmText: String,
        cancelText: String
    ) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.custom(poppinsBold, size: 20))
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button(action: { onSecondaryClick?() }) {
                    Text(cancelText)
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: onPrimaryClick) {
                    Text(confirmText)
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Success Content
    private func successContent(title: String, message: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            
            Text(title)
                .font(.custom(poppinsBold, size: 20))
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onPrimaryClick) {
                Text("OK")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Error Content
    private func errorContent(title: String, message: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
            }
            
            Text(title)
                .font(.custom(poppinsBold, size: 20))
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onPrimaryClick) {
                Text("OK")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Loading Content
    private func loadingContent(message: String) -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding(.bottom, 10)
            
            Text(message)
                .font(.custom(poppinsRegular, size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}
//
//// MARK: - Usage Examples
//
//// Example 1: Basic Usage
//struct BasicBottomSheetExample: View {
//    @State private var showSheet = false
//    
//    var body: some View {
//        Button("Show Sheet") {
//            showSheet = true
//        }
//        .bottomSheetView(isPresented: $showSheet) {
//            VStack(spacing: 20) {
//                Text("Hello!")
//                    .font(.title)
//                
//                Text("This is a bottom sheet")
//                
//                Button("Close") {
//                    showSheet = false
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//// Example 2: Custom Height
//struct CustomHeightExample: View {
//    @State private var showSheet = false
//    
//    var body: some View {
//        Button("Show Fixed Height Sheet") {
//            showSheet = true
//        }
//        .bottomSheetView(
//            isPresented: $showSheet,
//            height: 300,
//            cornerRadius: 32,
//            showTopIndicator: true
//        ) {
//            VStack {
//                Text("Fixed Height Sheet")
//                    .font(.headline)
//                Text("Height: 300")
//            }
//            .padding()
//        }
//    }
//}
//
//// Example 3: Alert Bottom Sheet
//struct AlertBottomSheetExample: View {
//    @State private var showAlert = false
//    
//    var body: some View {
//        Button("Show Alert") {
//            showAlert = true
//        }
//        .bottomSheetView(
//            isPresented: $showAlert,
//            height: UIScreen.main.bounds.height / 2.3,
//            cornerRadius: 25,
//            showTopIndicator: false,
//            onDismiss: {
//                print("Sheet dismissed")
//            }
//        ) {
//            CommonBottomSheetView(
//                type: .alert(
//                    icon: "exclamationmark.triangle.fill",
//                    title: "Alert",
//                    message: "This is an important message",
//                    primaryButton: "OK",
//                    secondaryButton: "Cancel"
//                ),
//                onPrimaryClick: {
//                    showAlert = false
//                },
//                onSecondaryClick: {
//                    showAlert = false
//                }
//            )
//        }
//    }
//}
//
//// Example 4: Success Sheet
//struct SuccessSheetExample: View {
//    @State private var showSuccess = false
//    
//    var body: some View {
//        Button("Show Success") {
//            showSuccess = true
//        }
//        .bottomSheetView(isPresented: $showSuccess) {
//            CommonBottomSheetView(
//                type: .success(
//                    title: "Success!",
//                    message: "Your action was completed successfully"
//                ),
//                onPrimaryClick: {
//                    showSuccess = false
//                }
//            )
//        }
//    }
//}
//
//// Example 5: Error Sheet
//struct ErrorSheetExample: View {
//    @State private var showError = false
//    
//    var body: some View {
//        Button("Show Error") {
//            showError = true
//        }
//        .bottomSheetView(
//            isPresented: $showError,
//            height: 350,
//            cornerRadius: 32
//        ) {
//            CommonBottomSheetView(
//                type: .error(
//                    title: "Error",
//                    message: "Something went wrong. Please try again."
//                ),
//                onPrimaryClick: {
//                    showError = false
//                }
//            )
//        }
//    }
//}
//
//// Example 6: Confirmation Sheet
//struct ConfirmationSheetExample: View {
//    @State private var showConfirmation = false
//    
//    var body: some View {
//        Button("Delete Item") {
//            showConfirmation = true
//        }
//        .bottomSheetView(isPresented: $showConfirmation) {
//            CommonBottomSheetView(
//                type: .confirmation(
//                    title: "Delete Item?",
//                    message: "Are you sure you want to delete this item? This action cannot be undone.",
//                    confirmText: "Delete",
//                    cancelText: "Cancel"
//                ),
//                onPrimaryClick: {
//                    // Delete action
//                    showConfirmation = false
//                },
//                onSecondaryClick: {
//                    showConfirmation = false
//                }
//            )
//        }
//    }
//}
//
//// Example 7: Loading Sheet
//struct LoadingSheetExample: View {
//    @State private var showLoading = false
//    
//    var body: some View {
//        Button("Show Loading") {
//            showLoading = true
//            
//            // Auto dismiss after 3 seconds
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                showLoading = false
//            }
//        }
//        .bottomSheetView(
//            isPresented: $showLoading,
//            showTopIndicator: false
//        ) {
//            CommonBottomSheetView(
//                type: .loading(message: "Processing..."),
//                onPrimaryClick: {}
//            )
//        }
//    }
//}
//
//// Example 8: Custom Content Sheet
//struct CustomContentSheetExample: View {
//    @State private var showCustom = false
//    @State private var selectedOption = ""
//    
//    let options = ["Option 1", "Option 2", "Option 3", "Option 4"]
//    
//    var body: some View {
//        Button("Show Options") {
//            showCustom = true
//        }
//        .bottomSheetView(
//            isPresented: $showCustom,
//            cornerRadius: 32,
//            showTopIndicator: true
//        ) {
//            VStack(spacing: 0) {
//                Text("Select an Option")
//                    .font(.custom(poppinsBold, size: 20))
//                    .padding(.top, 20)
//                    .padding(.bottom, 16)
//                
//                Divider()
//                
//                ScrollView {
//                    VStack(spacing: 0) {
//                        ForEach(options, id: \.self) { option in
//                            Button(action: {
//                                selectedOption = option
//                                showCustom = false
//                            }) {
//                                HStack {
//                                    Text(option)
//                                        .font(.custom(poppinsRegular, size: 16))
//                                        .foregroundColor(.primary)
//                                    
//                                    Spacer()
//                                    
//                                    if selectedOption == option {
//                                        Image(systemName: "checkmark")
//                                            .foregroundColor(.blue)
//                                    }
//                                }
//                                .padding(.horizontal, 20)
//                                .padding(.vertical, 16)
//                            }
//                            
//                            if option != options.last {
//                                Divider()
//                                    .padding(.leading, 20)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//// Example 9: Product Actions Sheet
//struct ProductActionsSheetExample: View {
//    @State private var showActions = false
//    let product: ProductDataModel1
//    
//    var body: some View {
//        Button("Show Actions") {
//            showActions = true
//        }
//        .bottomSheetView(
//            isPresented: $showActions,
//            height: 280,
//            cornerRadius: 32
//        ) {
//            VStack(spacing: 0) {
//                // Header
//                Text("Product Actions")
//                    .font(.custom(poppinsBold, size: 18))
//                    .padding(.top, 20)
//                    .padding(.bottom, 16)
//                
//                Divider()
//                
//                // Actions
//                VStack(spacing: 0) {
//                    actionButton(
//                        icon: "pencil",
//                        title: "Edit Product",
//                        color: .blue
//                    ) {
//                        showActions = false
//                        // Edit action
//                    }
//                    
//                    Divider().padding(.leading, 60)
//                    
//                    actionButton(
//                        icon: "eye",
//                        title: "View Details",
//                        color: .green
//                    ) {
//                        showActions = false
//                        // View action
//                    }
//                    
//                    Divider().padding(.leading, 60)
//                    
//                    actionButton(
//                        icon: "trash",
//                        title: "Delete Product",
//                        color: .red
//                    ) {
//                        showActions = false
//                        // Delete action
//                    }
//                }
//            }
//        }
//    }
//    
//    private func actionButton(
//        icon: String,
//        title: String,
//        color: Color,
//        action: @escaping () -> Void
//    ) -> some View {
//        Button(action: action) {
//            HStack(spacing: 16) {
//                Image(systemName: icon)
//                    .font(.system(size: 20))
//                    .foregroundColor(color)
//                    .frame(width: 32)
//                
//                Text(title)
//                    .font(.custom(poppinsRegular, size: 16))
//                    .foregroundColor(.primary)
//                
//                Spacer()
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//        }
//    }
//}
//
//// Example 10: Form Input Sheet
//struct FormInputSheetExample: View {
//    @State private var showForm = false
//    @State private var name = ""
//    @State private var email = ""
//    
//    var body: some View {
//        Button("Show Form") {
//            showForm = true
//        }
//        .bottomSheetView(
//            isPresented: $showForm,
//            height: 400,
//            cornerRadius: 32
//        ) {
//            VStack(spacing: 20) {
//                Text("Enter Details")
//                    .font(.custom(poppinsBold, size: 20))
//                
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Name")
//                        .font(.custom(poppinsSemiBold, size: 14))
//                    
//                    TextField("Enter name", text: $name)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//                
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Email")
//                        .font(.custom(poppinsSemiBold, size: 14))
//                    
//                    TextField("Enter email", text: $email)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .keyboardType(.emailAddress)
//                        .autocapitalization(.none)
//                }
//                
//                Button("Submit") {
//                    // Submit action
//                    showForm = false
//                }
//                .font(.custom(poppinsSemiBold, size: 16))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 16)
//                .background(Color.blue)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
//            .padding(20)
//        }
//    }
//}
//
//// MARK: - Preview
//struct BottomSheetExamples_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 20) {
//            BasicBottomSheetExample()
//            AlertBottomSheetExample()
//            SuccessSheetExample()
//            ErrorSheetExample()
//        }
//    }
//}
