//
//  ScheduleViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import Foundation


final class ScheduleViewModel {
    
    var getLessonDict : ResponseModal<[LessonModel]>?
    var request = ""
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getLesson(){
        self.eventHandler?(.loading)
        self.request = "lesson"
        APIManager.shared.requestPost(
            modelType: ResponseModal<[LessonModel]>.self, // response type
            type: APIEndPoint.getLesson,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.getLessonDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func getSellingTips(){
        self.eventHandler?(.loading)
        self.request = "sellingTips"
        APIManager.shared.requestPost(
            modelType: ResponseModal<[LessonModel]>.self, // response type
            type: APIEndPoint.getSellingTips,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.getLessonDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    func getHowToSell(){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[LessonModel]>.self, // response type
            type: APIEndPoint.howToSell,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.getLessonDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    func getShowTips(){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[LessonModel]>.self, // response type
            type: APIEndPoint.showTips,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.getLessonDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func getLetsPrepare(){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[LessonModel]>.self, // response type
            type: APIEndPoint.letsPrepare,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.getLessonDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

