//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var addressResponse = ResponseModel<AddressModel>()
    @Published var liveShowsResponse = ResponseModelPaginate<[HomeModel]>()
    @Published var accountInfo = ResponseModel<ProfileModel>()
    @Published var errorMessage: String?
    @Published var requestType = ""


    // MARK: - Get Live Shows
    func getLiveShows(param:GetLiveShowsRequest) async {
        self.requestType = "get"
        do {
            let response: ResponseModelPaginate<[HomeModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLiveShows(param: param),
                header: true
            )
            self.liveShowsResponse = response
        } catch {
            handle(error)
        }
    }
    
    func getProfile() async {
        requestType = "get"
        do {
            let response: ResponseModel<ProfileModel> = try await APIManager.shared.request(
                type: APIEndPoint.getprofile,
                header: true
            )
            self.accountInfo = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Handle Error
    private func handle(_ error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
