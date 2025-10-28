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
    @Published var storeShowResponse : ResponseModal<HomeModel>?
    @Published var errorMessage: String? = nil
    @Published var requestType: String = ""
    @Published var isStoreAPIDone = false

    // MARK: - Cache flags (only for current app session)
    private var hasLoadedLesson = false
    private var hasLoadedSellingTips = false
    private var hasLoadedHowToSell = false
    private var hasLoadedShowTips = false
    private var hasLoadedLetsPrepare = false
    private var hasLoadedTitleTips = false

    // MARK: - Get Lessons
    func getLesson() async {
        guard !hasLoadedLesson else { return }
        hasLoadedLesson = true
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
        guard !hasLoadedSellingTips else { return }
        hasLoadedSellingTips = true
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
        guard !hasLoadedHowToSell else { return }
        hasLoadedHowToSell = true
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
        guard !hasLoadedShowTips else { return }
        hasLoadedShowTips = true
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
        guard !hasLoadedLetsPrepare else { return }
        hasLoadedLetsPrepare = true
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
        guard !hasLoadedTitleTips else { return }
        hasLoadedTitleTips = true
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
    
    // MARK: - Get Product List
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
    
    // MARK: - Get Product
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
    
    // MARK: - Store Schedule Show
    func storeScheduleShow(param: StoreScheduleShowRequest, images: [String], key: String) async {
        self.requestType = "store"
        
        do {
            let parameters = try param.asDictionary()
            let response: ResponseModal<HomeModel> = try await APIManager.shared.uploadImage(
                type: APIEndPoint.storeScheduleShow(param: param),
                urlArray: images,
                mimeType: "image/jpeg",
                keyName: key,
                parameters: parameters,
                modalType: ResponseModal<HomeModel>.self,
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
