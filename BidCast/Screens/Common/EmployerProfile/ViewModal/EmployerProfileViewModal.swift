//
//  EmployerProfileViewModal.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 12/02/24.
//

import Foundation

class EmployerProfileViewModal {
    
    var response: ResponseModal<EmployerProfileJobsModal>?
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    func getEmployerDetail(parameter: String) {
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<EmployerProfileJobsModal>.self,
                type: APIEndPoint.getCompanyDetailsJob(param: parameter),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.response = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
}
