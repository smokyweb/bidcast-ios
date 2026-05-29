//
//  View+Extension.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 06/11/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

final class APIContext<T> {
    var data: T?

    init(initialData: T) {
        self.data = initialData
    }
}

enum CustomError: Error {
    case internetError(message: String)
    case otherError(message: String)
}


extension View {
    /// Unified API handler for serial or concurrent API calls
    func performAPICalls(
        isConcurrent: Bool = false,
        showLoader: Bool = true,
        onError: @escaping (Error) -> Void = { _ in },
        onSuccess: @escaping () -> Void = { },
        tasks: @escaping () async throws -> Void
    ) async {
        
        guard Reachability.isConnectedToNetwork() else {
            onError(URLError(.notConnectedToInternet))
            return
        }

        if showLoader {
            SVProgressHUD.show()
        }

        do {
            try await tasks()   // executes sequentially or concurrently as per your logic

            if showLoader {
                await SVProgressHUD.dismiss()
            }

            onSuccess()   // 🔥 success callback (only if tasks didn't throw)

        } catch {
            if showLoader { await SVProgressHUD.dismiss() }
            onError(error)      // 🔥 error callback
        }
    }
    
    func performInterDependentSequentialAPICalls<T>(
        showLoader: Bool = true,
        initialData: T,
        calls: [(APIContext<T>) async -> Void],
        completion: ((APIContext<T>) -> Void)? = nil
    ) async {

        let context = APIContext(initialData: initialData)

        if showLoader { SVProgressHUD.show() }

        for call in calls {
            await call(context)   // each API receives the same context
        }

        if showLoader { await SVProgressHUD.dismiss() }
        completion?(context)
    }

    func errorDesc(error: Error?, message: String?) -> String {
        // MC (2026-05-28): Blank Seller Hub popup fix. Treat an empty or
        // whitespace-only message the same as nil so we never render a sheet
        // with no text. Backend occasionally returns "" on benign states.
        if let msg = message,
           !msg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return msg
        }
        return error?.localizedDescription ?? "Something went wrong"
    }
}

// MARK: - Blank-message guard (MC 2026-05-28)
// Centralized helper so Seller Hub screens can decide whether an error/info
// message is worth surfacing. A nil, empty, or whitespace-only message means
// "nothing to show" — callers must NOT set showError = true in that case.
extension Optional where Wrapped == String {
    /// True when the wrapped string is nil, empty, or whitespace-only.
    var isBlankMessage: Bool {
        guard let s = self else { return true }
        return s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension String {
    /// True when the string is empty or whitespace-only.
    var isBlankMessage: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


extension View {
    func hideKeyboardPopup() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}


