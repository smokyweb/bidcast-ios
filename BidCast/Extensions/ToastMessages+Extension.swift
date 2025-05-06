//
//  ToastMessages+Extension.swift
//  Rise Shine Swing
//
//  Created by JAM-E-174 on 30/09/24.
//

import Foundation

enum Toast{
    enum Validation{
        //NEW
        static let emptyStreetAdd = "Please enter street address"
        static let emptyAddress = "Please enter address"
        static let emptyCity = "Please enter city"
        static let emptyZipCode = "Please enter zipCode"
        static let emptyState = "Please select state"
        static let emptyPhone = "Please enter phone number"
        static let emptyEmail = "Please enter Email"
        static let emptyMessage = "Please enter message"
        static let emptyDeleteMessage = "Please enter message"
        static let emptyReason = "Please enter message"
        static let emptyOtp = "Please enter OTP"
        static let emptyFirstName = "Please enter first name"
        static let emptyLastName = "Please enter last name"
        static let emptyPassword = "Please enter password"
        static let emptyConfirmPassword = "Please enter confirm password"
        static let passwordsDoNotMatch = "Please make sure password and confirm password must be the same"
        static let emptyCityName = "Please enter city name"
        static let emptyCountyName = "Please enter county name"
        static let emptyStateName = "Please enter state name"
        static let emptyAlarmTitle  = "Please enter alarm title"
        static let emptyAlarmTime  = "Please select alarm time"
        static let emptyAlarmDays  = "Please select alarm days"
        static let emptyAlarmComment  = "Please enter alarm description"
        static let addMusic = "Please add music"
        static let agreeTermPrivacyPolicy = "Please agree to the privacy policy"
        static let agreeTermAndCondition = "Please agree to the term And conditions"
        static let lastNameThreeChar = "The last name field must be at least 3 characters"
    }
    enum Message {
        static let OTPResent = "We have sent Otp again Please check."
        static let limitReached = "Limit reached, upgrade plan to add more songs"
        static let upgradePlan = "Limit reached, Please upgrade your plan to upload more musics."
    }
    enum Network {
        static let noConnection = "The Internet connection appears to be offline."
        static let slowInternet = "You have a poor internet connection, Please check your network and try again."
    }
    enum Confirmation {
      
    }
    enum Alert{
       
    }
}
