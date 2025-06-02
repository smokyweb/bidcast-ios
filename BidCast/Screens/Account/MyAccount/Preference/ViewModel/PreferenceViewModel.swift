//
//  PreferenceViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 02/06/25.
//

import Foundation

final class PreferenceViewModel : ObservableObject {
    
    var preferenceResponceDict : ResponseModal<PreferenceDataModel>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func getPreferenceContent(){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<PreferenceDataModel>.self, // response type
            type: APIEndPoint.getPreference,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.preferenceResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

    //MARK: updatePreference.
    func updatePreference(parameters: UpdatePreferenceRequest) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<PreferenceDataModel>.self,
            type: APIEndPoint.updatePreference(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.preferenceResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}



