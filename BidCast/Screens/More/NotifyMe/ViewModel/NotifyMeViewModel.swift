//
//  NotifyMeViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation


@MainActor
final class NotifyMeViewModel: ObservableObject {
    
    @Published var notifyLiveUserResponseDict: ResponseModal<[String]>?
    @Published var errorMessage: String? = nil
    
    func notifyLiveUser(parameter: NotifyLiveUserRequest) async {
        do {
            let response: ResponseModal<[String]> = try await APIManager.shared.request(
                type: APIEndPoint.notifyLiveUser(param: parameter),
                header: true
            )
            notifyLiveUserResponseDict = response
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


