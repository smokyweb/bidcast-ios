//
//  FAQViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//

import Foundation
import Foundation

final class FAQViewModel {
    
    var FAQModelDict = FAQModel()
    var requestType = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getFAQ() {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: FAQModel.self, // response type
            type: APIEndPoint.faq,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.FAQModelDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}


extension FAQViewModel {
    enum Event {
        case loading
        case stopLoading
        case dataLoaded
        case error(Error?)
        
    }
}

