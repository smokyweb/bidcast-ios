//
//  Strings.swift
//  BidCast
//
//  Created by JAM-E-174 on 03/10/24.
//

import Foundation

enum AppString{
    
    enum VCName{
        static let riseShineSwing = "RISE SHINE & SWING"
        static let forgotPassword = "FORGOT PASSWORD"
        static let newPassword = "NEW PASSWORD"
        static let enterCode = "ENTER CODE"
        static let updatePassword = "UPDATE PASSWORD"
        static let createYourAccount = "Create Your Account"
        static let home = "HOME"
        static let newAlarm = "NEW ALARM"
        static let editAlarm = "EDIT ALARM"
        static let subscriptions = "SUBSCRIPTIONS"
        static let logOut = "Logout"
        static let aboutUs = "ABOUT US"
        static let contactUs = "CONTACT US"
        static let deleteAccount = "DELETE ACCOUNT"
        static let privacyPolicy = "PRIVACY POLICY"
        static let termsAndConditions = "TERMS & CONDITIONS"
        static let faq = "FAQ"
        static let more = "MORE"
        static let myMusic = "MY MUSIC"
        static let myProfile = "MY PROFILE"
        static let addMusic = "MUSIC LIBRARY"
        static let Inventory = "Inventory"
        static let activity = "Activity"
        static let shows = "Shows"
        static let myOrders = "My Orders"
        static let wallet = "Wallet"
        static let offer = "Offer"
        static let tips = "Tips"
        static let analytics = "Analytics"
        static let shipping = "Shipping"
        static let sellerStatus = "Seller Status"
        

    }
    
    enum Header{
        static let enterCode = "ENTER CODE"
        static let createYourAccount = "Create Your Account"
        static let success = "Success!"
        static let alert = "Alert"
        static let forgotPassword = "FORGOT PASSWORD"
        static let privacyPolicy = "PRIVACY POLICY"
        static let termAndConditions = "TERM & CONDITIONS"
        static let home = "HOME"
        static let myAlarms = "MY ALARMS"
        static let newAlarm = "NEW ALARM"
        static let aboutUs = "ABOUT US"
        static let details = "DETAILS"
        static let faq = "FAQ"
        static let myMusic = "MY MUSIC"
        static let contactUs = "CONTACT US"
        static let logOut = "LOGOUT"
        static let delete = "DELETE"
        static let newPassword = "NEW PASSWORD"
        static let updatePassword = "Update Password"
        static let addMusic = "MUSIC LIBRARY"
        static let upgrade = "UPGRADE"
        static let removeSong = "REMOVE SONG"
        
    }
    
    enum Title{
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): match Android
        // sign-in field labels (`@string/email` = "Email", `@string/password` = "Password").
        static let password = "Password"
        static let oldPassword = "OLD PASSWORD"
        static let code = "ENTER CODE"
        static let confirmPassword = "CONFIRM PASSWORD"
        static let myAlarms = "My Alarms"
        static let alarmTitle = "Alarm Title"
        static let firstName = "FIRST NAME"
        static let lastName = "LAST NAME"
        static let email = "Email"
        static let zipCode = "ZIP CODE"
        static let confirmPass = "CONFIRM PASSWORD"
        static let phoneNumber = "PHONE NUMBER"
        static let message = "MESSAGE"
        static let sureYouWantLogout = "Are you sure you want to logout?"
        static let home = "Home"
        static let myAccount = "My Account"
        static let AboutUs = "About Us"
        static let contactUS = "Contact Us"
        static let faq = "FAQ"
        static let privacyPolicy = "Privacy Policy"
        static let termOfService = "Term of Service"
        static let logOut = "Logout"
        static let ourSubscription = "SUBSCRIPTIONS"
        static let newAlarm = "New Alarm"
        static let reasonForDeletion = "Reason For Deletion"
        static let getSubscription = "Get subscription as per your need"
        static let updatePassword = "UPDATE PASSWORD"
        static let addSong = "Add Song"
        static let availableBalance = "Available Balance"
        static let payOutHistory = "Payout History"
        
    
    }
    
    enum Placeholder{
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): match Android
        // sign-in placeholders. Android uses `Enter Your Email` for the email
        // field and `***********` for the password field.
        static let emailAddress = "Enter Your Email"
        static let enterCode = "Enter Code"
        static let password = "***********"
        static let oldpassword = "Enter Old Password"
        static let confirmPassword = "Confirm New Password"
        static let firstName = "Enter First Name"
        static let lastName = "Enter Last Name"
        static let email = "Enter Email Address"
        static let zipCode = "Enter Zip Code"
        static let confirmPass = "Enter Confirm Password"
        static let phoneNumber = "Enter Phone Number"
        static let message = "Type your message here..."
  
    }
    
    enum Description{
//        static let enterEmailMessage = "Please enter the email address associated with your account."
        static let incorrectAddress = "Incorrect Email Address"
        static let enterEmailMessage = "Enter the email address connected to your account."
        static let emailNotAssociatedMessage =  "The email address you entered is not associated with an account. Please try again with a different email."
        
        static let tooManyAttempt = "Too many attempts. Please try again after in 120 sec."
        static let successNewPassword = "Success! Please enter your new password below."
        static let successUpdatePassword = "Success! Please update your password below."
        static let enterCodeSent = "Enter the code sent to your email address."
        static let incorrectCode = "Incorrect Code"
        static let lorelumpsum = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit,sed diam nonummy nibh euismod tinciduaoreet dolore magna aliquam erat volutpat. Ut wisi enim ad veniam, quis nostrud exerci tation ullamcorper Ut wisi ed minim veniam suscipit lobortis nisl ut aliquip ex ea commodo Lorem ipsum dolor sit amet, consectetuer adipiscing elit,sed diam nonummy nibh euismod tinciduaoreet dolore magna aliquam erat volutpat. Ut wisi enim ad veniam, quis nostrud exerci tation ullamcorper Ut wisi ed minim veniam suscipit lobortis nisl ut aliquip ex ea commodo Lorem ipsum dolor sit amet, consectetuer adipiscing elit,sed diam nonummy nibh euismod tinciduaoreet dolore magna aliquam erat volutpat. Ut wisi enim ad veniam, quis nostrud exerci tation ullamcorper Ut wisi ed minim veniam suscipit lobortis nisl ut aliquip ex ea commodo Lorem ipsum dolor sit amet, consectetuer adipiscing elit,sed diam nonummy nibh euismod tinciduaoreet dolore magna aliquam erat volutpat. Ut wisi enim ad veniam, quis nostrud exerci tation ullamcorper Ut wisi ed minim veniam suscipit lobortis nisl ut aliquip ex ea commodo Lorem ipsum dolor sit amet, consectetuer adipiscing elit,sed diam nonummy nibh euismod tinciduaoreet dolore magna aliquam erat volutpat. Ut wisi enim ad veniam, quis nostrud exerci tation ullamcorper Ut wisi ed minim veniam suscipit lobortis nisl ut aliquip ex ea commodo Ut wisi enim ad veniam, quis nostrud exerci tation ullamcorper Ut wisi ed minim veniam suscipit lobortis nisl ut aliquip ex ea commodo Lorem ipsum dolor sit amet "
        static let lorem = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit,sed diam nonummy nibh euismod tinciduaoreet dolore magna aliquam erat volutpat. Ut wisi enim ad veniam, quis nostrud exerci tation ullamcorper Ut wisi ed minim veniam suscipit lobortis nisl ut aliquip ex ea commodo ."
        static let accountDeleteNote = "Deleting your account is irreversible and will permanently erase all your data. This action cannot be undone. Please consider carefully before proceeding."
        static let noSubscriptionsAvailable = "No Subscriptions Found"
        static let noMusicAvailable = "No Music Found"
    }
    
    enum NoData{
        
    }
    
    enum BtnTitle{
        //NEW
        static let sendCode = "Send Code"
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): match Android
        // CTA copy (`@string/login` = "Login").
        static let signIn = "Login"
        static let resendCode = "RESEND CODE"
        static let continues = "CONTINUE"
        static let home = "HOME"
        static let enterCode = "Enter Code"
        static let submit = "SUBMIT"
        static let ok = "Ok"
        static let login = "LOGIN"
        static let exit = "EXIT"
        static let myMusic = "MY MUSIC"
        static let yes = "YES"
        static let no = "NO"
        static let delete = "DELETE"
        static let addMusic = "MUSIC LIBRARY"
       
    }
    enum Validation{
        static let enterPassword = "Please enter password"
        static let enterConfirmPassword = "Please enter Confirm Password"
        static let passwordMismatch = "Please make sure Password and Confirm Password must be the same"
        
    }
    enum Alert{
        static let messageSent = "Message sent, you will be notified of a response!"
        static let successfullyAccCreated = "You have successfully created your account. Thank you for using “Rise Shine Swing”"
        static let confirmLogout = "Are you sure you want to logout?"
        static let musicAdded = "Music Added Successfully"
        static let profileDetailsUpdated = "Profile Details Updated Successfully"
        static let confirmDeleteProfile = "Are you sure you want to delete your profile?"
        static let deleteAccount = "Your delete account request has been sent successfully."
        static let deleteAlarm = "Are you sure you want to delete Alarm?"
        static let deleteMusic = "Are you sure you want to delete Music?"
        static let greaterThan5MB = "File size is more then 5 MB. Please use file less then that."
        static let upgardeSubscriptionPlan = "You are restricted to upload only one song for more uploads kindly subscribe to the available plans."
        static let freeSubscription = "You have already free subscription plan.Please choose different plan for more acccess"
        static let allReadySubscribed = "You already have an active subscription for this plan. Please choose a different plan."
        static let alreadyPaidSubscribedPlan = "You already have an active paid subscription plan."
        static let MusicUploadLimit = "Please Subscribe for upload more music."
        static let chooseSongFirst = "Please Choose Music for Upload"
        static let songAlreadyExistInLibrary = "Song already exists in music library."
        static let deleteMusicWithoutSub = "Upgrade to add more songs"
        static let deleteMusicWithSub = "Delete to swap songs"
        static let areYouSureToRemoveFromCate = "Are you sure you want to remove song from category?"
        static let musicDeletedSuccessfully = "Music deleted successfully"
        static let chooseMp3Song = "Please choose mp3 song."
    }
    
    enum navigateFrom{
        static let signUp = "SignUp"
        static let profile = "Profile"
        static let addAlarm = "Add Alarm"
        static let editAlarm = "Edit Alarm"
    }
    
    enum subscriptionType{
        static let annually = "io.annually"
        static let monthly = "io.monthly"
        static let onetime = "io.rise.onetime"
        static let free = "Free"
        
    }
}




