//
//  UploadVideoViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 31/01/24.
//

import Foundation

final class UploadVideoViewModal {
    
    var response: ResponseModal<UserDetailModal>?
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    func uploadVideo(videoURL: String) {
        self.eventHandler?(.loading)
        DispatchQueue.global(qos: .background).async {
            APIManager.shared
                .uploadFile(
                    type: APIEndPoint.uploadFile,
                    urlArray: [videoURL],
                    mimeType: "VIDEO/MOV",
                    modalType: ResponseModal<[String]>.self,
                    header: true,
                    completion: {
                        result in
                        self.eventHandler?(.stopLoading)
                        switch result {
                            case .success(let data):
                                self.updateEmployeeVideoResume(url: data.data.first ?? "")
                            case .failure(let error):
                                self.eventHandler?(.error(error))
                        }
                    })
        }
    }
    
    func updateEmployeeVideoResume(url: String) {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<UserDetailModal>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(video_resume: url, type: "video_resume")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.response = data
                            self.eventHandler?(.dataLoaded)
                            return
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                            return
                            
                    }
                }
    }
}
