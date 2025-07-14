//
//  WalletViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//


import Foundation

@MainActor
final class WalletViewModel: ObservableObject {
    
    @Published var transactionDict = ResponseModelPaginate<[TransactionModel]>()
    @Published var walletInfoDict = ResponseModel<WalletInfoModel>()
    @Published var payOutHistoryDict = ResponseModel<PayOutHistoryModel>()
    @Published var errorMessage: String? = nil

    

    // MARK: - Get Cards
    func getTransaction(param:TransactionRequest) async {
        do {
            if let response: ResponseModelPaginate<[TransactionModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getTransactionList(param: param),
                header: true
            ){
                self.transactionDict = response
            }
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Get WalletInfo
    func getWalletInfo() async {
        do {
            if let response: ResponseModel<WalletInfoModel> = try await APIManager.shared.request(
                type: APIEndPoint.getWalletInfo,
                header: true
            ) {
                self.walletInfoDict = response
            }
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Get PayOutHistory
    func getPayOutHistory() async {
        do {
            if let response: ResponseModel<PayOutHistoryModel> = try await APIManager.shared.request(
                type: APIEndPoint.getPayOutHistory,
                header: true
            ) {
                self.payOutHistoryDict = response
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
