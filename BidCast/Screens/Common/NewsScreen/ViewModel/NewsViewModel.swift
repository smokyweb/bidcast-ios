//
//  NewsViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//

import Foundation

final class NewsViewModel {
    
    var newsResponceDict : ResponseModal<[NewsResponseModel]>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getNewsContent(){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[NewsResponseModel]>.self, // response type
            type: APIEndPoint.get_news,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.newsResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}
