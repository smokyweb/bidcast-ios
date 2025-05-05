//
//  JobPostViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 07/02/24.
//

import Foundation

final class JobPostViewModal {
    
    var response: ResponseModal<JobDetailResponse>?
    var jobResponse: ResponseModalPaginate<JobResponse>?
    
    var requestType: String = ""
    
    var eventHandler: ((_ event: Event) -> Void)?
    
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
                            self.response = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - Apply for a Job
    func applyJob(parameter: SaveJobRequest) {
        requestType = "JobAction"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<JobResponse>.self,
                type: APIEndPoint.applyJob(param: parameter),
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
    
        //MARK: - Reject a Job
    func rejectJob(parameter: SaveJobRequest) {
        requestType = "JobAction"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<JobResponse>.self,
                type: APIEndPoint.rejectJob(param: parameter),
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
    
        //MARK: - Save Job by Employeer
    func saveEmployeeJob(parameter: SaveJobRequest) {
        self.requestType = "SaveJob"
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<JobResponse>.self,
                type: APIEndPoint.saveJob(param: parameter),
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
