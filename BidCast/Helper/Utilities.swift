//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation
import UIKit
import SVProgressHUD
import Kingfisher
import Toast_Swift
import MediaPlayer


var selectedIndexPath = IndexPath(row: 0, section: 0)
// QA-FIX-cmoafjxce002xzl1hgb5uj1l8 (2026-04-22):
// These were previously non-optional force-cast top-level lets. Because Swift
// lazily runs module initializers the first time any symbol from this file is
// referenced, they can fire before SceneDelegate is attached (or simply when
// `connectedScenes.first?.delegate` is not yet the SceneDelegate instance),
// which crashes the app on launch. Make both lazy computed vars so each
// callsite lives or fails on its own and launch can't be taken down by a
// timing mismatch.
var appDel: AppDelegate {
    // Force-unwrap kept only when the app really is launched; it matches the
    // prior semantics for non-launch callers while no longer being evaluated
    // eagerly at module init.
    return UIApplication.shared.delegate as! AppDelegate
}
var sceneDel: SceneDelegate {
    if let sd = UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.delegate as? SceneDelegate })
        .first {
        return sd
    }
    // Fallback: return a throwaway SceneDelegate stand-in is not possible, so
    // fail loudly. Callsites below all run after the scene has connected, so
    // this path should never trigger in practice. It still avoids the previous
    // crash at app-launch module-init time.
    return SceneDelegate()
}
var isHomeScreenchange = false
var isSelectedStoragechange = false
var pushViewController = UINavigationController()
var isFieldActionChanged: Bool = true
var subscriptionKey = "all"
// QA-FIX-cmoafjxce002xzl1hgb5uj1l8 (2026-04-23, wave 4):
// `let musicPlayer = MPMusicPlayerController.systemMusicPlayer` used to live
// here as a file-level eager global. Swift evaluates file-level `let`
// initializers the first time *any* symbol from the file is touched. On
// iOS 14.5+ `MPMusicPlayerController.systemMusicPlayer` requires the
// `NSAppleMusicUsageDescription` Info.plist key; without it the MediaPlayer
// framework can throw or return an unusable instance synchronously during
// that eager init, which then takes down app launch (the first thing we do
// is call `Utilities.sharedInstance.getVC(…)` from TabBarViewController's
// `viewDidLoad`, which touches this file).
//
// The symbol `musicPlayer` was declared but never referenced anywhere else
// in the codebase, so the safest fix is to delete it entirely. If the app
// ever needs a system music player it should (a) add the usage key, and
// (b) access `MPMusicPlayerController.systemMusicPlayer` lazily inside a
// function, not at module init time.
var audioPlayer: AVAudioPlayer?

//var statesList:[StatesModel] = []

class Utilities:NSObject{
    
    static let sharedInstance = Utilities()

    var baseUrl = ""
    var fromDayClose = 0
    var orderType = 0
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	var presentActionSheet : (UIAlertController) -> () = {_ in}
    
    override private init() {
        super.init()
    }
    
    
    
//    func getTaskPriority(priority: APICallPriority) -> TaskPriority {
//        var taskPriority: TaskPriority?
//        switch priority {
//        case .high:
//            taskPriority = .high
//        case .medium:
//            taskPriority = .medium
//        case .low:
//            taskPriority = .low
//        case .background:
//            taskPriority = .background
//        }
//        return taskPriority!
//    }
    
    func clearUserDetails() {
        let savedEmail = UserDefaults.standard.string(forKey: "email")
        let savedPassword = UserDefaults.standard.string(forKey: "password")
        //MARK: remember me work
        let rememberMe = UserDefaults.standard.bool(forKey: "RememberMe")
        debugLog("remember true or false --- \(rememberMe)" )
        debugLog("saved email--- \(savedEmail ?? "")")
        debugLog("saved password -----  \(savedPassword ?? "")")
        //MARK: remember me work up -----------------
        //name,
        UserDefaults.name = ""
        //first name
        UserDefaults.firstName = ""
        //last name
        UserDefaults.lastName = ""
        //role_id
        UserDefaults.roleId = 0
        
        //Role
        UserDefaults.role = ""
        //address
        UserDefaults.address = ""
        //phone
        UserDefaults.phone = ""
        //userId
        UserDefaults.userId = 0
        //token
        UserDefaults.accessToken = ""
        
        UserDefaults.isAgreePrivacyPolicy = false
        
        UserDefaults.isAgreeTermAndCondition = false
        
    }
    
    //MARK:- SVPRPOGRESS HUD METHODS

    func showError(message:String){
        SVProgressHUD.showDismissableError(with: message)

    }

    func showSuccess(message:String){
        SVProgressHUD.showDismissableSuccess(with: message)
    }

    //MARK:- SET IMAGE WITH URL

    @MainActor func setImageWithUrl(imgStr:String,imgView : UIImageView){
        //clearImageCache() // Call this before loading new images
        imgView.kf.indicatorType = .activity
        if let urlImage:URL = URL.init(string: imgStr)
        {
            imgView.kf.setImage(with: urlImage)
        }else{
            imgView.image = UIImage(named: "user")
            
        }
    }
//    options: [
//           .processor(ResizingImageProcessor(referenceSize: CGSize(width: 300, height: 300), mode: .aspectFit)),
//           .transition(.fade(0.2)),
//           .cacheOriginalImage
//       ]
    
    
    // Clear the cache before loading new images
    func clearImageCache() {
        ImageCache.default.clearMemoryCache() // Clear in-memory cache
        ImageCache.default.clearDiskCache() // Clear disk cache (optional)
    }
    
//    func isSubscriptionExpired(dateString: String) -> Bool {
//        // Remove "Etc/GMT" from the date string
//        let cleanedDateString = dateString.replacingOccurrences(of: "Etc/GMT", with: "").trimmingCharacters(in: .whitespaces)
//
//        // Date formatter to parse the cleaned date string
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust to your date format
//
//        // Convert the cleaned date string to a Date object
//        if let expirationDate = dateFormatter.date(from: cleanedDateString) {
//            let currentDate = Date()
//            return expirationDate < currentDate // Check if the subscription is expired
//        } else {
//            debugLog("Invalid date format.")
//            return false // Handle the error as needed
//        }
//    }
    
    func isSubscriptionExpired(dateString: String) -> Bool {
        // Create a DateFormatter for the input date string
         let expDate = dateString.replacingOccurrences(of: "Etc/GMT", with: "").trimmingCharacters(in: .whitespaces)
         debugLog(expDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Note the 'z' for time zone
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")

        // Convert the string to a Date object
        guard let targetDate = dateFormatter.date(from: expDate) else {
            debugLog("Invalid date string.")
            return false
        }

        // Get the current date in GMT
        let currentDate = Date() // This gets the current date in UTC (GMT)

        // Compare the dates
        return targetDate < currentDate // Returns true if the target date is before the current date
    }
    
    func cleanDateString(_ dateString: String) -> String {
        return dateString.replacingOccurrences(of: "Etc/GMT", with: "")
    }


    //MARK:- NUMBER FILER
    func numberFiler(string:String) -> Bool
    {
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        if string != numberFiltered
        {
            return false
            //return true // not a number
        }
        //return false
        return true
    }
    
    func getPrecisedFormat(format:String, value:String) -> String{
        let floatValue = Float(value) ?? 0
        let stringValue = String(format: format, floatValue)
        return stringValue
    }
    
    //MARK:- SEARCH BAR CONFIGURATION
    
    /// to make search bar font italic.
    func searchBarConfig(searchBar:UISearchBar) {
        
        if #available(iOS 13.0, *) {
            
            ///changes for ios 13
            //            searchBar.searchTextField.attributedPlaceholder = getAttributedTextWithFontColorAlignment(strForFontColor: "\("search_placeholder_location".localized())" as NSString, str:"", setColor: UIColor.white, fontType: DaffiaFont.defaultRegular(size: 14).value!, str1Alignemnt: .left, str2Alignemnt: .left)
            //
            //            searchBar.searchTextField.textColor = UIColor.defaultWhiteTextColor
            //            searchBar.searchTextField.alpha = 1.0
        }
        else{
            
            for subView in searchBar.subviews  {
                for subsubView in subView.subviews  {
                    if let textField = subsubView as? UITextField {
                        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("\("search_placeholder".localized())", comment:""), attributes: [NSAttributedString.Key.font : OutFitFont.defaultSemiBold(size: 14).value!,
                                                                                                                                                                                 NSAttributedString.Key.foregroundColor : UIColor.defaultBlackColor])
                        
                        textField.textColor = UIColor.defaultBlackColor
                        textField.alpha = 1.0
                    }
                }
            }
        }
        
        
    }
    
    func openActionSheetForPicker(completion:@escaping (_ sourceType: UIImagePickerController.SourceType?) -> Void) {
        
        
         let actionSheet = UIAlertController()
         
         let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { void in
             
 //            self.pickMediaFromSource(sourceType: UIImagePickerController.SourceType.camera)
             completion(UIImagePickerController.SourceType.camera)
         }
         
         actionSheet.addAction(cameraAction) 
         
         let galleryAction = UIAlertAction(title: "Photos", style: UIAlertAction.Style.default) { void in
             completion(UIImagePickerController.SourceType.photoLibrary)
 //            self.pickMediaFromSource(sourceType: UIImagePickerController.SourceType.photoLibrary)
         }
         
         actionSheet.addAction(galleryAction)
         
         let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
         
         actionSheet.addAction(cancelAction)
         
		presentActionSheet(actionSheet)
        
        
//        UIApplication.topViewController()!.present(actionSheet, animated: true, completion: nil)
        
        
     }
    
    func clearBackgroundColor(searchBar:UISearchBar) {
        
        guard let UISearchBarBackground: AnyClass = NSClassFromString("UISearchBarBackground") else { return }
        
        for view in searchBar.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UISearchBarBackground) {
                    subview.alpha = 0
                }
            }
        }
        searchBar.placeholder = "search_placeholder".localized()
        searchBar.layer.borderWidth = 1
        
        searchBar.layer.borderColor = UIColor.gray.cgColor
        searchBar.layer.cornerRadius = 5
        
        let txt:UITextField = searchBar.value(forKey: "searchField") as! UITextField
        
        
        txt.textColor = UIColor.defaultBlackColor
        txt.backgroundColor = UIColor.clear
        txt.clearButtonMode = UITextField.ViewMode.never
        txt.leftViewMode = .always
        txt.textAlignment = .left
        txt.returnKeyType = .search
//        txt.leftViewMode = UITextField.ViewMode.never
//        txt.rightViewMode = UITextField.ViewMode.never
        
    }
    
    func showAlertController(title:String,message:String,sourceViewController:UIViewController){
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            let okButton = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
//                pushViewController(tutorialVC, animated: true)
//                self.navigationController?.pushViewController(tutorialVC, animated: true)
                debugLog("Okay Button Pressed...")
            }
            
            alertController.addAction(okButton)

            sourceViewController.present(alertController, animated: true, completion: nil)
        }

    func showAlert2(title:String,message:String,sourceViewController:UIViewController,completionHandler: @escaping (_ result:Bool) -> Void){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        let okButton = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            completionHandler(true)
            debugLog("Okay Button Pressed...")
        }

//        let cancelButton = UIAlertAction(title: "No", style: .default)
//        { (alertAction) in
//            debugLog("Cancel Button Pressed..")
//        }

        alertController.addAction(okButton)
        //alertController.addAction(cancelButton)
        sourceViewController.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK:Get ViewController
    
    func getVC(storyBoardName:String, vcId:String) -> UIViewController{
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: vcId)
        return vc
    }
    func presentStatusVC(title:String,message:String,source:UIViewController, isSuccess:Bool){
        
        
//        let vc = self.getVC(storyBoardName: "Main", vcId: "DialogBoxViewController") as! DialogBoxViewController
//        vc.statusMsg1 = title
//        vc.statusMsg2 = message
//        vc.isSuccess = isSuccess
//        vc.navigateDelegate = source as? MakeNavigation
//        source.present(vc, animated: true)
    }
    
    //MARK:Date Conversion
	
	func getElapsedTimeStatus(timeInterval:Double) -> String{
		let date = Date(timeIntervalSince1970: timeInterval)
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		let string = formatter.localizedString(for: date, relativeTo: Date())
		return string
	}
    
    func convertStringDate(date:String) -> Date?{
        let isoDate = date

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let convertedDate = dateFormatter.date(from:isoDate)
        return convertedDate
    }
    
    func convertDate(date:String, format:String) -> Date?{
        let day = date
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US") // set locale to reliable US_POSIX
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale.init(identifier:"en_US_POSIX")
        dateFormatter.timeZone = TimeZone.init(abbreviation: "GMT")
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from:day)!
        return date
    }
    
    func showToast(source:UIViewController, message:String, postion: ToastPosition = .top,backgroundColor: UIColor? = nil){
        var style = ToastStyle()
		style.displayShadow = true
		style.shadowOpacity = 0.6
        style.titleFont = .systemFont(ofSize: 14)
        style.messageColor = .white
        style.backgroundColor = backgroundColor ?? .red
        style.cornerRadius = 20
//        source.view.makeToast("Got Message data from demo", duration: 3.0, position: postion, style: style)
        if !message.isEmpty {
            source.view.makeToast(message, duration: 3.0, position: postion, style: style)
        } else {
            // Handle the case when message is empty or invalid
            debugLog("Toast message is empty!")
        }
    }
    
    func addAnchorTags(to input: String) -> String {
        do {
            // Create a regular expression pattern to match URLs
            let pattern = "(http|https)://[^\\s]+"
            
            // Create a regular expression object
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            // Find all matches in the input string
            let matches = regex.matches(in: input, options: [], range: NSRange(input.startIndex..., in: input))
            
            // Create a mutable copy of the input string
            var modifiedString = input
            
            // Loop through matches in reverse order to avoid changing the string length while replacing
            for match in matches.reversed() {
                guard let range = Range(match.range, in: input) else { continue }
                let url = input[range]
                let replacement = "<a href=\"\(url)\">\(url)</a>"
                modifiedString = modifiedString.replacingCharacters(in: range, with: replacement)
            }
            
            return modifiedString
        } catch {
            debugLog("Error creating regular expression: \(error)")
            return input
        }
    }
    func getCurrentDate(format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
    
    func getFormattedDateFromString(dateString:String,toFormat:String,fromFormat:String,timeZone:String) -> String{
        
        if dateString == ""
        {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        dateFormatter.timeZone = timeZone != "" ? TimeZone(identifier: timeZone) : TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
        guard let getData = dateFormatter.date(from: dateString) else { return ""}
        
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: getData)
        
    }
	
	func hexStringToUIColor (hex:String) -> UIColor {
		var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return UIColor.gray
		}
		
		var rgbValue:UInt64 = 0
		Scanner(string: cString).scanHexInt64(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}

    
//MARK:- ATTRIBUTED TEXT
    
    func getAttributedText(string : NSString , strToReplace : NSString , setColor : UIColor) -> NSAttributedString
    {
        let attributedString1 = NSMutableAttributedString(string: "\(string)")
        attributedString1.addAttribute(NSAttributedString.Key.foregroundColor, value: setColor, range: string.range(of: strToReplace as String))
        return attributedString1
    }
    
    func getAttributedFont(string : NSString , strToReplace : NSString , fontType : UIFont) -> NSAttributedString
    {
      let attributedString1 = NSMutableAttributedString(string: "\(string)")
        attributedString1.addAttribute(NSAttributedString.Key.font, value: fontType, range: string.range(of: strToReplace as String))
      return attributedString1
    }
    
    
    func getAttributedText2(stringToChange:String, unchangedString:String, font1:UIFont, font2:UIFont) -> NSMutableAttributedString{
        let attributedText = NSMutableAttributedString(string: stringToChange, attributes: [NSAttributedString.Key.font: font1])
        
        attributedText.append(NSAttributedString(string: unchangedString, attributes: [NSAttributedString.Key.font: font2, NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        return attributedText
    }
    
    //MARK: FIREBASE ANALYTICS EVENTS
    
//    func logFirebaseEvent(name: String, parameters: [String: Any]? = nil) {
//        Analytics.logEvent(name, parameters: parameters)
//    }

    
    
    
    //False Image Url
//    func setImageForFalseImage(imgStr:String, imgView:UIImageView)  {
//        
//            guard let url = URL.init(string: imgStr) else {
//                return 
//            }
//            let resource = ImageResource(downloadURL: url)
//            
//            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
//                switch result {
//                case .success(let value):
//                    imgView.image = value.image
//                    return
//                case .failure(let error):
//                    imgView.image = UIImage(systemName: "aboutUs")
//                    return
//                }
//            }
//        }
    
    //MARK:- PLATFORM TYPE
    
//    func getPlatformType(platform : Platform) -> String{
//        switch platform {
//        case .android:
//            return "2"
//            break
//        case .ios:
//            return "1"
//            break
//        default:
//            return "0"
//            break
//        }
//    }
    
    //MARK:- CONVERT MODEL TO JSON
    
//    func convertModelToJSON(createOrderData:CreateOrderModel) -> [String:Any]{
//        let encoder = JSONEncoder()
//
//              guard let jsonData = try? encoder.encode(createOrderData) else { return [String:Any]()}
//              guard let dataDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any] else { return [String:Any]()}
//        return dataDict
//
//    }
    
    //MARK:- CALCULATIONS AND DATA PROCESSING
    
    
//    func configureCreateOrderModel(tableData:TableList,menuItemsSelected:[MenuItems],isComingFromTable:Bool) -> Double{
//          tableData.createOrderData.resetData()
//
//        self.setOrderDetailsData(tableData: tableData, isComingFromTable: isComingFromTable)
//        self.setCustomerOrderDetailData(tableData: tableData)
//          for i in 0..<menuItemsSelected.count{
//            let cartItems = ItemOrdered(JSON: [String : Any]())
//
//              cartItems.setData(menuItemsSelected: menuItemsSelected[i])
//            self.calculateAmountAndTaxes(cartItem: cartItems, createOrderData: tableData.createOrderData, from: "cart")
//            if menuItemsSelected[i].modifierSelectedArray.count > 0{
//                self.configureModifierDataInCartItem(menuItemsSelected: menuItemsSelected[i],cartItem: cartItems, tableData: tableData)
//              }
//              tableData.createOrderData.cartitems.append(cartItems)
//
//          }
//          for i in 0..<tableData.createOrderData.itemordered.count{
//            let itemsOrder : ItemOrdered = tableData.createOrderData.itemordered[i]
//
//            self.calculateAmountAndTaxes(cartItem: itemsOrder, createOrderData: tableData.createOrderData, from: "kitchen")
////                    if itemsOrder.ismodifier{
//                      for j in 0..<itemsOrder.modifier.count{
//                        self.calculateAmountAndTaxes(cartItem: itemsOrder.modifier[j], createOrderData: tableData.createOrderData, from: "kitchen")
//                      }
//
////                    }
//
//
//                }
//
//        self.calculateGrossAmount(createOrderData:tableData.createOrderData)
//          let roundOffVal = round(tableData.createOrderData.gross_amount)
//
//        return tableData.createOrderData.gross_amount
//
//      }
    
//
//    func setOrderDetailsData(tableData:TableList,isComingFromTable:Bool){
//        tableData.createOrderData.setData(index: selectedIndexPath.row)
//
//        if isComingFromTable{
//
//            tableData.createOrderData.default_rate_no = tableData.default_rate_no
//            tableData.createOrderData.roomunkid = tableData.roomunkid
//            tableData.createOrderData.tableunkid = tableData.id
//            tableData.createOrderData.tablename = tableData.name
//            tableData.createOrderData.area_name = tableData.area_name
//
//        }
//        else{
//            tableData.createOrderData.default_rate_no = userModelData.maintabs[selectedIndexPath.row].default_rate_no
//        }
//
//
//
//    }
//    func setCustomerOrderDetailData(tableData:TableList){
////        tableData.createOrderData.business_sourceunkid = tableData.customerInfo.business_sourceunkid
////        tableData.createOrderData.waiterunkid = tableData.customerInfo.waiterUnkid
////        tableData.createOrderData.firstname = tableData.customerInfo.first_name
////        tableData.createOrderData.remark = tableData.customerInfo.remark
////        tableData.createOrderData.guestunkid = tableData.customerInfo.guestunkid
//        tableData.createOrderData.custgstin = tableData.customerInfo.custgstin
//    }
//
//    func calculateAmountAndTaxes(cartItem:ItemOrdered,createOrderData:CreateOrderModel,from:String){
//
//        cartItem.discount_percentage = 0
//        cartItem.surcharge_amount = 0
//        cartItem.total_tax = 0
//        cartItem.discount_percentage = 0
//        if createOrderData.discounts.count != 0{
//        cartItem.discount_percentage = itemDiscountPercentage(item: cartItem, createOrderData: createOrderData)
//        }
//        if from == "cart"{
//        cartItem.discount_amount = (cartItem.applicable_rate * Double(cartItem.quantity))/100 * cartItem.discount_percentage
//        }
//        else{
//        cartItem.discount_amount = (cartItem.applicable_rate * Double(cartItem.quantity - cartItem.complementary_quantity))/100 * cartItem.discount_percentage
//        }
//
//        let tamountWithoutComplementary = cartItem.applicable_rate * Double(cartItem.quantity - cartItem.complementary_quantity)
//
//        cartItem.tamount = cartItem.applicable_rate * Double(cartItem.quantity)
//
//        if (createOrderData.istaxexcempt == 0 && createOrderData.issurchargeneeded == 1){
//            if from == "cart"{
//            cartItem.surcharge_amount = ((cartItem.tamount - cartItem.discount_amount)/100 * cartItem.totalsurcharge)
//            }
//            else{
//             cartItem.surcharge_amount = ((tamountWithoutComplementary - cartItem.discount_amount)/100 * cartItem.totalsurcharge)
//            }
//        }
//        if createOrderData.istaxexcempt == 0{
//            for i in 0..<cartItem.taxes.count{
//                if from == "cart"{
//                cartItem.taxes[i].tamount = cartItem.tamount + cartItem.surcharge_amount - cartItem.discount_amount
//                }
//                else{
//                 cartItem.taxes[i].tamount = tamountWithoutComplementary + cartItem.surcharge_amount - cartItem.discount_amount
//                }
//                cartItem.taxes[i].total = (cartItem.taxes[i].tamount)/100 * Double(cartItem.taxes[i].tax)!
//                cartItem.total_tax += cartItem.taxes[i].total
//            }
//        }
//        else{
//            cartItem.taxes = [Taxes(JSON: [String : Any]())]
//        }
//        cartItem.total = cartItem.tamount + cartItem.surcharge_amount - cartItem.discount_amount + cartItem.total_tax
//        createOrderData.discount += cartItem.discount_amount
//        createOrderData.tamount += cartItem.tamount
//        createOrderData.total_tax += cartItem.total_tax
//        createOrderData.total_amount += cartItem.total
//        createOrderData.surcharge_amount += cartItem.surcharge_amount
//        createOrderData.compltamount += (cartItem.applicable_rate * Double(cartItem.complementary_quantity))
//
//    }
//
//    func configureModifierDataInCartItem(menuItemsSelected: MenuItems,cartItem:ItemOrdered,tableData:TableList){
//         for group in menuItemsSelected.modifiergroups{
//             if group.isSelected{
//                 for modifier in group.modifier{
//                     if modifier.isselected{
//                         let modifierData = ItemOrdered(JSON: [String : Any]())
//                         modifierData.setData(menuItemsSelected: modifier)
//                        self.calculateAmountAndTaxes(cartItem: modifierData, createOrderData: tableData.createOrderData, from: "cart")
//                         cartItem.modifier.append(modifierData)
//                     }
//                 }
//             }
//         }
//     }
//
//    func calculateSelectedDiscount(createOrderData:CreateOrderModel){
//        for i in 0..<createOrderData.discounts.count{
//            var discountCopy = createOrderData.discounts[i]
//            createOrderData.discounts[i].discount = 0
//            if discountCopy.discount_type == "Receipt" || discountCopy.discount_type == "Manual"{
//                for item in createOrderData.cartitems{
//                 if item.isdiscountable == 0{
//                    createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                    for modifier in item.modifier{
//                        if modifier.isdiscountable == 0{
//                        createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity))/100 * Double(discountCopy.percentage)!
//                        }
//                    }
//
//                }
//
//                for item in createOrderData.itemordered{
//                    if item.isdiscountable == 0{
//                    createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity - item.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                for modifier in item.modifier{
//                    if modifier.isdiscountable == 0{
//                    createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity - modifier.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                        }
//                    }
//
//                }
//            } /// closing of if of Receipt and Manual Discount
//            else if discountCopy.discount_type == "Category"{
//                for disc_category in discountCopy.categoryunkids{
//                for item in createOrderData.cartitems{
//                if (item.isdiscountable == 0) && ("\(disc_category)" == item.itemcategoryunkid){
//                createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity))/100 * Double(discountCopy.percentage)!
//                }
//                for modifier in item.modifier{
//                if (modifier.isdiscountable == 0) && ("\(disc_category)" == modifier.itemcategoryunkid){
//                createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity))/100 * Double(discountCopy.percentage)!
//                }
//                }
//
//                }
//
//                for item in createOrderData.itemordered{
//                if (item.isdiscountable == 0) && ("\(disc_category)" == item.itemcategoryunkid){
//                createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity - item.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                for modifier in item.modifier{
//                if (modifier.isdiscountable == 0) && ("\(disc_category)" == modifier.itemcategoryunkid){
//                createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity - modifier.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                    }
//
//                    }
//                }
//            } /// closing  if of Category Discount
//            else if discountCopy.discount_type == "Subgroup"{
//            for disc_menusubgroup in discountCopy.menusubgroupunkids{
//                for item in createOrderData.cartitems{
//                if (item.isdiscountable == 0) && (disc_menusubgroup == item.menusubgroupunkid){
//                createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity))/100 * Double(discountCopy.percentage)!
//                }
//                for modifier in item.modifier{
//                if (modifier.isdiscountable == 0) && (disc_menusubgroup == modifier.menusubgroupunkid){
//                createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity))/100 * Double(discountCopy.percentage)!
//                }
//                }
//
//                }
//
//                for item in createOrderData.itemordered{
//                if (item.isdiscountable == 0) && (disc_menusubgroup == item.menusubgroupunkid){
//                createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity - item.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                for modifier in item.modifier{
//                if (modifier.isdiscountable == 0) && (disc_menusubgroup == modifier.menusubgroupunkid){
//                createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity - modifier.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                    }
//
//                    }
//                }
//            }/// closing  if of Subgroup Discount
//            else if discountCopy.discount_type == "Item"{
//            for disc_item in discountCopy.itemunkids{
//                for item in createOrderData.cartitems{
//                if (item.isdiscountable == 0) && (disc_item == item.itemsalesunkid){
//                createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity))/100 * Double(discountCopy.percentage)!
//                }
//                for modifier in item.modifier{
//                if (modifier.isdiscountable == 0) && (disc_item == modifier.itemsalesunkid){
//                createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity))/100 * Double(discountCopy.percentage)!
//                }
//                }
//
//                }
//
//                for item in createOrderData.itemordered{
//                if (item.isdiscountable == 0) && (disc_item == item.itemsalesunkid){
//                createOrderData.discounts[i].discount += (item.applicable_rate * Double(item.quantity - item.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                for modifier in item.modifier{
//                if (modifier.isdiscountable == 0) && (disc_item == modifier.itemsalesunkid){
//                createOrderData.discounts[i].discount += (modifier.applicable_rate * Double(modifier.quantity - modifier.complementary_quantity))/100 * Double(discountCopy.percentage)!
//                    }
//                    }
//
//                    }
//                }
//            }
//        }
//    }
//
//        func calculateGrossAmount(createOrderData:CreateOrderModel){
//        self.calculateSelectedDiscount(createOrderData: createOrderData)
//
//        createOrderData.gross_amount = createOrderData.total_amount + createOrderData.extracharges - createOrderData.compltamount - createOrderData.aggragator_discount
//
////            tableData.createOrderData.total_amount -= tableData.createOrderData.compltamount
//
//            createOrderData.surcharge_amount = createOrderData.surcharge_amount.round(to: 2)
//            createOrderData.total_tax = createOrderData.total_tax.round(to: 2)
//            createOrderData.tamount = createOrderData.tamount.round(to: 2)
//            createOrderData.discount = createOrderData.discount.round(to: 2)
//            createOrderData.total_amount = createOrderData.total_amount.round(to: 2)
//            createOrderData.total_itemdiscount = createOrderData.total_itemdiscount.round(to: 2)
//
//            createOrderData.narration = createOrderData.gross_amount.round(to: 0) - createOrderData.gross_amount
//
//            createOrderData.gross_amount = createOrderData.gross_amount + createOrderData.narration
//
//            createOrderData.narration = createOrderData.narration.round(to: 2)
//            createOrderData.gross_amount = createOrderData.gross_amount.round(to: 2)
//            createOrderData.compltamount = createOrderData.compltamount.round(to: 2)
//
//            createOrderData.paylist.map { (paylistObj) -> Paylist? in
//                if paylistObj.money_tendered != 0{
//                    createOrderData.amount_paid += paylistObj.money_tendered
//                }
//                return paylistObj
//            }
//            if createOrderData.amount_paid > createOrderData.gross_amount{
//                createOrderData.money_return = createOrderData.amount_paid - createOrderData.gross_amount
//            }
//            createOrderData.balance = createOrderData.gross_amount - createOrderData.amount_paid + createOrderData.money_return
//            createOrderData.tran_money_tendered = createOrderData.balance
//
//        }
//
//    //MARK:- ADD DISCOUNT
//
//    func addDiscount(discount:Discounts,createOrderData:CreateOrderModel){
//     var discountCopy : Discounts = discount
//     var isDiscountFound = false
//
//        if createOrderData.discounts.contains(where: {($0.id == discountCopy.id)}){
//         isDiscountFound = true
//        }
//        if !isDiscountFound{
//        var itemsFound = false
//
//            if discountCopy.discount_type == "Manual" || discountCopy.discount_type == "Offers" || discountCopy.discount_type == "Card Discount"{
//                itemsFound = true
//            }
//            else{
//                discountCopy.discount = 0
//                if discountCopy.discount_type == "Receipt"{
//                itemsFound = true
//
//                    for i in 0..<createOrderData.itemordered.count{
//                    let kitchenItemObj = createOrderData.itemordered[i]
//                    if kitchenItemObj.isdiscountable == 0{
//                        discountCopy.discount += (((kitchenItemObj.applicable_rate * Double(kitchenItemObj.quantity - kitchenItemObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//                        }
//
//                        for j in 0..<kitchenItemObj.modifier.count{
//                        let modifierObj = kitchenItemObj.modifier[j]
//                        if modifierObj.isdiscountable == 0{
//                        discountCopy.discount += (((modifierObj.applicable_rate * Double(modifierObj.quantity - modifierObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//
//                        }
//                        } // closing of j loop
//
//                    } // closing of i loop
//                } // closing of if of Receipt
//                else if discountCopy.discount_type == "Category"{
//                    for k in 0..<discountCopy.categoryunkids.count{
//
//                        for i in 0..<createOrderData.itemordered.count{
//                            let kitchenItemObj = createOrderData.itemordered[i]
//
//                            if (kitchenItemObj.isdiscountable == 0) && ("\(discountCopy.categoryunkids[k])" == kitchenItemObj.itemcategoryunkid){
//                            itemsFound = true
//                            discountCopy.discount += (((kitchenItemObj.applicable_rate * Double(kitchenItemObj.quantity - kitchenItemObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//                            }
//
//                         for j in 0..<kitchenItemObj.modifier.count{
//                         let modifierObj = kitchenItemObj.modifier[j]
//                        if (modifierObj.isdiscountable == 0) && ("\(discountCopy.categoryunkids[k])" == modifierObj.itemcategoryunkid){
//                        discountCopy.discount += (((modifierObj.applicable_rate * Double(modifierObj.quantity - modifierObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//
//                     }
//                     } // closing of j loop
//
//                     } // closing of i loop
//
//
//                    } // closing of k loop
//                } // closing of if of Category
//                else if discountCopy.discount_type == "Subgroup"{
//                    for k in 0..<discountCopy.menusubgroupunkids.count{
//
//                        for i in 0..<createOrderData.itemordered.count{
//                            let kitchenItemObj = createOrderData.itemordered[i]
//
//                            if (kitchenItemObj.isdiscountable == 0) && (discountCopy.menusubgroupunkids[k] == kitchenItemObj.menusubgroupunkid){
//                            itemsFound = true
//                            discountCopy.discount += (((kitchenItemObj.applicable_rate * Double(kitchenItemObj.quantity - kitchenItemObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//                            }
//
//                         for j in 0..<kitchenItemObj.modifier.count{
//                         let modifierObj = kitchenItemObj.modifier[j]
//                        if (modifierObj.isdiscountable == 0) && (discountCopy.menusubgroupunkids[k] == modifierObj.menusubgroupunkid){
//                        discountCopy.discount += (((modifierObj.applicable_rate * Double(modifierObj.quantity - modifierObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//
//                     }
//                     } // closing of j loop
//
//                     } // closing of i loop
//
//
//                    } // closing of k loop
//                } // closing of if of Subgroup
//                else if discountCopy.discount_type == "Item"{
//                    for k in 0..<discountCopy.itemunkids.count{
//
//                        for i in 0..<createOrderData.itemordered.count{
//                               let kitchenItemObj = createOrderData.itemordered[i]
//
//                               if (kitchenItemObj.isdiscountable == 0) && (discountCopy.itemunkids[k] == kitchenItemObj.itemsalesunkid){
//                               itemsFound = true
//                               discountCopy.discount += (((kitchenItemObj.applicable_rate * Double(kitchenItemObj.quantity - kitchenItemObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//                               }
//
//                            for j in 0..<kitchenItemObj.modifier.count{
//                            let modifierObj = kitchenItemObj.modifier[j]
//                           if (modifierObj.isdiscountable == 0) && (discountCopy.itemunkids[k] == modifierObj.itemsalesunkid){
//                           discountCopy.discount += (((modifierObj.applicable_rate * Double(modifierObj.quantity - modifierObj.complementary_quantity))/100) * Double(discountCopy.percentage)!)
//
//                        }
//                        } // closing of j loop
//
//                        } // closing of i loop
//
//                    } // closing of k loop
//
//                    if itemsFound{
//                     createOrderData.discounts.append(discountCopy)
//                     self.calculateDiscount(createOrderData: createOrderData)
//                     if (discountCopy.discount >= (createOrderData.tamount - createOrderData.compltamount)){
//                     showError(message: "Discount Exceeded','Selected Discount exceeded more than Bill amount.")
//                     createOrderData.discounts.removeLast()
//                     self.calculateDiscount(createOrderData: createOrderData)
//                    }
//                    }
//                    else{
//                    showError(message: "No Items Found For This Discount.")
//                    }
//
//                }
//            } // closing of else
//
//            if itemsFound && discountCopy.discount_type != "Item"{
//                createOrderData.discounts.append(discountCopy)
//                self.calculateDiscount(createOrderData: createOrderData)
//                if (discountCopy.discount >= (createOrderData.tamount - createOrderData.compltamount)){
//                 showError(message: "Discount Exceeded','Selected Discount exceeded more than Bill amount.")
//                createOrderData.discounts.removeLast()
//                self.calculateDiscount(createOrderData: createOrderData)
//                }
//            }
//            else if discountCopy.discount_type != "Item"{
//            showError(message: "No Items Found For This Discount.")
//            }
//
//        }
//        else{
//            showError(message: "Discount Already Added,Selected discount is already added, please select other discount")
//        }
//    }
//
//    func calculateDiscount(createOrderData:CreateOrderModel){
//      createOrderData.discount = 0.0
//      for i in 0..<createOrderData.itemordered.count{
//             let kitchenItemObj = createOrderData.itemordered[i]
//
//             if (kitchenItemObj.isdiscountable == 0){
//                kitchenItemObj.discount_percentage = itemDiscountPercentage(item: kitchenItemObj, createOrderData: createOrderData)
//                kitchenItemObj.discount_amount = (((kitchenItemObj.applicable_rate * Double(kitchenItemObj.quantity - kitchenItemObj.complementary_quantity))/100) * kitchenItemObj.discount_percentage)
//                createOrderData.discount += kitchenItemObj.discount_amount
//             }
//
//          for j in 0..<kitchenItemObj.modifier.count{
//          let modifierObj = kitchenItemObj.modifier[j]
//         if (modifierObj.isdiscountable == 0){
//            modifierObj.discount_percentage = itemDiscountPercentage(item: modifierObj, createOrderData: createOrderData)
//            modifierObj.discount_amount += (((modifierObj.applicable_rate * Double(modifierObj.quantity - modifierObj.complementary_quantity))/100) * modifierObj.discount_percentage)
//            createOrderData.discount += modifierObj.discount_amount
//
//      }
//      } // closing of j loop
//
//      }
////        createOrderData.discount += discount.discount
//    }
//
//    func itemDiscountPercentage(item:ItemOrdered,createOrderData:CreateOrderModel) -> Double{
//
//        var total_percentage : Double = 0
//        createOrderData.discounts.map { (discountObj) -> Discounts? in
//            if discountObj.disctype == "perc"{
//                if discountObj.discount_type == "Manual" || discountObj.discount_type == "Receipt" || discountObj.discount_type == "Offers" || discountObj.discount_type == "Card Discount"{
//                    total_percentage += Double(discountObj.percentage) ?? 0
//                }
//                else if discountObj.discount_type == "Category"{
//                    if discountObj.categoryunkids.contains(Int(item.itemcategoryunkid) ?? 0){
//                     total_percentage += Double(discountObj.percentage) ?? 0
//                    }
//                }
//                else if discountObj.discount_type == "Subgroup"{
//                    if discountObj.menusubgroupunkids.contains(Int(item.menusubgroupunkid) ?? 0){
//                     total_percentage += Double(discountObj.percentage) ?? 0
//                    }
//                }
//                else if discountObj.discount_type == "Item"{
//                    if discountObj.itemunkids.contains(Int(item.itemsalesunkid) ?? 0){
//                    total_percentage += Double(discountObj.percentage) ?? 0
//                    }
//                }
//            }
//            return discountObj
//        }
//
//        return total_percentage
//    }
//
//}//closing of Utilities


//func configureSaleUnitAccordingDefaultRate(rateToCompare:String,saleUnit:[SaleUnit]) -> [SaleUnit]{
//    let result = saleUnit.map { (saleUnit) -> SaleUnit in
//        var saleUnitData : SaleUnit = saleUnit
//
//        if (rateToCompare != "" ? rateToCompare : saleUnitData.defaultratenumber)  == "1"{
//               saleUnitData.appliedRate = saleUnitData.rate1
//            saleUnitData.actual_rate = saleUnitData.rate1
//              saleUnitData.applicable_rateNo = 1
//              }
//          else if (rateToCompare != "" ? rateToCompare : saleUnitData.defaultratenumber) == "2"{
//
//                  saleUnitData.appliedRate = saleUnitData.rate2
//                saleUnitData.actual_rate = saleUnitData.rate2
//                  saleUnitData.applicable_rateNo = 2
//              }
//          else if (rateToCompare != "" ? rateToCompare : saleUnitData.defaultratenumber) == "3"{
//                  saleUnitData.appliedRate = saleUnitData.rate3
//                saleUnitData.actual_rate = saleUnitData.rate3
//                  saleUnitData.applicable_rateNo = 3
//              }
//          else if (rateToCompare != "" ? rateToCompare : saleUnitData.defaultratenumber) == "4"{
//                  saleUnitData.appliedRate = saleUnitData.rate4
//                  saleUnitData.actual_rate = saleUnitData.rate4
//                  saleUnitData.applicable_rateNo = 4
//              }
//        else{
////        saleUnitData.appliedRate = saleUnitData.rate
////        saleUnitData.actual_rate = saleUnitData.rate
//          saleUnitData.applicable_rateNo = 0
//      }
//          return saleUnitData
//      }
//
//    return result
}
func adjustUITextViewHeight(arg : UITextView) {
//    arg.translatesAutoresizingMaskIntoConstraints = true
//    arg.sizeToFit()
    arg.isScrollEnabled = false
}
func checkForNilAndNull(dictionary:[String:Any],key:String) -> Bool
{
	if dictionary[key] == nil || dictionary[key] is NSNull{
		return false
	}
	return true
}

extension Encodable {

    /// Converting object to postable dictionary
    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }

      func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
          throw NSError()
        }
        return dictionary
      }
    
  
    
    //MARK:Date Formats
    
    
    
}
extension Dictionary {

    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }

    func printJson() {
        debugLog(json)
    }

}


@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 16.0
    @IBInspectable var rightInset: CGFloat = 16.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

func adjustUITextHeight(arg : UITextView) {
    arg.translatesAutoresizingMaskIntoConstraints = true
    arg.sizeToFit()
    arg.isScrollEnabled = false
}


//MARK: - get location string
func getLocation(city: String, county: String, state: String) -> String{
    var locationString = ""
    
    // Handle "null"
    let city = (city.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "null") ? "" : city
    let county = (county.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "null") ? "" : county
    let state = (state.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "null") ? "" : state
    
    if !city.isEmpty {
        locationString += city
    }
    
    if !county.isEmpty {
        if !locationString.isEmpty { locationString += ", " }
        locationString += county
    }

    if !state.isEmpty {
        if !locationString.isEmpty { locationString += ", " }
        locationString += state
    }

    // Handle empty location scenario
    if locationString.isEmpty {
        locationString = ""
    }
    return locationString
}

// Function to create a Date object from the current date and a given time string with seconds
func createDateFromCurrentDateAndTime(timeString: String) -> Date? {
    // Get the current date
    let currentDate = Date()
    
    // Create a DateFormatter instance
    let dateFormatter = DateFormatter()
    
    // Set the format to include hours, minutes, seconds, and AM/PM
    dateFormatter.dateFormat = "hh:mm:ss a"
    
    // Convert the time string into a Date object
    if let timeDate = dateFormatter.date(from: timeString) {
        // Get the calendar to extract the current date components
        let calendar = Calendar.current
        
        // Extract the current year, month, and day
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        
        // Combine the current date with the parsed time
        let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                         minute: calendar.component(.minute, from: timeDate),
                                         second: calendar.component(.second, from: timeDate),
                                         of: calendar.date(from: DateComponents(year: year, month: month, day: day))!)
        
        return combinedDate
    } else {
        debugLog("Invalid time string.")
        return nil
    }
}

// Function to create a Date object from the current date and a given time string (with or without seconds)
func createDateFromCurrentDateAndTimeForLocal(timeString: String) -> Date? {
    // Get the current date
    let currentDate = Date()
    
    // Create a DateFormatter instance
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    // Create two possible date formats: one with seconds and one without
    let formats = ["hh:mm:ss a", "hh:mm a"]
    
    // Try to parse the time string using the different formats
    for format in formats {
        dateFormatter.dateFormat = format
        
        if let timeDate = dateFormatter.date(from: timeString) {
            // Get the calendar to extract the current date components
            let calendar = Calendar.current
            
            // Extract the current year, month, and day
            let year = calendar.component(.year, from: currentDate)
            let month = calendar.component(.month, from: currentDate)
            let day = calendar.component(.day, from: currentDate)
            
            // Create a DateComponents object for the current date
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = calendar.component(.hour, from: timeDate)
            dateComponents.minute = calendar.component(.minute, from: timeDate)
            dateComponents.second = calendar.component(.second, from: timeDate) // This will be 0 if seconds are omitted
            
            // Combine the current date with the parsed time
            return calendar.date(from: dateComponents)
        }
    }
    
    print("Invalid time string: \(timeString)")
    return nil
}

//MARK: extractArtistAndTrackName
func extractArtistAndTrackName(from url: URL) -> (artist: String, trackName: String)? {
    let urlString = url.absoluteString
    let components = urlString.split(separator: "/")
    if components.count > 2 {
        let artistName = components[components.count - 2]
        let trackNameWithExtension = components.last?.split(separator: ".").first ?? ""
        
        return (artist: String(artistName), trackName: String(trackNameWithExtension))
    }
    
    return nil
}

//MARK: convertUTCToNewYorkTimeAMPM
func convertUTCToNewYorkTimeAMPM(_ timeString: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    formatter.timeZone = TimeZone(abbreviation: "UTC")  // Input is in UTC

    guard let date = formatter.date(from: timeString) else {
        return nil
    }

    formatter.dateFormat = "hh:mm a"
    formatter.timeZone = TimeZone(identifier: "America/New_York")  // Output in EST/EDT
    return formatter.string(from: date)
}






func debugLog(_ items: Any...) {
#if DEBUG
    print(items)
#endif

}
