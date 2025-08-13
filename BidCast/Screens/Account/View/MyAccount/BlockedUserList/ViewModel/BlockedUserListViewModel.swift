//
//  BlockedUserListViewModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 13/08/25.
//

import Foundation

@MainActor
final class BlockedUserListViewModel: ObservableObject {

    @Published var blockedUserListResponse = ResponseModel<[BlockedUserList]>()
    @Published var errorMessage: String? = nil

    func getBlockUser() async {
        do {
            let response: ResponseModel<[BlockedUserList]> = try await APIManager.shared.request(
                type: APIEndPoint.blockedUserList,
                header: true
            )
            self.blockedUserListResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
