//
//  ProductEndPoint.swift
//  Youtube MVVM Products
//
//  Created by Yogesh Patel on 15/01/23.
//

import Foundation

enum APIEndPoint {
    case login (param : LoginRequest)
    case singUp (param : RegisterRequest)
    case verifyUser (param : CreateUserRequest)

    case verifyOTP (param : VerifyOtpRequest)
    case resetPassword (param : ResetPasswordRequest)
    case forgotPassword (param : ForgetRequest)
    case updateProfile (param : UpdateUserRequest)
    case SubCompany(param : SubCompanyParam)
    case SubCompanyUpdate(param : SubCompanyParamUpdate)

    case uploadFile
    case getProfile
    case getCategories
    case aboutUs
    case get_news
    case privacyPolicy
    case getBusiness
    case contact (param : ContactModelParam)
    case Business (param : BusinessModelParam)
    case logout (device_token: String)
    case createUserProfile (param: CreateUserProfSection)
    case getJob (param: GetJobParameter)
    case upsertJob (param: JobUpsertParamter)
    case jobSwipe (param: JobSwipePatamter)
    case createWorkHistory (param: CreateWorkHistory)
    case getJobProfile
    case getEmployeeList(param: SearchRequest)
    case getEmployeeListByJobId(param: SearchRequestByJobId)
    case welcome
    case getEmployeeByJobId(param: EmployeeJobIdRequest)
    case getQualification
    case termsOfService
    case searchJob(param: SearchRequest)
    case getLanguage
    case performActionJob(param: PerformJobActionRequest)
    case setEmployerAvailability(param: EmployerAvailabilityRequest)
    case employerSchedule(param: EmployerScheduleRequest)
    case getEmployerAvailability
    case getSalaryType
    case getScheduledInterview(param: String)
    case getSubCompanyDetails(param: String)
    case deleteSubCompanyUser(param: DeleteCompanyUserParam)
    case UpdateSubCompanyUser(param: SubCompanyUserParam)

    case getSubCompany(param : String)

    case saveJob(param: SaveJobRequest)
    case getSavedJob
    case getSubCompanyUser

    case applyJob(param: SaveJobRequest)
    case getMatches(param: String?)
    case getMatchesCandidates(page: Int, job_id:Int)

    case scheduleInterviewForMatchedJob(param: ScheduleInterviewRequest)
    case getCompanyDetailsJob(param: String)
    case getSpecificJobDetail(param: String)
    case saveDeviceDetail(param: DeviceDetailModal)
    case getEmployeeDetail(id: String, job: String)
    case getNotification(param: String)
    case deleteNotification(param:String)
    case updateNotification(param: ReadNotification)
    case getNotificationCount
    case getEmploymentLocationType
    case cheduledInterviewlList
    case deleteJob(param: String)
    case deleteAccount(param:DeleteParam)
    case combineData
    case checkLinkedIn(param: String)
    case rescheduleInterviewStatus
    case getInterviewDetail(param: String)
    case updateInterviewStatus(statusId: String, matchId: String)
    case rejectJob(param: SaveJobRequest)
    case linkLinkedIn(param: LinkedInLinkModel)
    case CreateEvent(param: CreateEventParam)
    case linkedInConnect(param: LinkedInURL)
    case storeLinkedIn(param: LinkedInUserDetail)
    case upsertCompany(param: CreateCompanyRequest)
    case subscription(param: SubscriptionRequestModal)
    case SaveRightSwipe(param: RightSwipeRequestModal)
    case getProductEmployer
    case getProductCandidate
    case getCompanyName
    case filterSearch(param: FilterRequestModal)
    case filterJobSearch(param: FilterRequestModal)
    case removeSavedJob(param: RemoveSaveJobRequest)
}

extension APIEndPoint: EndPointType {
    
    var baseURL: String {
        return "https://backend.imperiumjob.com/api/"
    }
    var url: URL? {
        return URL(string: "\(baseURL)\(path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
    
    var path: String {
        switch self {
            case .login:
                return "login"
            case .singUp:
                return "register"
        case .verifyUser:
            return "verify-user-name"
            case .verifyOTP:
                return "verify_otp"
            case .resetPassword:
                return "reset_password"
            case .forgotPassword:
                return "forgot_password"
            case .getProfile:
                return "get_user_details"
            case .getCategories:
            return "get-categories-list"
            case .updateProfile:
                return "update_user"
            case .SubCompany:
            return "assign-user-access"
        case .SubCompanyUpdate:
        return "assign-user-access"
            case .uploadFile:
                return "file/upload"
            case .contact:
                return "contact_us"
            case .Business:
            return "upload-employer-doc"
            case .privacyPolicy:
                return "privacy-policy"
            case .getBusiness:
            return "get-employer-business-doc"
            case .getEmployerAvailability:
                return "get-employer-availability"
            case .aboutUs:
                return "about_us"
            case .get_news:
                return "get_news"
            case .logout(let token):
                return "logout?device_token=\(token)"
            case .createUserProfile:
                return "update_user_profile"
            case .getJob(let param):
                return "get_jobs?type=\(param.type)&search=\(param.search)&page=\(param.currentPage)"
            case .upsertJob:
                return "upsert_job"
            case .jobSwipe:
                return "swipe_job"
            case .createWorkHistory:
                return "create-work-history"
            case .getJobProfile:
                return "get-jobProfiles-list"
            case .getEmployeeList(let param):
                return "get_employees?search=\(param.search)&page=\(param.page)"
            case .getEmployeeListByJobId(let param):
                return "search-employee?search=\(param.search)&job_id=\(param.job_id)"
            case .welcome:
                return "video-link/get-videos"
            case .getEmployeeByJobId(let param):
                return "get-employee-list?job_id=\(param.job_id)&status=\(param.status)"
            case .getQualification:
                return "get-qualification-list"
            case .termsOfService:
                return "terms-of-service"
            case .searchJob(let param):
                return "get_jobs?type=\(param.type)&search=\(param.search)&page=\(param.page)"
            case .getLanguage:
                return "get-languages-list"
            case .performActionJob:
                return "perform-action"
            case .setEmployerAvailability:
                return "set-employer-availability"
            case .employerSchedule:
                return "employer-schedule"
            case .getSalaryType:
                return "get-salary-type"
            case .getScheduledInterview(let param):
                return "scheduled-interview-list?page=\(param)"
            case .getSubCompanyDetails(let param):
            return "get-assign-user?page=\(param)"
        case .deleteSubCompanyUser:
        return "update-user-status"
        case .UpdateSubCompanyUser:
        return "update-user-profile"
        case .getSubCompany(let param):
        return "sub-company-details?user_id=\(param)"
            case .saveJob:
                return "save-job"
            case .getSavedJob:
                return "get-saved-job"
        case .getSubCompanyUser:
            return "sub-company-details"
            case .applyJob:
                return "apply-job"
            case .getMatches(let param):
                return param == "0" ? "get-matches" : "get-matches?page=\(param ?? "1")"
            case .scheduleInterviewForMatchedJob:
                return "schedule-interview"
            case .getCompanyDetailsJob(let param):
                return "get-company-job/\(param)"
            case .getSpecificJobDetail(let param):
                return "get-job-details/\(param)"
            case .saveDeviceDetail:
                return "device-details"
            case .getEmployeeDetail(let id, let jobId):
                return "get_user_details?id=\(id)&job_id=\(jobId)"
            case .getMatchesCandidates(let page, let job_id):
            return "get-matches?page=\(page)&job_id=\(job_id)"
            case .getNotification(let param):
                return "get-notification?page=\(param)"
            case .deleteNotification(let id):
                return id != "" ? "delete-notification?id=\(id)" : "delete-notification"
            case .updateNotification:
                return "update-notification-status"
            case .getNotificationCount:
                return "count-unread-notification"
            case .getEmploymentLocationType:
                return "employment-location-type"
            case .cheduledInterviewlList:
                return "cheduled-interview-list"
            case .deleteAccount:
                return "delete-account"
            case .deleteJob(let param):
                return "delete-job/\(param)"
            case .combineData:
                return "merged-details"
            case .checkLinkedIn(let param):
                return "checkLinkedInAccount?code=\(param)"
            case .rescheduleInterviewStatus:
                return "update-status-Employee"
            case .getInterviewDetail(let param):
                return "get-interview-detail-by-id/\(param)"
            case .updateInterviewStatus(let statusId, let matchId):
                return "update-interview-status?status=\(statusId)&match_id=\(matchId)"
            case .rejectJob(let param):
                return "reject-job?job_id=\(param.job_id)"
            case .linkLinkedIn:
                return "link-profile-linkedIn"
            case .CreateEvent:
            return "store-access-token"
            case .linkedInConnect:
                return "get-user-details-linkedIn"
            case .storeLinkedIn:
                return "store-linkedIn-details"
            case .upsertCompany:
                return "upsert-company"
            case .subscription:
                return "subscribe"
            case .SaveRightSwipe:
            return "purchase-right-swipes"
            case .getCompanyName:
                return "get-company-name"
        case .getProductEmployer:
            return "get-subscription-plans"
        case .getProductCandidate:
            return "get-product-list"
            case .filterSearch:
                return "search"
        case .filterJobSearch(let param):
            return "get_jobs?category=\(param.category)&job_title=\(param.job_title)&salary=\(param.salary)"
            case .removeSavedJob:
                return "save-job"
        }
    }
    
    var method: HTTPMethods {
        switch self {
            case .login:
                return .post
            case .singUp:
                return .post
        case .verifyUser:
            return .post
            case .resetPassword:
                return .post
            case .forgotPassword:
                return .post
            case .verifyOTP:
                return .post
            case .getProfile:
                return .get
        case .getCategories:
            return .get
            case .updateProfile:
                return .post
        case .SubCompany:
            return .post
        case .SubCompanyUpdate:
            return .post
            case .uploadFile:
                return .post
            case .aboutUs:
                return .get
            case .contact:
                return .post
        case .Business:
            return .post
            case .privacyPolicy:
                return .get
        case .getBusiness:
            return .get
            case .getEmployerAvailability:
                return .get
            case .logout:
                return .get
            case .createUserProfile:
                return .post
            case .getJob:
                return .get
            case .upsertJob:
                return .post
            case .jobSwipe:
                return .post
            case .get_news:
                return .get
            case .createWorkHistory:
                return .post
            case .getJobProfile:
                return .get
            case .welcome:
                return .get
            case .getEmployeeList:
                return .get
        case .getEmployeeListByJobId:
            return .get
            case .getEmployeeByJobId:
                return .get
            case .getQualification:
                return .get
            case .termsOfService:
                return .get
            case .searchJob:
                return .get
            case .getLanguage:
                return .get
            case .performActionJob:
                return .post
            case .setEmployerAvailability:
                return .post
            case .getMatchesCandidates:
            return .get
            case .employerSchedule:
                return .post
            case .getSalaryType:
                return .get
            case .getScheduledInterview:
                return .get
            case .getSubCompanyDetails:
            return .get
        case .getSubCompany:
        return .get
            case .saveJob:
                return .post
            case .getSavedJob:
                return .get
        case .getSubCompanyUser:
            return .get
            case .applyJob:
                return .post
            case .getMatches:
                return .get
            case .scheduleInterviewForMatchedJob:
                return .post
            case .getCompanyDetailsJob:
                return .get
            case .getSpecificJobDetail:
                return .get
            case .saveDeviceDetail:
                return .post
            case .getEmployeeDetail:
                return .get
            case .getNotification:
                return .get
            case .deleteNotification:
                return .post
            case .updateNotification:
                return .post
            case .getNotificationCount:
                return .get
            case .getEmploymentLocationType:
                return .get
            case .cheduledInterviewlList:
                return .get
            case .deleteAccount:
                return .post
        case .deleteSubCompanyUser:
            return .post
        case .UpdateSubCompanyUser:
            return .post
            case .deleteJob:
                return .post
            case .combineData:
                return .get
            case .checkLinkedIn:
                return .get
            case .rescheduleInterviewStatus:
                return .post
            case .getInterviewDetail:
                return .get
            case .updateInterviewStatus:
                return .get
            case .rejectJob:
                return .post
            case .linkLinkedIn:
                return .post
            case .CreateEvent:
                return .post
            case .linkedInConnect:
                return .post
            case .storeLinkedIn:
                return .post
            case .upsertCompany:
                return .post
            case .subscription:
                return .post
            case .SaveRightSwipe:
            return .post
            case .getCompanyName:
                return .post
        case .getProductEmployer:
            return .get
        case .getProductCandidate:
            return .get
            case .filterSearch:
                return .post
        case .filterJobSearch:
            return .get
            case .removeSavedJob:
                return .post
        }
    }
    
    var body: Encodable? {
        switch self {
            case .login(let param):
                return param
            case .singUp(let param):
                return param
        case .verifyUser(let param):
            return param
            case .verifyOTP(let param):
                return param
            case .resetPassword(let param):
                return param
            case .forgotPassword(let param):
                return param
            case .getProfile:
                return nil
        case .getCategories:
            return nil
            case .updateProfile(let param):
                return param
        case .SubCompany(let param):
            return param
        case .SubCompanyUpdate(let param):
            return param
            case .uploadFile:
                return nil
            case .aboutUs:
                return nil
            case .contact(let param):
                return param
        case .Business(let param):
            return param
            case .privacyPolicy:
                return nil
        case .getBusiness:
            return nil
            case .getEmployerAvailability:
                return nil
            case .logout:
                return nil
            case .createUserProfile(let param):
                return param
            case .getJob:
                return nil
            case .upsertJob(let param):
                return param
            case .jobSwipe(let param):
                return param
            case .get_news:
                return nil
            case .createWorkHistory(let param):
                return param
            case .getJobProfile:
                return nil
            case .welcome:
                return nil
            case .getEmployeeList:
                return nil
        case .getEmployeeListByJobId:
            return nil
            case .getEmployeeByJobId:
                return nil
            case .getQualification:
                return nil
            case .termsOfService:
                return nil
            case .searchJob:
                return nil
            case .getLanguage:
                return nil
            case .performActionJob(let param):
                return param
            case .setEmployerAvailability(let param): 
                return param
            case .employerSchedule(let param):
                return param
            case .getSalaryType:
                return nil
            case .getScheduledInterview:
                return nil
        case .getSubCompanyDetails:
            return nil
        case .getSubCompany:
            return nil
            case .saveJob(let param):
                return param
            case .getSavedJob:
                return nil
        case .getSubCompanyUser:
            return nil
            case .applyJob(let param):
                return param
            case .getMatches:
                return nil
            case .scheduleInterviewForMatchedJob(let param):
                return param
            case .getCompanyDetailsJob:
                return nil
            case .getSpecificJobDetail:
                return nil
            case .saveDeviceDetail(let param):
                return param
            case .getEmployeeDetail:
                return nil
        case .getMatchesCandidates:
            return nil
            case .getNotification:
                return  nil
            case .deleteNotification:
                return nil
            case .updateNotification(let param):
                return param
            case .getNotificationCount:
                return nil
            case .getEmploymentLocationType:
                return nil
            case .cheduledInterviewlList:
                return nil
            case .deleteAccount(let param):
                return param
        case .deleteSubCompanyUser(let param):
            return param
        case .UpdateSubCompanyUser(let param):
            return param
            case .deleteJob:
                return nil
            case .combineData:
                return nil
            case .checkLinkedIn:
                return nil
            case .rescheduleInterviewStatus:
                return nil
            case .getInterviewDetail:
                return nil
            case .updateInterviewStatus:
                return nil
            case .rejectJob:
                return nil
            case .linkLinkedIn(let param):
                return param
            case .CreateEvent(let param):
               return param
            case .linkedInConnect(let param):
                return param
            case .storeLinkedIn(let param):
                return param
            case .upsertCompany(let param):
                return param
            case .subscription:
                return nil
            case .SaveRightSwipe:
            return nil
            case .getCompanyName:
                return nil
        case .getProductEmployer:
            return nil
        case .getProductCandidate:
            return nil
            case .filterSearch(let param):
                return param
        case .filterJobSearch:
            return nil
            case .removeSavedJob(let param):
                return param
        }
    }
    
    var jsonBody: [String : Any]? {
        switch self {
            case .login:
                return nil
            case .singUp:
                return nil
        case .verifyUser:
            return nil
            case .verifyOTP:
                return nil
            case .resetPassword:
                return nil
            case .forgotPassword:
                return nil
            case .getProfile:
                return nil
           case .getCategories:
            return nil
            case .updateProfile:
                return nil
            case .uploadFile:
                return nil
            case .aboutUs:
                return nil
            case .contact:
                return nil
        case .Business:
            return nil
            case .privacyPolicy:
                return nil
        case .getBusiness:
            return nil
            case .getEmployerAvailability:
                return nil
            case .logout:
                return nil
            case .createUserProfile:
                return nil
            case .getJob:
                return nil
            case .upsertJob:
                return nil
            case .jobSwipe:
                return nil
            case .get_news:
                return nil
            case .createWorkHistory:
                return nil
            case .getJobProfile:
                return nil
            case .getEmployeeList:
                return nil
        case .getEmployeeListByJobId:
            return nil
            case .welcome:
                return nil
            case .getEmployeeByJobId:
                return nil
            case .getQualification:
                return nil
            case .termsOfService:
                return nil
            case .searchJob:
                return nil
            case .getLanguage:
                return nil
            case .performActionJob:
                return nil
            case .setEmployerAvailability:
                return nil
            case .employerSchedule:
                return nil
            case .getSalaryType:
                return nil
            case .getScheduledInterview:
                return nil
        case .getSubCompanyDetails:
            return nil
        case .getSubCompany:
            return nil
            case .saveJob:
                return nil
            case .getSavedJob:
                return nil
        case .getSubCompanyUser:
            return nil
            case .applyJob:
                return nil
            case .getMatches:
                return nil
            case .scheduleInterviewForMatchedJob:
                return nil
            case .getCompanyDetailsJob:
                return nil
            case .getSpecificJobDetail:
                return nil
            case .saveDeviceDetail:
                return nil
            case .getEmployeeDetail:
                return nil
        case .getMatchesCandidates:
            return nil
            case .getNotification:
                return nil
            case .deleteNotification:
                return nil
            case .updateNotification:
                return nil
            case .getNotificationCount:
                return nil
            case .getEmploymentLocationType:
                return nil
            case .cheduledInterviewlList:
                return nil
            case .deleteAccount:
                return nil
        case .deleteSubCompanyUser:
            return nil
        case .UpdateSubCompanyUser:
            return nil
            case .deleteJob:
                return nil
            case .combineData:
                return nil
            case .checkLinkedIn:
                return nil
            case .rescheduleInterviewStatus:
                return nil
            case .getInterviewDetail:
                return nil
            case .updateInterviewStatus:
                return nil
            case .rejectJob:
                return nil
            case .linkLinkedIn:
                return nil
           case .CreateEvent:
            return nil
            case .linkedInConnect:
                return nil
            case .storeLinkedIn:
                return nil
            case .upsertCompany:
                return nil
            case .subscription(let param):
                return ["subscription": param.subscription, "receipt": param.receipt, "platform": param.platform, "matches_count": param.matches_count]
            case .getCompanyName:
                return nil
        case .getProductEmployer:
            return nil
        case .getProductCandidate:
            return nil
            case .SaveRightSwipe(let param):
            return ["quantity": param.quantity, "price": param.price, "receipt": param.receipt]
            case .filterSearch:
                return nil //["category": param.category, "company_name": param.company_name, "salary": param.salary_upper_bound, "location": param.location, "job_title": param.job_title]
            case .removeSavedJob:
                return nil
        case .filterJobSearch:
            return nil
        case .SubCompany:
            return nil
        case .SubCompanyUpdate:
            return nil
        }
    }
    
    var headers: [String : String]? {
        APIManager.commonHeaders
    }
}

