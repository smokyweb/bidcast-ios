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
    @Published var errorMessage: String? = nil
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
    
    
    func handle(error: Error) {
        errorMessage = error.localizedDescription
    }
}
