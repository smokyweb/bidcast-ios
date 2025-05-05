//
//  SavedScreenViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 29/01/24.
//

import Foundation

final class SavedScreenViewModal {
    
    var savedJob = JobResponseModal()
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    
    func getSavedJob(parameter: GetJobParameter) {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: JobResponseModal.self,
                type: APIEndPoint.getJob(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.savedJob = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
}
