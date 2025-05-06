//
//  getDeviceDetailsViewModel.swift
//  BidCast
//
//  Created by JAM-E-174 on 25/09/24.
//


import Foundation

final class DeviceDetailsViewModel {
    
    enum RequestType {
        case saveDeviceDetail
        case none
    }
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none
    
    //MARK: - alarmDict
    var deviceDetailDict : ResponseModel<DeviceDetailModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
        
    @MainActor
    func saveDeviceData(parameters: DeviceDetailParam) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<DeviceDetailModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.sendDeviceDetails(param: parameters),
                    header: true)
                self.requestType = .saveDeviceDetail
                self.deviceDetailDict = userResponseArray
            }catch(let error) {
                if let dataError = error as? DataError {
                    let errorMessage = dataError.getErrorMessage()
                    self.userDelegate?.showError(error: errorMessage)
                }
                else {
                    self.userDelegate?.showError(error: error.localizedDescription)
                }
            }
        }
    }
}
