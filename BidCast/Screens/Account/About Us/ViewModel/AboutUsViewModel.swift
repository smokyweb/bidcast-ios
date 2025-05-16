//
//  AboutUsViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import Foundation

final class AboutUsViewModel {
    
    var aboutResponceDict : ResponseModal<AboutUsModel>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getAboutContent(){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<AboutUsModel>.self, // response type
            type: APIEndPoint.aboutUs,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.aboutResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

