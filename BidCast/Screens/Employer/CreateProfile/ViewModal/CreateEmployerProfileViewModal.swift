//
//  CreateEmployerProfileViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 13/02/24.
//

import Foundation

final class CreateEmployerProfileViewModal {
    
    var imageUploadResponse: ResponseModal<[String]>?
    var response: ResponseModal<JobActionResponse>?
    var companyResponse: ResponseModal<CompanyUserResponse>?
    var updateCompanyResponse: ResponseModal<String?>?
    var companyResponseDetails: ResponseModal<CompanyUserResponse>?

    
    var requestType: String = ""
    
        //MARK: - Event Handler to Screen
    var eventHandler: ((_ event: Event) -> Void)?
    
        //MARK: - Upload Image
    func uploadImages(parameter: [String]) {
        self.eventHandler?(.loading)
        requestType = "UploadImage"
        DispatchQueue.global(qos: .background).async {
            APIManager.shared
                .uploadFile(
                    type: APIEndPoint.uploadFile,
                    urlArray: parameter,
                    mimeType: "image/png",
                    modalType: ResponseModal<[String]>.self,
                    header: true,
                    completion: {
                        result in
                        switch result {
                            case .success(let data):
                                self.imageUploadResponse = data
                           
                                self.eventHandler?(.dataLoaded)
                                return
                            case .failure(let error):
                                self.eventHandler?(.stopLoading)
                                self.eventHandler?(.error(error))
                        }
                    })
        }
    }
    
    func uploadImagesToUser(parameter: [String],userParam : SubCompanyParam) {
        self.eventHandler?(.loading)
        requestType = "UploadImage"
        DispatchQueue.global(qos: .background).async {
            APIManager.shared
                .uploadFile(
                    type: APIEndPoint.uploadFile,
                    urlArray: parameter,
                    mimeType: "image/png",
                    modalType: ResponseModal<[String]>.self,
                    header: true,
                    completion: {
                        result in
                        switch result {
                            case .success(let data):
                                self.imageUploadResponse = data
                            var newPara = userParam
                            newPara.image = data.data[0]
                            self.updateSubCompanyDetails(parameter: newPara)
                                self.eventHandler?(.dataLoaded)
                                return
                            case .failure(let error):
                                self.eventHandler?(.stopLoading)
                                self.eventHandler?(.error(error))
                        }
                    })
        }
    }
    
    
    func uploadImagesToCompanyUser(parameter: [String],userParam : SubCompanyUserParam) {
        self.eventHandler?(.loading)
        requestType = "UploadImage"
        DispatchQueue.global(qos: .background).async {
            APIManager.shared
                .uploadFile(
                    type: APIEndPoint.uploadFile,
                    urlArray: parameter,
                    mimeType: "image/png",
                    modalType: ResponseModal<[String]>.self,
                    header: true,
                    completion: {
                        result in
                        switch result {
                            case .success(let data):
                                self.imageUploadResponse = data
                            var newPara = userParam
                            newPara.image = data.data[0]
                            self.updateSubCompanyUser(parameter: newPara)
                                self.eventHandler?(.dataLoaded)
                                return
                            case .failure(let error):
                                self.eventHandler?(.stopLoading)
                                self.eventHandler?(.error(error))
                        }
                    })
        }
    }
    
    func uploadImagesToUserUpdate(parameter: [String],userParam : SubCompanyParamUpdate) {
        self.eventHandler?(.loading)
        requestType = "UploadImage"
        DispatchQueue.global(qos: .background).async {
            APIManager.shared
                .uploadFile(
                    type: APIEndPoint.uploadFile,
                    urlArray: parameter,
                    mimeType: "image/png",
                    modalType: ResponseModal<[String]>.self,
                    header: true,
                    completion: {
                        result in
                        switch result {
                            case .success(let data):
                                self.imageUploadResponse = data
                            var newPara = userParam
                            newPara.image = data.data[0]
                            self.updateSubCompanyUserDetails(parameter: newPara)
                                self.eventHandler?(.dataLoaded)
                                return
                            case .failure(let error):
                                self.eventHandler?(.stopLoading)
                                self.eventHandler?(.error(error))
                        }
                    })
        }
    }
    
    func updateEmployerDetails(parameter: UserPersonalInfo) {
        self.eventHandler?(.loading)
        requestType = "UpdateDetail"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<JobActionResponse>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(profile_info: [parameter], type: "profile_info")),
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
    
    
    func updateSubCompanyDetails(parameter: SubCompanyParam) {
        self.eventHandler?(.loading)
        requestType = "UpdateCompany"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<String?>.self,
                type: APIEndPoint.SubCompany(param: parameter),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.updateCompanyResponse = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
    
    
    func updateSubCompanyUser(parameter: SubCompanyUserParam) {
        self.eventHandler?(.loading)
        requestType = "UpdateCompanyUser"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<JobActionResponse>.self,
                type: APIEndPoint.UpdateSubCompanyUser(param: parameter),
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
    
    func updateSubCompanyUserDetails(parameter: SubCompanyParamUpdate) {
        self.eventHandler?(.loading)
        requestType = "UpdateCompany"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<String?>.self,
                type: APIEndPoint.SubCompanyUpdate(param: parameter),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.updateCompanyResponse = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
    
    func getSubCompanyUserDetails() {
        self.eventHandler?(.loading)
        requestType = "GetCompanyUser"
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
    
    func getSubCompanyDetails(user_id: String) {
        self.eventHandler?(.loading)
        requestType = "GetCompany"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<CompanyUserResponse>.self,
                type: APIEndPoint.getSubCompany(param: user_id),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.companyResponse = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
    
    
}
