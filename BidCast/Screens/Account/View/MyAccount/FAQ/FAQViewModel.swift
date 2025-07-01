//
//  FAQViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//

import Foundation

@MainActor
final class FAQViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var faqModel = FAQModel()
    @Published var errorMessage: String?
    
    // MARK: - API Call
    func getFAQ() async {
        do {
            let response: FAQModel = try await APIManager.shared.request(
                type: APIEndPoint.faq,
                header: true
            )
            self.faqModel = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
