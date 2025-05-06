//
//  EditProfileViewModel.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-174 on 19/09/24.
//

import Foundation

final class ProfileViewModel {
    
    enum RequestType {
        case getProfile
        case editProfile
        case none
    }
    
    var requestType: RequestType = .none
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    var getUserDict : ResponseModel<ProfileDataModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var editUserProfileDict : ResponseModel<EditProfileModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }

    @MainActor
    func getUserData(){
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<ProfileDataModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.getProfile,
                    header: true)
                self.requestType = .getProfile
                self.getUserDict = userResponseArray
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
        
    @MainActor
    func editProfileDetails(param: [String: Any], keysValue: [String], mimeTypes:[String], images: [[String]]?) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<EditProfileModel>? = try await APIManager.shared.uploadImageWithMultipleKeys(
                    type: APIEndPoint.updateProfile(param: param),
                    urlArray: images,
                    mimeType: mimeTypes,
                    keyName: keysValue,
                    parameters: param,
                    modelType: ResponseModel<EditProfileModel>?.self,
                    header: true)
                self.requestType = .editProfile
                self.editUserProfileDict = userResponseArray
            }catch {
                let dataError = error as? DataError
                debugLog(error)
                switch dataError {
                case .errorMessage(let message):
                    debugLog(message ?? "")
                    self.userDelegate?.showError(error:message ?? "" )
                case .invalidCode(let message):
                    debugLog(message ?? "")
                    self.userDelegate?.showError(error:message ?? "" )
                case .invalidResponse(let data):
                    debugLog(data)
                    if let data = data{
                        let  dataObj = try JSONSerialization.jsonObject(with: data, options: [])
                        debugLog(dataObj)
                    }
                default: break
                }
            }
        }
    }
}



