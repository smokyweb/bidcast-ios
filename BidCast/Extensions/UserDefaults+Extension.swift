//  BidCast
//
//  Created by Vivek-JAM-E-328 on 31/08/24.

import Foundation

extension UserDefaults{
    
    //MARK: - Login
    
    //remember me
    static var rememberMe:Bool {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.rememberMe)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.rememberMe) as? Bool ?? false
        }
    }
    
    //username
    static var username:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.userName)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.userName) as? String ?? ""
        }
    }
    
    //password
    static var password:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.password)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.password) as? String ?? ""
        }
    }
    
    //name,
    static var name:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.name)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.name) as? String ?? ""
        }
    }
    //first name
    static var firstName:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.firstName)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.firstName) as? String ?? ""
        }
    }
    
    //last name
    static var lastName:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.lastName)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.lastName) as? String ?? ""
        }
    }
    
    //role_id
    static var roleId:Int {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.roleId)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.roleId) as? Int ?? 0
        }
    }
    
    //email
    static var email:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.email)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.email) as? String ?? ""
        }
    }
    
    //profileImage
    static var profileImage:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.profileImage)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.profileImage) as? String ?? ""
        }
    }
    
    //Role
    static var role:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.role)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.role) as? String ?? ""
        }
    }
    
    //address
    static var address:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.address)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.address) as? String ?? ""
        }
    }
    
    //phone
    static var phone:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.phone)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.phone) as? String ?? ""
        }
    }
    
    //userId
    static var userId:Int {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.userId)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.userId) as? Int ?? 0
        }
    }
    
    //token
    static var accessToken:String {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.accessToken)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.accessToken) as? String ?? ""
        }
    }
    
    static var isAppActive:Bool {
        set(input){
            self.standard.setValue(input, forKey: "isAppActive")
        }
        get{
            
            return self.standard.value(forKey: "isAppActive") as? Bool ?? false
        }
    }
    
    //MARK: - OLD
    static var language:String {
        set(input){
            self.standard.setValue(input, forKey: "language")
        }
        get{
            return self.standard.value(forKey: "language") as? String ?? ""
        }
    }
    
    static var admin:Bool {
        set(input){
            self.standard.setValue(input, forKey: "admin")
        }
        get{
            
            return self.standard.value(forKey: "admin") as? Bool ?? false
        }
    }
    static var host:Bool {
        set(input){
            self.standard.setValue(input, forKey: "host")
        }
        get{
            
            return self.standard.value(forKey: "host") as? Bool ?? false
        }
    }
    
    static var profileURL:String {
        set(input){
            self.standard.setValue(input, forKey: "img_Url")
        }
        get{
            return self.standard.value(forKey: "img_Url") as? String ?? ""
        }
    }
    static var userRole:String {
        set(input){
            self.standard.setValue(input, forKey: "user_Role")
        }
        get{
            return self.standard.value(forKey: "user_Role") as? String ?? ""
        }
    }
    static var gameType:String {
        set(input){
            self.standard.setValue(input, forKey: "game_type")
        }
        get{
            return self.standard.value(forKey: "game_type") as? String ?? ""
        }
    }
    static var newCategory:String {
        set(input){
            self.standard.setValue(input, forKey: "new_category")
        }
        get{
            return self.standard.value(forKey: "new_category") as? String ?? ""
        }
    }
    static var baseUrl:String {
        set(input){
            self.standard.setValue(input, forKey: "base_Url")
        }
        get{
            return self.standard.value(forKey: "base_Url") as? String ?? ""
        }
    }
    static var songUrl:String {
        set(input){
            self.standard.setValue(input, forKey: "songUrl")
        }
        get{
            return self.standard.value(forKey: "songUrl") as? String ?? ""
        }
    }
    static var songId:String {
        set(input){
            self.standard.setValue(input, forKey: "songId")
        }
        get{
            return self.standard.value(forKey: "songId") as? String ?? ""
        }
    }

    static var alarmId:Int {
        set(input){
            self.standard.setValue(input, forKey: "alarmId")
        }
        get{
            return self.standard.value(forKey: "alarmId") as? Int ?? 0
        }
    }
    
    static var mediaType:String {
        set(input){
            self.standard.setValue(input, forKey: "mediaType")
        }
        get{
            return self.standard.value(forKey: "mediaType") as? String ?? ""
        }
    }
    static var lastEmail:String {
        set(input){
            self.standard.setValue(input, forKey: "lastEmail")
        }
        get{
            return self.standard.value(forKey: "lastEmail") as? String ?? ""
        }
    }
    static var refreshToken:String {
        set(input){
            self.standard.setValue(input, forKey: "refresh_token")
        }
        get{
            return self.standard.value(forKey: "refresh_token") as? String ?? ""
        }
    }
    static var oneSignalToken:String {
        set(input){
            self.standard.setValue(input, forKey: "oneSignalToken")
        }
        get{
            return self.standard.value(forKey: "oneSignalToken") as? String ?? ""
        }
    }
    static var deviceId:String {
        set(input){
            self.standard.setValue(input, forKey: "deviceId")
        }
        get{
            return self.standard.value(forKey: "deviceId") as? String ?? ""
        }
    }
    
    static var timeInterval:Int {
        set(input){
            self.standard.setValue(input, forKey: "timeInterval")
        }
        get{
            return self.standard.value(forKey: "timeInterval") as? Int ?? 0
        }
    }
   
    static var userData:Data {
        set(input){
            self.standard.setValue(input, forKey: "userData")
        }
        get{
            
            return self.standard.value(forKey: "userData") as! Data
        }
    }
    
    static var settingData:Data {
        set(input){
            self.standard.setValue(input, forKey: "settingData")
        }
        get{
            
            return self.standard.value(forKey: "settingData") as! Data
        }
    }
    static var isSubscribe:Bool {
        set(input){
            self.standard.setValue(input, forKey: "isSubscribe")
        }
        get{
            
            return self.standard.value(forKey: "isSubscribe") as? Bool ?? false
        }
    }
    static var isSubscriptionExpired:Bool {
        set(input){
            self.standard.setValue(input, forKey: "isSubscriptionExpired")
        }
        get{
            
            return self.standard.value(forKey: "isSubscriptionExpired") as? Bool ?? false
        }
    }
    
    static var originalTransactionIdBack:String {
        set(input){
            self.standard.setValue(input, forKey: "originalTransactionIdBack")
        }
        get{
            
            return self.standard.value(forKey: "originalTransactionIdBack") as? String ?? ""
        }
    }
    
    static var originalTransactionIdApple:String {
        set(input){
            self.standard.setValue(input, forKey: "originalTransactionIdApple")
        }
        get{
            
            return self.standard.value(forKey: "originalTransactionIdApple") as? String ?? ""
        }
    }
    
    static var activeProduct:String {
        set(input){
            self.standard.setValue(input, forKey: "activeroduct")
        }
        get{
            
            return self.standard.value(forKey: "activeroduct") as? String ?? ""
        }
    }
    
    static var activeProductExpiry:String {
        set(input){
            self.standard.setValue(input, forKey: "activeProductExpiry")
        }
        get{
            
            return self.standard.value(forKey: "activeProductExpiry") as? String ?? ""
        }
    }
    
    static var subscribeType:String {
        set(input){
            self.standard.setValue(input, forKey: "subscribeType")
        }
        get{
            return self.standard.value(forKey: "subscribeType") as? String ?? ""
        }
    }
    static var subscriptionMessage:String {
        set(input){
            self.standard.setValue(input, forKey: "subscriptionMessage")
        }
        get{
            return self.standard.value(forKey: "subscriptionMessage") as? String ?? ""
        }
    }
    
    static var walkThroughEnabled:String {
        set(input){
            self.standard.setValue(input, forKey: "walkThroughEnabled")
        }
        get{
            return self.standard.value(forKey: "walkThroughEnabled") as? String ?? ""
        }
    }
    
    static var userName:String{
        set(input){
            self.standard.setValue(input, forKey: "userName")
        }
        get{
            
            return self.standard.value(forKey: "userName") as? String ?? ""
        }
    }
    
    static var gameId:String{
        set(input){
            self.standard.setValue(input, forKey: "gameId")
        }
        get{
            
            return self.standard.value(forKey: "gameId") as? String ?? ""
        }
    }
    
    static var userEmail:String{
        set(input){
            self.standard.setValue(input, forKey: "userEmail")
        }
        get{
            
            return self.standard.value(forKey: "userEmail") as? String ?? ""
        }
    }
    static var userPhone:String{
        set(input){
            self.standard.setValue(input, forKey: "userPhone")
        }
        get{
            return self.standard.value(forKey: "userPhone") as? String ?? ""
        }
    }
    static var firstTime : Bool{
        set(input){
            self.standard.setValue(input, forKey: "firstTime")
        }
        get{
            return self.standard.value(forKey: "firstTime") as? Bool ?? false
        }
    }
//    static var userDetails:loginModel{
//        set(input){
//            self.standard.setValue(input, forKey: "userDetails")
//        }
//        get{
//
//            return self.standard.value(forKey: "userDetails") as? loginModel ?? loginModel([String : Any]())
//        }
//    }
    
    static var lastLoginTime:String{
        set(input){
            self.standard.setValue(input, forKey: "lastLoginTime")
        }
        get{
            return self.standard.value(forKey: "lastLoginTime") as? String ?? ""
        }
    }
    static var shouldRestrictApiCallOnBack : Bool{
        set(input){
            self.standard.setValue(input, forKey: "shouldRestrictApiCallOnBack")
        }
        get{
            return self.standard.value(forKey: "shouldRestrictApiCallOnBack") as? Bool ?? false
        }
    }
    //isAgreeTermAndCondition
    static var isAgreeTermAndCondition:Bool {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.isAgreeTermAndCondition)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.isAgreeTermAndCondition) as? Bool ?? false
        }
    }
    //isAgreeTermAndCondition
    static var isAgreePrivacyPolicy:Bool {
        set(input){
            self.standard.setValue(input, forKey: UserDefaultsKeys.isAgreePrivacyPolicy)
        }
        get{
            return self.standard.value(forKey:  UserDefaultsKeys.isAgreePrivacyPolicy) as? Bool ?? false
        }
    }
}


extension UserDefaults {
    func saveUserDetails() {
       
    }
}

extension UserDefaults {
    static func getReadableSubscriptionType() -> String {
        let subscriptionType = UserDefaults.subscribeType
        let subscriptionTypeMap: [String: String] = [
            "io.annually": "Annually Subscription",
            "io.monthly": "Monthly Subscription"
        ]
        return subscriptionTypeMap[subscriptionType] ?? subscriptionType
    }
}
