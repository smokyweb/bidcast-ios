//
//  KycViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//


import Foundation

@MainActor
final class KycViewModel: ObservableObject {
    
    @Published var kycDetailsDict = ResponseModel<KycDetailsModel>()
    @Published var checkKycDict = ResponseModel<CheckKycModel>()
    @Published var fundTransferDict: ResponseModel<FundTransferModel>?
    @Published var errorMessage: String? = nil
    
    // MARK: - Get checkKycDetail.
    func getKycDetail() async throws {
        errorMessage?.removeAll()
        do {
            if let response: ResponseModel<KycDetailsModel> = try await APIManager.shared.request(
                type: APIEndPoint.getKycDetails,
                header: true
            ) {
                self.kycDetailsDict = response
            }
        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Get checkKycDetail.
    func checkKycDetail() async throws {
        errorMessage?.removeAll()
        do {
            if let response: ResponseModel<CheckKycModel> = try await APIManager.shared.request(
                type: APIEndPoint.checkKYC,
                header: true
            ) {
                self.checkKycDict = response
            }
        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - fundTransfer.
    func fundTransfer(param : FundTransferRequest) async{
        errorMessage?.removeAll()
        do {
            if let response: ResponseModel<FundTransferModel>? = try await APIManager.shared.request(
                type: APIEndPoint.fundTransfer(param: param),
                header: true
            ) {
                self.fundTransferDict = response
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
