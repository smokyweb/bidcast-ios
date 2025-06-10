//
//  PreferenceViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 02/06/25.
//

import Foundation

@MainActor
final class PreferenceViewModel: ObservableObject {
    
    @Published var preferenceResponse = ResponseModel<PreferenceDataModel>()
    @Published var errorMessage: String? = nil

    // MARK: - Get Preference
    func getPreferenceContent() async {
        do {
            let response: ResponseModel<PreferenceDataModel> = try await APIManager.shared.request(
                type: APIEndPoint.getPreference,
                header: true
            )
            self.preferenceResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Update Preference
    func updatePreference(parameters: UpdatePreferenceRequest) async {
        do {
            let response: ResponseModel<PreferenceDataModel> = try await APIManager.shared.request(
                type: APIEndPoint.updatePreference(param: parameters),
                header: true
            )
            self.preferenceResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
