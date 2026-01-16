//
//  ShowsViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//
import Foundation

@MainActor
final class ShowsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var scheduledShow: ResponseModelPaginate<[HomeModel]>?
    @Published var updateStatusRespone : ResponseModelPaginate<UpdateStatusModel>?
    @Published var storePromoteShowModel : ResponseModel<StorePromoteShowModel>?
    @Published var getShowOverviewModel : ResponseModel<GetShowOverviewModel>?
    @Published var sellerResponse : ResponseModelPaginate<[SellerUserModel]>?
    @Published var promoteShow: ResponseModelPaginate<[BoostModel]>?
    @Published var scheduledShowData: ResponseModelPaginate<HomeModel>?
    @Published var clipResponse: ResponseModel<ClipModel>?
    @Published var errorMessage: String? = nil
    @Published var countResponse = countModel()
    @Published var requestType: String = ""
    
    // MARK: - Get Lessons
    func getLiveSHows(param:GetLiveShowsRequest) async {
        requestType = "lesson"
        do {
            let response: ResponseModelPaginate<[HomeModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getScheduledShow(param: param),
                header: true
            )
            scheduledShow = response
        } catch {
            handle(error: error)
        }
    }
    
    func makeClip(param:ClipRequest) async {
        requestType = "clip"
        do {
            let response: ResponseModel<ClipModel> = try await APIManager.shared.request(
                type: APIEndPoint.makeClip(param: param),
                header: true
            )
            clipResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Get Lessons
    func getPromoteShows() async {
        requestType = "promote"
        do {
            let response: ResponseModelPaginate<[BoostModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getPromoteShow,
                header: true
            )
            promoteShow = response
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Get live seller
    func getLiveSeller() async {
        requestType = "promote"
        do {
            let response: ResponseModelPaginate<[SellerUserModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLiveSeller,
                header: true
            )
            sellerResponse = response
        } catch {
            handle(error: error)
        }
    }
    
    func UpdateLiveShows(param:LiveShowUpdateRequest) async {
        requestType = "lesson"
        do {
            let response: ResponseModelPaginate<UpdateStatusModel> = try await APIManager.shared.request(
                type: APIEndPoint.UpdateShowStatus(param: param),
                header: true
            )
            updateStatusRespone = response
        } catch {
            handle(error: error)
        }
    }
    
    func storePromoteShow(parameters: StorePromoteShowRequest) async {
        requestType = "promoteShow"
        do {
           if let response:  ResponseModel<StorePromoteShowModel>? = try await APIManager.shared.request(
                type: APIEndPoint.storePromoteShow(param: parameters),
                header: true
           ){
               self.storePromoteShowModel = response
           }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    func CountUppdate(parameters: countRequest) async {
        requestType = "count"
        do {
           if let response: countModel = try await APIManager.shared.request(
                type: APIEndPoint.countUpdate(param: parameters),
                header: true
           ){
               self.countResponse = response
           }
           
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    // MARK: - storeShippingProfile
    func getShowOverview(request: ShowOverviewRequest) async throws{
        requestType = "showOverview"
        do {
            let response: ResponseModel<GetShowOverviewModel> = try await APIManager.shared.request(
                type: APIEndPoint.getShowOverview(param: request),
                header: true)
            self.getShowOverviewModel = response
        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
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
            scheduledShowData = response
        } catch {
            handle(error: error)
        }
    }
    
    func handle(error: Error) {
        errorMessage = error.localizedDescription
    }
    
//    PromoteShow
    //schedule-show/store-promote-show
//    schedule_show_id
//    promote_show_id
    
    //sendTip
}
