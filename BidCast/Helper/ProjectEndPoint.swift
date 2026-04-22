//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.
//  iOS parity phase 1 (2026-04-22): removed template cruft endpoint cases
//  (alarm/music/weather/subscription/company/welcome/tutorial/getRoll/categories/getNotification/state-list).
//  Keep this list as the source-of-truth iOS endpoint registry. New endpoints
//  should be added in the order: AUTHENTICATION -> PROFILE -> EXPLORE -> (future:
//  HOME FEED, SHOWS, BIDS, ORDERS, PAYMENTS, KYC, SHIPPING, CHAT, NOTIFICATIONS).

import Foundation

enum APIEndPoint {
    //MARK: -  AUTHENTICATION
    case login(param: SignInRequest)
    case singUp(param: SignUpRequest)
    case verifyOTP(param: VerifyOtpRequest)
    case resetPassword(param: ResetPasswordRequest)
    case changePassword(param: UpdatePasswordRequest)
    case forgotPassword(param: ForgetRequest)
    case logout(param: LogoutRequest)
    case sendDeviceDetails(param: DeviceDetailParam)

    //MARK: - PROFILE
    case getProfile
    case updateProfile(param: [String: Any])
    case deleteAccountRequest(param: DeleteProfileRequest)

    //MARK: - STATIC PAGES
    case aboutUs
    case contact(param: ContactUsRequest)
    case privacyPolicy
    case termsCondition
    case faq

    //MARK: - Explore / Products (matches Android backend contract)
    case getCategory                 // GET api/get-category
    case getProducts                 // POST api/v1/get-product (multipart form)
}

extension APIEndPoint: EndPointType {

    var baseURL: String {
        return "https://backend.bidcast.betaplanets.com/api/"
    }

    var url: URL? {
        let path = "\(baseURL)\(path)"
        let urlString = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return URL(string: urlString ?? "")
    }

    var path: String {
        switch self {
        //MARK: - AUTHENTICATION
        case .login:                return "login"
        case .singUp:               return "register"
        case .verifyOTP:            return "verify-otp"
        case .resetPassword:        return "reset-password"
        case .changePassword:       return "change-password"
        case .forgotPassword:       return "forgot-password"
        case .logout:               return "logout"
        case .sendDeviceDetails:    return "device-details"

        //MARK: - PROFILE
        case .getProfile:           return "get-profile"
        case .updateProfile:        return "update-profile"
        case .deleteAccountRequest: return "delete-profile"

        //MARK: - STATIC PAGES
        case .aboutUs:              return "about-us"
        case .contact:              return "contact-us"
        case .privacyPolicy:        return "privacy-policy"
        case .termsCondition:       return "terms-of-service"
        case .faq:                  return "get-questions"

        //MARK: - Explore / Products
        case .getCategory:          return "get-category"
        case .getProducts:          return "v1/get-product"
        }
    }

    var method: HTTPMethods {
        switch self {
        //MARK: - AUTHENTICATION
        case .login:                return .post
        case .singUp:               return .post
        case .verifyOTP:            return .post
        case .resetPassword:        return .post
        case .changePassword:       return .post
        case .forgotPassword:       return .post
        case .logout:               return .post
        case .sendDeviceDetails:    return .post

        //MARK: - PROFILE
        case .getProfile:           return .get
        case .updateProfile:        return .post
        case .deleteAccountRequest: return .post

        //MARK: - STATIC PAGES
        case .aboutUs:              return .get
        case .contact:              return .post
        case .privacyPolicy:        return .get
        case .termsCondition:       return .get
        case .faq:                  return .get

        //MARK: - Explore / Products
        case .getCategory:          return .get
        case .getProducts:          return .post
        }
    }

    var body: Encodable? {
        switch self {
        //MARK: - AUTHENTICATION
        case .login(let param):                 return param
        case .singUp(let param):                return param
        case .verifyOTP(let param):             return param
        case .resetPassword(let param):         return param
        case .changePassword(let param):        return param
        case .forgotPassword(let param):        return param
        case .logout(let param):                return param
        case .sendDeviceDetails(let param):     return param

        //MARK: - PROFILE
        case .getProfile:                       return nil
        case .updateProfile:                    return nil
        case .deleteAccountRequest(let param):  return param

        //MARK: - STATIC PAGES
        case .aboutUs:                          return nil
        case .contact(let param):               return param
        case .privacyPolicy:                    return nil
        case .termsCondition:                   return nil
        case .faq:                              return nil

        //MARK: - Explore / Products
        case .getCategory:                      return nil
        case .getProducts:                      return nil // sent as multipart form fields via APIManager.postMultipartForm
        }
    }

    var headers: [String: String]? {
        APIManager.commonHeaders
    }
}
