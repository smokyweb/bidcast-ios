//
//  MenuOptionsViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 07/02/24.
//

import Foundation
import OneSignalFramework

final class MenuOptionsViewModal {
    
        //MARK: - Response Vairables
    var logOutResponse: ResponseModal<MenuOptionsModal>?
    var privacyResponse: ResponseModal<MenuOptionsModal>?
    var termServiceResonse: ResponseModal<MenuOptionsModal>?
    var aboutUsResponse: ResponseModal<MenuOptionsModal>?
    
        //MARK: - Event Handler
    var eventHandler: ((_ event: Event) -> Void)?
    
        //MARK: - User LogOut
    func logOut() {
        self.eventHandler?(.loading)
        if let deviceToken: String = UserDefaultsManager.shared.value(forKey: .deviceToken) {
            APIManager.shared
                .requestPost(
                    modelType: ResponseModal<MenuOptionsModal>.self,
                    type: APIEndPoint.logout(device_token: deviceToken),
                    header: true) { result in
                        self.eventHandler?(.stopLoading)
                        switch result {
                            case .success(let data):
                                self.logOutResponse = data
                                self.eventHandler?(.dataLoaded)
                            case .failure(let error):
                                self.eventHandler?(.error(error))
                        }
                    }
        }
    }
    
        //MARK: - Privacy Policy
    func getPrivacyDetails() {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<MenuOptionsModal>.self,
                type: APIEndPoint.privacyPolicy,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.privacyResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - Terms Of Services
    func getTermsOfServ() {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<MenuOptionsModal>.self,
                type: APIEndPoint.termsOfService,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.termServiceResonse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - About Us
    func getAboutUs() {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<MenuOptionsModal>.self,
                type: APIEndPoint.termsOfService,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.aboutUsResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
}
