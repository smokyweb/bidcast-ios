//
//  JobUpsertViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 29/01/24.
//

import Foundation

final class JobUpsertViewModal {
    
    var jobResponse: ResponseModal<JobResponse>?
    var qualificationResponse: ResponseModal<[QualificationResponse]>?
    var salaryTypeResponse: ResponseModal<[SalaryTypeResponse]>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    
    var requestType = ""
    
    func getQualification() {
        self.eventHandler?(.loading)
        self.requestType = "GetQualification"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[QualificationResponse]>.self,
                type: APIEndPoint.getQualification,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.qualificationResponse = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
    
    func getSalaryType() {
        self.eventHandler?(.loading)
        self.requestType = "GetSalaryType"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[SalaryTypeResponse]>.self,
                type: APIEndPoint.getSalaryType,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.salaryTypeResponse = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
    
    func upsertJob(parameters: JobUpsertParamter) {
        self.eventHandler?(.loading)
        self.requestType = "CreateJob"
        APIManager.shared.requestPost(
            modelType: ResponseModal<JobResponse>.self, // response type
            type: APIEndPoint.upsertJob(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.jobResponse = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
}
