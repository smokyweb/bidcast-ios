//
//  UserCreateProfileViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 24/01/24.
//

import Foundation
import UIKit

final class UserCreateProfileViewModal {
    
    var response: ResponseModal<Int>?
    var profileResponse: ResponseModal<UserDetailModal>?
    var categoriesResponse: ResponseModal<[userCategories]>?

    var signUpResponceDict = LoginResponce()

    var requestType: String = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    
    func updateBasicDetailWithImage(parameters: CreateUserProfSection, images: [String]) {
        self.eventHandler?(.loading)
        APIManager.shared
            .uploadFile(
                type: APIEndPoint.uploadFile,
                urlArray: images,
                mimeType: "image/jpg",
                modalType: ResponseModal<[String]>.self,
                header: true,
                completion: {
                    result in
                    switch result {
                        case .success(let data):
                            if data.status == "success" {
                                var newPara = parameters
                                newPara.profile_image = data.data[0]
                                self.updateBasicDetail(parameters: newPara)
                            } else {
                                self.updateBasicDetail(parameters: parameters)
                            }
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                })
    }
    
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
    
    func updateBasicDetail(parameters: CreateUserProfSection) {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<Int>.self,
                type: APIEndPoint.createUserProfile(param: parameters),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.response = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getProfile() {
        self.eventHandler?(.loading)
        self.requestType = "GetProfile"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<UserDetailModal>.self,
                type: APIEndPoint.getProfile,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.profileResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    
    func getCategories() {
        self.eventHandler?(.loading)
        self.requestType = "GetCategories"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[userCategories]>.self,
                type: APIEndPoint.getCategories,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.categoriesResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
}
