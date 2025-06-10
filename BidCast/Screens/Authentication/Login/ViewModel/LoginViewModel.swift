//
//  LoginViewModel.swift
//  BidSwipe
//
//  Created by Abdul-JAM-E-157 on 18/01/24.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var loginResponse = ResponseModel<LoginModel>()
   
    @Published var errorMessage: String? = nil
    @Published var requestType: String = ""
    
    var employerId: String?

    // MARK: - Login
    func logIn(parameters: SignInRequest) async {
        do {
            self.requestType = "Login"
            if let response: ResponseModel<LoginModel> = try await APIManager.shared.request(
                type: APIEndPoint.login(param: parameters),
                header: false
            ) {
                self.loginResponse = response
                
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
