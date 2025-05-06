//
// NewAlarmViewModel.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

final class NewAlarmViewModel {
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    var NewAlarmStatusDict : ResponseModel<AlarmModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func newAlarmRequest(request: AlarmRequest)  {
        Task {
            do {
                let userResponseArray: ResponseModel<AlarmModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.NewAlarm(request: request),
                    header: true)
                self.NewAlarmStatusDict = userResponseArray
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


