//  Rise Shine Swing
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation

enum APIEndPoint {
    case login (param : SignInRequest)
    case singUp(param : SignUpRequest)
    case getRoll
    case welcome
    case aboutUs
    case contact(param : ContactUsRequest)
    case verifyOTP(param : VerifyOtpRequest)
    case resetPassword(param : newPasswordRequest)
    case changePassword(param : UpdatePasswordRequest)
    case forgotPassword(param : ForgetRequest)
    case tutorial
    case getProfile
    case getNotification
    case privacyPolicy
    case termsCondition
    case faq
    case alarm
    case getCurrentWeather(param : CurrentWeatherRequest)
    case getSubscriptionList
    case validateSubscription
    case categories
    case addMusic(param : [String:Any])
    case updateProfile(param : [String:Any])
    case musicRequest
    case deleteMusicRequest(param : DeleteSongRequest)
    case deleteAlarmRequest(param : deleteAlarmRequest)
    case changeAlarmStatus(param : changeAlarmRequest)
    case NewAlarm(request: AlarmRequest)
    case deleteAccountRequest(param : DeleteProfileRequest)
    case addSubscriptionRequest(param : AddSubscriptionsRequest)
    case addFinalMusic(request: [addFinalMusicRequest])
    case logout(param : LogoutRequest)
    case getWeather
    case sendDeviceDetails(param : DeviceDetailParam)
    
    //MARK: - Company API
    case getStateList
    case companyAddress(param : CompanyAdressRequest)
    case companyInfo(param : CompanyInfoRequest)
    case addAllMusic
    case deleteMusicFromCategoryRequest(param : DeleteSongFromCategoryRequest)
}

extension APIEndPoint: EndPointType {
    
    
    var baseURL: String {
        return "https://riseshineswing.betaplanets.com/api/"
    }
    var url: URL? {
        let path = "\(baseURL)\(path)"
        let urlString = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return URL(string: urlString ?? "")
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .musicRequest:
            return "my-music"
        case .addMusic:
            return "add-music"
        case .updateProfile:
            return "update-profile"
        case .changeAlarmStatus:
            return "change-alarm-status"
        case .NewAlarm:
            return "upsert-alarm"
        case .getCurrentWeather:
            return "current-weather-details"
        case .singUp:
            return "register"
        case .getRoll:
            return "get-role"
        case .welcome:
            return "get-welcome-video"
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
            return "terms-of-service"
        case .faq:
            return "get-questions"
        case .alarm:
            return "get-alarms"
        case .getSubscriptionList:
            return "subscription/planlist"
        case .categories:
            return "get-categories"
        case .tutorial:
            return "mobileapi/v1/tutorial"
        case .getProfile:
            return "get-profile"
        case .getNotification:
            return "mobileapi/v1/get_notification_setting"
        case .aboutUs:
            return "about-us"
        case .logout:
            return "logout"
            
        //MARK: - Company API
        case .getStateList:
            return "state"
        case .companyAddress:
            return "company-address"
        case .companyInfo:
            return "company-profile"
        case .deleteMusicRequest(param: let param):
            return "delete-music/\(param.musicId)"
        case .deleteAlarmRequest(param: let param):
            return "delete-alarm/\(param.alarmId)"
        case .deleteAccountRequest(param: let param):
         return "delete-profile"
        case .addSubscriptionRequest(param : let param):
            return "subscription/add"
        case .validateSubscription:
            return "subscription/validation"
        case .addFinalMusic:
            return "add-music-final"
        case .getWeather:
            return "get-weather-forecast"
        case .sendDeviceDetails:
            return "device-details"
        case .addAllMusic:
            return "v2/add-music"
        case .deleteMusicFromCategoryRequest:
            return "remove-song-from-category"
        }
    }
    
    var method: HTTPMethods {
        switch self {
        case .login:
            return .post
        case .addMusic:
            return .post
        case .updateProfile:
            return .post
        case .musicRequest:
            return .get
        case .changeAlarmStatus:
            return .post
        case .NewAlarm:
            return .post
        case .singUp:
            return .post
        case .addSubscriptionRequest:
            return .post
        case .getRoll:
            return .get
        case .welcome:
            return .get
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
        case .tutorial:
            return .get
        case .getProfile:
            return .get
        case .getNotification:
            return .get
        case .aboutUs:
            return .get
        case .privacyPolicy:
            return .get
        case .termsCondition:
            return .get
        case .faq:
            return .get
        case .alarm:
            return .get
        case .getSubscriptionList:
            return .get
        case .categories:
            return .get
        //MARK: - Company API
        case .getStateList:
            return .get
        case .companyAddress:
            return .post
        case .companyInfo:
            return .post
        case .deleteMusicRequest:
            return .get
        case .deleteAlarmRequest:
            return .post
        case .getCurrentWeather:
            return .post
        case .deleteAccountRequest:
            return .post
        case .validateSubscription:
            return .get
        case .addFinalMusic:
            return .post
        case .getWeather:
            return .get
        case .sendDeviceDetails:
            return .post
        case .addAllMusic:
            return .post
        case .deleteMusicFromCategoryRequest:
            return .post
        }
    }
    
    var body: Encodable? {
        switch self {
        case .login(let param):
            return param
        case .addMusic:
            return nil
        case .updateProfile:
            return nil
        case .musicRequest:
            return nil
        case .changeAlarmStatus(let param):
            return param
        case .NewAlarm(let param):
            return param
        case .singUp(let param):
            return param
        case .addSubscriptionRequest(let param):
            return param
        case .getRoll:
            return nil
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
        case .alarm:
            return nil
        case .getSubscriptionList:
            return nil
        case .categories:
            return nil
        case .aboutUs:
            return nil
        case .contact(let param):
            return param
        case .verifyOTP(let param):
            return param
        case .tutorial:
            return nil
        case .getProfile:
            return nil
        case .getNotification:
            return nil
        case .logout(let param):
            return param
        //MARK: - Company API
        case .getStateList:
            return nil
        case .companyAddress(let param):
            return param
        case .companyInfo(let param):
            return param
        case .deleteMusicRequest:
            return nil
        case .deleteAlarmRequest:
            return nil
        case .deleteAccountRequest(let param):
            return param
        case .validateSubscription:
            return nil
        case .addFinalMusic(let param):
            return param
        case .getWeather:
            return nil
        case .sendDeviceDetails(let param):
            return param
        case .addAllMusic:
            return nil
        case .deleteMusicFromCategoryRequest(let param):
            return param
        case .getCurrentWeather(let param):
            return param
        }
    }
    
    var headers: [String : String]? {
        APIManager.commonHeaders
    }

}
