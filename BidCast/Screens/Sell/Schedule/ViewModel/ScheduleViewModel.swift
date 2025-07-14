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
    @Published var productResponse: ResponseModalPaginate<[ProductDataModel]>?
    @Published var getProductResponse: ResponseModal<[ProductDataModel]>?
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
            let response: ResponseModalPaginate<[ProductDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getUserProduct(param: parameters),
                header: true
            )
            self.productResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    func getProduct(parameters: ProductRequest) async {
        do {
            let response: ResponseModal<[ProductDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getProduct(param: parameters),
                header: true
            )
            self.getProductResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    func storeScheduleShow(param: StoreScheduleShowRequest, images: [String], key: String) async {
        self.requestType = "store"
        
        do {
            let parameters = try param.asDictionary()

            let response: ResponseModal<StoreScheduleShowModel> = try await APIManager.shared.uploadImage(
                type: APIEndPoint.storeScheduleShow(param: param),
                urlArray: images,
                mimeType: "image/jpeg",
                keyName: key,
                parameters: parameters,
                modalType: ResponseModal<StoreScheduleShowModel>.self,
                header: true
            )
            
            self.storeShowResponse = response
            
        } catch {
            handle(error: error)
        }
    }

    
    
    // MARK: - Centralized Error Handler
     func handle(error: Error) {
        if let dataError = error as? DataError {
            switch dataError {
            case .invalidCode(let message):
                self.errorMessage = message ?? "Invalid code error"
            case .invalidResponse(let data):
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    self.errorMessage = "Invalid response: \(json)"
                } else {
                    self.errorMessage = "Invalid response with no data"
                }
            default:
                self.errorMessage = error.localizedDescription
            }
        } else {
            self.errorMessage = error.localizedDescription
        }
    }
}
