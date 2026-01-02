//
//  SellerVerificationViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

import Combine

@MainActor
final class SellerVerificationViewModel: ObservableObject {
    
    @Published var storeIDCardDict: ResponseModel<StoreIDCardModel>?
    @Published var storePhoneNumberDict = ResponseModel<SellerPhoneNumberModel>()
    @Published var otpVerifyDict = ResponseModel<SellerOtpVerifyModel>()
    @Published var paymentDetailDict = ResponseModel<SellerIdentityFetch>()
    @Published var sellerVerificationDict: ResponseModel<SellerVerificationModel>?
    @Published var errorMessage: String?
    @Published var requestType: String = ""
    @Published var cardDict = ResponseModel<[CardModel]>()
//MARK: storeIDCard.
    func storeIDCard(
        parameters: [String: Any],
        images: [[String]]? = nil,
        mimeType: [String],
        keysValue: [String],
        uploadImages: [String]? = nil
    ) async {
        requestType = "storeIDCard"
        do {
            let response: ResponseModel<StoreIDCardModel>? = try await APIManager.shared.uploadImageWithMultipleKeys(
                type: APIEndPoint.buyerIdentityStore,
                urlArray: images,
                mimeType: mimeType,
                keyName: keysValue,
                parameters: parameters,
                modelType: ResponseModel<StoreIDCardModel>?.self,
                header: true
            )
            self.storeIDCardDict = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    // MARK: - Get Cards
    func getCard() async {
        do {
        let response: ResponseModel<[CardModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getCard,
                header: true
            )
                self.cardDict = response
            
        } catch {
            handle(error: error)
        }
    }
        
    // MARK: - storePhoneNumber
    func storePhoneNumber(parameters: StorePhoneNumberRequest) async {
        
        do {
            requestType = "storePhoneNumber"
            let response: ResponseModel<SellerPhoneNumberModel> = try await APIManager.shared.request(
                type: APIEndPoint.storePhoneNumber(param: parameters),
                header: true
            )
            self.storePhoneNumberDict = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - otpVerify
    func otpVerify(parameters: OtpVerifyRequest) async {
        requestType = "otpVerify"
        do {
            let response: ResponseModel<SellerOtpVerifyModel> = try await APIManager.shared.request(
                type: APIEndPoint.otpVerify(param: parameters),
                header: true
            )
            self.otpVerifyDict = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - fetchSellerDetail
    func fetchSellerPaymentDetail() async {
        requestType = "sellerPayment"
        do {
            let response: ResponseModel<SellerIdentityFetch> = try await APIManager.shared.request(
                type: APIEndPoint.sellerIdentityFetch,
                header: true
            )
            self.paymentDetailDict = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - SellerVerification
    func SellerVerification(
        parameters: [String: Any],
        images: [[String]]? = nil,
        mimeType: [String],
        keysValue: [String],
        uploadImages: [String]? = nil
    ) async {
        requestType = "SellerVerification"
        do {
            let response: ResponseModel<SellerVerificationModel>? = try await APIManager.shared.uploadImageWithMultipleKeys(
                type: APIEndPoint.sellerVerification,
                urlArray: images,
                mimeType: mimeType,
                keyName: keysValue,
                parameters: parameters,
                modelType: ResponseModel<SellerVerificationModel>?.self,
                header: true
            )
            self.sellerVerificationDict = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}




