//
//  EmployeeProfileViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 08/02/24.
//

import Foundation

final class EmployeeProfileViewModal {
    
    var response: ResponseModal<EmployerSaveResponse>?
    var setEmployerAvailability: EmployerAvailability?
    var getEmployerAvailability: GetAvailability?
    var employerScheduleData: EmployerScheduleInterView?
    var employeeDetailResponse: ResponseModal<UserDetailModal>?
    var jobDetailResponse: ResponseModal<JobDetailResponse>?
    var createEventDict: CreateEventModel?
    var requestType = ""
    
    //MARK: - Event Handler to Screen
    var eventHandler: ((_ event: Event) -> Void)?
    
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
                        self.response = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                    }
                }
    }
    
    //MARK: - Get Employee Detail
    func getEmployeeDetail(employeeId: String,jobId: String) {
        requestType = "GetEmployeeDetails"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<UserDetailModal>.self,
                type: APIEndPoint.getEmployeeDetail(id: employeeId,job: jobId),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.employeeDetailResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    func CreateEvents(param: CreateEventParam) {
        self.eventHandler?(.loading)
        self.requestType = "CreateEvents"
        APIManager.shared
            .requestPost(
                modelType: CreateEventModel.self,
                type: APIEndPoint.CreateEvent(param: param),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.createEventDict = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    //MARK: - Get Job Detail
    func getJobDetail(jobId: String) {
        requestType = "GetJobDetails"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<JobDetailResponse>.self,
                type: APIEndPoint.getSpecificJobDetail(param: jobId),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.jobDetailResponse = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
    
    //MARK: - Set Employer Availability
    
    
    func setEmployerAvailabilityData(parameter: EmployerAvailabilityRequest) {
        self.eventHandler?(.loading)
        requestType = "SetEmployerAvailability"
        print("params are======>>>>>", parameter)
        APIManager.shared
            .requestPost(
                modelType: EmployerAvailability.self,
                type: APIEndPoint.setEmployerAvailability(param: parameter),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.setEmployerAvailability = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                    }
                }
    }
    
    //MARK: - Get Employer Availability
    
    func getEmployerAvailabilityData() {
        self.eventHandler?(.loading)
        requestType = "GetEmployerAvailability"
        APIManager.shared
            .requestPost(
                modelType: GetAvailability.self,
                type: APIEndPoint.getEmployerAvailability,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.getEmployerAvailability = data
                        print("getEmployerAvailabilityData=======> ", self.getEmployerAvailability)
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    //MARK: - Employer Schedule InterView Api
    
    func employerScheduleApi(parameter: EmployerScheduleRequest){
        self.eventHandler?(.loading)
        requestType = "EmployerScheduleInterView"
        APIManager.shared
            .requestPost(
                modelType: EmployerScheduleInterView.self,
                type: APIEndPoint.employerSchedule(param: parameter),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.employerScheduleData = data
                        print("timeSlotData is=======> ", self.employerScheduleData)
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                    }
                }
    }
    
}
