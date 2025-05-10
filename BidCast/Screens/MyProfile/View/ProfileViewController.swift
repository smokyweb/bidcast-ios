//
//  EditProfileViewController.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-221 on 03/09/24.
//

import UIKit
import SVProgressHUD
import FittedSheets
import AVFoundation
import Photos
import CropViewController

enum ProfileSection: Int,CaseIterable {
    case myProfileHeaderImage
    case ProfileformData
    case updatePassword
    case submitBtn
    case DeleteBtn
    
    func numberOfRows(data: [ProfileSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}
enum ProfileformData : Int,CaseIterable{
    case firstName
    case lastName
    case email
    
    var title : String{
        switch self {
        case .firstName:
            return AppString.Title.firstName
        case .lastName:
            return  AppString.Title.lastName
        case .email:
            return AppString.Title.email
        }
    }
    var placeholder: String {
        switch self {
        case .firstName:
            return AppString.Placeholder.firstName
        case .lastName:
            return AppString.Placeholder.lastName
        case .email:
            return AppString.Placeholder.email
        }
    }
    var image : String{
        switch self {
        case .firstName:
            return "ic_user"
        case .lastName:
            return "ic_user"
        case .email:
            return "ic_mail"
        }
    }
}

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // MARK: IBOutlets.
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var profileTbl: UITableView!
    
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    var isProfileChange: (Bool) -> Void = {_ in}
    
    //MARK: Properties.
    var firstName  = ""
    var lastName  = ""
    var zipCode = ""
    var profilePic: String = ""
    var password  = ""
    var image = ""
    var email = ""
    var selectedImage : UIImage?
    var selectedImageURL : URL?
    var isSelectedImage = false
    var isChangedImage = false
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    var isTapped = false
    //var profileData : ProfileModel?
    var viewModel = ProfileViewModel()
    
    // MARK: Properties
    var sectionData: [ProfileSection: Int] = [
        .myProfileHeaderImage: 1,
        .ProfileformData: 3,
        .updatePassword : 1,
        .submitBtn : 1,
        .DeleteBtn : 1
    ]
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.initialViewModel()
        self.fetchApi()
        if self.profilePic != "" {
            self.isSelectedImage = true
        }
    }
    
    //MARK: Fetch API
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getUserData()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    // MARK: initialViewModel
    func initialViewModel(){
        self.viewModel.userDelegate = self
    }
    
    
    //MARK: sucessDeleteProfile.
//    private func sucessDeleteProfile() {
//        SVProgressHUD.dismiss()
//        if viewModel.deleteProfileDict?.status == "success" {
//            DispatchQueue.main.async {
//                UserDefaults.profileURL = ""
//                self.isChangedImage = false
//                self.selectedImage = UIImage(systemName: "person.circle.fill")
//                self.isSelectedImage = false
//                self.isChangedImage = true
//                self.isProfileChange(true)
//                self.profileTbl.reloadData()
//            }
//        }
//        else {
//            Utilities.sharedInstance.showToast(source: self, message: self.viewModel.deleteProfileDict?.message ?? "")
//        }
//    }
    
    // MARK: tappedSubmitBtn.
    private func tappedSubmitBtn(){
        self.view.endEditing(true)
        if !self.isTapped{
           self.isTapped = true
            if firstName == ""{
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyFirstName)
            }else if lastName == ""{
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyLastName)
            }
            else if self.lastName.count <= 2 {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.lastNameThreeChar)
            }
            else if zipCode == ""{
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyZipCode)
            }
            else if Reachability.isConnectedToNetwork() {
                SVProgressHUD.show()
                let param = ["first_name": self.firstName, "last_name": self.lastName, "zip_code" : self.zipCode] as [String:Any]
                debugLog(param)
                
                if self.selectedImageURL?.absoluteString ?? "" != ""{
                    self.viewModel.editProfileDetails(param: param, keysValue: ["profile_image"], mimeTypes: ["image"], images: [[self.selectedImageURL?.absoluteString ?? ""]])
                }else{
                    self.viewModel.editProfileDetails(param: param, keysValue: [], mimeTypes: [], images: [[]])
                    //                self.viewModel.editProfileDetails(parameters: param)
                }
            } else {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.profileTbl.delegate = self
        self.profileTbl.dataSource = self
        let cellIds = [AppHeaderExpendableCell.identifier,EditProfileCell.identifier,SubmitCell.identifier,TextFieldCell.identifier,RemberMeCell.identifier]
        profileTbl.registerCells(for: cellIds)
        self.profileTbl.separatorStyle = .none
        profileTbl.showsVerticalScrollIndicator = false
        self.headerView.midLbl.text = AppString.VCName.myProfile
        self.headerView.rightButton.isHidden = true
        self.headerView.leftButton.addTarget(self, action: #selector(didTabBack), for: .touchUpInside)
        self.profileTbl.rowHeight = UITableView.automaticDimension
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    // MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    // MARK: didTap.
    func didTap(index:Int){
        
    }
    
    // MARK: didTapShowAlert.
    @objc private func didTapShowAlert(_ sender: Any) {
        let alertController = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        
        // Camera action
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.openCamera()
        }
        
        // Gallery action
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.openGallery()
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: openCamera.
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = .camera
                        imagePicker.allowsEditing = false
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showPermissionAlert(for: "Camera")
                    }
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showNoCameraAlert()
            }
            
        }
    }
    
    //MARK: openGallery.
//        private func openGallery() {
//            PHPhotoLibrary.requestAuthorization { status in
//                if status == .authorized {
//                    DispatchQueue.main.async {
//                        let imagePicker = UIImagePickerController()
//                        imagePicker.delegate = self
//                        imagePicker.sourceType = .photoLibrary
//                        imagePicker.allowsEditing = false
//                        self.present(imagePicker, animated: true, completion: nil)
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        self.showPermissionAlert(for: "Photo Library")
//                    }
//                }
//            }
//        }
    
    //MARK: openGallery.
    private func openGallery() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.allowsEditing = false
                    imagePicker.modalPresentationStyle = .pageSheet
                    self.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert(for: "Photo Library")
                }
            }
        }
    }
    
    //MARK: showNoCameraAlert.
    private func showNoCameraAlert() {
        let alert = UIAlertController(title: "No Camera", message: "This device has no camera", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: showPermissionAlert.
    private func showPermissionAlert(for service: String) {
        let alert = UIAlertController(title: "\(service) Access Denied", message: "Please allow \(service) access in Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            //            self.selectedImage.append(selectedImage)
            //            self.isSelectedImage = true
            //            if let imageURL = info[.imageURL] as? URL {
            //                self.selectedImageURL.append(imageURL)
            //                debugLog("Image URL: \(imageURL)")
            //            }
            //            else {
            //                if let imageData = selectedImage.jpegData(compressionQuality: 0.1) {
            //                    let tempDirectoryURL = FileManager.default.temporaryDirectory
            //                    let imageURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString + ".jpg")
            //                    do {
            //                        try imageData.write(to: imageURL)
            //                        self.selectedImageURL.append(imageURL)
            //                        debugLog("Temporary Image URL: \(imageURL)")
            //                    } catch {
            //                        debugLog("Error saving image to temporary file: \(error)")
            //                    }
            //                }
            //            }
            self.dismiss(animated: true , completion: nil)
            let cropViewController = CropViewController(image: selectedImage)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
            debugLog("Image selected: \(selectedImage)")
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource.
extension ProfileViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ProfileSection(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ProfileSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AlarmSection")
        }
        
        switch rowType {
        case .myProfileHeaderImage:
            let cell = profileTbl.dequeueCell(with: EditProfileCell.self)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapShowAlert))
            cell.userImage.isUserInteractionEnabled = false
            cell.userImage.addGestureRecognizer(tapGesture)
            if  self.isSelectedImage == false {
                cell.deleteBtn.isHidden = true
            }else{
                cell.deleteBtn.isHidden = false
            }
            cell.deleteBtn.isHidden = false
            if self.selectedImage != nil   {
                cell.userImage.image = self.selectedImage
            }else {
                if self.profilePic != ""{
                    Utilities.sharedInstance.setImageWithUrl(imgStr: profilePic, imgView: cell.userImage)
                }
                else {
                    cell.userImage.image = UIImage(systemName: "person.circle.fill")
                }
            }
            cell.contentView.backgroundColor = AppColor.white
            cell.selectionStyle = .none
            cell.didTapDelete = { sender in
                self.didTapShowAlert(sender)
            }
            return cell
        case .ProfileformData:
            guard let rowType = ProfileformData.allCases[safe: indexPath.row] else {
                fatalError("Invalid index for AlarmSection")
            }
            let options : [ProfileformData] = ProfileformData.allCases
            let profileForm = options[indexPath.row]
            switch rowType {
            case .firstName:
                let cell = profileTbl.dequeueCell(with: TextFieldCell.self)
                cell.textFieldOlt.isUserInteractionEnabled = true
                cell.textFieldOlt.placeholder = profileForm.placeholder
                cell.titleLblOlt.text = profileForm.title
                cell.imgIconOlt.image = UIImage(named: profileForm.image)
                cell.textFieldOlt.keyboardType = .alphabet
                cell.textFieldOlt.autocapitalizationType = .sentences
                cell.eyeBtnOlt.isHidden = true
                if self.firstName == ""{
                    cell.textFieldOlt.placeholder = AppString.Placeholder.firstName
                }else{
                    cell.textFieldOlt.text = self.firstName
                }
                cell.entertext = {  [weak self] text in
                    self?.firstName = text.text ?? ""
                }
                return cell
            case .lastName:
                let cell = profileTbl.dequeueCell(with: TextFieldCell.self)
                cell.textFieldOlt.isUserInteractionEnabled = true
                cell.textFieldOlt.placeholder = profileForm.placeholder
                cell.titleLblOlt.text = profileForm.title
                cell.imgIconOlt.image = UIImage(named: profileForm.image)
                cell.textFieldOlt.keyboardType = .alphabet
                cell.textFieldOlt.autocapitalizationType = .sentences
                cell.eyeBtnOlt.isHidden = true
                if self.lastName == ""{
                    cell.textFieldOlt.placeholder = AppString.Placeholder.lastName
                }else{
                    cell.textFieldOlt.text = self.lastName
                }
                cell.entertext = {  [weak self] text in
                    self?.lastName = text.text ?? ""
                }
                return cell
            case .email: //this is zipcode
                let cell = profileTbl.dequeueCell(with: TextFieldCell.self)
                cell.textFieldOlt.isUserInteractionEnabled = false
                cell.textFieldOlt.placeholder = profileForm.placeholder
                cell.titleLblOlt.text = profileForm.title
                cell.imgIconOlt.image = UIImage(named: profileForm.image)
                cell.textFieldOlt.keyboardType = .emailAddress
                cell.eyeBtnOlt.isHidden = true
                if self.email != ""{
                    cell.textFieldOlt.text = self.email
                }else{
                    
                }
                cell.entertext = {  [weak self] text in
                    self?.email = text.text ?? ""
                }
                return cell
            }
        case .updatePassword:
            let cell = profileTbl.dequeueCell(with: RemberMeCell.self)
            cell.rememberMe.isHidden = true
            cell.forgotPaswordOlt.text = AppString.Title.updatePassword
            cell.forgotPaswordOlt.font = JostFont.defaultBold(size: 13).value
            cell.didTapForgot = { sender in
                self.pushVCWithValue(with: NewPasswordViewController.self, storyboardName: .onboardings) { value in
                    value.isComeFromUpdatePass = true
                }
            }
            return cell
        case .submitBtn:
            let cell = profileTbl.dequeueCell(with: SubmitCell.self)
            cell.selectionStyle = .none
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.submit)
            cell.didTapSum = { [weak self] sender in
                self?.tappedSubmitBtn()
            }
            return cell
        case .DeleteBtn:
            let cell = profileTbl.dequeueCell(with: SubmitCell.self)
            cell.selectionStyle = .none
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.delete,backgroundColor: AppColor.danger)
            cell.didTapSum = { [weak self] sender in
                self?.pushVC(with: DeleteProfileViewController.self, storyboardName: .account)
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ProfileSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AlarmSection")
        }
        
        switch rowType {
        case .myProfileHeaderImage:
            return Const.Height.AutomaticDimension
        case .ProfileformData:
            return Const.Height.AutomaticDimension
        case .updatePassword:
            return Const.Height.rememberMe
        case .submitBtn:
            return Const.Height.submitBtn
        case .DeleteBtn:
            return Const.Height.submitBtn
        }
    }
}

//MARK: UIImage Extension.
extension UIImage {
    func stringToImage(compressionQuality: CGFloat = 0.8) -> String? {
        guard let imageData = self.jpegData(compressionQuality: compressionQuality) else {
            debugLog("Error converting image to data.")
            return nil
        }
        return imageData.base64EncodedString()
    }
}

//MARK: EditProfileViewController()
extension ProfileViewController{
    private  func deleteProfileAlert(){
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithDoubleButtonViewController") as! AlertWithDoubleButtonViewController
        vc.image = UIImage(named: "ic_bin")
        vc.content = AppString.Alert.confirmDeleteProfile
        vc.heading = AppString.Header.delete
        vc.firstBtnTitle = AppString.BtnTitle.yes
        vc.isHiddenRequired = false
        vc.secondBtnTitle = AppString.BtnTitle.no
        vc.titleColor2 = AppColor.dangerRed ?? .red
        vc.borderColor2 = AppColor.dangerRed ?? .red
        vc.firstBackColor =  AppColor.dangerRed ?? .red
        vc.secondBackColor =  .white
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            if UserDefaults.profileURL == "" {
                //no profile url
                self.selectedImage = nil
                self.isSelectedImage = false
                self.isChangedImage = false
                self.profileTbl.reloadData()
            }else {
                if Reachability.isConnectedToNetwork(){
                    DispatchQueue.main.async {
//                        self.viewModel.deleteProfile()
                        self.dismiss(animated: true)
                    }
                }else{
                    Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
                }
            }
            self.dismiss(animated: true)
        }
        vc.secondBtnClosure = {
            self.dismiss(animated: true)
        }
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
        sheet.cornerRadius = Corner_32
        sheet.overlayColor = .black.withAlphaComponent(0.9)
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        self.present(sheet, animated: true, completion: nil)
    }
}

//MARK: CropViewControllerDelegate()
extension ProfileViewController:CropViewControllerDelegate{
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: {
        })
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        debugLog("didCropImageToRect")
    }
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    //MARK: updateImageViewWithImage
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        self.selectedImage = image
        self.isChangedImage = true
        self.isSelectedImage = true
        if let imageData = image.jpegData(compressionQuality: 0.1) {
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let imageURL = tempDirectoryURL.appendingPathComponent("selectedImage.jpg")
            
            do {
                try imageData.write(to: imageURL)
                self.selectedImageURL = imageURL
                debugLog("Temporary Image URL: \(imageURL)")
            } catch {
                debugLog("Error saving image to temporary file: \(error)")
            }
        }
        DispatchQueue.main.async {
            self.profileTbl.reloadData()
        }
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
}

//MARK: API CALL.
extension ProfileViewController: UserServices {
    func reloadData() {
        
        //For categoryDict
        if self.viewModel.requestType == .getProfile {
            if let dict = self.viewModel.getUserDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
                    if let userData = dict.data {
                        firstName =  userData.firstName ?? ""
                        lastName =  userData.lastName ?? ""
                        zipCode =  "\(userData.zip_code ?? -1)"
                        profilePic = userData.profile_image ?? ""
                        email = userData.email ?? ""
                    }
                    self.profileTbl.reload()
                    SVProgressHUD.dismiss()
                    self.viewModel.requestType = .none
                  
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //For editUserProfileDict
        if self.viewModel.requestType == .editProfile {
            if let dict = self.viewModel.editUserProfileDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "",backgroundColor: .green.withAlphaComponent(0.6))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        sceneDel.navigateToLandingScreen()
                    }
                    self.viewModel.requestType = .none
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
    }
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
    
    func saveUserDetail(){
        
    }
}
