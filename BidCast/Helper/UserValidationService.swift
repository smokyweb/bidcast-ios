//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.
//

import UIKit

class UserValidationService {

    // MARK: - Types

    enum ValidationError: LocalizedError {
        case passwordEmpty
        case passwordInvalid
        case emailEmpty
        case emailInvalid
        case nameEmpty
        case amountEmpty
        case cardEmpty
        case nameInvalid
        case mobileNumber
        case mobileNoInvalid
        case birthDate
        case anniDate
        case textFieldEmpty
        case itemNameEmpty
        case validateAmount
        case amount
        case title
        case date
   
        var errorDescription: String? {
            
            switch self {
            case .passwordEmpty:
                return "Password is required"
            case .passwordInvalid:
                return "Password should not contain any space.\nPassword should contain at least one digit(0-9).\nPassword length should be between 8 to 15 characters.\nPassword should contain at least one lowercase letter(a-z).\nPassword should contain at least one uppercase letter(A-Z).\nPassword should contain at least one special character ( @, #, %, &, !, $, etc…)."
//            case.passwordInvalid:
//                return "Password is invalid"
            case .emailEmpty:
                return "Email Address is required"
            case .emailInvalid:
                return "Email Address is invalid"
            case .nameEmpty:
                return "Name is required"
            case .nameInvalid:
                return "Name contains atleast 3 characters"
            case .mobileNumber:
                return "Mobile Number us required."
            case .mobileNoInvalid:
                return "Mobile no. must contain at least 10 numbers"
            case .birthDate:
                return "Birth date is required"
            case .anniDate:
                return "Anniversary date is required"
            case .textFieldEmpty:
                return "Text is required"
            case .itemNameEmpty:
                return "Menu item name required"
            case .validateAmount:
                return "Please enter Amount"
            case .amountEmpty:
                return "Fund Amount is required"
            case .cardEmpty:
                return "No card Found"
            case .amount:
                return "Amount is required"
            case .title:
                return "Title is required"
            case .date:
                return "Date is required"
            }
        }
    }
    
    
    // MARK: - Properties
    
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    static let sharedValidationService = UserValidationService()
    
    
    // MARK: - Validators
    
    func validatePassword(password: String, sourceController:UIViewController) -> Bool {
        let password = password.trim

        guard !password.isEmpty else {
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.passwordEmpty.errorDescription!)
            return false
        }
    
        return true
    }
    func validateTitle(title: String, sourceController:UIViewController) -> Bool {
        let title = title.trim

        guard !title.isEmpty else {
            Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.title.errorDescription!)
            return false
        }
    
        return true
    }
    func validateAmount(amount: String, sourceController:UIViewController) -> Bool {
        let amount = amount.trim

        guard !amount.isEmpty else {
            Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.amount.errorDescription!)
            return false
        }
    
        return true
    }
    func validatedate(date: String, sourceController:UIViewController) -> Bool {
        let date = date.trim

        guard !date.isEmpty else {
            Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.date.errorDescription!)
            return false
        }
    
        return true
    }
    func validateName(_ text:String, sourceController:UIViewController) -> Bool {
        guard !text.isEmpty else {
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.nameInvalid.errorDescription!)
            return false
        }
        //        guard UserValidationService.emailPredicate.evaluate(with: email) else {
        //            Utilities.sharedInstance.showError(message: ValidationError.emailInvalid.errorDescription!)
        //            return false
        //        }
        return true
    }
    
    func validateAmount(_ text:String, sourceController:UIViewController) -> Bool {
        guard !text.isEmpty else {
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.amountEmpty.errorDescription!)
            return false
        }
        return true
    }
    func validateCardEmpty(_ text:String, sourceController:UIViewController) -> Bool {
        guard !text.isEmpty else {
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.cardEmpty.errorDescription!)
            return false
        }
        return true
    }
//    func validateTableArray(_ array:[String]) -> Bool{
//        
//    }

    func validateEmail(_ email: String, sourceController:UIViewController) -> Bool {
        guard !email.isEmpty else {
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.emailEmpty.errorDescription!)
            return false
        }
        return true
    }
    
    func validateEmpty(_ text:String) -> Bool {
        guard !text.isEmpty else {
            Utilities.sharedInstance.showError(message: ValidationError.textFieldEmpty.errorDescription!)
            return false
        }
        return true
    }
    
    func isMobileEmpty(_ text:String,sourceController:UIViewController) -> Bool {
        guard !text.isEmpty else {
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.mobileNumber.errorDescription!)
            return false
        }
        return true
    }
    
    func validateMenuItemName(_ text:String) -> Bool {
        guard !text.isEmpty else {
            Utilities.sharedInstance.showError(message: ValidationError.itemNameEmpty.errorDescription!)
            return false
        }
        return true
    }
    
    func isValidEmail(testStr:String,sourceController:UIViewController) -> Bool {
        
        let emailRegEx = "(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        guard emailTest.evaluate(with: testStr) else{
//            Utilities.sharedInstance.showError(message: ValidationError.emailInvalid.errorDescription!)
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.emailInvalid.errorDescription!)
            return false
        }
        return true
    }
    
    public func isValidPassword(password:String,sourceController:UIViewController) -> Bool {
        
//        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        var passwordRegex = "^[A-Za-z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~].{8,}$"
        
        let passTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        guard passTest.evaluate(with: password) else{
//            Utilities.sharedInstance.showError(message: ValidationError.emailInvalid.errorDescription!)
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.passwordInvalid.errorDescription!)
            return false
        }
        return true
    }
    
    func validateNumber(_ text:String, sourceController:UIViewController) -> Bool {
        
        let mobText = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[0-9]).{10}$")
        
        guard mobText.evaluate(with: text) else {
			Utilities.sharedInstance.showToast(source: sourceController, message: ValidationError.mobileNoInvalid.errorDescription!)
            return false
        }
        return true
    }
    
}
