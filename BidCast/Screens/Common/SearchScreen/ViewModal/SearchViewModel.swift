//
//  SearchViewModel.swift
// BidSwipe
//
//  Created by JAM-E-265 on 02/02/24.
//


import Foundation

final class SearchViewModel {
    
    var employeeSearchResponse : ResponseModalPaginate<[UserDetailModal]>?
    var employeeSearchJobResponse : ResponseModalPaginate<[UserDetailSearchModal]>?
    var jobSearchResponse: ResponseModalPaginate<[JobDetailResponse]>?
    var companyNameResponse: ResponseModal<[CompanyNameResponse]>?
    
    var requestType: String = ""
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    func employeeSearch(parameter: SearchRequest) {
        self.requestType = "EmployeeSearch"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[UserDetailModal]>.self,
                type: APIEndPoint.getEmployeeList(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.employeeSearchResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    
    func employeeSearchByJob(parameter: SearchRequestByJobId) {
        self.requestType = "EmployeeSearchByJob"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[UserDetailSearchModal]>.self,
                type: APIEndPoint.getEmployeeListByJobId(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.employeeSearchJobResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func jobSearch(parameter: SearchRequest) {
        self.requestType = "JobSearch"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[JobDetailResponse]>.self,
                type: APIEndPoint.searchJob(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.jobSearchResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getCompanyName() {
        self.requestType = "GetCompanyName"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[CompanyNameResponse]>.self,
                type: APIEndPoint.getCompanyName,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.companyNameResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getFilterSearch(parameter: FilterRequestModal) {
        self.requestType = "JobFilterSearch"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[JobDetailResponse]>.self,
                type: APIEndPoint.filterSearch(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.jobSearchResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getFilterJobSearch(parameter: FilterRequestModal) {
        self.requestType = "JobFilterSearch"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[JobDetailResponse]>.self,
                type: APIEndPoint.filterJobSearch(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.jobSearchResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getEmployeeFilterSearch(parameter: FilterRequestModal) {
        self.requestType = "EmployeeFilterSearch"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[UserDetailModal]>.self,
                type: APIEndPoint.filterSearch(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.employeeSearchResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func getSelectedJobEmployee(parameter: EmployeeJobIdRequest) {
        self.requestType = "GetEmpByJobId"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[UserDetailModal]>.self,
                type: APIEndPoint.getEmployeeByJobId(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.employeeSearchResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
}
