//
//  CompanyDetailViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 13/02/24.
//

import Foundation

final class CompanyDetailViewModal {
    
    var response: ResponseModal<UserDetailModal>?
    var linkedInResponse: ResponseModal<[String]>?
    var companyResponse: ResponseModal<CreateCompanyResponse>?
    var createEventDict: CreateEventModel?
    var categoriesResponse: ResponseModal<[userCategories]>?
    var companyUserResponse: ResponseModal<CompanyUserResponse>?
    var companyResponseDetails: ResponseModal<CompanyUserResponse>?

    var requestType: String = ""
    
        //MARK: - Event Handler to Screen
    var eventHandler: ((_ event: Event) -> Void)?
    
    func getDetail() {
        self.requestType = "GetDetail"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<UserDetailModal>.self,
                type: APIEndPoint.getProfile,
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
                            return
                            
                    }
                }
    }
    
    func getSubCompanyDetails() {
        self.eventHandler?(.loading)
        requestType = "GetCompany"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<CompanyUserResponse>.self,
                type: APIEndPoint.getSubCompanyUser,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.companyResponseDetails = data
                        UserDefaultsManager.shared.setModel(data.data, forKey: .UserAcceess)
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
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
    
        //MARK: Link Account with LinkedIn
    func linkLinkedIn(param: LinkedInLinkModel) {
        self.eventHandler?(.loading)
        self.requestType = "LinkLinkedIn"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[String]>.self,
                type: APIEndPoint.linkLinkedIn(param: param),
                header: true) { result in
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
    

    
    func createCompanyWithImage(parameters: CreateCompanyRequest, images: [String]) {
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
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            if data.status == "success" {
                                var newPara = parameters
                                newPara.logo = data.data[0]
                                self.createCompany(param: newPara)
                            } else {
                                self.createCompany(param: parameters)
                            }
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                })
    }
    
    func createCompany(param: CreateCompanyRequest) {
        self.eventHandler?(.loading)
        self.requestType = "CreateCompanyProfile"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<CreateCompanyResponse>.self,
                type: APIEndPoint.upsertCompany(param: param),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.companyResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
}
