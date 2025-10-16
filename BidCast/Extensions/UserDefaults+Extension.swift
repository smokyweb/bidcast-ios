//
//  UserDefaults+Extension.swift
//  MentorPOS
//
//  Created by admin on 3/3/20.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation

extension UserDefaults{

    static var language:String {
        set(input){
            self.standard.setValue(input, forKey: "language")
        }
        get{
            return self.standard.value(forKey: "language") as? String ?? ""
        }
    }
    static var linkedSpotify:Bool {
        set(input){
            self.standard.setValue(input, forKey: "linkedSpotify")
        }
        get{
            
            return self.standard.value(forKey: "linkedSpotify") as? Bool ?? false
        }
    }
    
    static var allowBidForAllUser:Bool{
        set(input){
            self.standard.setValue(input, forKey: "allowBidForAllUser")
        }
        get{
            
            return self.standard.value(forKey: "allowBidForAllUser") as?  Bool ?? false
        }
    }
    
    static var linkedAppleMusic:Bool {
        set(input){
            self.standard.setValue(input, forKey: "linkedAppleMusic")
        }
        get{
            
            return self.standard.value(forKey: "linkedAppleMusic") as? Bool ?? false
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
    
    static var isLiveEnded:Bool {
        set(input){
            self.standard.setValue(input, forKey: "isLiveEnded")
        }
        get{
            
            return self.standard.value(forKey: "isLiveEnded") as? Bool ?? false
        }
    }
    
    static var isFirstShowCreated:Bool {
        set(input){
            self.standard.setValue(input, forKey: "isFirstShowCreated")
        }
        get{
            
            return self.standard.value(forKey: "isFirstShowCreated") as? Bool ?? false
        }
    }
    
    static var accessToken:String {
        set(input){
            self.standard.setValue(input, forKey: "access_token1")
        }
        get{
            return self.standard.value(forKey: "access_token1") as? String ?? ""
        }
    }
    
    static var FCMToken:String {
        set(input){
            self.standard.setValue(input, forKey: "FCMToken")
        }
        get{
            return self.standard.value(forKey: "FCMToken") as? String ?? ""
        }
    }
    
    static var pdfURL: URL? {
            get {
                if let urlString = self.standard.string(forKey: "pdfURL") {
                    return URL(fileURLWithPath: urlString)
                }
                return nil
            }
            set(input) {
                if let url = input {
                    self.standard.setValue(url.path, forKey: "pdfURL")
                } else {
                    self.standard.removeObject(forKey: "pdfURL")
                }
            }
        }
    
    static var accessTokenS:String {
        set(input){
            self.standard.setValue(input, forKey: "access_token")
        }
        get{
            return self.standard.value(forKey: "access_token") as? String ?? ""
        }
    }
    static var creationYear:String {
        set(input){
            self.standard.setValue(input, forKey: "creationYear")
        }
        get{
            return self.standard.value(forKey: "creationYear") as? String ?? ""
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
    
    static var userNameAdd:String {
        set(input){
            self.standard.setValue(input, forKey: "userNameAdd")
        }
        get{
            return self.standard.value(forKey: "userNameAdd") as? String ?? ""
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
    static var firebaseToken:String {
        set(input){
            self.standard.setValue(input, forKey: "firebase_token")
        }
        get{
            return self.standard.value(forKey: "firebase_token") as? String ?? ""
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
            self.standard.setValue(input, forKey: "deviceId")
        }
        get{
            return self.standard.value(forKey: "deviceId") as? Int ?? 0
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
    static var Houtlet:String {
        set(input){
            self.standard.setValue(input, forKey: "Houtlet")
        }
        get{
            return self.standard.value(forKey: "Houtlet") as? String ?? ""
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
    
    static var fullName:String{
        set(input){
            self.standard.setValue(input, forKey: "fullName")
        }
        get{
            
            return self.standard.value(forKey: "fullName") as? String ?? ""
        }
    }
    
    static var sellerVerafied : String{
        set(input){
            self.standard.setValue(input, forKey: "sellerVerafied")
        }
        get{
            
            return self.standard.value(forKey: "sellerVerafied") as? String ?? ""
        }
    }
    
    static var sellerAddress : Bool{
        set(input){
            self.standard.setValue(input, forKey: "sellerAddress")
        }
        get{
            
            return self.standard.value(forKey: "sellerAddress") as? Bool ?? false
        }
    }
    
    static var hasCardAdded : Bool{
        set(input){
            self.standard.setValue(input, forKey: "hasCardAdded")
        }
        get{
            
            return self.standard.value(forKey: "hasCardAdded") as? Bool ?? false
        }
    }
    
    static var buyerVerafied : String{
        set(input){
            self.standard.setValue(input, forKey: "buyerVerafied")
        }
        get{
            
            return self.standard.value(forKey: "buyerVerafied") as? String ?? ""
        }
    }
    static var isFirstLogin:Int{
        set(input){
            self.standard.setValue(input, forKey: "isFirstLogin")
        }
        get{
            
            return self.standard.value(forKey: "isFirstLogin") as? Int ?? 0
        }
    }
    
    static var userId:Int{
        set(input){
            self.standard.setValue(input, forKey: "userId")
        }
        get{
            
            return self.standard.value(forKey: "userId") as? Int ?? 0
        }
    }
    
    
    static var EmployerRightSwipe:String?{
        set(input){
            self.standard.setValue(input, forKey: "EmployerRightSwipe")
        }
        get{
            
            return self.standard.value(forKey: "EmployerRightSwipe") as? String ?? ""
        }
    }
    
    static var companyReadAccess:Bool{
        set(input){
            self.standard.setValue(input, forKey: "companyReadAccess")
        }
        get{
            
            return self.standard.value(forKey: "companyReadAccess") as? Bool ?? false
        }
    }
    
    static var isFirstTimeLogin:Bool{
        set(input){
            self.standard.setValue(input, forKey: "isFirstTimeLogin")
        }
        get{
            
            return self.standard.value(forKey: "companyReadAccess") as? Bool ?? false
        }
    }
    
    static var companyWriteAccess:Bool{
        set(input){
            self.standard.setValue(input, forKey: "companyWriteAccess")
        }
        get{
            
            return self.standard.value(forKey: "companyWriteAccess") as?  Bool ?? false
        }
    }
    
    static var companyDeleteAccess:Bool{
        set(input){
            self.standard.setValue(input, forKey: "companyDeleteAccess")
        }
        get{
            
            return self.standard.value(forKey: "companyDeleteAccess") as?  Bool ?? false
        }
    }
    
    static var ActionRead:Bool{
        set(input){
            self.standard.setValue(input, forKey: "ActionRead")
        }
        get{
            
            return self.standard.value(forKey: "ActionRead") as?  Bool ?? false
        }
    }
    
    static var ActionWrite:Bool{
        set(input){
            self.standard.setValue(input, forKey: "ActionWrite")
        }
        get{
            
            return self.standard.value(forKey: "ActionWrite") as?  Bool ?? false
        }
    }
    
    static var ActionDelete:Bool{
        set(input){
            self.standard.setValue(input, forKey: "ActionDelete")
        }
        get{
            
            return self.standard.value(forKey: "ActionDelete") as?  Bool ?? false
        }
    }
    
    static var DocRead:Bool{
        set(input){
            self.standard.setValue(input, forKey: "DocRead")
        }
        get{
            
            return self.standard.value(forKey: "DocRead") as?  Bool ?? false
        }
    }
    
    static var DocWrite:Bool{
        set(input){
            self.standard.setValue(input, forKey: "DocWrite")
        }
        get{
            
            return self.standard.value(forKey: "DocWrite") as?  Bool ?? false
        }
    }
    
    static var DocDelete:Bool{
        set(input){
            self.standard.setValue(input, forKey: "DocDelete")
        }
        get{
            
            return self.standard.value(forKey: "DocDelete") as?  Bool ?? false
        }
    }
    
    static var CalendarRead:Bool{
        set(input){
            self.standard.setValue(input, forKey: "CalendarRead")
        }
        get{
            
            return self.standard.value(forKey: "CalendarRead") as? Bool ?? false
        }
    }
    
    
    static var CalendarWrite:Bool{
        set(input){
            self.standard.setValue(input, forKey: "CalendarWrite")
        }
        get{
            
            return self.standard.value(forKey: "CalendarWrite") as?  Bool ?? false
        }
    }
    
    static var CalendarDelete:Bool{
        set(input){
            self.standard.setValue(input, forKey: "CalendarDelete")
        }
        get{
            
            return self.standard.value(forKey: "CalendarDelete") as?  Bool ?? false
        }
    }
    
    static var InterViewRead:Bool{
        set(input){
            self.standard.setValue(input, forKey: "InterViewRead")
        }
        get{
            
            return self.standard.value(forKey: "InterViewRead") as?  Bool ?? false
        }
    }
    
    static var InterViewWrite:Bool{
        set(input){
            self.standard.setValue(input, forKey: "InterViewWrite")
        }
        get{
            
            return self.standard.value(forKey: "InterViewWrite") as?  Bool ?? false
        }
    }
    
    static var InterViewDelete:Bool{
        set(input){
            self.standard.setValue(input, forKey: "InterViewDelete")
        }
        get{
            
            return self.standard.value(forKey: "InterViewDelete") as?  Bool ?? false
        }
    }
    
   
    
    static var userFirstNameWithApple:String{
        set(input){
            self.standard.setValue(input, forKey: "userFirstNameWithApple")
        }
        get{
            
            return self.standard.value(forKey: "userFirstNameWithApple") as? String ?? ""
        }
    }
    
    static var userLastNameWithApple:String{
        set(input){
            self.standard.setValue(input, forKey: "userLastNameWithApple")
        }
        get{
            
            return self.standard.value(forKey: "userLastNameWithApple") as? String ?? ""
        }
    }
    
    static var userEmailWithApple:String{
        set(input){
            self.standard.setValue(input, forKey: "userEmailWithApple")
        }
        get{
            
            return self.standard.value(forKey: "userEmailWithApple") as? String ?? ""
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
    
    static var rememberMe:Bool{
        set(input){
            self.standard.setValue(input, forKey: "rememberMe")
        }
        get{
            return self.standard.value(forKey: "rememberMe") as? Bool ?? false
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
    
    static var firstName:String{
        set(input){
            self.standard.setValue(input, forKey: "firstName")
        }
        get{
            
            return self.standard.value(forKey: "firstName") as? String ?? ""
        }
    }
    
    static var lastName:String{
        set(input){
            self.standard.setValue(input, forKey: "lastName")
        }
        get{
            
            return self.standard.value(forKey: "lastName") as? String ?? ""
        }
    }
    
    static var password:String{
        set(input){
            self.standard.setValue(input, forKey: "password")
        }
        get{
            
            return self.standard.value(forKey: "password") as? String ?? ""
        }
    }
    
    static var userLocaion:String{
        set(input){
            self.standard.setValue(input, forKey: "userLocaion")
        }
        get{
            
            return self.standard.value(forKey: "userLocaion") as? String ?? ""
        }
    }
    

}
