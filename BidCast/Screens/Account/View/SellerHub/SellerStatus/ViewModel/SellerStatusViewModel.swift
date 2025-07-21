//
//  SellerStatusViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

@MainActor
final class SellerStatusViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var sellerStatusResponse: ResponseModel<SellerDataModel>?
    @Published var errorMessage: String? = nil
    @Published var countResponse = countModel()
    @Published var requestType: String = ""
    
    // MARK: - Get Lessons
    func getSellerStatus() async {
        requestType = "lesson"
        do {
            if let response: ResponseModel<SellerDataModel> = try await APIManager.shared.request(
                type: APIEndPoint.sellerStatus,
                header: true
            ){
                sellerStatusResponse = response
            }
        } catch {
            handle(error: error)
        }
    }
    
   
    
    func handle(error: Error) {
        errorMessage = error.localizedDescription
    }
}
