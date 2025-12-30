//
//  AddCardViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//


import Foundation

final class AddCardViewModel: ObservableObject {
    
    @Published var cardDict = ResponseModel<[CardModel]>()
    @Published var addCardDict = ResponseModel<[CardModel]>()
    @Published var sellerStorePaymentDict = ResponseModel<Int>()
    @Published var errorMessage: String? = nil
    
    
//    @MainActor
//    func addCard(parameters: AddCardRequest) async  {
//       
//            do {
//                if let response: ResponseModel<[CardModel]> = try await APIManager.shared.request(
//                    type: APIEndPoint.AddCard(param: parameters),
//                    header: true) {
//                    self.addCardDict = response
//                }
//            }catch let error{
//                if let dataError = error as? DataError {
//                    switch dataError {
//                    case .invalidCode(let message):
//                        self.errorMessage = message ?? "Invalid code error"
//                    case .invalidResponse(let data):
//                        if let data = data,
//                           let json = try? JSONSerialization.jsonObject(with: data, options: []) {
//                            self.errorMessage = "Invalid response: \(json)"
//                        } else {
//                            self.errorMessage = "Invalid response with no data"
//                        }
//                    default:
//                        self.errorMessage = error.localizedDescription
//                    }
//                } else {
//                    self.errorMessage = error.localizedDescription
//                }
//            
//        }
//    }
    
    @MainActor
    func addSellerCard(parameters: StorePaymentMethodRequest) async  {
       
            do {
                if let response: ResponseModel<Int> = try await APIManager.shared.request(
                    type: APIEndPoint.storePaymentMethod(param: parameters),
                    header: true) {
                    self.sellerStorePaymentDict = response
                }
            }catch let error{
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

    @MainActor
    func getCard() async throws {
        do {
            if let response: ResponseModel<[CardModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getCard,
                header: true) {
                self.addCardDict = response
            }
        }catch let error{
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

    @MainActor
    func deleteCard(parameters: DeleteCardRequest) async throws {
        do{
            if let response: ResponseModel<CardModel> = try await APIManager.shared.request(
                type: APIEndPoint.deleteCard(param: parameters),
                header: true) {
                try await getCard()
            }
        }catch let error{
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
}
