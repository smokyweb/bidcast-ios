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

        if showLoader { SVProgressHUD.show() }

        do {
            try await tasks()   // executes sequentially or concurrently as per your logic

            if showLoader { await SVProgressHUD.dismiss() }

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


}


extension View {
    func hideKeyboardPopup() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}


