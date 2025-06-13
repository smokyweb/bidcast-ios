//
//  ScheduleViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

//
//  ScheduleViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import Foundation

@MainActor
final class ScheduleViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var lessonsResponse: ResponseModal<[LessonModel]>?
    @Published var tipsResponse: ResponseModal<TitleTipsModel>?
    @Published var productResponse: ResponseModal<[ProductDataModel]>?
    @Published var storeShowResponse : ResponseModal<StoreScheduleShowModel>?
    @Published var errorMessage: String? = nil
    @Published var requestType: String = ""
    @Published var isStoreAPIDone = false

    // MARK: - Get Lessons
    func getLesson() async {
        requestType = "lesson"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLesson,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Selling Tips
    func getSellingTips() async {
        requestType = "sellingTips"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getSellingTips,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get How To Sell
    func getHowToSell() async {
        requestType = "howToSell"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.howToSell,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Show Tips
    func getShowTips() async {
        requestType = "showTips"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.showTips,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Let's Prepare
    func getLetsPrepare() async {
        requestType = "letsPrepare"
        do {
            let response: ResponseModal<[LessonModel]> = try await APIManager.shared.request(
                type: APIEndPoint.letsPrepare,
                header: true
            )
            lessonsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Title Tips
    func getTitleTips(param: TipParam) async {
        requestType = "titleTips"
        do {
            let response: ResponseModal<TitleTipsModel> = try await APIManager.shared.request(
                type: APIEndPoint.getAllTips(param: param),
                header: true
            )
            tipsResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    func getProductList(parameters: UserProductRequest) async {
        do {
            let response: ResponseModal<[ProductDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getUserProduct(param: parameters),
                header: true
            )
            self.productResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    func storeScheduleShow(param: StoreScheduleShowRequest, images: [String], key: String) {
        self.requestType = "store"
        var parameters = [String: Any]()
        
        do {
            parameters = try param.asDictionary()
        } catch {
            self.errorMessage = "Invalid parameters: \(error.localizedDescription)"
            return
        }
        
        APIManager.shared.uploadImage(
            type: APIEndPoint.storeScheduleShow(param: param),
            urlArray: images,
            mimeType: "image/jpeg",
            keyName: key,
            parameters: parameters,
            modalType: ResponseModal<StoreScheduleShowModel>.self,
            header: true
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.isStoreAPIDone = true
                    self.storeShowResponse = data
                case .failure(let error):
                    self.isStoreAPIDone = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        errorMessage = error.localizedDescription
    }
}
