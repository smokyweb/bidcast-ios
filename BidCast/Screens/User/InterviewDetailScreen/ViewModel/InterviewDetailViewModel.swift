//
//  InterviewDetailViewModel.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 08/03/24.
//

import Foundation

final class InterviewDetailViewModel {
    
        //MARK: Response
    var response: ResponseModal<InterviewScheduleModal>?
    var scheduleJobResponse: ResponseModalPaginate<InterviewScheduleModal>?
    var requestType: String = ""
    
        //MARK: - Handler
    var eventHandler: ((_ event: Event) -> Void)?
    
    func getInterviewDetail(id: String){
        self.requestType = "GetInterviewDetail"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<InterviewScheduleModal>.self,
            type: APIEndPoint.getInterviewDetail(param: id),
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
    
        //MARK: - Schedule Interview for Matched Job
    func scheduleMatchedJobInterview(parameter: ScheduleInterviewRequest) {
        self.requestType = "ScheduleInterview"
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
    
    //MARK: - Update Interview Status
    func updateInterviewStatus(status_id statusId: String, match_id matchId: String) {
        self.requestType = "UpdateInterviewStatus"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<InterviewScheduleModal>.self,
                type: APIEndPoint.updateInterviewStatus(statusId: statusId, matchId: matchId),
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
}
