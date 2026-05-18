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
    case premierShop
    case applyPremierShop
    case promoteTool
    case contact(param : ContactUsRequest)
    case verifyOTP(param : VerifyOtpRequest)
    case resetPassword(param : ResetPasswordRequest)
    case changePassword(param : UpdatePasswordRequest)
    case forgotPassword(param : ForgetRequest)
    case privacyPolicy
    case termsCondition
    case faq
    case category(param:CategoryRequest)
    case getSubCategories(param:[String:Any] )
    case storeFavCategories(param:[String:Any] )
    case auctionType
    case logout
    case sellerHubInfo
    case getLesson
    case getSellingTips
    case howToSell
    case showTips
    case letsPrepare
    case getAllTips(param:TipParam)
    case storeProduct(productId: Int? ,param : [String:Any] )
    case storeAddress(param:AddressRequest)
    case getAddress
    case checkValidShowDate(param:checkScheduleRequest)
    
    case getMyPurchasedOrder(param: PurchaseOrderRequuest)
    case getPurchasedOrderDetails(param : PurchaseOrderDetailsRequest)
    
    case setDefaultAddress(param:AddressDefaultParam)
    case getPreference
    case updatePreference(param : UpdatePreferenceRequest)
    case notifyLiveUser(param : NotifyLiveUserRequest)
    case deleteAddress(param:AddressDefaultParam)
    case getLiveShows(param:GetLiveShowsRequest)
    case getProfileById(param:ProfileParamRequest)

    case followUnfollow(param:FollowRequest)
    case getSellerInfo(param: SellerInfoRequest)
    case getReportSellerCategory
    case reportSeller(param: SellerReportRequest)
    case countUpdate(param:countRequest)
    case fetchProduct(param : FetchProductRequest)
    case storeIDCard(param : [String:Any])
    case storePhoneNumber(param : StorePhoneNumberRequest)
    case otpVerify(param : OtpVerifyRequest)
    case storePaymentMethod(param : StorePaymentMethodRequest)
    case buyerIdentityStore
    case sellerVerification
    case buyerIdentityList
    case sellerIdentityFetch
    case notificationListing
    case deleteNotification(param : DeleteNotificationRequest)
    case getMyScheduleShow(param : GetMyScheduleShowRequest)
    case getTotalRating(param : GetTotalRatingRequest)
    case addRating(param : AddRatingRequest)
    case productOrderListing(param : ProductOrderListingRequest)
    case productPurchaseDetail(param : ProductPurchaseDetailRequest)
    case productOrder(param : ProductOrderRequest)
    case productOrderDetails(param : ProductOrderDetailRequest)
    case makeOffer(param : MakeOfferRequest)
    case makeOfferList(param: PageRequest)
    case offerUpdateStatus(param : OfferUpdateStatusRequest)
    case searching(param : SearchingRequest)
    case promo(param : PromoCodeRequest)
    case getReferralCode
    case getclip(param : clipRequest)

    case storeScheduleShow
    case updateScheduleShow
    case addCard(param:AddCardRequest)
    case deleteCard(param:DeleteCardRequest)
    case setDefaultCard(param:DeleteCardRequest)
    case getCard
    case updateCard(param: UpdateCardRequest)
    case getTransactionList(param : TransactionRequest)

    case getScheduledShow(param:GetLiveShowsRequest)
    case UpdateShowStatus(param:LiveShowUpdateRequest)
    case getBidList(param:PageRequest)

    case getNotificationListing(param:PageRequest)
    case saveDeviceDetail(param : DeviceDetailRequest)
    case getWalletInfo
    case getPayOutHistory
    case getKycDetails
    case checkKYC
    case fundTransfer(param : FundTransferRequest)
    case getprofile
    case updateProfile(param:UpdateProfileRequest)
    case storeBid(param:StoreBidRequest)
    case sellerStatus
    case getState
    case uploadProductImage
    case deleteProduct(param : DeleteProduct)
    case blockUser(param : BlockUserRequest)
    case blockedUserList
    case getMailClass
    case getUspsShippingPrice
    case getPromoteShow
    case getLiveSeller

    case getAgoraToken
    case getProfile
    case getCategories
    
    case get_news
    case createUserProfile (param: CreateUserProfSection)
    case termsOfService
//
    case getNotification(param: String)
    case deleteAccount(param:DeleteParam)
    case sendChatNotification(param: SendChatNotification)
    case getTipsData
    case sendTipAmount(param: TipAmountRequest)
    case getSellerAnalytic(param: SellerAnalyticsRequest)
    case getExportDetails(param: ExportDetailsRequest)
    case getSalesPerformace(param: SalesPerformanceRequest)
    case getVisitorsAnalytic(param: VisitorsAnalyticsRequest)
    case storePromoteShow(param: StorePromoteShowRequest)
    case storeShipping(param: StoreShippingRequest)
    case deleteShippingProfile(param: DeleteShippingProfileRequest)
    case getShippinProfiles
    case getShippinDetails
    case getShowOverview(param: ShowOverviewRequest)
    case updateProductStatus(param: UpdateProductStatusRequest)
    case getPromoteToolDetails(param:promoteToolRequest)
    case storeDomesticShipment(param:SaveDomesticShipmentRequest)
    
    //MARK: - V1
    case getProduct(param:ProductRequest)
    case getScheduleShow(param:getShowRequest)
    case orderReceipt(param:getOrderReceiptRequest)
    case saveProduct(param:MakeOfferListRequest)
    case getCoupon
    case updateVacation(param:vacationRequest)
    case makeClip(param:ClipRequest)
    case createSurprise(param:SurpriseRequest)
    case getSurprise
    case editProductPrice(param:EditProductUnitRequest)
    case deleteProductSuppriseSet(param:DeleteProductSetRequest)
    case SaveShippingCosts(param:SaveShippingCostsRequest)

    case unifiedSearch(param: SearchRequest)


}

extension APIEndPoint: EndPointType {
    
    
    var baseURL: String {
        return "https://backend.bidcast.betaplanets.com/api/"
    }
    
    var baseURL1: String {
        return "https://backend.bidcast.betaplanets.com/api/v1/"
    }
    
    var url: URL? {
        switch self {
        case .getProduct,
                .productPurchaseDetail,
                .productOrder,
                .productOrderListing,
                .productOrderDetails,
                .getPurchasedOrderDetails,
                .getMyPurchasedOrder,
                .fetchProduct,
                .getScheduleShow,
                .unifiedSearch:
            return URL(string: "\(baseURL1)\(path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        default :
            return URL(string: "\(baseURL)\(path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .singUp:
            return "register"
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
        case .premierShop:
            return "get-premier-shop"
        case .applyPremierShop:
            return "apply-premier-shop"
        case .promoteTool:
            return "get-promote-tools"
        case .logout:
            return "logout"
        case .sellerHubInfo:
            return "seller-hub-info"
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
//            https://backend.bidcast.betaplanets.com/api/get-category?get_count=true
        case .category(param:let param) :
            return "get-category?category_id=\(param.category_id ?? "")&type=\(param.type ?? "")&search=\(param.search ?? "")&get_count=\(param.get_count)"
        case .auctionType:
            return "get-auction-type"
//        case .getInventory:
//            return "get-my-inventory"
        case .storeProduct(param:let param):
            if let id = param.productId {
                return "store-product?product_id=\(id)"
            }
            else  {
                return "store-product"
            }
            
        case .getAllTips:
            return "get-all-tips"
        case .storeAddress:
            return "upsert-shipping-address"
        case .getAddress:
            return "get-shipping-address"
            
            
        case .getMyPurchasedOrder:
            return "get-my-purchases-orders"
            
            
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
            
        case .followUnfollow:
            return "follow-unfollow"
        case .countUpdate:
            return "zegocloud/webhook"
        case .fetchProduct:
            return "get-product-details"
        case .storeIDCard:
            return "store-id-card"
        case .storePhoneNumber:
            return "seller-identity/store-phone-number"
        case .otpVerify:
            return "otp-verify"
        case .storePaymentMethod:
            return "seller-identity/store-payment-method"
        case .buyerIdentityStore:
            return "buyer-identity/store"
        case .sellerVerification:
            return "store-seller-verification"
        case .buyerIdentityList:
            return "buyer-identity/list"
        case .sellerIdentityFetch:
            return "seller-identity/fetch"
        case .notificationListing:
            return "notification/listing"
        case .deleteNotification:
            return "notification/delete"
        case .getNotificationListing(param:let param):
            return "notification/listing?page=\(param.page)"
        case .getMyScheduleShow(param:let param):
            return "get-my-schedule-show?=\(param.type ?? "")&page=\(param.page)"
        case .productOrderListing:
            return "get-my-orders"
        case .productPurchaseDetail:
            return "checkout-product-detail"
        case .productOrder:
            return "place-order"
        case .productOrderDetails:
            return "get-order-status"
        case .makeOffer:
            return "offer/make"
        case .makeOfferList(param:let param):
            return "offer/lists?page=\(param.page)"
        case .offerUpdateStatus(param:let param):
            return "offer/update-status=\(param.offer_id)&page=\(param.page)"
        case .searching:
            return "user/searching"
        case .promo:
            return "promo/verify-code"
        case .getReferralCode:
            return "referral-code/fetch"
        case .getPurchasedOrderDetails:
            return "get-order-details"
        case .addCard:
            return "add-card"
        case .updateCard:
            return "update-card"
        case .deleteCard:
            return "delete-card"
        case .setDefaultCard:
            return "set-default-card"
        case .getCard:
            return "get-card"
        case .getTransactionList:
            return "transaction-history/listing"
        case .storeScheduleShow:
            return "store-schedule-show"
        case .updateScheduleShow:
            return "update-schedule-show"
        case .getScheduledShow:
            return "get-my-schedule-show"
        case .UpdateShowStatus:
            return "schedule-show/update-live-status"
        case .getBidList(param:let param):
            return "bid/fetch?page=\(param.page)"
       
        case .getWalletInfo:
            return "wallet-info"
        case .getprofile:
            return "get-profile"
        case .updateProfile:
            return "update-profile"
        case .storeBid:
            return "bid/store"
        case .sellerStatus:
            return "seller-status"
        case .getState:
            return "get-states"
        case .uploadProductImage:
            return "store-product-meta"
        case .deleteProduct(let param):
            return "delete-product?product_id=\(param.product_id)"
        case .blockUser:
            return "block-unblock"
        case .blockedUserList:
            return  "blocked-users"
        case .getMailClass:
            return "usps/mail-classes"
        case .getUspsShippingPrice:
            return "get-usps-shipping-price"
        case .getPayOutHistory:
            return "stripe/payout-history"
        case .getKycDetails:
            return "stripe/kyc-details"
        case .checkKYC:
            return "stripe/check-Kyc"
        case .fundTransfer:
            return "stripe/fund-transfer"
        case .getTotalRating(let param):
            return "get-seller-rating?seller_id=\(param.seller_id)"
        case .addRating:
            return "seller-rating"
        case .getPromoteShow:
            return "get-promote-show"
            
            
            //MARK: Old
            
        case .getProfile:
            return "get_user_details"
        case .getCategories:
            return "get-categories-list"
        case .getSubCategories:
            return "get-subcategories"
        case .storeFavCategories:
            return "user/favorite"
       
      
        case .get_news:
            return "get_news"
            
        case .createUserProfile:
            return "update_user_profile"
       
        case .termsOfService:
            return "terms-of-service"
       
        case .saveDeviceDetail:
            return "upsert-device-details"
        
        case .getNotification(let param):
            return "get-notification?page=\(param)"
        
        case .deleteAccount:
            return "delete-profile"
       
       
        case .sendChatNotification:
            return "send-chat-notification"
        case .getTipsData:
            return "get-tip-amount"
        case .sendTipAmount:
            return "send-tip-amount"
        case .getSellerAnalytic(let param):
            let filter = param.filter ?? ""
            let start_date = param.start_date ?? ""
            let end_date = param.end_date ?? ""
            return "seller-analytic?filter=\(filter)&start_date=\(start_date)&end_date=\(end_date)"
        case .getExportDetails(let param):
            let filter = param.filter ?? ""
            let start_date = param.start_date ?? ""
            let end_date = param.end_date ?? ""
            let type = param.type ?? ""
            return "export-deatils?type=\(type)&filter=\(filter)&start_date=\(start_date)&end_date=\(end_date)"
        case .getSalesPerformace(let param):
            let filter = param.filter
            let year = param.year
            let month = param.month ?? ""
            var endPoint = ""
            if filter == "monthly" {
                endPoint = "sales-performance?filter=\(filter)&year=\(year)&month=\(month)"
            }
            else if filter == "yearly" {
                endPoint = "seller/sales-performance?filter=\(filter)&year=\(year)"
            }
            return endPoint
        case .getVisitorsAnalytic(let param):
            let filter = param.filter
            let year = param.year
            let month = param.month ?? ""
            var endPoint = ""
            if filter == "monthly" {
                endPoint = "seller/visitor-analytics?filter=\(filter)&year=\(year)&month=\(month)"
            }
            else if filter == "yearly" {
                endPoint = "seller/visitor-analytics?filter=\(filter)&year=\(year)"
            }
            return endPoint
        case .storePromoteShow:
            return "schedule-show/store-promote-show"
            
        case .getLiveSeller:
            return "get-live-seller"
            
        case .getAgoraToken:
            return "agora-token"
            
        case .getSellerInfo(param: let param):
            return "get-seller-info?seller_id=\(param.seller_id)"
        case .getReportSellerCategory:
            return "report-categories"
        case .reportSeller:
            return "report-seller"
        case .storeShipping:
            return "store-shipping-profile"
        case .deleteShippingProfile(param: let param):
            return "delete-shipping-profile/\(param.shipping_profile_id)"
        case .getShippinProfiles:
            return "get-shipping-profile"
        case .getShowOverview(param: let param):
            return "get-show-overview?show_id=\(param.show_id)"
        case .updateProductStatus:
            return "update-product-status"
            
            //MARK: - V1
//        case .getUserProduct:
//            return "get-user-product"
        case .getProduct:
            return "get-product"
//        case .getItemList(let param):
//            return "product/fetch-by-status?type=\(param.type)&page=\(param.page)"
        case .getPromoteToolDetails(param: let param):
            return "promote-tool-details?filter=\(param.filter)"
        case .checkValidShowDate:
            return "check-schedule-show"
        case .getScheduleShow(param: let param):
            return "get-show-details-by-id?show_id=\(param.show_id)"
        case .orderReceipt:
            return "product/order-receipt"
        case .saveProduct:
            return "product/save"
        case .getCoupon:
            return "get-coupon"
        case .updateVacation:
            return "update-vacation-mode-status"
        case .makeClip(param: let param):
            return "make-clip"
        case .getclip(param: let param):
            return "get-clips?seller_id=\(param.sellerId ?? "")&page=\(param.page)"
        case .createSurprise:
            return "store-surprise-product"
        case .getSurprise:
            return "get-surprise-product"
        case .editProductPrice(param: let param):
            return "edit-product-set-item-unit"
        case .deleteProductSuppriseSet(param: let param):
            return "delete-product-set"
        case .storeDomesticShipment(param: let param):
            return "save-domestic-shipment-setting"
        case .SaveShippingCosts(param: let param):
            return "save-shipping-costs"
        case .getShippinDetails:
            return "get-shipping-details"
        case .unifiedSearch:
            return "search"
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
        case .sellerHubInfo:
            return .get
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
        case .premierShop:
            return .get
        case .applyPremierShop:
            return .post
        case .promoteTool:
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
//        case .getInventory:
//            return .post
        case .storeProduct:
            return .post
        case .getAllTips:
            return .post
            
        case .storeAddress:
            return .post
        case .deleteNotification:
            return .post
        case .getNotificationListing:
            return .post
            
        case .getAddress:
            return .get
        case .getMyPurchasedOrder:
            return .post
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
            
     
            
            
        case .followUnfollow:
            return .post
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
        case .sellerVerification:
            return .post
        case .buyerIdentityList:
            return .get
        case .sellerIdentityFetch:
            return .get
        case .notificationListing:
            return .get
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
        case .searching:
            return .post
        case .promo:
            return .post
        case .getReferralCode:
            return .get
        case .getPurchasedOrderDetails:
            return .post
        case .addCard:
            return .post
        case .updateCard:
            return .post
        case .deleteCard:
            return .post
//        case .setDefaultCard:
//            return .post
        case .getCard:
            return .get
        case .getTransactionList:
            return .post
        case .storeScheduleShow:
            return .post
        case .updateScheduleShow:
            return .post
        case .getScheduledShow:
            return .post
        case .UpdateShowStatus:
            return .post
        case .getBidList:
            return .get
       
        case .getprofile:
            return .get
        case .updateProfile:
            return .post
        case .countUpdate:
            return .post
        case .storeBid:
            return .post
        case .sellerStatus:
            return .get
        case .setDefaultCard:
            return .post
        case .getState:
            return .get
        case .uploadProductImage:
            return .post
        case .deleteProduct:
            return .post
        case .blockUser:
            return .post
        case .blockedUserList:
            return .get
        case .getMailClass:
            return .get
        case .getUspsShippingPrice:
            return .get
        case .getPromoteShow:
            return .get
            
            //MARK: Old
            
        case .getProfile:
            return .get
            
        case .getCategories:
            return .get
        case .getSubCategories:
            return .post
        case .storeFavCategories:
            return .post
        case .createUserProfile:
            return .post
        
       
        case .get_news:
            return .get
        
        case .termsOfService:
            return .get
        
        case .saveDeviceDetail:
            return .post
       
        case .getNotification:
            return .get
       
        case .deleteAccount:
            return .post
      
      
        case .getWalletInfo:
            return .get
        case .getPayOutHistory:
            return .post
        case .getKycDetails:
            return .get
        case .checkKYC:
            return .post
        case .fundTransfer:
            return .post
        case .getTotalRating:
            return .get
        case .addRating:
            return .post
        case .sendChatNotification:
            return .post
        case .getTipsData:
            return .get
        case .sendTipAmount:
            return .post
        case .getSellerAnalytic:
            return .get
        case .getExportDetails:
            return .get
        case .getSalesPerformace:
            return .get
        case .getVisitorsAnalytic:
            return .get
        case .storePromoteShow:
            return .post
        
        case .getLiveSeller:
            return .get
        case .getAgoraToken:
            return .post
        case .getReportSellerCategory:
            return .get
        case .reportSeller:
            return .post
        case .getSellerInfo:
            return .get
        case .storeShipping:
            return .post
        case .deleteShippingProfile:
            return .post
        case .getShippinProfiles:
            return .get
        case .getShowOverview:
            return .get
        case .updateProductStatus:
            return .post
            
            //MARK: V1
//        case .getUserProduct:
//            return .post
        case .getProduct:
            return .post
//        case .getItemList:
//            return .post
        case .getPromoteToolDetails:
            return .get
        case .checkValidShowDate:
            return .post
        case .getScheduleShow:
            return .get
        case .orderReceipt:
            return .post
        case .saveProduct:
            return .post
        case .getCoupon:
            return .get
        case .updateVacation:
            return .post
        case .makeClip:
            return .post
        case .getclip(param: _):
            return .get
        case .createSurprise(param: let param):
            return .post
        case .getSurprise:
            return .get
        case .editProductPrice(param: let param):
            return .post
        case .deleteProductSuppriseSet(param: let param):
            return .post
        case .storeDomesticShipment(param: let param):
            return .post
        case .SaveShippingCosts(param: let param):
            return .post
        case .getShippinDetails:
            return .get
        case .unifiedSearch:
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
        case .sellerHubInfo:
            return nil
        case .aboutUs:
            return nil
        case .premierShop:
            return nil
        case .applyPremierShop:
            return nil
        case .promoteTool:
            return nil
        case .contact(let param):
            return param
        case .verifyOTP(let param):
            return param
//        case .getInventory(let param):
//            return param
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
        case .storeProduct:
            return nil
        case .getAllTips(let param):
            return param
            
        case .storeAddress(param: let param):
            return param
        case .getAddress:
            return nil
            
        case .getMyPurchasedOrder(param: let param):
            return param
            
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
        case .getLiveShows(param: let param):
            return param
        case .getProfileById(param: let param):
            return param
       
        case .followUnfollow(param: let param):
            return param
            
            
            //MARK: Faz
        case .deleteNotification(param: let param):
            return param
        case .getNotificationListing:
            return nil
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
        case .sellerVerification:
            return nil
        case .buyerIdentityList:
            return nil
        case .sellerIdentityFetch:
            return nil
        case .notificationListing:
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
        case .makeOfferList:
            return nil
        case .offerUpdateStatus(param: let param):
            return param
        case .searching(param: let param):
            return param
        case .promo(param: let param):
            return param
        case .getReferralCode:
            return nil
        case .getPurchasedOrderDetails(param: let param):
            return param
        case .addCard(param: let param):
            return param
        case .updateCard(param: let param):
            return param
        case .deleteCard(param: let param):
            return param
        case .setDefaultCard(param: let param):
            return param
        case .getCard:
            return nil
        case .getTransactionList(param: let param):
                return param
//        case .storeScheduleShow(param: let param):
//            return param
        case .storeScheduleShow:
            return nil
        case .updateScheduleShow:
            return nil
       
        case .getScheduledShow(param: let param):
            return param
        case .UpdateShowStatus(param: let param):
            return param
        case .getBidList:
            return nil
       
        case .getprofile:
            return nil
        case .updateProfile(param: let param):
            return param
        case .countUpdate(param: let param):
            return param
        case .storeBid(param: let param):
            return param
        case .sellerStatus:
            return nil
//        case .setDefaultCard(param: let param):
//            return param
        case .getState:
            return nil
        case .uploadProductImage:
            return nil
        case .deleteProduct:
            return nil
        case .blockUser(param: let param):
            return param
        case .blockedUserList:
            return nil
        case .getMailClass:
            return nil
        case .getUspsShippingPrice:
            return nil
        case .getPromoteShow:
            return nil
            
            
            
            //MARK: Old
            
        case .getProfile:
            return nil
        case .getCategories:
            return nil
        case .getSubCategories(_):
            return nil
        case .storeFavCategories(_):
            return nil
        
        case .createUserProfile(let param):
            return param
       
        case .get_news:
            return nil
       
        case .termsOfService:
            return nil
        
        case .saveDeviceDetail(let param):
            return param
       
        case .getNotification:
            return  nil
       
        case .deleteAccount(let param):
            return param
      
        case .getWalletInfo:
            return nil
        case .getPayOutHistory:
            return nil
        case .getKycDetails:
            return nil
        case .checkKYC:
            return nil
        case .fundTransfer(let param):
            return param
        case .getTotalRating:
            return nil
        case .addRating(let param):
            return param
        case .sendChatNotification(let param):
            return param
        case .getTipsData:
            return nil
        case .sendTipAmount(let param):
            return param
        case .getSellerAnalytic:
            return  nil
        case .getExportDetails:
            return  nil

        case .getSalesPerformace:
            return  nil
        case .getVisitorsAnalytic:
            return nil
        case .storePromoteShow(let param):
            return param
        case .getLiveSeller:
            return nil
        case .getAgoraToken:
            return nil
        case .getSellerInfo:
            return nil
        case .getReportSellerCategory:
            return nil
        case .reportSeller(param: let param):
            return param
        case .storeShipping(param: let param):
            return param
        case .deleteShippingProfile:
            return nil
        case .getShippinProfiles:
            return nil
        case .getShowOverview:
            return nil
        case .updateProductStatus(param: let param):
            return param
            
        //MARK: V1
        case .getProduct(param: let param):
            return param
//        case .getItemList(param: let param):
//            return param
        case .getPromoteToolDetails:
            return nil
        case .checkValidShowDate(param: let param):
            return param
        case .getScheduleShow:
            return nil
        case .orderReceipt(param: let param):
            return param
        case .saveProduct(param: let param):
            return param
        case .getCoupon:
            return nil
        case .updateVacation(param: let param):
            return param
        case .makeClip(param: let param):
            return param
        case .getclip(param: let param):
            return nil
        case .createSurprise(param: let param):
            return param
        case .getSurprise:
            return nil
        case .editProductPrice(param: let param):
            return param
        case .deleteProductSuppriseSet(param: let param):
            return param
        case .storeDomesticShipment(param: let param):
            return param
        case .SaveShippingCosts(param: let param):
            return param
        case .getShippinDetails:
            return nil
        case .unifiedSearch(let param):
            return param
        }
    }
    
    var jsonBody: [String : Any]? {
        switch self {
        case .login:
            return nil
        case .singUp:
            return nil
        case .aboutUs:
            return nil
        case .premierShop:
            return nil
        case .applyPremierShop:
            return nil
        case .promoteTool:
            return nil
        case .contact:
            return nil
        case .verifyOTP:
            return nil
        case .resetPassword:
            return nil
        case .changePassword:
            return nil
        case .forgotPassword:
            return nil
        case .privacyPolicy:
            return nil
        case .termsCondition:
            return nil
        case .faq:
            return nil
        case .category:
            return nil
        case .auctionType:
            return nil
        case .logout:
            return nil
        case .sellerHubInfo:
            return nil
//        case .getInventory(param: let param):
//            return nil
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
        case .getAllTips:
            return nil
        case .storeProduct(productId: _, param: let param):
            return param
        case .storeAddress:
            return nil
        case .getAddress:
            return nil
        case .getMyPurchasedOrder:
            return nil
        case .setDefaultAddress:
            return nil
        case .getPreference:
            return nil
        case .updatePreference:
            return nil
        case .notifyLiveUser:
            return nil
        case .deleteAddress:
            return nil
        case .getLiveShows:
            return nil
        case .getProfileById:
            return nil
       
        case .followUnfollow:
            return nil
        case .countUpdate(param: _):
            return nil
        case .fetchProduct(param: _):
            return nil
        case .storeIDCard(param: _):
            return nil
        case .storePhoneNumber(param: _):
            return nil
        case .otpVerify(param: _):
            return nil
        case .storePaymentMethod(param: _):
            return nil
        case .buyerIdentityStore:
            return nil
        case .sellerVerification:
            return nil
        case .buyerIdentityList:
            return nil
        case .sellerIdentityFetch:
            return nil
        case .notificationListing:
            return nil
        case .deleteNotification:
            return nil
        case .getMyScheduleShow:
            return nil
        case .getTotalRating:
            return nil
        case .addRating:
            return nil
        case .productOrderListing:
            return nil
        case .productPurchaseDetail:
            return nil
        case .productOrder:
            return nil
        case .productOrderDetails:
            return nil
        case .makeOffer:
            return nil
        case .makeOfferList:
            return nil
        case .offerUpdateStatus:
            return nil
        case .searching:
            return nil
        case .promo:
            return nil
        case .getReferralCode:
            return nil
        case .getPurchasedOrderDetails:
            return nil
//        case .storeScheduleShow(param: let param):
//            return nil
        case .storeScheduleShow:
            return nil
        case .updateScheduleShow:
            return nil
        case .addCard:
            return nil
        case .updateCard:
            return nil
        case .deleteCard:
            return nil
        case .setDefaultCard:
            return nil
        case .getCard:
            return nil
        case .getTransactionList:
            return nil
    
        case .getScheduledShow:
            return nil
        case .UpdateShowStatus:
            return nil
        case .getBidList:
            return nil
       
        case .getNotificationListing:
            return nil
        case .saveDeviceDetail:
            return nil
        case .getWalletInfo:
            return nil
        case .getPayOutHistory:
            return nil
        case .getKycDetails:
            return nil
        case .checkKYC:
            return nil
        case .fundTransfer:
            return nil
        case .getprofile:
            return nil
        case .updateProfile:
            return nil
        case .storeBid:
            return nil
        case .sellerStatus:
            return nil
//        case .setDefaultCard:
//            return nil
        case .getState:
            return nil
        case .uploadProductImage:
            return nil
       
        case .getProfile:
            return nil
        case .getCategories:
            return nil
        case .getSubCategories(let param):
            return param
        case .storeFavCategories(let param):
            return param
        case .get_news:
            return nil
       
        case .createUserProfile:
            return nil
        
        case .termsOfService:
            return nil
        
        case .getNotification:
            return nil
       
        case .deleteAccount:
            return nil
        
        case .sendChatNotification:
            return nil
        case .getTipsData:
            return nil
        case .deleteProduct:
            return nil
        case .blockUser:
            return nil
        case .blockedUserList:
            return nil
        case .getMailClass:
            return nil
        case .getPromoteShow:
            return nil
        case .sendTipAmount:
            return nil
        case .getSellerAnalytic:
            return  nil
        case .getExportDetails:
            return  nil
        case .getSalesPerformace:
            return  nil
        case .getVisitorsAnalytic:
            return nil
        case .storePromoteShow:
            return  nil
        case .getLiveSeller:
            return  nil
        case .getAgoraToken:
            return nil
        case .getSellerInfo:
            return nil
        case .getReportSellerCategory:
            return nil
        case .reportSeller:
            return nil
        case .storeShipping:
            return nil
        case .deleteShippingProfile:
            return nil
        case .getShippinProfiles:
            return nil
        case .getShowOverview:
            return nil
        case .updateProductStatus:
            return nil
            //MARK: - V1
//        case .getUserProduct:
//            return nil
        case .getProduct:
            return nil
//        case .getItemList(param: let param):
//            return nil
        case .getPromoteToolDetails:
            return nil
        case .checkValidShowDate:
            return nil
        case .getScheduleShow:
            return nil
        case .orderReceipt:
            return nil
        case .saveProduct:
            return nil
        case .getCoupon:
            return nil
        case .updateVacation:
            return nil
        case .makeClip:
            return nil
        case .getclip:
            return nil
        case .createSurprise:
            return nil
        case .getSurprise:
            return nil
        case .editProductPrice(param: let param):
            return nil
        case .deleteProductSuppriseSet(param: let param):
            return nil
        case .storeDomesticShipment(param: let param):
            return nil
        case .SaveShippingCosts(param: let param):
            return nil
        case .getShippinDetails:
            return nil
        case .getUspsShippingPrice:
            return nil
        }
    }
    
    
    var headers: [String : String]? {
        APIManager.commonHeaders
    }
}
