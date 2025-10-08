//
//  TipsViewModel.swift
//  BidCast
//
//  Created by Vivek_JAM_E_328 on 19/05/25.
//

import Foundation

@MainActor
final class TipsViewModel: ObservableObject {

    @Published var getTipsResponse: ResponseModel<TipsModel>?
    @Published var sendTipAmountResponse: ResponseModel<SendTipAmountModel>?
    @Published var errorMessage: String? = nil

    func getTipsData() async {
        do {
            let response: ResponseModel<TipsModel> = try await APIManager.shared.request(
                type: APIEndPoint.getTipsData,
                header: true
            )
            self.getTipsResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    func sendTipsAmountData(request: TipAmountRequest) async {
        do {
            let response: ResponseModel<SendTipAmountModel> = try await APIManager.shared.request(
                type: APIEndPoint.sendTipAmount(param: request),
                header: true
            )
            self.sendTipAmountResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
