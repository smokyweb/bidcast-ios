//
//  TrustedBuyerViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 10/06/25.
//

import Foundation

enum RequestedAPIType: String {
    case none = ""
    case addTrustedBuyer = "AddTrustedBuyer"
}

//MARK: addTrustedBuyer
final class TrustedBuyerViewModel {
    
    @Published var addTrustedBuyerDict: ResponseModel<TrustedBuyerModel>?
    @Published var requestType: RequestedAPIType = .none
    
    //    func addTrustedBuyer(image: [String]) {
    //
    //        APIManager.shared
    //            .uploadImage(
    //                type: APIEndPoint.buyerIdentityStore,
    //                urlArray: image,
    //                mimeType: "image/png",
    //                keyName: "image",
    //                parameters :[String:Any](),
    //                modelType:  ResponseModel<TrustedBuyerModel>?.self,
    //                header: true,
    //                completion: {
    //                    result in
    //                    switch result {
    //                    case .success(let data):
    //                        print(data)
    //                        self.addTrustedBuyerDict = data
    //                    case .failure(let error):
    //                        print(error)
    //                    }
    //                })
    //    }
    
    func addTrustedBuyer(param: [String: Any], keysValue: [String], mimeTypes:[String], musics: [[String]]?) {
             APIManager.shared.uploadImageWithMultipleKeys(
                type: APIEndPoint.buyerIdentityStore(param: param),
                urlArray: musics,
                mimeType: mimeTypes,
                keyName: keysValue,
                parameters: param,
                modelType: ResponseModel<TrustedBuyerModel>?.self,
                header: true,
                completion: {
                    result in
                    switch result {
                    case .success(let data):
                        print(data)
                        self.addTrustedBuyerDict = data
                    case .failure(let error):
                        print(error)
                    }
                })
        }
    }
        
