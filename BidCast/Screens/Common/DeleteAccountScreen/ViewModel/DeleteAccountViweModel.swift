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
            let response: ResponseModal<[String]> = try await APIManager.shared.request(
                type: APIEndPoint.deleteAccount(param: param),
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
