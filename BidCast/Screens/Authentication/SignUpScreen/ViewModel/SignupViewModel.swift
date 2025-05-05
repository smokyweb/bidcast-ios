//
//  SignupViewModel.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//

import Foundation

final class SignupViewModel {
    
    var signUpResponceDict = LoginResponce()
    var linkedInResponse: ResponseModal<LinkedInDataResponse>?
    var userNameDict: ResponseModal<[String]>?

    
    var requestType: String = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func register(parameters: RegisterRequest) {
        self.requestType = "RegisterUser"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: LoginResponce.self, // response type
            type: APIEndPoint.singUp(param: parameters),
            header: false) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.signUpResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    
    func registerUser(parameters: CreateUserRequest) {
        self.requestType = "RegisterUserName"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[String]>.self, // response type
            type: APIEndPoint.verifyUser(param: parameters),
            header: false) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.userNameDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func saveDeviceDetail(parameter: DeviceDetailModal) {
        APIManager.shared.requestPost(
            modelType: ResponseModal<SignInData>.self, // response type
            type: APIEndPoint.saveDeviceDetail(param: parameter),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(_):
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
}
