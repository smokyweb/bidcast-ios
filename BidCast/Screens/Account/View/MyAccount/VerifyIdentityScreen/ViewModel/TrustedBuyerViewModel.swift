//
//  TrustedBuyerViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 10/06/25.
//

import Foundation
import Combine

final class TrustedBuyerViewModel: ObservableObject {
    
    @Published var addTrustedBuyerDict: ResponseModal<TrustedBuyerModel>?
    @Published var getBuyerVerificationStatusDict = ResponseModel<TrustedBuyerModel>()

    @Published var errorMessage: String?
    
    func addTrustedBuyer(images: [String], key: String) async { 
        do {
            let result: ResponseModal<TrustedBuyerModel> = try await APIManager.shared.uploadImage1(
                type: APIEndPoint.buyerIdentityStore,
                urlArray: images,
                mimeType: "image",
                keyName: key,
                parameters: [:],
                modalType: ResponseModal<TrustedBuyerModel>.self,
                header: true
            )
            self.addTrustedBuyerDict = result
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func getBuyerVerificationStatus() async {
        do {
            let response: ResponseModel<TrustedBuyerModel> = try await APIManager.shared.request(
                type: APIEndPoint.buyerIdentityList,
                header: true
            )
            self.getBuyerVerificationStatusDict = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

}
