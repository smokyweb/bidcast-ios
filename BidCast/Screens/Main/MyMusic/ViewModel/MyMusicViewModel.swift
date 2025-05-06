//
//  MyMusicViewModel.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

final class MyMusicViewModel {
    
    //MARK: - variables
    enum RequestType {
        case getCategory
        case getMusicList
        case deleteSong
        case addMusic
        case addAllMusic
        case addFinalMusic
        case deleteSongFromCategory
        case none
    }
    
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none
    
    var categoryDict : ResponseModel<[CategoryModel]?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var songListDict : ResponseModel<[SongModel]?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var deleteSongDict : ResponseModel<DeleteMusicModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var addMusicDict : ResponseModel<AddMusicModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var addAllMusic : ResponseModel<[AddAllMusicModel]>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var addFinalMusicDict : ResponseModel<AddFinalMusicModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var deleteSongFromCategoryDict : ResponseModel<deleteSongFromCategoryModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }


    @MainActor
    func getCategoryData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<[CategoryModel]?>? = try await APIManager.shared.request(
                    type: APIEndPoint.categories,
                    header: true)
                self.requestType = .getCategory
                self.categoryDict = userResponseArray
               
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
    func getSongListData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<[SongModel]?>? = try await APIManager.shared.request(
                    type: APIEndPoint.musicRequest,
                    header: true)
                self.requestType = .getMusicList
                self.songListDict = userResponseArray
              
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
    func deleteSongData(parameters: DeleteSongRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<DeleteMusicModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.deleteMusicRequest(param: parameters),
                    header: true)
                self.requestType = .deleteSong
                self.deleteSongDict = userResponseArray
               
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
    func deleteSongFromCategoryData(parameters: DeleteSongFromCategoryRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<deleteSongFromCategoryModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.deleteMusicFromCategoryRequest(param: parameters),
                    header: true)
                self.requestType = .deleteSongFromCategory
                self.deleteSongFromCategoryDict = userResponseArray
               
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
    func addSongData(param: [String: Any], keysValue: [String], mimeTypes:[String], musics: [[String]]?) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<AddMusicModel>? = try await APIManager.shared.uploadImageWithMultipleKeys(
                    type: APIEndPoint.addMusic(param: param),
                    urlArray: musics,
                    mimeType: mimeTypes,
                    keyName: keysValue,
                    parameters: param,
                    modelType: ResponseModel<AddMusicModel>?.self,
                    header: true)
                self.requestType = .addMusic
                self.addMusicDict = userResponseArray
               
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
    func addFinalMusic(parameters: [addFinalMusicRequest]) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<AddFinalMusicModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.addFinalMusic(request: parameters),
                    header: true)
                self.requestType = .addFinalMusic
                self.addFinalMusicDict = userResponseArray
               
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
    func addAllMusicData(param: [String: Any], keysValue: [String], mimeTypes:[String], musics: [[String]]?) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<[AddAllMusicModel]>? = try await APIManager.shared.uploadImageWithMultipleKeys(
                    type: APIEndPoint.addAllMusic,
                    urlArray: musics,
                    mimeType: mimeTypes,
                    keyName: keysValue,
                    parameters: param,
                    modelType: ResponseModel<[AddAllMusicModel]>?.self,
                    header: true)
                self.requestType = .addAllMusic
                self.addAllMusic = userResponseArray
               
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


