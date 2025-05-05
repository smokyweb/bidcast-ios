//
//  AboutUsViewModel.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//

import Foundation

final class AboutUsViewModel {
    
    var aboutResponceDict : ResponseModal<AboutUsResponseModel>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getAboutContent(){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<AboutUsResponseModel>.self, // response type
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

