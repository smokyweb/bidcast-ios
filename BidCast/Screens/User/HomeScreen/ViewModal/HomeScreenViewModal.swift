//
//  HomeScreenViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 29/01/24.
//

import Foundation

final class HomeScreenViewModal {
    
        //MARK: - Responses
    var jobResponse: ResponseModal<[JobDetailResponse]>?
    var response = UserResponseModal()
    var saveJobResponse: ResponseModal<JobResponse>?
    var getSavedJobResponse: ResponseModalPaginate<[SavedJobListResponse]>?
    var applyJobResponse: ResponseModalPaginate<JobResponse>?
    var rejectJobResponse: ResponseModal<JobResponse>?
    var getJobMatchesResponse: ResponseModalPaginate<[InterviewScheduleModal]>?
    var scheduleJobResponse: ResponseModalPaginate<InterviewScheduleModal>?
    var notiCountDict: ResponseModal<Int>?
    var welcomeDict : ResponseModal<WelcomeModel>?

    var requestType = ""
        //MARK: - Handler
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    
        //MARK: - Get Job Request
    func getJob(parameter: GetJobParameter) {
        self.eventHandler?(.loading)
        self.requestType = "GetJob"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[JobDetailResponse]>.self,
                type: APIEndPoint.getJob(param: parameter),
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
    
    
    
        //MARK: - Swipe Job Functionality
    func swipeJob(parameter: JobSwipePatamter) {
        self.requestType = "SwipeJob"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<JobSwipeResponse>.self,
                type: APIEndPoint.jobSwipe(param: parameter),
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
    
        //MARK: - Get Job Scheduled Interview
    func getJobInterview() {
        
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
                            self.applyJobResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - Get Employee Saved Job
    func getSavedJob() {
        self.requestType = "GetSavedJob"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[SavedJobListResponse]>.self,
                type: APIEndPoint.getSavedJob,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.getSavedJobResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - Apply for a Job
    func applyJob(parameter: SaveJobRequest) {
        self.eventHandler?(.loading)
        self.requestType = "ApplyJob"
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<JobResponse>.self,
                type: APIEndPoint.applyJob(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.applyJobResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - Reject a Job
    func rejectJob(parameter: SaveJobRequest) {
        self.eventHandler?(.loading)
        self.requestType = "RejectJob"
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<JobResponse>.self,
                type: APIEndPoint.rejectJob(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.applyJobResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - Get Employee Matched Job's
    func getJobMatchesForEmployee(currentPage: Int) {
        self.eventHandler?(.loading)
        requestType = "GetMatchedJob"
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[InterviewScheduleModal]>.self,
                type: APIEndPoint.getMatches(param: "\(currentPage)"),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.getJobMatchesResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: - Schedule Interview for Matched Job
    func scheduleMatchedJobInterview(parameter: ScheduleInterviewRequest) {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<InterviewScheduleModal>.self,
                type: APIEndPoint.scheduleInterviewForMatchedJob(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.scheduleJobResponse = data
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
    
    func getProfile() {
        self.eventHandler?(.loading)
        self.requestType = "GetProfile"
        APIManager.shared
            .requestPost(
                modelType: UserResponseModal.self,
                type: APIEndPoint.getProfile,
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
    
        //MARK: - Update Interview Status
    func updateInterviewStatus(status_id statusId: String, match_id matchId: String) {
        requestType = "UpdateInterviewStatus"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<InterviewScheduleModal>.self,
                type: APIEndPoint.updateInterviewStatus(statusId: statusId, matchId: matchId),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(_):
//                            self.scheduleJobResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
}
