//
//  MenuOptionsViewModel.swift
//  BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 07/02/24.
//

import Foundation

@MainActor
final class MenuOptionsViewModel: ObservableObject {
    
    // MARK: - Published Response Variables
    @Published var logOutResponse = ResponseModel<MenuOptionsModal>()
    @Published var privacyResponse = ResponseModel<MenuOptionsModal>()
    @Published var termsResponse = ResponseModel<MenuOptionsModal>()
    @Published var aboutUsResponse = ResponseModel<MenuOptionsModal>()
    
    @Published var errorMessage: String? = nil
    
    // MARK: - Logout
    func logOut() async {
        do {
            if let response: ResponseModel<MenuOptionsModal> = try await APIManager.shared.request(
                type: APIEndPoint.logout,
                header: true
            ) {
                self.logOutResponse = response
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Privacy Policy
    func getPrivacyDetails() async {
        do {
            if let response: ResponseModel<MenuOptionsModal> = try await APIManager.shared.request(
                type: APIEndPoint.privacyPolicy,
                header: true
            ) {
                self.privacyResponse = response
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Terms of Service
    func getTermsOfService() async {
        do {
            if let response: ResponseModel<MenuOptionsModal> = try await APIManager.shared.request(
                type: APIEndPoint.termsCondition,
                header: true
            ) {
                self.termsResponse = response
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - About Us
    func getAboutUs() async {
        do {
            if let response: ResponseModel<MenuOptionsModal> = try await APIManager.shared.request(
                type: APIEndPoint.termsOfService, // Verify if this endpoint is correct for About Us
                header: true
            ) {
                self.aboutUsResponse = response
            }
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        if let dataError = error as? DataError {
            switch dataError {
            case .invalidCode(let message):
                self.errorMessage = message ?? "Invalid code error"
            case .invalidResponse(let data):
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    self.errorMessage = "Invalid response: \(json)"
                } else {
                    self.errorMessage = "Invalid response with no data"
                }
            default:
                self.errorMessage = error.localizedDescription
            }
        } else {
            self.errorMessage = error.localizedDescription
        }
    }
}
