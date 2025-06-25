//
//  NotificationViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class NotificationViewModel: ObservableObject {
    
    @Published var deleteNotiDict: ResponseModal<DeleteNotificationModel>?
    @Published var notiListingDict : ResponseModal<[NotificationListingModel]>?
    @Published var errorMessage: String? = nil
    
    var request: String = ""
    
    // MARK: - DeleteNotification
    func DeleteNotification(param: DeleteNotificationRequest) async {
        self.request = "DeleteNotification"
        do {
            let response: ResponseModal<DeleteNotificationModel> = try await APIManager.shared.request(
                type: APIEndPoint.deleteNotification(param: param),
                header: true
            )
            self.deleteNotiDict = response
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - GetNotification
    func GetNotification() async {
        self.request = "NotificationListing"
        do {
            let response: ResponseModal<[NotificationListingModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getNotificationListing,
                header: true
            )
            self.notiListingDict = response
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Centralized Error Handler
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
