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
    @Published var checkKycDict = ResponseModel<CheckKycModel>()
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
        errorMessage?.removeAll()
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
        errorMessage?.removeAll()
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
        errorMessage?.removeAll()
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
    // MARK: - Get checkKycDetail.
    func checkKycDetail() async {
        errorMessage?.removeAll()
        do {
            if let response: ResponseModel<CheckKycModel> = try await APIManager.shared.request(
                type: APIEndPoint.checkKYC,
                header: true
            ) {
                self.checkKycDict = response
            }
        } catch(let error) {
            handle(error: error)
        }
    }
    
    // MARK: - otpVerify
    func otpVerify(parameters: OtpVerifyRequest) async {
        requestType = "otpVerify"
        errorMessage?.removeAll()
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
        errorMessage?.removeAll()
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
        errorMessage?.removeAll()
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
            handle(error: error)
        }
    }
    
    // MARK: - Error Handling
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




