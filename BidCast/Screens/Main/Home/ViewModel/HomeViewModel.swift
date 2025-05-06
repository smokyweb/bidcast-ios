//
//  HomeViewModel.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

final class HomeViewModel {
    
    enum RequestType {
        case getAlarm
        case deleteAlarm
        case changeAlarmStatus
        case getWeather
        case getCurrentWeather
        case none
    }

    
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    
    var requestType: RequestType = .none
    
    //MARK: - alarmDict
    var alarmDict : ResponseModel<[AlarmModel]?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    //MARK: - changeAlarmStatusDict
    var changeAlarmStatusDict : ResponseModel<AlarmModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    //MARK: - deleteAlarmDict
    var deleteAlarmDict : ResponseModel<deleteAlarmModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    //MARK: - weatherDict
    var weatherDict : ResponseModel<weatherModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    //MARK: - getCurrentWeatherDict
    var getCurrentWeatherDict : ResponseModel<CurrentWeatherModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    
    
    @MainActor
    func getAlarmData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<[AlarmModel]?>? = try await APIManager.shared.request(
                    type: APIEndPoint.alarm,
                    header: true)
                self.requestType = .getAlarm
                self.alarmDict = userResponseArray
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
    
    
    @MainActor
    func getCurrentWeatherData(parameters: CurrentWeatherRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<CurrentWeatherModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.getCurrentWeather(param: parameters),
                    header: true)
                self.requestType = .getCurrentWeather
                self.getCurrentWeatherDict = userResponseArray
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
    
    @MainActor
    func changeAlarmRequest(parameters: changeAlarmRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<AlarmModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.changeAlarmStatus(param: parameters),
                    header: true)
                self.requestType = .changeAlarmStatus
                self.changeAlarmStatusDict = userResponseArray
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
    func deleteAlarmData(parameters: deleteAlarmRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<deleteAlarmModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.deleteAlarmRequest(param: parameters),
                    header: true)
                self.requestType = .deleteAlarm
                self.deleteAlarmDict = userResponseArray
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
    func getWeatherData(){
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<weatherModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.getWeather,
                    header: true)
                self.requestType = .getWeather
                self.weatherDict = userResponseArray
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


