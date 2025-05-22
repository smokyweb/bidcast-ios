//
//  LoginViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 18/01/24.
//

import Foundation


final class LoginViewModel:NSObject {
    
    var loginResponceDict: ResponseModal<LoginModel>?
    var linkedInResponse: ResponseModal<LinkedInDataResponse>?
   
    var employerId: String?
    var requestType: String = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
	    
    func logIn(parameters: SignInRequest) {
        self.eventHandler?(.loading)
        requestType = "Login"
        APIManager.shared.requestPost(
            modelType: ResponseModal<LoginModel>.self, // response type
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
    
    
  
}

