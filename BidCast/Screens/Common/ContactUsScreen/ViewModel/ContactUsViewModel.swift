//
//  ContactUsViewModel.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//
import Foundation

final class ContactUsViewModel {
    
    var contactModelDict = ContactModel()
    var businessModelDict = BusinessModel()
    var updateBusineedModelDict = UpdateBusinessModel()
    var requestType = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func contactUs(parameters: ContactUsRequest) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ContactModel.self, // response type
            type: APIEndPoint.contact(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.contactModelDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    
    func getBusinessDetails() {
        requestType = "getBusinessDetails"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: BusinessModel.self, // response type
            type: APIEndPoint.getBusiness,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.businessModelDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
//    func createCompanyWithImage(parameters: BusinessModelParam, images: [URL]) {
//        self.eventHandler?(.loading)
//        
//
//
//            // Proceed with file upload
//            APIManager.shared.uploadFilePdf(
//                type: APIEndPoint.uploadFile, // Your endpoint type
//                fileURL: images,
//                mimeType: "application/pdf",
//                modalType: ResponseModal<[String]>.self, // Expected response model
//                header: true // Include headers if needed
//            ) { result in
//                switch result {
//                case .success(let response):
//                    print("File uploaded successfully: \(response)")
//                    // Handle success response
//                case .failure(let error):
//                    print("Failed to upload file: \(error.localizedDescription)")
//                    // Handle error
//                }
//            }
//
//    }

    func createCompanyWithImage(parameters: BusinessModelParam, images: [String]) {
        self.eventHandler?(.loading)
        APIManager.shared
            .uploadFile(
                type: APIEndPoint.uploadFile,
                urlArray: images,
                mimeType: "application/pdf",
                modalType: ResponseModal<[String]>.self,
                header: true,
                completion: {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            if data.status == "success" {
                                var newPara = parameters
                                newPara.file = data.data[0]
                                self.Business(parameters: newPara)
                            } else {
//                                self.Business(parameters: newPara)
                            }
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                })
    }
//
    
    func Business(parameters: BusinessModelParam) {
        requestType = "UpdateBusinessDetails"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: UpdateBusinessModel.self, // response type
            type: APIEndPoint.Business(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.updateBusineedModelDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

}


extension ContactUsViewModel {
    
    enum Event {
        case loading
        case stopLoading
        case dataLoaded
        case error(Error?)
        
    }
    
}

