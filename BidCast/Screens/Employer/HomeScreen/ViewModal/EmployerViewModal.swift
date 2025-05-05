//
//  EmployerViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 03/02/24.
//

import Foundation

final class EmployerViewModal {
    
    var response : ResponseModalPaginate<[JobDetailResponse]>?
    var userByJobResponse: ResponseModalPaginate<[UserDetailModal]>?
    var notiCountDict: ResponseModal<Int>?
    var CombineDict: ResponseModal<CombineDataModel>?

    var deleteJobResponse: ResponseModal<[String]>?
    var responseJob: ResponseModal<JobDetailResponse>?
    var responseEmployee: ResponseModal<EmployerSaveResponse>?
    var getJobMatchesResponse: ResponseModalPaginate<[InterviewScheduleModal]>?
    var welcomeDict : ResponseModal<WelcomeModel>?
    var companyResponse: ResponseModal<CompanyUserResponse>?

    var eventHandler: ((_ event: Event) -> Void)?
    var requestType = ""
    
    
    func getJobRequest(parameter: GetJobParameter) {
        self.requestType = "Get"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[JobDetailResponse]>.self,
                type: APIEndPoint.getJob(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.response = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
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
                            self.companyResponse = data
                        UserDefaultsManager.shared.setModel(data.data, forKey: .UserAcceess)
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
    
    func getWelcomeVideo() {
        self.requestType = "Video"
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
    
    //MARK: - Perform Action on Job
    func performJobAction(parameter: PerformJobActionRequest) {
        self.eventHandler?(.loading)
        requestType = "Action"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<EmployerSaveResponse>.self,
                type: APIEndPoint.performActionJob(param: parameter),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.responseEmployee = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                    }
                }
    }
    
    //MARK: - Get Employee Matched Job's
    func getJobMatchesForEmployee(currentPage: Int,job_id:Int) {
    self.eventHandler?(.loading)
    requestType = "GetMatchedJob"
    APIManager.shared
        .requestPost(
            modelType: ResponseModalPaginate<[UserDetailModal]>.self,
            type: APIEndPoint.getMatchesCandidates(page: currentPage, job_id: job_id),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.userByJobResponse = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
}
    
    func getSelectedJobEmployee(parameter: EmployeeJobIdRequest) {
        self.requestType = "GetSelected"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[UserDetailModal]>.self,
                type: APIEndPoint.getEmployeeByJobId(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.userByJobResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getJobDetail(parameter: String) {
        requestType = "GetJobDetail"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<JobDetailResponse>.self,
                type: APIEndPoint.getSpecificJobDetail(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.responseJob = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getNotificationCount(){
        self.requestType = "GetNotiCount"
//        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<Int>.self, // response type
            type: APIEndPoint.getNotificationCount,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.notiCountDict = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
    func deleteJob(parameter: String) {
        self.requestType = "DeleteJob"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[String]>.self,
            type: APIEndPoint.deleteJob(param: parameter),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.deleteJobResponse = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
    func getCombineDetail() {
//        self.eventHandler?(.loading)
        self.requestType = "CombineDetail"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<CombineDataModel>.self,
                type: APIEndPoint.combineData,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                        self.CombineDict = data
                            self.eventHandler?(.dataLoaded)
                        
                            UserDefaultsManager.shared.setModel(data.data, forKey: .combineData)
                            return
                        case .failure(let error):
                            Log.e(String(describing: error))
                            return
                    }
                }
    }
}
