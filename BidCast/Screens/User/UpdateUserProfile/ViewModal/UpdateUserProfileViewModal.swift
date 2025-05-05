//
//  UpdateUserProfileViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 30/01/24.
//

import Foundation

final class UpdateUserProfileViewModal {
    
    var response: ResponseModal<Int>?
    
    //MARK: - Response Collection
    var skillResponse: ResponseModal<[UserSkillResponseModal]>?
    var createJobResponse: ResponseModal<WorkHistory>?
    var profileInfoResponse: ResponseModal<SignInData>?
    var jobCategoryResponse: ResponseModal<[JobCategoriesListModal]>?
    var qualificationResponse: ResponseModal<[QualificationResponse]>?
    var educationResponse: ResponseModal<[EducationResponse?]>?
    var languageListResponse: ResponseModal<[JobResponse]>?
    var langUpdResponse: ResponseModal<[UserSkillResponseModal]>?
    var userDetailResponse: ResponseModal<UserDetailModal>?
    
    //MARK: - Event Handler to Screen
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    

    var requestType = ""
    
    //MARK: - Get Detail
    func getDetail() {
        self.eventHandler?(.loading)
        self.requestType = "GetDetail"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<UserDetailModal>.self,
                type: APIEndPoint.getProfile,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.userDetailResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }

    //MARK: - Update Employee Skill
    func updateEmployeeSkill(parameter: [Skill]) {
        self.eventHandler?(.loading)
        self.requestType = "UpdateEmployeeSkill"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[UserSkillResponseModal]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(skills: parameter, type: "skills")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.skillResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Update Employee Liceses and Certificates
    func updateEmployeeLicCer(parameter: [LicenseCertification]) {
        self.requestType = "UpdateVolunteer"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[UserSkillResponseModal]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(license_certifications: parameter, type: "license_certifications")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.skillResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Update Employee Voluntory Work Experience
    func updateEmployeeVolExp(parameter: [VolunteerExperience]) {
        self.requestType = "UpdateVolunteer"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[UserSkillResponseModal]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(volunteer_experiences: parameter, type: "volunteer_experiences")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.skillResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Create Employee Work History
    func createEmployeeWorkHistory(parameter: CreateWorkHistory) {
        self.eventHandler?(.loading)
        self.requestType = "CreateEmployeeWorkHistory"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<WorkHistory>.self,
                type: APIEndPoint.createWorkHistory(param: parameter),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.createJobResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Upload Image
    func uploadImages(parameter: [String]) {
        self.eventHandler?(.loading)
        self.requestType = "UploadImages"
        DispatchQueue.global(qos: .background).async {
            APIManager.shared
                .uploadFile(
                    type: APIEndPoint.uploadFile,
                    urlArray: parameter,
                    mimeType: "image/png",
                    modalType: ResponseModal<[String]>.self,
                    header: true,
                    completion: {
                        result in
                        switch result {
                        case .success(let data):
                            var images: [Imagee] = []
                            data.data.forEach { img in
                                images.append(Imagee(image: img))
                            }
                            self.addImageToProfile(parameter: images)
                        case .failure(let error):
                            self.eventHandler?(.stopLoading)
                            self.eventHandler?(.error(error))
                        }
                    })
        }
    }
    
    //MARK: - Add Image to Profile
    func addImageToProfile(parameter: [Imagee]) {
        self.requestType = "AddImageToProfile"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[UserSkillResponseModal]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(images: parameter, type: "images")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.skillResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Update Profile Info
    func updateProfileInfo(parameter: [UserPersonalInfo]) {
        self.requestType = "UpdateProfileInfo"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<SignInData>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(profile_info: parameter, type: "profile_info")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.profileInfoResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Job Profile List
    func getJobProfileList() {
        self.requestType = "GetJobProfile"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[JobCategoriesListModal]>.self,
                type: APIEndPoint.getJobProfile,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.jobCategoryResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Update Employee Interested Job
    func updateEmployeeInterestedJob(parameter: [InterestedJob]) {
        self.requestType = "UpdateEmployeeInterestedJob"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[UserSkillResponseModal]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(interested_jobs: parameter, type: "interested_jobs")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.skillResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Update Employee Work History
    func updateEmployeeWorkHistory(parameter: [CreateWorkHistory], mrJt: String, mrC: String) {
        self.requestType = "UpdateEmployeeWorkHistory"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[UserSkillResponseModal]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(work_histories: parameter, type: "work_histories")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.skillResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Qualification List
    func getQualification() {
        self.requestType = "GetQualification"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[QualificationResponse]>.self,
                type: APIEndPoint.getQualification,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.qualificationResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    //MARK: - Update Employee Education
    func updateEmployeeEducation(parameter: [EmployeeEducationRequest]) {
        self.requestType = "UpdateEmployeeEducation"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[EducationResponse?]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(education: parameter, type: "education")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.educationResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                    }
                }
    }
    
    //MARK: - Language List
    func getLanguageList() {
        self.requestType = "GetLanguageList"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[JobResponse]>.self,
                type: APIEndPoint.getLanguage,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.languageListResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                    }
                }
    }
    
    //MARK: - Update Employee Language
    func updateEmployeeLanguage(parameter: [EmpLanguageRequest]) {
        self.requestType = "UpdateEmployeeLanguage"
        self.eventHandler?(.loading)
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[UserSkillResponseModal]>.self,
                type: APIEndPoint.updateProfile(param: UpdateUserRequest(languages: parameter, type: "languages")),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.langUpdResponse = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
}
