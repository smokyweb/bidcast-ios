//
//  SignupViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//

import Foundation

@MainActor
final class SignupViewModel: ObservableObject {
    
    @Published var signUpResponse = ResponseModel<SignUpModel>()
    @Published var errorMessage: String? = nil
    @Published var requestType: String = ""
    
    // MARK: - Register User
    func register(parameters: SignUpRequest) async {
        do {
            self.requestType = "RegisterUser"
            if let response: ResponseModel<SignUpModel> = try await APIManager.shared.request(
                type: APIEndPoint.singUp(param: parameters),
                header: false
            ){
                self.signUpResponse = response
            }
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Register UserName
    func registerUser(parameters: SignUpRequest) async {
        do {
            self.requestType = "RegisterUserName"
            if let response: ResponseModel<SignUpModel> = try await APIManager.shared.request(
                type: APIEndPoint.singUp(param: parameters),
                header: false
            ){
                self.signUpResponse = response
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
