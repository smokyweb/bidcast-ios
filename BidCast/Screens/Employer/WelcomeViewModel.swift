//
//  WelcomeViewModel.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 02/02/24.
//

import Foundation


final class WelcomeViewModel {
    
    var welcomeDict : ResponseModal<WelcomeModel>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getWelcomeVideo() {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<WelcomeModel>.self, // response type
            type: APIEndPoint.welcome,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.welcomeDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

struct WelcomeModel: Codable {
    var welcome, howToMakeYourResume, exampleResume: String?
    
    enum CodingKeys: String, CodingKey {
        case welcome
        case howToMakeYourResume = "how-to-make-your-resume"
        case exampleResume = "example-resume"
    }
}
