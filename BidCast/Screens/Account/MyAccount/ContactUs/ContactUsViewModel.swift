//
//  ContactUsViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//
import Foundation
import Foundation

@MainActor
final class ContactUsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var contactModel = ContactModel()
    @Published var businessModel = BusinessModel()
    @Published var updateBusinessModel = UpdateBusinessModel()
    @Published var errorMessage: String?
    @Published var requestType = ""

    // MARK: - Contact Us API
    func contactUs(parameters: ContactUsRequest) async {
        do {
            let response: ContactModel = try await APIManager.shared.request(
                type: APIEndPoint.contact(param: parameters),
                header: true
            )
            self.contactModel = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Get Business Details
    func getBusinessDetails() async {
        do {
            self.requestType = "getBusinessDetails"
            let response: BusinessModel = try await APIManager.shared.request(
                type: APIEndPoint.getBusiness,
                header: true
            )
            self.businessModel = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Update/Create Business
    func updateBusiness(parameters: BusinessModelParam) async {
        do {
            self.requestType = "UpdateBusinessDetails"
            let response: UpdateBusinessModel = try await APIManager.shared.request(
                type: APIEndPoint.Business(param: parameters),
                header: true
            )
            self.updateBusinessModel = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Centralized Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
