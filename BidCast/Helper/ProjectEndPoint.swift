//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.
//  iOS parity phase 1 (2026-04-22): removed template cruft endpoint cases
//  (alarm/music/weather/subscription/company/welcome/tutorial/getRoll/categories/
//  getNotification/state-list).
//  iOS parity phase 2 (2026-04-22): expanded to 1-to-1 mirror of Android
//  `ApiInterface.kt` — 120+ cases grouped by domain. Any new endpoint should
//  land in one of the MARK sections below. Do NOT invent endpoints; every
//  case maps to an exact @POST/@GET in Android.
//
//  Body convention:
//   - `param: <TypedRequest>` — use the model-layer Encodable request type
//     where it exists (e.g. SignInRequest, MakeOfferRequest).
//   - `param: [String: Any]` — legacy dict body. New code should prefer typed.
//   - No param — for GET endpoints with no body, or POST endpoints whose body
//     is sent as multipart via APIManager.postMultipartForm (see `isMultipart`).

import Foundation

enum APIEndPoint {
    //MARK: - AUTHENTICATION
    case login(param: SignInRequest)
    case singUp(param: SignUpRequest)
    case verifyOTP(param: VerifyOtpRequest)
    case resetPassword(param: ResetPasswordRequest)
    case changePassword(param: UpdatePasswordRequest)
    case forgotPassword(param: ForgetRequest)
    case logout(param: LogoutRequest)
    case sendDeviceDetails(param: DeviceDetailParam)
    case upsertDeviceDetails(param: DeviceDetailsRequest)

    //MARK: - PROFILE
    case getProfile
    case getProfileById(param: [String: Any])
    case updateProfile(param: [String: Any])
    case deleteAccountRequest(param: DeleteProfileRequest)
    // Legacy aliases referenced by existing screens — keep until the usages migrate.
    case deleteProfile
    case editProfileDetails(param: [String: Any])
    case fetchReferral
    case userFavorite(param: [String: Any])
    case userSearching(param: SearchRequest)
    case updateVacationModeStatus(param: [String: Any])

    //MARK: - STATIC PAGES
    case aboutUs
    case contact(param: ContactUsRequest)
    case privacyPolicy
    case termsCondition
    case faq
    case getLesson
    case getHowToSellStep
    case getPrepareStep
    case getPageUrl(slug: String)

    //MARK: - CATEGORIES & SHOP DATA
    case getCategory
    case getSubCategories(param: GetSubCategoriesRequest)
    case getStates
    case getMailClasses
    case getUSPSBoxDimensions
    case getAuctionType
    case getCoupon
    case getReportCategories
    case getShippingProfile
    case getShippingDetails

    //MARK: - PRODUCTS
    case getProducts                                  // POST api/v1/get-product (multipart)
    case getUserProducts(param: [String: Any])        // POST api/get-user-product
    case getProductsByStatus(param: [String: Any])    // POST api/v1/get-my-purchases-orders
    case getProductDetails(param: [String: Any])      // POST api/v1/get-product-details
    case storeProduct(param: StoreProductRequest)
    case storeProductMeta
    case updateProductStatus(param: [String: Any])
    case deleteProduct(param: [String: Any])
    case saveSellerProduct(param: [String: Any])      // POST api/product/save

    //MARK: - SURPRISE / PRODUCT SETS
    case storeSurpriseProduct(param: [String: Any])
    case getSurpriseProduct
    case getSetDetails
    case editSurpriseSetUnit(param: [String: Any])
    case deleteSurpriseSet(param: [String: Any])

    //MARK: - SHOWS / SCHEDULE
    case storeScheduleShow(param: [String: Any])
    case updateScheduleShow(param: [String: Any])
    case getMyScheduledShow(param: [String: Any])
    case getLiveShow(param: [String: Any])
    case getLiveSeller
    case getShowDetails                               // GET api/v1/get-show-details-by-id
    case getShowOverview
    case checkScheduleShow(param: [String: Any])
    case updateLiveStatus(param: [String: Any])
    case notifyLiveUser(param: [String: Any])

    //MARK: - LIVE TOKENS / AGORA / ZEGO
    case generateToken(param: [String: Any])
    case getAgoraToken(param: [String: Any])

    //MARK: - BIDS
    case createBid(param: [String: Any])
    case fetchBids(page: String)

    //MARK: - TIPS
    case getAllTips(param: [String: Any])
    case getTipAmount
    case sendTipAmount(param: [String: Any])

    //MARK: - CLIPS
    case getUserClips
    case makeClip(param: [String: Any])

    //MARK: - ORDERS
    case placeOrder(param: [String: Any])             // POST api/v1/place-order
    case getPurchaseProduct(param: [String: Any])     // POST api/v1/checkout-product-detail
    case getOrderListing(param: [String: Any])        // POST api/v1/get-my-orders
    case getOrderReceipt(param: [String: Any])
    case getOrderDetails(param: [String: Any])        // POST api/v1/get-order-status
    case fetchOrderDetail(param: [String: Any])       // POST api/v1/get-order-details
    case changeOrderStatus(param: [String: Any])
    case raiseTicket(param: [String: Any])

    //MARK: - PAYMENTS / KYC / WALLET
    case addPaymentCard(param: AddPaymentCardRequest)
    case getPaymentCard
    case setDefaultCard(param: [String: Any])
    case deleteCard(param: [String: Any])
    case getKYCDetails
    case checkKyc
    case storeSellerVerification(param: [String: Any])
    case fundTransfer(param: FundTransferRequest)
    case payout(param: FundTransferRequest)
    case getPayoutHistory(param: [String: Any])
    case walletInfo
    case getTransactionsHistory(param: [String: Any])
    case verifyPromoCode(param: VerifyPromoCodeRequest)

    //MARK: - SELLER IDENTITY / BUYER IDENTITY
    case fetchSellerVerification
    case storeSellerId(param: [String: Any])
    case storePhoneNumber(param: [String: Any])
    case verifyNumberOtp(param: [String: Any])
    case storePaymentMethod(param: [String: Any])
    case fetchBuyerIdentity
    case storeBuyerIdentity(param: [String: Any])

    //MARK: - SHIPPING ADDRESSES
    case getShippingAddress
    case addShippingAddress(param: [String: Any])
    case setDefaultShippingAddress(param: [String: Any])
    case deleteAddress(param: [String: Any])
    case storeShippingProfile(param: [String: Any])
    case deleteShippingProfile(profileId: String)
    case saveDomesticShipmentSetting(param: [String: Any])
    case saveShippingCosts(param: [String: Any])

    //MARK: - OFFERS
    case makeOffer(param: MakeOfferRequest)
    case offerList(param: [String: Any])
    case offerUpdateStatus(param: UpdateOfferStatusRequest)

    //MARK: - SOCIAL / FOLLOW / BLOCK / REPORT / RATING
    case followUser(param: FollowUnfollowRequest)
    case blockUnblockUser(param: BlockUnblockRequest)
    case getBlockedUsers
    case reportSeller(param: ReportSellerRequest)
    case storeSellerRating(param: StoreSellerRatingRequest)
    case getSellerRating
    case sendChatNotification(param: SendChatNotificationRequest)

    //MARK: - NOTIFICATIONS
    case getNotification(param: [String: Any])
    case deleteNotification(param: [String: Any])

    //MARK: - SETTINGS (per-user privacy + shop toggles)
    case settingsList
    case settingsStore(param: SettingStoreRequest)

    //MARK: - SELLER HUB / ANALYTICS / PROMOTE / PREMIER SHOP
    case getSellerHubInfo
    case getSellerStatus
    case getSellerInfo
    case getSellerAnalytics
    case getVisitorsAnalytics
    case getSalesPerformance
    case exportAnalyticsData
    case getPremierShop
    case applyPremierShop
    case getPromoteTools
    case getPromoteToolsDetails
    case getPromoteShowList
    case promoteShow(param: PromoteShowRequest)
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
        case .login:                    return "login"
        case .singUp:                   return "register"
        case .verifyOTP:                return "verify-otp"
        case .resetPassword:            return "reset-password"
        case .changePassword:           return "change-password"
        case .forgotPassword:           return "forgot-password"
        case .logout:                   return "logout"
        case .sendDeviceDetails:        return "device-details"
        case .upsertDeviceDetails:      return "upsert-device-details"

        //MARK: - PROFILE
        case .getProfile:               return "get-profile"
        case .getProfileById:           return "get-profile-by-id"
        case .updateProfile:            return "update-profile"
        case .deleteAccountRequest:     return "delete-profile"
        case .deleteProfile:            return "delete-profile"
        case .editProfileDetails:       return "update-profile"
        case .fetchReferral:            return "referral-code/fetch"
        case .userFavorite:             return "user/favorite"
        case .userSearching:            return "user/searching"
        case .updateVacationModeStatus: return "update-vacation-mode-status"

        //MARK: - STATIC PAGES
        case .aboutUs:                  return "about-us"
        case .contact:                  return "contact-us"
        case .privacyPolicy:            return "privacy-policy"
        case .termsCondition:           return "terms-conditions"        // QA-NOTE: Android path
        case .faq:                      return "get-FAQ"                 // QA-NOTE: Android path
        case .getLesson:                return "get-lesson"
        case .getHowToSellStep:         return "how-to-sell"
        case .getPrepareStep:           return "get-prepare"
        case .getPageUrl(let slug):     return "get-pages-url/\(slug)"

        //MARK: - CATEGORIES & SHOP DATA
        case .getCategory:              return "get-category"
        case .getSubCategories:         return "get-subcategories"
        case .getStates:                return "get-states"
        case .getMailClasses:           return "usps/mail-classes"
        case .getUSPSBoxDimensions:     return "get-usps-shipping-price"
        case .getAuctionType:           return "get-auction-type"
        case .getCoupon:                return "get-coupon"
        case .getReportCategories:      return "report-categories"
        case .getShippingProfile:       return "get-shipping-profile"
        case .getShippingDetails:       return "get-shipping-details"

        //MARK: - PRODUCTS
        case .getProducts:              return "v1/get-product"
        case .getUserProducts:          return "get-user-product"
        case .getProductsByStatus:      return "v1/get-my-purchases-orders"
        case .getProductDetails:        return "v1/get-product-details"
        case .storeProduct:             return "store-product"
        case .storeProductMeta:         return "store-product-meta"
        case .updateProductStatus:      return "update-product-status"
        case .deleteProduct:            return "delete-product"
        case .saveSellerProduct:        return "product/save"

        //MARK: - SURPRISE / PRODUCT SETS
        case .storeSurpriseProduct:     return "store-surprise-product"
        case .getSurpriseProduct:       return "get-surprise-product"
        case .getSetDetails:            return "get-set-details"
        case .editSurpriseSetUnit:      return "edit-product-set-item-unit"
        case .deleteSurpriseSet:        return "delete-product-set"

        //MARK: - SHOWS / SCHEDULE
        case .storeScheduleShow:        return "store-schedule-show"
        case .updateScheduleShow:       return "update-schedule-show"
        case .getMyScheduledShow:       return "get-my-schedule-show"
        case .getLiveShow:              return "get-live-show"
        case .getLiveSeller:            return "get-live-seller"
        case .getShowDetails:           return "v1/get-show-details-by-id"
        case .getShowOverview:          return "get-show-overview"
        case .checkScheduleShow:        return "check-schedule-show"
        case .updateLiveStatus:         return "schedule-show/update-live-status"
        case .notifyLiveUser:           return "notify-live-user"

        //MARK: - LIVE TOKENS / AGORA / ZEGO
        case .generateToken:            return "generate-token"
        case .getAgoraToken:            return "agora-token"

        //MARK: - BIDS
        case .createBid:                return "bid/store"
        case .fetchBids(let page):      return "bid/fetch?page=\(page)"

        //MARK: - TIPS
        case .getAllTips:               return "get-all-tips"
        case .getTipAmount:             return "get-tip-amount"
        case .sendTipAmount:            return "send-tip-amount"

        //MARK: - CLIPS
        case .getUserClips:             return "get-clips"
        case .makeClip:                 return "make-clip"

        //MARK: - ORDERS
        case .placeOrder:               return "v1/place-order"
        case .getPurchaseProduct:       return "v1/checkout-product-detail"
        case .getOrderListing:          return "v1/get-my-orders"
        case .getOrderReceipt:          return "v1/get-order-receipt"
        case .getOrderDetails:          return "v1/get-order-status"
        case .fetchOrderDetail:         return "v1/get-order-details"
        case .changeOrderStatus:        return "change-order-status"
        case .raiseTicket:              return "raise-ticket"

        //MARK: - PAYMENTS / KYC / WALLET
        case .addPaymentCard:           return "add-card"
        case .getPaymentCard:           return "get-card"
        case .setDefaultCard:           return "set-default-card"
        case .deleteCard:               return "delete-card"
        case .getKYCDetails:            return "stripe/kyc-details"
        case .checkKyc:                 return "stripe/check-Kyc"
        case .storeSellerVerification:  return "store-seller-verification"
        case .fundTransfer:             return "stripe/fund-transfer"
        case .payout:                   return "stripe/fund-transfer"   // QA-NOTE: Android reuses same path
        case .getPayoutHistory:         return "stripe/payout-history"
        case .walletInfo:               return "wallet-info"
        case .getTransactionsHistory:   return "transaction-history/listing"
        case .verifyPromoCode:          return "../promo/verify-code"   // QA-NOTE: Android route is `promo/verify-code` (no /api prefix)

        //MARK: - SELLER IDENTITY / BUYER IDENTITY
        case .fetchSellerVerification:  return "seller-identity/fetch"
        case .storeSellerId:            return "seller-identity/store-id-card"
        case .storePhoneNumber:         return "seller-identity/store-phone-number"
        case .verifyNumberOtp:          return "seller-identity/otp-verify"
        case .storePaymentMethod:       return "seller-identity/store-payment-method"
        case .fetchBuyerIdentity:       return "buyer-identity/list"
        case .storeBuyerIdentity:       return "buyer-identity/store"

        //MARK: - SHIPPING ADDRESSES
        case .getShippingAddress:       return "get-shipping-address"
        case .addShippingAddress:       return "upsert-shipping-address"
        case .setDefaultShippingAddress:return "set-default-shipping-address"
        case .deleteAddress:            return "delete-shipping-address"
        case .storeShippingProfile:     return "store-shipping-profile"
        case .deleteShippingProfile(let profileId):
                                        return "delete-shipping-profile/\(profileId)"
        case .saveDomesticShipmentSetting:
                                        return "save-domestic-shipment-setting"
        case .saveShippingCosts:        return "save-shipping-costs"

        //MARK: - OFFERS
        case .makeOffer:                return "offer/make"
        case .offerList:                return "offer/lists"
        case .offerUpdateStatus:        return "offer/update-status"

        //MARK: - SOCIAL
        case .followUser:               return "follow-unfollow"
        case .blockUnblockUser:         return "block-unblock"
        case .getBlockedUsers:          return "blocked-users"
        case .reportSeller:             return "report-seller"
        case .storeSellerRating:        return "seller-rating"
        case .getSellerRating:          return "get-seller-rating"
        case .sendChatNotification:     return "send-chat-notification"

        //MARK: - NOTIFICATIONS
        case .getNotification:          return "notification/listing"
        case .deleteNotification:       return "notification/delete"

        //MARK: - SETTINGS
        case .settingsList:             return "setting/list"
        case .settingsStore:            return "setting/store"

        //MARK: - SELLER HUB / ANALYTICS / PROMOTE / PREMIER SHOP
        case .getSellerHubInfo:         return "seller-hub-info"
        case .getSellerStatus:          return "seller-status"
        case .getSellerInfo:            return "get-seller-info"
        case .getSellerAnalytics:       return "seller-analytic"
        case .getVisitorsAnalytics:     return "seller/visitor-analytics"
        case .getSalesPerformance:      return "seller/sales-performance"
        case .exportAnalyticsData:      return "export-deatils"           // QA-NOTE: Android typo
        case .getPremierShop:           return "get-premier-shop"
        case .applyPremierShop:         return "apply-premier-shop"
        case .getPromoteTools:          return "get-promote-tools"
        case .getPromoteToolsDetails:   return "promote-tool-details"
        case .getPromoteShowList:       return "get-promote-show"
        case .promoteShow:              return "schedule-show/store-promote-show"
        }
    }

    var method: HTTPMethods {
        switch self {
        //MARK: - GET endpoints
        case .getProfile, .fetchReferral,
             .aboutUs, .privacyPolicy, .termsCondition, .faq,
             .getLesson, .getHowToSellStep, .getPrepareStep, .getPageUrl,
             .getCategory, .getStates, .getMailClasses, .getUSPSBoxDimensions,
             .getAuctionType, .getCoupon, .getReportCategories,
             .getShippingProfile, .getShippingDetails,
             .getSurpriseProduct, .getSetDetails,
             .getLiveSeller, .getShowDetails, .getShowOverview,
             .fetchBids(_), .getTipAmount, .getUserClips,
             .getPaymentCard, .getKYCDetails, .walletInfo,
             .fetchSellerVerification, .fetchBuyerIdentity,
             .getShippingAddress,
             .getBlockedUsers, .getSellerRating,
             .settingsList,
             .getSellerHubInfo, .getSellerStatus, .getSellerInfo,
             .getSellerAnalytics, .getVisitorsAnalytics, .getSalesPerformance,
             .exportAnalyticsData,
             .getPremierShop, .getPromoteTools, .getPromoteToolsDetails,
             .getPromoteShowList:
            return .get

        //MARK: - POST endpoints (everything else)
        default:
            return .post
        }
    }

    /// Android marks the vast majority of POST endpoints as `@Multipart`.
    /// This flag lets APIManager pick `postMultipartForm` vs JSON body.
    /// Only endpoints where Android uses `@Body` (pure JSON) return false.
    var isMultipart: Bool {
        switch self {
        case .login, .singUp, .verifyOTP, .resetPassword,
             .forgotPassword, .upsertDeviceDetails,
             .getProducts, .getUserProducts, .getProductsByStatus,
             .getProductDetails, .storeProduct, .storeProductMeta,
             .updateProductStatus, .saveSellerProduct,
             .storeScheduleShow, .updateScheduleShow, .getMyScheduledShow,
             .getLiveShow, .notifyLiveUser, .checkScheduleShow, .updateLiveStatus,
             .generateToken, .getAgoraToken,
             .createBid, .getAllTips, .sendTipAmount, .makeClip,
             .placeOrder, .getPurchaseProduct, .getOrderListing,
             .getOrderReceipt, .fetchOrderDetail, .changeOrderStatus,
             .raiseTicket,
             .addPaymentCard, .storeSellerVerification, .fundTransfer, .payout,
             .getPayoutHistory, .getTransactionsHistory, .verifyPromoCode,
             .storeSellerId, .storePhoneNumber, .verifyNumberOtp,
             .storePaymentMethod, .storeBuyerIdentity,
             .addShippingAddress, .setDefaultShippingAddress, .deleteAddress,
             .storeShippingProfile, .saveDomesticShipmentSetting, .saveShippingCosts,
             .makeOffer, .offerList, .offerUpdateStatus,
             .followUser, .blockUnblockUser, .reportSeller,
             .storeSellerRating, .sendChatNotification,
             .settingsStore, .applyPremierShop, .promoteShow,
             .getProfileById, .userFavorite, .userSearching, .updateVacationModeStatus,
             .setDefaultCard, .deleteCard,
             .editSurpriseSetUnit, .deleteSurpriseSet,
             .contact, .getSubCategories:
            return true
        default:
            return false
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
        case .upsertDeviceDetails(let param):   return param

        //MARK: - PROFILE (mostly dict-based legacy; TODO-PHASE3 migrate to typed)
        case .deleteAccountRequest(let param):  return param
        case .userSearching(let param):         return param

        //MARK: - STATIC PAGES
        case .contact(let param):               return param

        //MARK: - CATEGORIES
        case .getSubCategories(let param):      return param

        //MARK: - PRODUCTS (typed bodies)
        case .storeProduct(let param):          return param

        //MARK: - PAYMENTS
        case .addPaymentCard(let param):        return param
        case .verifyPromoCode(let param):       return param
        case .fundTransfer(let param):          return param
        case .payout(let param):                return param

        //MARK: - OFFERS
        case .makeOffer(let param):             return param
        case .offerUpdateStatus(let param):     return param

        //MARK: - SOCIAL
        case .followUser(let param):            return param
        case .blockUnblockUser(let param):      return param
        case .reportSeller(let param):          return param
        case .storeSellerRating(let param):     return param
        case .sendChatNotification(let param):  return param

        //MARK: - SETTINGS
        case .settingsStore(let param):         return param

        //MARK: - PROMOTE
        case .promoteShow(let param):           return param

        //MARK: - Dict-based bodies (TODO-PHASE3 migrate to typed request structs)
        // Multipart endpoints generally send fields via APIManager.postMultipartForm;
        // returning `nil` here is intentional — the feature VM packs the fields.
        default:
            return nil
        }
    }

    var headers: [String: String]? {
        APIManager.commonHeaders
    }
}
