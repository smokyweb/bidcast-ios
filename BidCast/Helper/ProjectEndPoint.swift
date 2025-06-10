//
//  ProductEndPoint.swift
//  Youtube MVVM Products
//
//  Created by Yogesh Patel on 15/01/23.
//

import Foundation

enum APIEndPoint{
    case login (param : SignInRequest)
    case singUp(param : SignUpRequest)
    case aboutUs
    case contact(param : ContactUsRequest)
    case verifyOTP(param : VerifyOtpRequest)
    case resetPassword(param : ResetPasswordRequest)
    case changePassword(param : UpdatePasswordRequest)
    case forgotPassword(param : ForgetRequest)
    case privacyPolicy
    case termsCondition
    case faq
    case category
    case auctionType
    case logout
    case getInventory(param : InventoryRequest)
    
    case getLesson
    case getSellingTips
    case howToSell
    case showTips
    case letsPrepare
    case getAllTips(param:TipParam)
    case storeProduct(param : StoreProductParam )
    case storeAddress(param:AddressRequest)
    case getAddress
    case setDefaultAddress(param:AddressDefaultParam)
    case getPreference
    case updatePreference(param : UpdatePreferenceRequest)
    case notifyLiveUser(param : NotifyLiveUserRequest)
    case deleteAddress(param:AddressDefaultParam)
    case getLiveShows
    case getProfileById(param:ProfileParamRequest)
    case getUserProduct(param : UserProductRequest)
    case followUnfollow(param:FollowRequest)
    
    
    //MARK: Faz
    case fetchProduct(param : FetchProductRequest)
    case storeIDCard(param : [String:Any])
    case storePhoneNumber(param : StorePhoneNumberRequest)
    case otpVerify(param : VerifyOtpRequest)
    case storePaymentMethod(param : StorePaymentMethodRequest)
    case buyerIdentityStore(param : [String:Any])
    case buyerIdentityList
    case sellerIdentityFetch
    case notificationListing
    case deleteNotification(param : DeleteNotificationRequest)
    case getLiveShow
    case getMyScheduleShow(param : GetMyScheduleShowRequest)
    case productOrderListing(param : ProductOrderListingRequest)
    case productPurchaseDetail(param : ProductPurchaseDetailRequest)
    case productOrder(param : ProductOrderRequest)
    case productOrderDetails(param : ProductOrderDetailRequest)
    case makeOffer(param : MakeOfferRequest)
    case makeOfferList(param : MakeOfferListRequest)
    case offerUpdateStatus(param : OfferUpdateStatusRequest)
    case transactionListing(param : TransactionHistoryListingRequest)
    case searching(param : SearchingRequest)
    case promo(param : PromoCodeRequest)
    
    
    
    
    
    
    //MARK: Extension
    case AddCard(param:AddCardRequest)
    case deleteCard(param:DeleteCardRequest)
    case getCard
    case getTransactionList(param : TransactionRequest)
    
    //MARK: OLD
    
    case SubCompany(param : SubCompanyParam)
    case SubCompanyUpdate(param : SubCompanyParamUpdate)
    
    case uploadFile
    case getProfile
    case getCategories
    
    case get_news
    
    case getBusiness
    
    case Business (param : BusinessModelParam)
    
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
    case getProductEmployer
    case getProductCandidate
    case getCompanyName
    case filterSearch(param: FilterRequestModal)
    case filterJobSearch(param: FilterRequestModal)
    case removeSavedJob(param: RemoveSaveJobRequest)
}

extension APIEndPoint: EndPointType {
    
    var baseURL: String {
        return "https://backend.bidcast.betaplanets.com/api/"
    }
    
    var url: URL? {
        return URL(string: "\(baseURL)\(path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
            //        case .updateProfile:
            //            return "update-profile"
        case .singUp:
            return "register"
            //        case .getRoll:
            //            return "get-role"
        case .contact:
            return "contact-us"
        case .verifyOTP:
            return "verify-otp"
        case .resetPassword:
            return "reset-password"
        case .changePassword:
            return "change-password"
        case .forgotPassword:
            return "forgot-password"
        case .privacyPolicy:
            return "privacy-policy"
        case .termsCondition:
            return "terms-conditions"
        case .faq:
            return "get-FAQ"
        case .aboutUs:
            return "about-us"
        case .logout:
            return "logout"
        case .getLesson:
            return "get-lesson"
        case .getSellingTips:
            return "selling-tips"
        case .howToSell:
            return "how-to-sell"
        case .showTips:
            return "show-tips"
        case .letsPrepare:
            return "get-prepare"
        case .category :
            return "get-category"
        case .auctionType:
            return "get-auction-type"
        case .getInventory:
            return "get-my-inventory"
        case .storeProduct:
            return "store-product"
        case .getAllTips:
            return "get-all-tips"
        case .storeAddress:
            return "upsert-shipping-address"
        case .getAddress:
            return "get-shipping-address"
        case .setDefaultAddress:
            return "set-default-shipping-address"
        case .getPreference:
            return "setting/list"
        case .updatePreference:
            return "setting/store"
        case .notifyLiveUser:
            return "notify-live-user"
        case .deleteAddress:
            return "delete-shipping-address"
        case .getLiveShows:
            return "get-live-show"
        case .getProfileById:
            return "get-profile-by-id"
        case .getUserProduct:
            return "get-user-product"
        case .followUnfollow:
            return "follow-unfollow"
            
            //MARK: Faz
        case .fetchProduct:
            return "fetch-product"
        case .storeIDCard:
            return "store-id-card"
        case .storePhoneNumber:
            return "store-phone-number"
        case .otpVerify:
            return "otp-verify"
        case .storePaymentMethod:
            return "store-payment-method"
        case .buyerIdentityStore:
            return "buyer-identity/store"
        case .buyerIdentityList:
            return "buyer-identity/list"
        case .sellerIdentityFetch:
            return "seller-identity/fetch"
        case .notificationListing:
            return "notification/listing"
        case .deleteNotification:
            return "notification/delete"
        case .getLiveShow:
            return "get-live-show"
        case .getMyScheduleShow:
            return "get-my-schedule-show"
        case .productOrderListing:
            return "product/order-listing"
        case .productPurchaseDetail:
            return "product/purchase-details"
        case .productOrder:
            return "product/order"
        case .productOrderDetails:
            return "product/order-details"
        case .makeOffer:
            return "offer/make"
        case .makeOfferList:
            return "offer/lists"
        case .offerUpdateStatus:
            return "offer/update-status"
        case .transactionListing:
            return "transaction-history/listing"
        case .searching:
            return "user/searching"
        case .promo:
            return "promo/verify-code"

            
            
            //MARK: Extenion
            
        case .AddCard:
            return "add-card"
        case .deleteCard:
            return "delete-card"
        case .getCard:
            return "get-card"
        case .getTransactionList:
            return "transaction-history/listing"
            
            //MARK: Old
            
        case .getProfile:
            return "get_user_details"
        case .getCategories:
            return "get-categories-list"
        case .SubCompany:
            return "assign-user-access"
        case .SubCompanyUpdate:
            return "assign-user-access"
        case .uploadFile:
            return "file/upload"
            
        case .Business:
            return "upload-employer-doc"
            
        case .getBusiness:
            return "get-employer-business-doc"
        case .getEmployerAvailability:
            return "get-employer-availability"
            
        case .get_news:
            return "get_news"
            
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
        case .removeSavedJob:
            return "save-job"
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
            
        case .logout:
            return .post
        case .resetPassword:
            return .post
        case .changePassword:
            return .post
        case .forgotPassword:
            return .post
        case .contact:
            return .post
        case .verifyOTP:
            return .post
        case .aboutUs:
            return .get
        case .privacyPolicy:
            return .get
        case .termsCondition:
            return .get
        case .faq:
            return .get
        case .getLesson:
            return .get
        case .getSellingTips:
            return .get
        case .howToSell:
            return .get
        case .showTips:
            return .get
        case .letsPrepare:
            return .get
        case .category :
            return .get
        case .auctionType:
            return .get
        case .getInventory:
            return .post
        case .storeProduct:
            return .post
        case .getAllTips:
            return .post
            
        case .storeAddress:
            return .post
            
        case .getAddress:
            return .get
        case .setDefaultAddress:
            return .post
        case .getPreference:
            return .get
        case .updatePreference:
            return .post
        case .notifyLiveUser:
            return .post
        case .deleteAddress:
            return .post
        case .getLiveShows:
            return .post
        case .getProfileById:
            return .post
        case .getUserProduct:
            return .post
        case .followUnfollow:
            return .post
            
            //MARK: Faz
        case .fetchProduct:
            return .post
        case .storeIDCard:
            return .post
        case .storePhoneNumber:
            return .post
        case .otpVerify:
            return .post
        case .storePaymentMethod:
            return .post
        case .buyerIdentityStore:
            return .post
        case .buyerIdentityList:
            return .get
        case .sellerIdentityFetch:
            return .get
        case .notificationListing:
            return .get
        case .deleteNotification:
            return .post
        case .getLiveShow:
            return .post
        case .getMyScheduleShow:
            return .post
        case .productOrderListing:
            return .post
        case .productPurchaseDetail:
            return .post
        case .productOrder:
            return .post
        case .productOrderDetails:
            return .post
        case .makeOffer:
            return .post
        case .makeOfferList:
            return .post
        case .offerUpdateStatus:
            return .post
        case .transactionListing:
            return .post
        case .searching:
            return .post
        case .promo:
            return .post
            
            
            
            
            //MARK: Extension
        case .AddCard:
            return .post
        case .deleteCard:
            return .post
        case .getCard:
            return .get
        case .getTransactionList:
            return .post
            
            //MARK: Old
            
        case .getProfile:
            return .get
            
        case .getCategories:
            return .get
            
        case .SubCompany:
            return .post
        case .SubCompanyUpdate:
            return .post
        case .uploadFile:
            return .post
            
        case .getBusiness:
            return .get
        case .getEmployerAvailability:
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
        case .Business:
            return .post
            
            
            
            
       
       
       
        
        }
    }
    
    var body: Encodable? {
        switch self {
            //MARK: -  AUTHENTICATION
        case .login(let param):
            return param
        case .singUp(let param):
            return param
            
        case .welcome:
            return nil
        case .resetPassword(let param):
            return param
        case .changePassword(let param):
            return param
        case .forgotPassword(let param):
            return param
        case .privacyPolicy:
            return nil
        case .termsCondition:
            return nil
        case .faq:
            return nil
        case .logout:
            return nil
        case .aboutUs:
            return nil
        case .contact(let param):
            return param
        case .verifyOTP(let param):
            return param
        case .getInventory(let param):
            return param
        case .getLesson:
            return nil
        case .getSellingTips:
            return nil
        case .howToSell:
            return nil
        case .showTips:
            return nil
        case .letsPrepare:
            return nil
        case .category:
            return nil
        case .auctionType:
            return nil
        case .storeProduct(param: let param):
            return param
        case .getAllTips(let param):
            return param
            
        case .storeAddress(param: let param):
            return param
        case .getAddress:
            return nil
        case .setDefaultAddress(param: let param):
            return param
        case .getPreference:
            return nil
            
        case .updatePreference(param: let param):
            return param
            
        case .notifyLiveUser(param: let param):
            return param
        case .deleteAddress(param: let param):
            return param
        case .getLiveShows:
            return nil
        case .getProfileById(param: let param):
            return param
        case .getUserProduct(param: let param):
            return param
        case .followUnfollow(param: let param):
            return param
            
            //MARK: Faz
        case .fetchProduct(param: let param):
            return param
        case .storeIDCard:
            return nil
        case .storePhoneNumber(param: let param):
            return param
        case .otpVerify(param: let param):
            return param
        case .storePaymentMethod(param: let param):
            return param
        case .buyerIdentityStore:
            return nil
        case .buyerIdentityList:
            return nil
        case .sellerIdentityFetch:
            return nil
        case .notificationListing:
            return nil
        case .deleteNotification(param: let param):
            return param
        case .getLiveShow:
            return nil
        case .getMyScheduleShow(param: let param):
            return param
            
        case .productOrderListing(param: let param):
            return param
        case .productPurchaseDetail(param: let param):
            return param
        case .productOrder(param: let param):
            return param
        case .productOrderDetails(param: let param):
            return param
        case .makeOffer(param: let param):
            return param
        case .makeOfferList(param: let param):
            return param
        case .offerUpdateStatus(param: let param):
            return param
        case .transactionListing(param: let param):
            return param
        case .searching(param: let param):
            return param
        case .promo(param: let param):
            return param
            
            
            //MARK: Extenson
        case .AddCard(param: let param):
            return param
        case .deleteCard(param: let param):
            return param
        case .getCard:
            return nil
            
        case .getTransactionList(param: let param):
                return param
            
            
            //MARK: Old
            
        case .getProfile:
            return nil
        case .getCategories:
            return nil
            
        case .SubCompany(let param):
            return param
        case .SubCompanyUpdate(let param):
            return param
        case .uploadFile:
            return nil
            
        case .Business(let param):
            return param
            
        case .getBusiness:
            return nil
        case .getEmployerAvailability:
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
    
    //    var jsonBody: [String : Any]? {
    //        switch self {
    //            case .login:
    //                return nil
    //            case .singUp:
    //                return nil
    //
    //            case .verifyOTP:
    //                return nil
    //            case .resetPassword:
    //                return nil
    //            case .forgotPassword:
    //                return nil
    //            case .getProfile:
    //                return nil
    //           case .getCategories:
    //            return nil
    //
    //            case .uploadFile:
    //                return nil
    //            case .aboutUs:
    //                return nil
    //            case .contact:
    //                return nil
    //        case .Business:
    //            return nil
    //            case .privacyPolicy:
    //                return nil
    //        case .getBusiness:
    //            return nil
    //            case .getEmployerAvailability:
    //                return nil
    //            case .logout:
    //                return nil
    //            case .createUserProfile:
    //                return nil
    //            case .getJob:
    //                return nil
    //            case .upsertJob:
    //                return nil
    //            case .jobSwipe:
    //                return nil
    //            case .get_news:
    //                return nil
    //            case .createWorkHistory:
    //                return nil
    //            case .getJobProfile:
    //                return nil
    //            case .getEmployeeList:
    //                return nil
    //        case .getEmployeeListByJobId:
    //            return nil
    //            case .welcome:
    //                return nil
    //            case .getEmployeeByJobId:
    //                return nil
    //            case .getQualification:
    //                return nil
    //            case .termsOfService:
    //                return nil
    //            case .searchJob:
    //                return nil
    //            case .getLanguage:
    //                return nil
    //            case .performActionJob:
    //                return nil
    //            case .setEmployerAvailability:
    //                return nil
    //            case .employerSchedule:
    //                return nil
    //            case .getSalaryType:
    //                return nil
    //            case .getScheduledInterview:
    //                return nil
    //        case .getSubCompanyDetails:
    //            return nil
    //        case .getSubCompany:
    //            return nil
    //            case .saveJob:
    //                return nil
    //            case .getSavedJob:
    //                return nil
    //        case .getSubCompanyUser:
    //            return nil
    //            case .applyJob:
    //                return nil
    //            case .getMatches:
    //                return nil
    //            case .scheduleInterviewForMatchedJob:
    //                return nil
    //            case .getCompanyDetailsJob:
    //                return nil
    //            case .getSpecificJobDetail:
    //                return nil
    //            case .saveDeviceDetail:
    //                return nil
    //            case .getEmployeeDetail:
    //                return nil
    //        case .getMatchesCandidates:
    //            return nil
    //            case .getNotification:
    //                return nil
    //            case .deleteNotification:
    //                return nil
    //            case .updateNotification:
    //                return nil
    //            case .getNotificationCount:
    //                return nil
    //            case .getEmploymentLocationType:
    //                return nil
    //            case .cheduledInterviewlList:
    //                return nil
    //            case .deleteAccount:
    //                return nil
    //        case .deleteSubCompanyUser:
    //            return nil
    //        case .UpdateSubCompanyUser:
    //            return nil
    //            case .deleteJob:
    //                return nil
    //            case .combineData:
    //                return nil
    //            case .checkLinkedIn:
    //                return nil
    //            case .rescheduleInterviewStatus:
    //                return nil
    //            case .getInterviewDetail:
    //                return nil
    //            case .updateInterviewStatus:
    //                return nil
    //            case .rejectJob:
    //                return nil
    //            case .linkLinkedIn:
    //                return nil
    //           case .CreateEvent:
    //            return nil
    //            case .linkedInConnect:
    //                return nil
    //            case .storeLinkedIn:
    //                return nil
    //            case .upsertCompany:
    //                return nil
    //            case .subscription(let param):
    //                return ["subscription": param.subscription, "receipt": param.receipt, "platform": param.platform, "matches_count": param.matches_count]
    //            case .getCompanyName:
    //                return nil
    //        case .getProductEmployer:
    //            return nil
    //        case .getProductCandidate:
    //            return nil
    //            case .SaveRightSwipe(let param):
    //            return ["quantity": param.quantity, "price": param.price, "receipt": param.receipt]
    //            case .filterSearch:
    //                return nil //["category": param.category, "company_name": param.company_name, "salary": param.salary_upper_bound, "location": param.location, "job_title": param.job_title]
    //            case .removeSavedJob:
    //                return nil
    //        case .filterJobSearch:
    //            return nil
    //        case .SubCompany:
    //            return nil
    //        case .SubCompanyUpdate:
    //            return nil
    //        }
    //    }
    
    var headers: [String : String]? {
        APIManager.commonHeaders
    }
}

