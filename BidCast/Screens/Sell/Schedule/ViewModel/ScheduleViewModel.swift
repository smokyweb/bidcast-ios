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
    @Published var storeShowResponse : ResponseModal<HomeModel>?
    @Published var checkScheduleResponse : ResponseModal<ScheduleModel>?
    @Published var scheduledShow: ResponseModelPaginate<HomeModel>?
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
    
    // MARK: - Get Selling Tips
    func CheckScheduleShow(param :  checkScheduleRequest) async {
        requestType = "check"
        do {
            let response: ResponseModal<ScheduleModel> = try await APIManager.shared.request(
                type: APIEndPoint.checkValidShowDate(param: param),
                header: true
            )
            checkScheduleResponse = response
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
    
    // MARK: - Get scxhedule showData
    @MainActor
    func getScheduleShowData(param: getShowRequest) async {
//        guard !hasLoadedTitleTips else { return }
//        hasLoadedTitleTips = true
        requestType = "show"
        
        do {
            let response: ResponseModelPaginate<HomeModel> = try await APIManager.shared.request(
                type: APIEndPoint.getScheduleShow(param: param),
                header: true
            )
            scheduledShow = response
        } catch {
            handle(error: error)
        }
    }
    

    
   
    
    // MARK: - Store Schedule Show
//    func storeScheduleShow(param: StoreScheduleShowRequest, images: [String], key: String) async {
//        self.requestType = "store"
//        
//        do {
//            let parameters = try param.asDictionary()
//            let response: ResponseModal<HomeModel> = try await APIManager.shared.uploadImage(
//                type: APIEndPoint.storeScheduleShow(param: param),
//                urlArray: images,
//                mimeType: "image/jpeg",
//                keyName: key,
//                parameters: parameters,
//                modalType: ResponseModal<HomeModel>.self,
//                header: true
//            )
//            self.storeShowResponse = response
//        } catch {
//            handle(error: error)
//        }
//    }
    func storeScheduleShow(param: [String: Any], images: [String], key: String) async throws{
        self.requestType = "store"
        
        do {
            let response: ResponseModal<HomeModel> = try await APIManager.shared.uploadImage(
                type: APIEndPoint.storeScheduleShow,
                urlArray: images,
                mimeType: "image/jpeg",
                keyName: key,
                parameters: param,
                modalType: ResponseModal<HomeModel>.self,
                header: true
            )
            self.storeShowResponse = response
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func updateScheduleShow(param: [String: Any], images: [String], key: String) async throws{
        self.requestType = "update"
        
        do {
            let response: ResponseModal<HomeModel> = try await APIManager.shared.uploadImage(
                type: APIEndPoint.updateScheduleShow,
                urlArray: images,
                mimeType: "image/jpeg",
                keyName: key,
                parameters: param,
                modalType: ResponseModal<HomeModel>.self,
                header: true
            )
            self.storeShowResponse = response
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
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

@MainActor
final class ProductViewModel: ObservableObject {
    // MARK: - Get Product
    @Published var productsResponse: ResponseModelPaginate<[ProductDataModel1]>?
    @Published var productsResponse1: ResponseModelPaginate<[ProductDataModel1]>?
    @Published var errorMessage: String? = nil
    @Published var requestType: String = ""
    
    func getProductsData(parameters: ProductRequest) async throws{
        
        do {
            let response: ResponseModelPaginate<[ProductDataModel1]> = try await APIManager.shared.request(
                type: APIEndPoint.getProduct(param: parameters),
                header: true
            )
            self.productsResponse1 = response
        }
        catch(let error) {
            if let dataError = error as? DataError {
                DispatchQueue.main.async {
                    self.errorMessage = dataError.getErrorMessage()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
            throw error
        }
    }
    
    func getProductsData1(parameters: ProductRequest) async throws{
        
        do {
            let response: ResponseModelPaginate<[ProductDataModel1]> = try await APIManager.shared.request(
                type: APIEndPoint.getProduct(param: parameters),
                header: true
            )
            self.productsResponse1 = response
        }
        catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
}
