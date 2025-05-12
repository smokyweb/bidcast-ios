//
//  LoginViewModel.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 18/01/24.
//

import Foundation


final class LoginViewModel:NSObject {
    
    var loginResponceDict: ResponseModal<UserDetailModal>?
    var linkedInResponse: ResponseModal<LinkedInDataResponse>?
    var welcomeVideoResponse : ResponseModal<WelcomeModel>?
    var employerId: String?
    var requestType: String = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
	    
    func logIn(parameters: SignInRequest) {
        self.eventHandler?(.loading)
        requestType = "Login"
        APIManager.shared.requestPost(
            modelType: ResponseModal<UserDetailModal>.self, // response type
            type: APIEndPoint.login(param: parameters),
            header: false) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.loginResponceDict = data
                    self.employerId = "\(self.loginResponceDict?.data.id ?? 0)"
                    UserDefaultsManager.shared.setValue(self.employerId, forKey: .employerId)
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
    func saveDeviceDetail(parameter: DeviceDetailModal) {
        self.eventHandler?(.loading)
        requestType = "SaveDeviceDetail"
        APIManager.shared.requestPost(
            modelType: ResponseModal<SignInData>.self, // response type
            type: APIEndPoint.saveDeviceDetail(param: parameter),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        print(data)
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
    func getLinkedInDetails(param: String) {
        self.eventHandler?(.loading)
        requestType = "LinkedInDetail"
        APIManager.shared.requestPost(
            modelType: ResponseModal<LinkedInDataResponse>.self,
            type: APIEndPoint.checkLinkedIn(param: param),
            header: false) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.linkedInResponse = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
    func getCombineDetail() {
        self.eventHandler?(.loading)
        requestType = "CombineDetail"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<CombineDataModel>.self,
                type: APIEndPoint.combineData,
                header: true) {
                    result in
                    switch result {
                        case .success(let data):
                            UserDefaultsManager.shared.setModel(data.data, forKey: .combineData)
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            Log.e(String(describing: error))
                            return
                    }
                }
    }
    
    func getWelcomeVideo() {
        self.requestType = "WelcomeVideo"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<WelcomeModel>.self, // response type
            type: APIEndPoint.welcome,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.welcomeVideoResponse = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
}

