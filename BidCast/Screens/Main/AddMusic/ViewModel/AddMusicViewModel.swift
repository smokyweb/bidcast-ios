//
//  AddMusicViewModel.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

final class AddMusicViewModel {
    
    //MARK: - variables
    enum RequestType {
        case getMusicList
        case deleteSong
        case addFinalMusic
        case none
    }
    
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none

    //MARK: musicListDict.
    var musicListDict : ResponseModel<[SongModel]?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    //MARK: deleteMusicDict.
    var deleteMusicDict : ResponseModel<DeleteMusicModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    //MARK: addFinalMusicDict.
    var addFinalMusicDict : ResponseModel<AddFinalMusicModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }

//    @MainActor
//    func getSongListData(parameters: SongRequest) {
//        Task { // @MainActor in
//            do {
//                let userResponseArray: ResponseModel<[SongModel]?>? = try await APIManager.shared.request(
//                    type: APIEndPoint.musicRequest(param: parameters),
//                    header: true)
//                self.requestType = .getMusicList
//                self.songListDict = userResponseArray
//              
//            }catch {
//                let dataError = error as? DataError
//                debugLog(error)
//                switch dataError {
//                case .errorMessage(let message):
//                    debugLog(message ?? "")
//                    self.userDelegate?.showError(error:message ?? "" )
//                case .invalidCode(let message):
//                    debugLog(message ?? "")
//                    self.userDelegate?.showError(error:message ?? "" )
//                case .invalidResponse(let data):
//                    debugLog(data)
//                    if let data = data{
//                        let  dataObj = try JSONSerialization.jsonObject(with: data, options: [])
//                        debugLog(dataObj)
//                    }
//                default: break
//                }
//            }
//        }
//    }
    
//    @MainActor
//    func deleteSongData(parameters: DeleteSongRequest) {
//        Task { // @MainActor in
//            do {
//                let userResponseArray: ResponseModel<DeleteMusicRequest>? = try await APIManager.shared.request(
//                    type: APIEndPoint.deleteMusicRequest(param: parameters),
//                    header: true)
//                self.requestType = .deleteSong
//                self.deleteSongDict = userResponseArray
//               
//            }catch {
//                let dataError = error as? DataError
//                debugLog(error)
//                switch dataError {
//                case .errorMessage(let message):
//                    debugLog(message ?? "")
//                    self.userDelegate?.showError(error:message ?? "" )
//                case .invalidCode(let message):
//                    debugLog(message ?? "")
//                    self.userDelegate?.showError(error:message ?? "" )
//                case .invalidResponse(let data):
//                    debugLog(data)
//                    if let data = data{
//                        let  dataObj = try JSONSerialization.jsonObject(with: data, options: [])
//                        debugLog(dataObj)
//                    }
//                default: break
//                }
//            }
//        }
//    }

    
//    @MainActor
//    func addFinalMusic(parameters: [addFinalMusicRequest]) {
//        Task { // @MainActor in
//            do {
//                let userResponseArray: ResponseModel<AddFinalMusicModel>? = try await APIManager.shared.request(
//                    type: APIEndPoint.addFinalMusic(request: parameters),
//                    header: true)
//                self.requestType = .addFinalMusic
//                self.addFinalMusicDict = userResponseArray
//               
//            }catch {
//                let dataError = error as? DataError
//                debugLog(error)
//                switch dataError {
//                case .errorMessage(let message):
//                    debugLog(message ?? "")
//                    self.userDelegate?.showError(error:message ?? "" )
//                case .invalidCode(let message):
//                    debugLog(message ?? "")
//                    self.userDelegate?.showError(error:message ?? "" )
//                case .invalidResponse(let data):
//                    debugLog(data)
//                    if let data = data{
//                        let  dataObj = try JSONSerialization.jsonObject(with: data, options: [])
//                        debugLog(dataObj)
//                    }
//                default: break
//                }
//            }
//        }
//    }
}


