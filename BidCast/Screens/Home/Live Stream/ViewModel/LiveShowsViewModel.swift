//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation


@MainActor
final class LiveShowsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var addressResponse = ResponseModel<AddressModel>()
    @Published var liveShowsResponse = ResponseModel<[LiveShowsModel]>()
    @Published var countResponse = countModel()
    @Published var errorMessage: String?
    @Published var BidResponse = ResponseModel<BidModel>()
    @Published var followDict = ResponseModel<FolloweModel>()
    @Published var categoriesResponse = ResponseModel<[SellerCategoryDetailsModel]>()
    @Published var reportSellerResponse = ResponseModel<[String?]>()
    @Published var requestType: String = ""
    @Published var titleStream : String = "Stream Ended"
    @Published var messageStream : String = "The live stream has ended."
    @Published var sellerInfo = ResponseModel<SellerInfoResponse>()
    
    // MARK: - Store Address
    func storeAddress(parameters: AddressRequest) async {
        requestType = "store"
        do {
            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.storeAddress(param: parameters),
                header: true
            )
            self.addressResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Get Live Shows
    func getLiveShows(param:GetLiveShowsRequest) async {
        requestType = "get"
        do {
            let response: ResponseModel<[LiveShowsModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLiveShows(param:param),
                header: true
            )
            self.liveShowsResponse = response
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
    
    func storeBid(parameters: StoreBidRequest) async {
        requestType = "store"
        do {
            let response: ResponseModel<BidModel> = try await APIManager.shared.request(
                type: APIEndPoint.storeBid(param: parameters),
                header: true
            )
            self.BidResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func followUnfollow(parameters: FollowRequest) async {
        do {
            self.requestType = "follow"
            if let response : ResponseModel<FolloweModel> = try await APIManager.shared.request(
                type: APIEndPoint.followUnfollow(param: parameters),
                header: true
           ) {
                followDict = response
           }
            
            // Refresh profile after follow/unfollow
//            await getProfile(param: ProfileParamRequest(id: parameters.following_id))
        } catch {
            handle(error: error)
        }
    }
    
    /// Get seller info safely. Uses SellerInfoRequest (which has `seller_id`).
    func getSellerInfo(sellerID: String) async throws  {
        let req = SellerInfoRequest(seller_id: sellerID)
        do {
            self.requestType = "sellerInfo"
            let response : ResponseModel<SellerInfoResponse> = try await APIManager.shared.request(
                type: APIEndPoint.getSellerInfo(param: req),
                header: true
            )
            self.sellerInfo = response
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

    
    /// Fetch all report categories (GET request)
    func getReportCategories() async throws {
        do {
            self.requestType = "reportCategories"

            let response: ResponseModel<[SellerCategoryDetailsModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getReportSellerCategory,
                header: true
            )

            self.categoriesResponse = response
        }
        catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            } else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    /// report seller API
    func reportSeller(request: SellerReportRequest) async throws {
        do {
            self.requestType = "reportSeller"

            let response: ResponseModel<[String?]> = try await APIManager.shared.request(
                type: APIEndPoint.reportSeller(param: request),
                header: true
            )
            self.reportSellerResponse = response
        }
        catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            } else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func handle(error: Error) {
        if let dataError = error as? DataError {
            switch dataError {
            case .invalidCode(let message):
                self.errorMessage = message ?? "Invalid code error"
            case .invalidResponse(let data):
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    self.errorMessage = "Invalid response: \(json)"
                    print(errorMessage)
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



import Foundation
import Combine

@MainActor
final class LiveShowsViewModel1: ObservableObject {

    // MARK: - Request kinds (replace stringly typed 'requestType')
    enum RequestKind: String {
        case none
        case storeAddress
        case getLiveShows
        case countUpdate
        case storeBid
        case followUnfollow
        case getSellerInfo
        case storeScheduleShow
        // add more as needed
    }

    // MARK: - Published state (optional where appropriate)
    @Published var addressResponse: ResponseModel<AddressModel>?
    @Published var liveShowsResponse: ResponseModel<[LiveShowsModel]>?
    @Published var countResponse: countModel?
    @Published var bidResponse: ResponseModel<BidModel>?
    @Published var followResponse: ResponseModel<FolloweModel>?
    @Published var sellerInfo: ResponseModel<SellerInfoResponse>?
    @Published var storeShowResponse: ResponseModel<HomeModel>?

    @Published var errorMessage: String?
    @Published var requestKind: RequestKind = .none

    // small UI strings - keep as simple state
    @Published var titleStream: String = "Stream Ended"
    @Published var messageStream: String = "The live stream has ended."

    // Keep track of inflight tasks so caller can cancel if needed
    private var inflightTasks: [RequestKind: Task<Void, Never>] = [:]

    // MARK: - Generic request helper
    /// Centralized wrapper around APIManager.request to reduce duplication.
    private func performRequest<T: Decodable>(
        endpoint: APIEndPoint,
        assignTo published: @escaping (ResponseModel<T>?) -> Void,
        for kind: RequestKind
    ) async {
        // Cancel previous same-kind task if present
        inflightTasks[kind]?.cancel()

        // Create a Task to allow cancellation
        let task = Task { @MainActor in
            self.requestKind = kind
            self.errorMessage = nil
        }

        inflightTasks[kind] = task

        await task.value // ensure initial state set (non-blocking)

        // Actual network call off the main actor (APIManager presumably is async)
        do {
            let response: ResponseModel<T> = try await APIManager.shared.request(
                type: endpoint,
                header: true
            )

            // Update UI on main actor
            await MainActor.run {
                published(response)
                self.errorMessage = nil
                self.requestKind = .none
            }
        } catch {
            await MainActor.run {
                if let dataError = error as? DataError {
                    self.errorMessage = dataError.getErrorMessage()
                } else {
                    self.errorMessage = error.localizedDescription
                }
                // reset requestKind so UI knows call finished
                self.requestKind = .none
            }
        }

        // remove inflight
        inflightTasks[kind] = nil
    }

    // MARK: - API functions (clean, safe patterns)

    func storeAddress(parameters: AddressRequest) {
        Task {
            await performRequest(
                endpoint: APIEndPoint.storeAddress(param: parameters),
                assignTo: { (r: ResponseModel<AddressModel>?) in self.addressResponse = r },
                for: .storeAddress
            )
        }
    }

    func getLiveShows(param: GetLiveShowsRequest) {
        Task {
            await performRequest(
                endpoint: APIEndPoint.getLiveShows(param: param),
                assignTo: { (r: ResponseModel<[LiveShowsModel]>?) in self.liveShowsResponse = r },
                for: .getLiveShows
            )
        }
    }

//    func CountUppdate(parameters: countRequest) {
//        Task {
//            await performRequest(
//                endpoint: APIEndPoint.countUpdate(param: parameters),
//                assignTo: { (r: countModel?) in self.countResponse = r },
//                for: .countUpdate
//            )
//        }
//    }

    func storeBid(parameters: StoreBidRequest) {
        Task {
            await performRequest(
                endpoint: APIEndPoint.storeBid(param: parameters),
                assignTo: { (r: ResponseModel<BidModel>?) in self.bidResponse = r },
                for: .storeBid
            )
        }
    }

    func followUnfollow(parameters: FollowRequest) {
        Task {
            await performRequest(
                endpoint: APIEndPoint.followUnfollow(param: parameters),
                assignTo: { (r: ResponseModel<FolloweModel>?) in self.followResponse = r },
                for: .followUnfollow
            )
        }
    }

    /// Get seller info safely. Uses SellerInfoRequest (which has `seller_id`).
    func getSellerInfo(sellerID: String) {
        let req = SellerInfoRequest(seller_id: sellerID)
        Task {
            await performRequest(
                endpoint: APIEndPoint.getSellerInfo(param: req),
                assignTo: { (r: ResponseModel<SellerInfoResponse>?) in
                    self.sellerInfo = r
                },
                for: .getSellerInfo
            )
        }
    }

    /// Upload + store schedule show (adapted style of your storeScheduleShow)
    func storeScheduleShow(param: [String: Any], images: [String], key: String) {
        // cancel previous storeScheduleShow if any
        inflightTasks[.storeScheduleShow]?.cancel()

        let task = Task { @MainActor in
            self.requestKind = .storeScheduleShow
            self.errorMessage = nil
        }
        inflightTasks[.storeScheduleShow] = task

        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                let response: ResponseModel<HomeModel>? = try await APIManager.shared.uploadImage(
                    type: APIEndPoint.storeScheduleShow,
                    urlArray: images,
                    mimeType: "image/jpeg",
                    keyName: key,
                    parameters: param,
                    modalType: ResponseModel<HomeModel>.self,
                    header: true
                )

                await MainActor.run {
                    self.storeShowResponse = response
                    self.requestKind = .none
                }
            } catch {
                await MainActor.run {
                    if let dataError = error as? DataError {
                        self.errorMessage = dataError.getErrorMessage()
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    self.requestKind = .none
                }
            }
            await MainActor.run {
                self.inflightTasks[.storeScheduleShow] = nil
            }
        }
    }

    // MARK: - Utility: cancel in-flight request for a kind
    func cancel(kind: RequestKind) {
        inflightTasks[kind]?.cancel()
        inflightTasks[kind] = nil
        Task { @MainActor in
            if self.requestKind == kind { self.requestKind = .none }
        }
    }
}
