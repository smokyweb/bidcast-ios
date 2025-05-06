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

class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // MARK: IBOutlets.
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var profileTbl: UITableView!
    var isProfileChange: (Bool) -> Void = {_ in}
    
    //MARK: Properties.
    var firstName  = ""
    var lastName  = ""
    var profilePic: String = ""
    var password  = ""
    var image = ""
    var selectedImage : UIImage?
    var selectedImageURL : URL?
    var isSelectedImage = false
    var isChangedImage = false
    var croppedRect = CGRect.zero
    var croppedAngle = 0
    //    var profileData : ProfileModel?
    var viewModel = EditProfileViewModel()
    var firebaseViewModel = MessagesViewModel(firebaseManager: FirebaseManager())
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.observeEvent()
        if self.profilePic != "" {
            self.isSelectedImage = true
        }
    }
    
    //MARK: observeEvent.
    private func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .loading:
                SVProgressHUD.show()
            case .stopLoading:
                print("loaded")
            case .dataLoaded:
                if  self.viewModel.requestType == "deleteProfile"{
                    self.sucessDeleteProfile()
                }else{
                    self.APIFetchSuccess()
                }
                print("sucess")
            case .error(let error):
                print(error as Any)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    if  self.viewModel.requestType == "deleteProfile"{
                        Utilities.sharedInstance.showToast(source: self, message: self.viewModel.deleteProfileDict?.error_type ?? "")
                    }else{
                        Utilities.sharedInstance.showToast(source: self, message: error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
    
    // MARK: updateUserProfile.
    private func updateUserProfile() {
        let profilePic = UserDefaults.profileURL
        let userName = UserDefaults.userName
        let userId = "\(UserDefaults.userId)"
        let user = UserModel(userId: userId, name: userName, profilePic: profilePic)
        //first chat initialtion
        self.firebaseViewModel.createUser(user: user) { message in
            print(message)
        }
    }
    
    //MARK: APIFetchSuccess.
    private  func APIFetchSuccess() {
        DispatchQueue.main.async {
            //dismiss loader
            self.isProfileChange(true)
            SVProgressHUD.dismiss()
            if self.viewModel.editProfileDict?.status == "success" {
                //update User Default
                if let data =  self.viewModel.editProfileDict?.data {
                    UserDefaults.userName = "\(data.first_name ?? "") \(data.last_name ?? "")"
                    UserDefaults.profileURL = data.image ?? ""
                    //update firebaseUser
                    self.updateUserProfile()
                }
                isFieldActionChanged = false
                let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
                vc.image = UIImage(named: "pop-up-right")
                vc.content = AppString.Alert.profileDetailsUpdated
                vc.heading = AppString.Header.success
                vc.firstBtnTitle = AppString.BtnTitle.ok
                vc.isHiddenRequired = true
                var options = SheetOptions()
                options.shrinkPresentingViewController = false
                options.pullBarHeight = Height_30
                vc.firstBtnClosure = {
                    self.dismiss(animated: true)
                    self.goToBack()
                }
                let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.35) : .percent(0.45)], options: options)
                sheet.cornerRadius = Corner_32
                sheet.overlayColor = .black.withAlphaComponent(0.9)
                sheet.dismissOnPull = false
                sheet.dismissOnOverlayTap = true
                sheet.gripSize = CGSize(width: Width_50, height: Height_0)
                self.present(sheet, animated: true, completion: nil)
            }
            else {
                //show error message
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: self.viewModel.editProfileDict?.message ?? "")
            }
        }
    }
    
    //MARK: sucessDeleteProfile.
    private func sucessDeleteProfile() {
        SVProgressHUD.dismiss()
        if viewModel.deleteProfileDict?.status == "success" {
            DispatchQueue.main.async {
                UserDefaults.profileURL = ""
                self.isChangedImage = false
                self.selectedImage = UIImage(systemName: "person.circle.fill")
                self.isSelectedImage = false
                self.isChangedImage = true
                self.isProfileChange(true)
                self.profileTbl.reloadData()
            }
        }
        else {
            Utilities.sharedInstance.showToast(source: self, message: self.viewModel.deleteProfileDict?.message ?? "")
        }
    }
    
    // MARK: tappedSubmitBtn.
    private func tappedSubmitBtn(){
        self.view.endEditing(true)
        if firstName == ""{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyFirstName)
        }else if lastName == ""{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyLastName)
        }
        else if Reachability.isConnectedToNetwork() {
            
            
            let param = ["first_name": self.firstName, "last_name": self.lastName] as [String:Any]
            print(param)
            
            if self.selectedImageURL?.absoluteString ?? "" != ""{
                self.viewModel.editProfileDetails(parameters: param, image: self.selectedImageURL?.absoluteString ?? "")
            }else{
                self.viewModel.editProfileDetails(parameters: param)
            }
        }
        else {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.profileTbl.delegate = self
        self.profileTbl.dataSource = self
        let cellIds = [AppHeaderExpendableCell.identifier,ProfileCell.identifier,EditProfileCell.identifier,HayUsedCell.identifier,TextFieldWithLabelCell.identifier,SubmitCell.identifier,SignUpTodayCell.identifier,SecondBtnCell.identifier]
        profileTbl.registerCells(for: cellIds)
        self.profileTbl.separatorStyle = .none
        profileTbl.showsVerticalScrollIndicator = false
        self.headerView.midLbl.text = AppString.VCName.editProfile
        self.headerView.rightButton.isHidden = true
        self.headerView.leftButton.addTarget(self, action: #selector(didTabBack), for: .touchUpInside)
        self.profileTbl.rowHeight = UITableView.automaticDimension
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
    //    private func openGallery() {
    //        PHPhotoLibrary.requestAuthorization { status in
    //            if status == .authorized {
    //                DispatchQueue.main.async {
    //                    let imagePicker = UIImagePickerController()
    //                    imagePicker.delegate = self
    //                    imagePicker.sourceType = .photoLibrary
    //                    imagePicker.allowsEditing = false
    //                    self.present(imagePicker, animated: true, completion: nil)
    //                }
    //            } else {
    //                DispatchQueue.main.async {
    //                    self.showPermissionAlert(for: "Photo Library")
    //                }
    //            }
    //        }
    //    }
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
            //                print("Image URL: \(imageURL)")
            //            }
            //            else {
            //                if let imageData = selectedImage.jpegData(compressionQuality: 0.1) {
            //                    let tempDirectoryURL = FileManager.default.temporaryDirectory
            //                    let imageURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString + ".jpg")
            //                    do {
            //                        try imageData.write(to: imageURL)
            //                        self.selectedImageURL.append(imageURL)
            //                        print("Temporary Image URL: \(imageURL)")
            //                    } catch {
            //                        print("Error saving image to temporary file: \(error)")
            //                    }
            //                }
            //            }
            self.dismiss(animated: true , completion: nil)
            let cropViewController = CropViewController(image: selectedImage)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
            print("Image selected: \(selectedImage)")
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource.
extension EditProfileViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = profileTbl.dequeueCell(with: AppHeaderExpendableCell.self)
            cell.titleOlt.text = AppString.Header.editAccount
            cell.rightButtonOlt.isHidden = true
            cell.rightView.isHidden = true
            cell.contentView.backgroundColor = AppColor.View.bgLightGray
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 1 {
            let cell = profileTbl.dequeueCell(with: EditProfileCell.self)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapShowAlert))
            cell.userImage.isUserInteractionEnabled = true
            cell.userImage.addGestureRecognizer(tapGesture)
            if  self.isSelectedImage == false {
                cell.deleteBtn.isHidden = true
            }else{
                cell.deleteBtn.isHidden = false
            }
            if self.selectedImage != nil   {
                cell.userImage.image = self.selectedImage
            }
            else {
                if self.profilePic != ""{
                    Utilities.sharedInstance.setImageWithUrl(imgStr: profilePic, imgView: cell.userImage)
                }
                else {
                    cell.userImage.image = UIImage(systemName: "person.circle.fill")
                }
            }
            cell.contentView.backgroundColor = AppColor.View.bgLightGray
            cell.selectionStyle = .none
            cell.didTapDelete = { sender in
                self.deleteProfileAlert()
            }
            return cell
        }else if indexPath.row == 2{
            let cell = profileTbl.dequeueCell(with: TextFieldWithLabelCell.self)
            cell.titleOlt.text = AppString.Title.firstName
            if self.firstName == ""{
                cell.textFieldOlt.placeholder = AppString.Placeholder.firstName
            }else{
                cell.textFieldOlt.text = self.firstName
            }
            cell.eyeBtnOlt.isHidden = true
            cell.vectorImageolt.image = UIImage(systemName: "person.circle")
            cell.entertext = { [weak self] text in
                self?.firstName = text.text ?? ""
            }
            cell.selectionStyle = .none
            
            return cell
            
        } else if indexPath.row == 3{
            let cell = profileTbl.dequeueCell(with: TextFieldWithLabelCell.self)
            cell.titleOlt.text = AppString.Title.lastName
            if self.firstName == ""{
                cell.textFieldOlt.placeholder =  AppString.Placeholder.lastName
            }else{
                cell.textFieldOlt.text =  self.lastName
            }
            cell.vectorImageolt.image = UIImage(systemName: "person.circle")
            cell.eyeBtnOlt.isHidden = true
            cell.entertext = { [weak self] text in
                self?.lastName = text.text ?? ""
            }
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 4{
            //save button
            let cell = profileTbl.dequeueCell(with: SubmitCell.self)
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = AppColor.View.bgLightGray
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.save)
            cell.didTapSum = { [weak self] sender in
                self?.tappedSubmitBtn()
            }
            return cell
        }
        else if indexPath.row == 5{
            //            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldWithLabelCell", for: indexPath) as! TextFieldWithLabelCell
            //            cell.contentView.backgroundColor = UIColor(r: 245, g: 246, b: 250, alpha: 1)
            //            cell.titleOlt.text = "Password"
            //            cell.textFieldOlt.placeholder = "Password"
            //            cell.eyeBtnOlt.isHidden = false
            //            cell.vectorImageolt.image = UIImage(systemName: "lock")
            //            cell.textFieldOlt.isSecureTextEntry = true
            //            cell.editPasswordOlt.isHidden = false
            //            cell.entertext = { text in
            //                self.password = text.text ?? ""
            //            }
            //            cell.selectionStyle = .none
            //            return cell
            let cell = profileTbl.dequeueCell(with: SecondBtnCell.self)
            cell.selectionStyle = .none
            cell.exitBtn.titleLabel?.font  = MontserratFont.defaultBold(size: 12.0).value
            cell.exitBtn.setupButton(title: AppString.BtnTitle.changePassword)
            cell.contentView.backgroundColor = AppColor.View.bgLightGray
            cell.didTapExit = { [weak self]  sender in
                let vc = Utilities.sharedInstance.getVC(storyBoardName: "Onboardings", vcId: "NewPasswordViewController") as! NewPasswordViewController
                vc.isComeFromUpdatePass = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        }
        else {
            let cell = profileTbl.dequeueCell(with: SignUpTodayCell.self)
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = AppColor.View.bgLightGray
            cell.signUpOlt.text = AppString.Header.deleteAccount
            cell.footerView.backgroundColor = AppColor.Button.darkRed
            cell.signUpOlt.textColor = AppColor.Button.darkRed
            cell.hayPlacesOlt.isHidden = true
            cell.didTapSignUP = { sender in
                let storyboard = UIStoryboard(name: "Onboardings", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "DeleteAccountViewController") as! DeleteAccountViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }
    }
}
//MARK: UIImage Extension.
extension UIImage {
    func stringToImage(compressionQuality: CGFloat = 0.8) -> String? {
        guard let imageData = self.jpegData(compressionQuality: compressionQuality) else {
            print("Error converting image to data.")
            return nil
        }
        return imageData.base64EncodedString()
    }
}

//MARK: EditProfileViewController()
extension EditProfileViewController{
    private  func deleteProfileAlert(){
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Alert2ViewController") as! Alert2ViewController
        vc.image = UIImage(named: "delete")
        vc.content = AppString.Alert.confirmDeleteProfile
        vc.heading = AppString.Header.delete
        vc.firstBtnTitle = AppString.BtnTitle.yes
        vc.isHiddenRequired = false
        vc.secondBtnTitle = AppString.BtnTitle.no
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
                        self.viewModel.deleteProfile()
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
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.45) : .percent(0.55)], options: options)
        sheet.cornerRadius = Corner_32
        sheet.overlayColor = .black.withAlphaComponent(0.9)
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        self.present(sheet, animated: true, completion: nil)
    }
}

//MARK: CropViewControllerDelegate()
extension EditProfileViewController:CropViewControllerDelegate{
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: {
        })
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        print("didCropImageToRect")
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
                print("Temporary Image URL: \(imageURL)")
            } catch {
                print("Error saving image to temporary file: \(error)")
            }
        }
        DispatchQueue.main.async {
            self.profileTbl.reloadData()
        }
        cropViewController.dismiss(animated: true, completion: nil)
        
    }
}
