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
    
    func getProductList(parameters: ProductRequest) async {
        do {
            let response: ResponseModal<[ProductDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getProduct(param: parameters),
                header: true
            )
            self.productResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    func storeScheduleShow(parameters: StoreScheduleShowRequest) async {
        do {
            let response: ResponseModal<StoreScheduleShowModel> = try await APIManager.shared.request(
                type: APIEndPoint.storeScheduleShow(param: parameters),
                header: true
            )
            self.storeShowResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    func storeScheduleShow(parameters: StoreScheduleShowRequest,images: [String], key: String) async {
        var parameter = [String:Any]()
        do {
            parameter = try parameters.asDictionary()
        } catch {
            print(error.localizedDescription)
        }
        do {
            let response: ResponseModal<StoreScheduleShowModel> = try await APIManager.shared.uploadImage1(
                type: APIEndPoint.storeScheduleShow(param: parameters),
                urlArray: images,
                mimeType: "image",
                keyName: key,
                parameters: parameter,
                modalType:  ResponseModal<StoreScheduleShowModel>.self,
                header: true
            )
            self.storeShowResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        errorMessage = error.localizedDescription
    }
}
