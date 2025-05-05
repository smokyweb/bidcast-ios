//
//  NotificationViewModel.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/02/24.
//

import Foundation


final class NotificationViewModel {
    
    var notificationResponceDict : ResponseModalPaginate<[NotificationListModel]>?
    var jobDetailResponse: ResponseModal<JobDetailResponse>?
    var deleteNotiResponse: ResponseModal<[String]>?
    var requestType = ""
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    
    func getNotificationContent(page: String) {
        self.requestType = "GetNotification"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModalPaginate<[NotificationListModel]>.self,
            type: APIEndPoint.getNotification(param: page),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.notificationResponceDict = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
    func deleteNotification(id:String){
        self.requestType = "DeleteNotification"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[String]>.self, // response type
            type: APIEndPoint.deleteNotification(param: id),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        self.deleteNotiResponse = data
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
    func updateNotificationContent(notiId: String){
        self.requestType = "UpdateNotification"
//        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[String]>.self, // response type
            type: APIEndPoint.updateNotification(param: ReadNotification(id: [notiId])),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                    case .success(let data):
                        print(data)
                        self.eventHandler?(.dataLoaded)
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                }
            }
    }
    
        //    func updateNotificationContent(notiId: ReadNotification){
        //        self.requestType = "ReadNoti"
        //        self.eventHandler?(.loading)
        //        APIManager.shared.requestPost(
        //            modelType: ResponseModal<NotiData>.self, // response type
        //            type: APIEndPoint.updateNotification(param: notiId),
        //            header: true) { result in
        //                self.eventHandler?(.stopLoading)
        //                switch result {
        //                    case .success(let data):
        //                        print(data)
        //                        self.eventHandler?(.dataLoaded)
        //                    case .failure(let error):
        //                        self.eventHandler?(.error(error))
        //                }
        //            }
        //    }
    
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
    
    struct NotiData:Codable{
        
    }
}
