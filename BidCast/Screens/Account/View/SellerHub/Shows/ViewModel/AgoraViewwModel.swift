
//
//  ShowsViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//
import Foundation

@MainActor
final class AgoraViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var getAgoraDict: ResponseModel<GetAgoraModel>?
    
    @Published var errorMessage: String? = nil
    @Published var requestType: String = ""
    
    // MARK: - Get Lessons
//    func getAgoraToken(param: AgoraTokenRequest) async {
    func getAgoraToken(param: [String: Any]) async {
        requestType = "agoraToken"
//        do {
//            let response: ResponseModel<GetAgoraModel>? = try await APIManager.shared.request(
//                type: APIEndPoint.getAgoraToken(param: param),
//                header: true
//            )
//            getAgoraDict = response
//        } catch {
//            handle(error: error)
//        }
        
        do {
            let response: ResponseModel<GetAgoraModel>? = try await APIManager.shared.uploadImageWithMultipleKeys(
                type: APIEndPoint.getAgoraToken,
                urlArray: nil,
                mimeType: [],
                keyName: [],
                parameters: param,
                modelType: ResponseModel<GetAgoraModel>?.self,
                header: false
            )
            self.getAgoraDict = response
        } catch {
            handle(error: error)
        }
    }
    
    private func handle(error: Error) {
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
