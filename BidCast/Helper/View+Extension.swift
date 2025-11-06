//
//  View+Extension.swift
//  BidCast
//
//  Created by JamTech on 06/11/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

extension View {
    /// Unified API handler for serial or concurrent API calls
    func performAPICalls(
        isConcurrent: Bool = false,
        showLoader: Bool = true,
        onError: @escaping (Error) -> Void = { _ in },
        tasks: @escaping () async throws -> Void
    ) async {
        guard Reachability.isConnectedToNetwork() else {
            onError(URLError(.notConnectedToInternet))
            return
        }

        if showLoader { SVProgressHUD.show() }

        do {
            if isConcurrent {
                // Run concurrent tasks
                try await tasks()
            } else {
                // Run serially (sequentially)
                try await tasks()
            }
            if showLoader { await SVProgressHUD.dismiss() }
        } catch {
            if showLoader { await SVProgressHUD.dismiss() }
            onError(error) // Let the caller handle the error
        }
    }
}


//extension View {
//    /// Shows a standard alert sheet with icon, title, and message
//    func showAlertSheet(
//        icon: ImageResource,
//        title: String,
//        message: String,
//        primaryBtnText: String = AppString.ok.localized,
//        secondaryBtnText: String = "",
//        alertType: BottomSheetType,
//        showError: Binding<Bool>
//    ) {
//        alertType = .sheetType(
//            icon: icon,
//            title: title,
//            message: message,
//            primaryBtnText: primaryBtnText,
//            secondaryBtnText: secondaryBtnText
//        )
//        showError.wrappedValue = true
//    }
//}
//
