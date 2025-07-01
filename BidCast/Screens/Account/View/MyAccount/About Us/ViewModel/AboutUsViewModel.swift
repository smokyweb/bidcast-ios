//
//  AboutUsViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import Foundation

@MainActor
final class AboutUsViewModel: ObservableObject {

    @Published var aboutResponse = ResponseModel<AboutUsModel>()
    @Published var errorMessage: String? = nil

    func getAboutContent() async {
        do {
            let response: ResponseModel<AboutUsModel> = try await APIManager.shared.request(
                type: APIEndPoint.aboutUs,
                header: true
            )
            self.aboutResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
