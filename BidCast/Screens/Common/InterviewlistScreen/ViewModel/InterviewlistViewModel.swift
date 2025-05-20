//
//  InterviewlistViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 27/02/24.
//

import Foundation
 
class InterviewlistViewModel {
    
    var interviewDict : ResponseModalPaginate<[InterviewScheduleModal]>?
    var subCompanyDict : ResponseModalPaginate<[SubCompanyModal]>?
    var deleteCompanyDict : ResponseModal<String?>?
    var request = ""

    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getInterviewContent(currentPage: Int) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModalPaginate<[InterviewScheduleModal]>.self, // response type
            type: APIEndPoint.getScheduledInterview(param: "\(currentPage)"),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.interviewDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    

    func getCompanyUser(currentPage: Int) {
        request = "getUser"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModalPaginate<[SubCompanyModal]>.self, // response type
            type: APIEndPoint.getSubCompanyDetails(param: "\(currentPage)"),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.subCompanyDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func deactivateeCompanyUser(parameter: DeleteCompanyUserParam) {
        self.eventHandler?(.loading)
        request = "Deactivate"
        APIManager.shared.requestPost(
            modelType: ResponseModal<String?>.self, // response type
            type: APIEndPoint.deleteSubCompanyUser(param: parameter),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.deleteCompanyDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    

}
