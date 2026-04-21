//
//  DeleteAccountViweModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 01/03/24.
//

import Foundation

@MainActor
final class DeleteAccountViewModel: ObservableObject {
    
    @Published var deleteResponseDict: ResponseModal<[String]>?
    @Published var errorMessage: String?
    
    func postDeleteRequest(param: DeleteParam) async {
        do {
            // Backend expects multipart/form-data (reason="...") like curl example.
            let parameters: [String: Any] = ["reason": param.reason ?? ""]
            let response: ResponseModal<[String]> = try await APIManager.shared.uploadImage1(
                type: APIEndPoint.deleteAccount(param: param),
                urlArray: nil,
                mimeType: "text/plain",
                keyName: "reason",
                parameters: parameters,
                modalType: ResponseModal<[String]>.self,
                header: true
            )
            self.deleteResponseDict = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

struct DeleteParam: Codable {
    var reason: String?
}
