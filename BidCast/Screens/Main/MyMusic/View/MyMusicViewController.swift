
//
//  MyMusicViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//
import UIKit
import SVProgressHUD
import FittedSheets
import MobileCoreServices
import UniformTypeIdentifiers
import MediaPlayer


class MyMusicViewController: UIViewController {
    
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var categoryArr: [CategoryModel] = [] // Array of categories (from your API)
    var serverSongArr: [[MusicModel]] = [[], [], [], [], []] // Array of categories (from your API)
    var expandedSections: Set<Int> = [] // Track expanded sections
    var selectedMusicURL:[URL] = []
    var selectedMuisc:[UIImage] = []
    var serverMusicURLs: [[String]] = [[], [], [], [], []]
    var categoryID : Int?
    //    var localMusicArr: [[UploadSongModel]] = [[], [], [], [], []]  // Array of localMusicArr.
    var localMusicArr: [[SongModel]] = [[], [], [], [], []]
    var viewModel = MyMusicViewModel()
    var isAddSongSelected : Bool = false
    var mediaItem: MPMediaItem?
    var mediaLabel: String?
    var descriptions: String?
    var mediaID: String?
    var SelectedRow: Int?
    var selectedSection: Int?
    var deleteSectionIndex: Int?
    var uploadedMusicArray: [AddMusicModel] = []
    var categoryArray: [Int] = []
    var categoryMusicData: [addFinalMusicRequest] = []
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInit()
        self.clearLocalMusicArr()
    }
    
    //MARK: ViewLife Cycle Methods.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.fetchApi()
    }
    
    //MARK: - Configure view Method.
    private func loadInit(){
        self.initialViewModel()
        self.configureTableView()
       
    }
    
    //    @IBAction func submitBtnTapped(_ sender: UIButton) {
    //        if let section = selectedSection {
    //            let musicCount = self.localMusicArr[section].count + self.serverSongArr[section].count
    //            if UserDefaults.isSubscribe{
    //                if UserDefaults.subscribeType == AppString.subscriptionType.annually{
    //                    if musicCount < 5 {
    //                        self.addMusicData(section: section)
    //                    }
    //                }
    //                else if UserDefaults.subscribeType == AppString.subscriptionType.monthly{
    //                    if musicCount < 5 {
    //                        self.addMusicData(section: section)
    //                    }
    //                }
    //                else if UserDefaults.subscribeType == AppString.subscriptionType.onetime{
    //                    if musicCount < 3 {
    //                        self.addMusicData(section: section)
    //                    }
    //                    else {
    //                        Utilities.sharedInstance.showToast(source: self, message: Toast.Message.upgradePlan)
    //                    }
    //                }
    //                else{
    //                    if musicCount < 1 {
    //                        self.addMusicData(section: section)
    //                    }else {
    //                        Utilities.sharedInstance.showToast(source: self, message: Toast.Message.limitReached)
    //                    }
    //                }
    //            }
    //            else{
    //                if musicCount < 1 {
    //                    self.addMusicData(section: section)
    //                }else {
    //                    Utilities.sharedInstance.showToast(source: self, message: Toast.Message.limitReached)
    //                }
    //            }
    //        }
    //    }
    
    @IBAction func submitBtnTapped(_ sender: UIButton) {
        self.addFinalMusic()
        //        if self.localMusicArr.contains(where: { !$0.isEmpty }) {
        //            if let section = self.selectedSection {
        //                addMusicData(section: section)
        //            }
        //        } else {
        //            Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.chooseSongFirst)
        //        }
    }
    
    func checkSongUploadLimit() {
        guard let section = selectedSection else { return }
        
        let musicCount = self.localMusicArr[section].count + self.serverSongArr[section].count
        
        // Define limits for each subscription type
        var limit: Int = getSongLimit()
        
        // Check subscription status
        if !UserDefaults.isSubscriptionExpired{
            if musicCount < limit {
                if self.localMusicArr[self.selectedSection ?? 0].count >= 1 {
                    //show toast Popup
                    debugLog("show toast Popup")
                    Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.MusicUploadLimit)
                    return
                }
                else {
                    self.openSongOption()
                }
            } else {
                let message: String
                if UserDefaults.subscribeType == AppString.subscriptionType.onetime {
                    message = Toast.Message.upgradePlan
                } else {
                    message = Toast.Message.limitReached
                }
                Utilities.sharedInstance.showToast(source: self, message: message)
            }
        } else {
            // If not subscribed, apply the same logic for the "free" plan
            if musicCount < 5 {
                if self.localMusicArr[self.selectedSection ?? 0].count >= 1 {
                    //show toast Popup
                    debugLog("show toast Popup")
                    Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.MusicUploadLimit)
                    return
                }
                else {
                    self.openSongOption()
                }
            } else {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Message.limitReached)
            }
        }
    }
    //    func checkSongUploadLimit() {
    //        // Track total song count across all categories
    //        let totalMusicCount = self.localMusicArr.flatMap { $0 }.count + self.serverSongArr.flatMap { $0 }.count
    //
    //        // Define the maximum song upload limit (15 in total)
    //        let limit = 15
    //
    //        // Check if user has subscription or not
    //        if !UserDefaults.isSubscriptionExpired {
    //            if totalMusicCount < limit {
    //                if self.localMusicArr[self.selectedSection ?? 0].count >= 1 {
    //                    // Show toast message if the local music section already has 1 song
    //                    debugLog("show toast Popup")
    //                    Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.oneMusicUploadLimit)
    //                    return
    //                } else {
    //                    // Allow to open song options for upload
    //                    self.openSongOption()
    //                }
    //            } else {
    //                let message: String
    //                if UserDefaults.subscribeType == AppString.subscriptionType.onetime {
    //                    message = Toast.Message.upgradePlan
    //                } else {
    //                    message = Toast.Message.limitReached
    //                }
    //                Utilities.sharedInstance.showToast(source: self, message: message)
    //            }
    //        } else {
    //            // For free users, apply the same logic with a limit of 5 songs
    //            if totalMusicCount < 5 {
    //                if self.localMusicArr[self.selectedSection ?? 0].count >= 1 {
    //                    // Show toast if the local music section already has 1 song
    //                    debugLog("show toast Popup")
    //                    Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.oneMusicUploadLimit)
    //                    return
    //                } else {
    //                    // Allow to open song options for upload
    //                    self.openSongOption()
    //                }
    //            } else {
    //                Utilities.sharedInstance.showToast(source: self, message: Toast.Message.limitReached)
    //            }
    //        }
    //    }
    
    
    private func getSongLimit() -> Int{
        var limit: Int = 0
        switch UserDefaults.subscribeType {
        case AppString.subscriptionType.annually:
            limit = 15
        case  AppString.subscriptionType.monthly:
            limit = 15
        case AppString.subscriptionType.onetime:
            limit = 15
        default:
            limit = 4
        }
        return limit
    }
    
    //MARK: - Configure TableView Method
    private func configureTableView() {
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.configTblView(bgColor: .ultraLightGray)
        
        // Register cells and headers/footers
        let cellIds = [
            SongRowTableViewCell.identifier,AppHeaderCell.identifier,LabelCell.identifier,SubmitCell.identifier
        ]
        tblView.registerCells(for: cellIds)
        tblView.register(UINib(nibName: "myMusicHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "myMusicHeader")
        tblView.register(UINib(nibName: "addSongButtonFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "addSongButtonFooterView")
        btnSubmit.makeCornerRounded(ofSize: Corner_26)
        btnSubmit.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        
        configureHeaderView()
        if #available(iOS 15.0, *) {
            tblView.sectionHeaderTopPadding = 0
        }
    }
    
    //MARK: - configureHeaderView
    private func configureHeaderView() {
        self.headerView.headerViewSetup(rightButtonHidden: false,
                                        leftButtonHidden: false,
                                        headerName: AppString.VCName.myMusic, rightButtonAction: didTapSideMenu, leftButtonAction: didTabBack)
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchWithLabel : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.notNotchCenter : 0
        self.headerView.bottomLbl.isHidden = false
        self.headerView.bottomLbl.text = AppString.VCName.riseShineSwing
    }
    
    //MARK: - didtapBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    //MARK: Fetch API
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getCategoryData()
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
    
    // MARK: didTapSideMenu
    @objc private func didTapSideMenu() {
        self.openSideMenu()
    }
    
    // MARK: openSongOption
    func openSongOption(){
        let alertController = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        
        // documentAction action
        let documentAction = UIAlertAction(title: "Choose From Files", style: .default) { _ in
            self.pickerAudioFile()
        }
        
        // library action
        let libraryAction = UIAlertAction(title: "Choose From Apple Music", style: .default) { _ in
            self.openSongLibrary()
            //            5529346171716157870
            //            let persistentID: Int64 = 5529346171716157870 // Replace with the actual persistentID you want to search for
            //            if let mediaItem = self.getMediaItem(with: persistentID) {
            //                debugLog("Found song: \(mediaItem.title ?? "Unknown")")
            //                self.playSong(using: mediaItem)
            //            } else {
            //                debugLog("No song found with this persistentID.")
            //            }
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(documentAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - clearLocalMusicArr
    func clearLocalMusicArr() {
        self.selectedSection = nil
        self.SelectedRow = nil
        self.deleteSectionIndex = nil
        self.localMusicArr = [[], [], [], [], []]
        self.selectedMusicURL.removeAll()
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource.
extension MyMusicViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoryArr.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Always show rows for sections 0 and 1
        if section == 0 || section == 1 {
            return 1
        } else {
            // For sections 2 and beyond, use expandedSections for collapse/expand
            if expandedSections.contains(section) {
                let sectionData = categoryArr[section - 2] //data at pertiular category
                let serverSongs = sectionData.music
                //                if localMusicArr.count > 0 && localMusicArr[section - 2].count > 0 {
                let count = (serverSongs?.count ?? 0)  + localMusicArr[section - 2].count
                return count == 0 ? 0 : min(count, 5)
                //                return (serverSongs?.count ?? 0)  + localMusicArr[section - 2].count
                //                }
                //                else {
                //                    return (serverSongs?.count ?? 0)
                //                }
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = AppString.Header.myMusic
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tblView.dequeueCell(with: SubmitCell.self)
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.addMusic)
            cell.didTapSum = { sender in
                self.pushVC(with: AddMusicViewController.self, storyboardName: .main)
            }
            return cell
        }
        else{
            let cell = tblView.dequeueCell(with: SongRowTableViewCell.self)
            cell.selectionStyle = .none
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            serverSongArr[indexPath.section - 2] = categoryArr[indexPath.section - 2].music ?? []
            if indexPath.row < serverSongArr[indexPath.section - 2].count {
                let song = serverSongArr[indexPath.section - 2][indexPath.row]
                cell.titleOlt.text = song.title
                cell.subTitleOlt.text = song.artist_name
                cell.didTapDeleteImg = { [weak self] sender in
                    //delete server image
                    guard let self = self else { return }
                    let musicId = self.categoryArr[indexPath.section - 2].music?[indexPath.row].id ?? -1
                    if musicId != -1 {
                        self.SelectedRow = indexPath.row
                        self.deleteSectionIndex = indexPath.section - 2
                        self.deleteMusicAlert(param: DeleteSongFromCategoryRequest(music_id: musicId))
                    }
                }
            }else{
                let localRowIndex = indexPath.row - serverSongArr[indexPath.section - 2].count
                let localSong = localMusicArr[indexPath.section - 2][localRowIndex]
                cell.titleOlt.text = localSong.title
                cell.subTitleOlt.text = localSong.artistName

                cell.didTapDeleteImg = { [weak self] sender in
                    guard let self = self else { return }
                    
                    // Show the delete confirmation alert
                    self.deleteMusicAlertLocal { [weak self] in
                        guard let self = self else { return }
                        
                        // Disable the button during deletion
                        cell.rightButtonOlt.isUserInteractionEnabled = false
                        print("my section: \(indexPath.section), row: \(indexPath.row)")

                        // Remove the song from category music data
                        debugPrint("Arr :- \(self.localMusicArr[indexPath.section - 2])")
                        debugPrint("categoryMusicData:- \(self.categoryMusicData)")
                        
//                        for (index, item) in self.categoryMusicData.enumerated(){
//                            if item.music_id.contains(localSong.id ?? 0) {
//                                var musicIds = self.categoryMusicData[index].music_id
//                                musicIds = musicIds.filter({$0 != localSong.id ?? 0})
//                                print(musicIds)
//                                self.categoryMusicData[index].music_id = musicIds
//                            }
//                        }
                        for (index, item) in self.categoryMusicData.enumerated() {
                            if item.music_id.contains(localSong.id ?? 0) {
                                var musicIds = self.categoryMusicData[index].music_id
                                musicIds = musicIds.filter { $0 != localSong.id ?? 0 }
                                if musicIds.isEmpty {
                                    self.categoryMusicData.remove(at: index)
                                } else {
                                    self.categoryMusicData[index].music_id = musicIds
                                }
                            }
                        }

                        //Ensure the row index is valid
                        let originalLocalRowIndex = indexPath.row - serverSongArr[indexPath.section - 2].count
                        guard originalLocalRowIndex >= 0 && originalLocalRowIndex < self.localMusicArr[indexPath.section - 2].count else {
                            print("Invalid originalLocalRowIndex: \(originalLocalRowIndex) for section: \(indexPath.section)")
                            cell.rightButtonOlt.isUserInteractionEnabled = true
                            return
                        }

                        // Remove the song from the local music array
                        self.localMusicArr[indexPath.section - 2].remove(at: originalLocalRowIndex)
                        
                        debugPrint("Arr after remove :- \(self.localMusicArr[indexPath.section - 2])")
                        
                        Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.musicDeletedSuccessfully ,backgroundColor: .green.withAlphaComponent(0.4))
                        
                        // Reload the table view
                        self.tblView.reloadData()

                        // Re-enable the button
                        cell.rightButtonOlt.isUserInteractionEnabled = true
                    }
                }
            }
            //Current Code
//            else{
//                let localRowIndex = indexPath.row - serverSongArr[indexPath.section - 2].count
//                let localSong = localMusicArr[indexPath.section - 2][localRowIndex]
//                cell.titleOlt.text = localSong.title
//                cell.subTitleOlt.text = localSong.artistName
//                cell.didTapDeleteImg = { [weak self] sender in
//                    guard let self = self else { return }
//                    let localRowIndex = indexPath.row - serverSongArr[indexPath.section - 2].count
//                    let localSong = localMusicArr[indexPath.section - 2][localRowIndex]
//                    cell.rightButtonOlt.isUserInteractionEnabled = false
//                    print("my section: \(indexPath.section), row: \(indexPath.row)")
//
//                    debugPrint("Arr :- \(self.localMusicArr[indexPath.section - 2])")
//                    for (index, item) in self.categoryMusicData.enumerated() {
//                        if item.music_id.contains(where: { $0 == localSong.id ?? 0 }) {
//                            self.categoryMusicData.remove(at: index)
//                            break
//                        }
//                    }
//                    let originalLocalRowIndex = indexPath.row - serverSongArr[indexPath.section - 2].count
//                    guard originalLocalRowIndex >= 0 && originalLocalRowIndex < self.localMusicArr[indexPath.section - 2].count else {
//                        print("Invalid originalLocalRowIndex: \(originalLocalRowIndex) for section: \(indexPath.section)")
//                        cell.rightButtonOlt.isUserInteractionEnabled = true
//                        return
//                    }
//                    self.localMusicArr[indexPath.section - 2].remove(at: originalLocalRowIndex)
//                    self.tblView.reloadData()
//                    cell.rightButtonOlt.isUserInteractionEnabled = true
//                }
//            }
//            MARK: OLD CODE.
//            else{
//                let localSong = localMusicArr[indexPath.section - 2][indexPath.row - serverSongArr[indexPath.section - 2].count]
//                cell.titleOlt.text = localSong.title
//                cell.subTitleOlt.text = localSong.artistName
//                cell.didTapDeleteImg = { [weak self] sender in
//                    cell.rightButtonOlt.isUserInteractionEnabled = false
//                    print("my section: \(indexPath.section), row: \(indexPath.row)")
//                    guard let self = self else { return }
//                    
//                    debugPrint("Arr :- \(localMusicArr[indexPath.section - 2])")
//                    
//                    let song = localMusicArr[indexPath.section - 2][indexPath.row - serverSongArr[indexPath.section - 2].count]
//                    
//                    for (index,item) in categoryMusicData.enumerated(){
//                        if item.music_id.contains(where: { $0 == song.id ?? 0 }) {
//                            categoryMusicData.remove(at: index)
//                        }
//                    }
//                
//                    localMusicArr[indexPath.section - 2].remove(at: indexPath.row - serverSongArr[indexPath.section - 2].count)
//                    tblView.deleteRows(at: [indexPath], with: .automatic)
//                    cell.rightButtonOlt.isUserInteractionEnabled = true
//                }
//            }
            return cell
        }
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //            guard let rowType = MyMusicSection.allCases[safe: indexPath.section] else {
        //                fatalError("Invalid index for HomeSection")
        //            }
        if indexPath.section == 0 {
            return Const.Height.header
        }
        else if indexPath.section == 1 {
            return 90
        }
        else  {
            return 63
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tblView.dequeueReusableHeaderFooterView(withIdentifier: "myMusicHeader") as? myMusicHeader else {
            return nil
        }
        
        // Initially apply corner radius to all corners if it's the first time.
        if !self.expandedSections.contains(section) {
            // First-time setup (when section is collapsed)
            headerView.sepratorLine.isHidden = true
            headerView.imgUpsDown.image = UIImage(named: "ic_arrowDown")
            headerView.innerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        } else {
            //When the section is expanded, only apply top corners
            headerView.sepratorLine.isHidden = false
            headerView.imgUpsDown.image = UIImage(named: "ic_arrowUp")
            headerView.addTopCorner(to: headerView.innerViewOlt, cornerRadius: Corner_12)
//            headerView.applySideShadow(to: headerView.innerViewOlt, opacity:  0.5, shadowRadius: Radius_04, shadowColor:  AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.left,.right,.top])
        }
        
        if section >= 2 {
            let category = self.categoryArr[section - 2]
            if let imageUrl = category.icon {
                Utilities.sharedInstance.setImageWithUrl(imgStr: imageUrl, imgView: headerView.imgOlt)
            } else {
                headerView.imgOlt.image = UIImage(named: "ic_banner")
            }
            headerView.lblTitle.text = category.title
            headerView.subTitle.text = category.description
            headerView.musicCountOlt.isHidden = true
            let totalTitles = category.music?.filter { $0.title != nil }.count ?? 0
            if UserDefaults.isSubscribe{
                if !UserDefaults.isSubscriptionExpired {
                    if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                        UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                        headerView.musicCountOlt.text = "(\(totalTitles) of 3)"
                    } else if UserDefaults.subscribeType == AppString.subscriptionType.onetime{
                        headerView.musicCountOlt.text = "(\(totalTitles) of 3)"
                    }
                }else{
                    headerView.musicCountOlt.text = "(\(totalTitles) of 3)"
                }
            }else{
                headerView.musicCountOlt.text = "(\(totalTitles) of 3)"
            }
            headerView.setupUI()
            headerView.toggleSectionAction = {
                self.toggleSection(section)
                self.categoryID = self.categoryArr[section - 2].id
                headerView.setNeedsLayout()
                
                DispatchQueue.main.async {
                    headerView.layoutIfNeeded()
                    
                    if self.expandedSections.contains(section) {
                        debugLog("Expanded section: \(section)")
                        headerView.sepratorLine.isHidden = false
                        headerView.imgUpsDown.image = UIImage(named: "ic_arrowUp")
                        headerView.addTopCorner(to: headerView.innerViewOlt, cornerRadius: Corner_12)
//                        headerView.applySideShadow(to: headerView.innerViewOlt, opacity:  0.5, shadowRadius: Radius_04, shadowColor:  AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.left,.right,.top])
                    } else {
                        debugLog("Collapsed section: \(section)")
                        headerView.innerViewOlt.makeCornerRounded(ofSize: Corner_12)
                        headerView.sepratorLine.isHidden = true
                        headerView.imgUpsDown.image = UIImage(named: "ic_arrowDown")
                        headerView.innerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
                    }
                }
            }
        } else {
            // Disable toggle action for sections 0 and 1
            headerView.toggleSectionAction = nil
        }
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0 // No footer for sections 0 and 1
        } else {
            return 110
        }
    }
    
    // Footer View - Show or hide based on expanded state
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tblView.dequeueReusableHeaderFooterView(withIdentifier: "addSongButtonFooterView") as! addSongButtonFooterView
        // Initially apply corner radius to all corners if it's the first time.
        if !self.expandedSections.contains(section){
            // First-time setup (when section is collapsed)
            footerView.outerView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        } else{
            //When the section is expanded, only apply top corners
//            footerView.applySideShadow(to: footerView.outerView, opacity:  0.5, shadowRadius: Radius_04, shadowColor:  AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.left,.right,.bottom])
        }
        
        // Only show footer if the section is expanded and it's section 2 or beyond
        if section >= 2 && expandedSections.contains(section) {
            footerView.addSubscription.isHidden = !UserDefaults.isSubscriptionExpired ? false : true
            footerView.addSubscription.titleLabel?.font = AppFont.placeHolder
            footerView.addBottomCorner(to: footerView.outerView, cornerRadius: Corner_12)
//            footerView.applySideShadow(to: footerView.outerView, opacity:  0.5, shadowRadius: Radius_04, shadowColor:  AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.left,.right,.bottom])
            footerView.addSongBtn.titleLabel?.font = AppFont.placeHolder
            footerView.addSongBtn.tag = section
            //FOR hide addSubscription Button.
            if !UserDefaults.isSubscriptionExpired {
                if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                    UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                    footerView.addSubscription.isHidden = true
                }else{
                    footerView.addSubscription.isHidden = false
                }
            }else{
                footerView.addSubscription.isHidden = false
            }
            footerView.didTapSum = { sender in
                //toDO: addSong list upload page
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "SelectMusicListViewController") as! SelectMusicListViewController
                vc.categoryArr = self.categoryArr
                vc.selectedSongArray = self.localMusicArr
                vc.submitBtnClosure = { musicIds in
                    print("Music Ids: \(musicIds)")
                    //assuming category id is fixed
                    self.dismiss(animated: true)
//                    self.goToBack()
                    
                    self.categoryMusicData.append(addFinalMusicRequest(category_id: section - 1, music_id: musicIds.compactMap({$0.id})))
                    
                    for item in musicIds {
                        if self.localMusicArr[section - 2].filter({$0.id == item.id}).count > 0 {
                            //item already present
                        }
                        else {
                            self.localMusicArr[section - 2].append(item)
                        }
                    }
//                    for item in musicIds {
//                        // Use contains to check if the song already exists in the array
//                        if self.localMusicArr[section - 2].contains(where: { $0.artistName == item.artistName && $0.title == item.title }) {
//                            // item already present
//                            print("Song with title \(item.title ?? "Unknown Title") and artist \(item.artistName ?? "Unknown Artist") is already present.")
//                        } else {
//                            // Song does not exist in localMusicArr, so add it
//                            self.localMusicArr[section - 2].append(item)
//                        }
//                    }

//                    self.localMusicArr[section - 2] = musicIds
                    self.tblView.reload()
                }
                var options = SheetOptions()
                options.shrinkPresentingViewController = false
                options.pullBarHeight = Height_30
                
                let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.55) : .percent(0.65)], options: options)
                sheet.cornerRadius = Corner_32
                sheet.overlayColor = .black.withAlphaComponent(0.9)
                sheet.dismissOnPull = false
                sheet.dismissOnOverlayTap = true
                sheet.gripSize = CGSize(width: Width_50, height: Height_0)
                self.present(sheet, animated: true, completion: nil)
                self.pushVC(with: SelectMusicListViewController.self, storyboardName: .main)
                //                self.categoryID = self.categoryArr[section - 2].id
                //
                //                //This is used to check user upload one song at one time per category.
                //                //                if let section = self.selectedSection , !self.localMusicArr[section].isEmpty {
                //                //                    Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.oneMusicUploadLimit)
                //                //                    self.selectedSection = section - 2
                //                //                }
                //                self.selectedSection = section - 2
                //                if let selectedSection = self.selectedSection {
                //                    let category = self.categoryArr[selectedSection]
                //                    let totalTitles = category.music?.filter { $0.title != nil }.count ?? 0
                //                    if totalTitles > 0 && UserDefaults.isSubscriptionExpired {
                //                        DispatchQueue.main.async {
                //                            Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.upgardeSubscriptionPlan)
                //                        }
                //                    }else {
                //                        self.checkSongUploadLimit()
                //                    }
                //                }
            }
            footerView.didTapSubscription = { sender in
                self.pushVC(with: OurSubscriptionViewController.self, storyboardName: .main)
                
            }
            return footerView
        } else {
            footerView.outerView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
            return nil
        }
    }
    
    
    // Footer height should be conditional on expanded state
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0 // No footer for sections 0 and 1
        } else {
            // For section 2 and beyond, toggle footer height based on expanded state
            if expandedSections.contains(section) {
                return 53 // Show footer for expanded sections
            } else {
                return 0 // Hide footer for collapsed sections
            }
        }
    }
    
    // Handle Section Expansion/Collapse
    func toggleSection(_ section: Int) {
        // Only toggle for section 2 and beyond
        if section >= 2 {
            if expandedSections.contains(section) {
                expandedSections.remove(section) // Collapse the section
            } else {
                expandedSections.insert(section) // Expand the section
            }
            tblView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
    }
    
}



//MARK: MyMusicViewController.
extension MyMusicViewController{
    //MARK: fetch api .
    //    private func fetchSongListApi(){
    //        if Reachability.isConnectedToNetwork(){
    //            SVProgressHUD.show()
    //            self.viewModel.getSongListData(parameters: SongRequest(category_id: categoryID ?? 0))
    //        }else{
    //            DispatchQueue.main.async {
    //                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
    //            }
    //        }
    //    }
}

//MARK: API CALL.
extension MyMusicViewController: UserServices {
    func reloadData() {
        //For categoryDict
        if self.viewModel.requestType == .getCategory {
            if let dict = self.viewModel.categoryDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
                    //update aray and sectionDict
                    self.clearLocalMusicArr()
                    self.categoryArr = (dict.data ?? []) ?? []
                    SVProgressHUD.dismiss()
                    //                categoryArr.forEach { category in
                    //                }
                    //self.serverSongArr =  self.categoryArr
                    
                    self.tblView.reload()
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        if self.viewModel.requestType == .deleteSong {
            if let dict = self.viewModel.deleteSongDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    SVProgressHUD.dismiss()
                    debugLog("success Delet Music API Response")
                    //update aray and sectionDict
                    if SelectedRow != nil && self.deleteSectionIndex != nil {
                        if var music = self.categoryArr[deleteSectionIndex!].music {
                            music.remove(at: SelectedRow!)
                            self.categoryArr[deleteSectionIndex!].music = music
                            self.categoryArr.removeAll()
                        }
                    }
                    self.fetchApi()
                    self.tblView.reloadData()
                    //                    for (index , cat) in self.categoryArr.enumerated() {
                    //                        let res = cat.music?.filter({$0.id != musicId})
                    //                        self.categoryArr[index].music = res
                    //                    }
                    
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //
        if self.viewModel.requestType == .deleteSongFromCategory {
            if let dict = self.viewModel.deleteSongFromCategoryDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success Delet Music API Response")
                    SVProgressHUD.dismiss()
                    //update aray and sectionDict
                    if SelectedRow != nil && self.deleteSectionIndex != nil {
                        if var music = self.categoryArr[deleteSectionIndex!].music {
                            music.remove(at: SelectedRow!)
                            self.categoryArr[deleteSectionIndex!].music = music
//                            self.categoryArr.removeAll()
                        }
                    }
//                    self.fetchApi()
                    Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.musicDeletedSuccessfully,backgroundColor: .green.withAlphaComponent(0.4))
                    self.tblView.reloadData()
                    //                    for (index , cat) in self.categoryArr.enumerated() {
                    //                        let res = cat.music?.filter({$0.id != musicId})
                    //                        self.categoryArr[index].music = res
                    //                    }
                    
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //For songListDict
        if self.viewModel.requestType == .getMusicList {
            if let dict = self.viewModel.songListDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response =====>\n\n\n\n")
                    SVProgressHUD.dismiss()
                    //update aray and sectionDict
                    
                    //                self.tblView.reload()
                    //                    self.serverSongArr[0] = dict.data ?? []
                    //                    self.sectionData[.musicList] = self.serverSongArr.count > 0 ? self.serverSongArr.count : 0
                    self.tblView.reload()
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //for addMusicDict
        if self.viewModel.requestType == .addMusic {
            if let dict = viewModel.addMusicDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
                    SVProgressHUD.dismiss()
                    //                    Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.musicAdded ,backgroundColor : .success.withAlphaComponent(0.8))
                    if let data = dict.data {
                        self.uploadedMusicArray.append(data)
                    }
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                }
            }
        }
        
        //for addFinalMusicDict
        if self.viewModel.requestType == .addFinalMusic {
            if let dict = viewModel.addFinalMusicDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
                    SVProgressHUD.dismiss()
                    self.successMuiscAddAlert()
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
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
}


//MARK: addMusicData
extension MyMusicViewController {
    func addMusicData(section: Int) {
        //        self.view.endEditing(true)
        //
        //        if Reachability.isConnectedToNetwork() {
        //
        //            var mimeType: [String] = []
        //            var musics: [[String]] = []
        //            var keysValue: [String] = []
        //
        //            for song in localMusicArr[section] {
        //                guard let artistName = song.artistName,
        //                      let trackName = song.trackName,
        //                      let categoryID = song.categoryId,
        //                      let type = song.type else {
        //                    continue
        //                }
        //
        //
        //                var songParam = [String: Any]()
        //                switch type {
        //                case .apple:
        //                    songParam = [
        //                        "category_id" : categoryID,
        //                        "title": trackName,
        //                        "artist_name": artistName,
        //                        "type": type.rawValue,
        //                        "apple_music_song_id": song.appleMusicSongId
        //                    ]
        //                case .local:
        //                    mimeType.append("audio/mp3")
        //                    keysValue.append("song")
        //                    if let songURL = song.url {
        //                        musics = [[songURL.description]]
        //                    }
        //
        //                    songParam = [
        //                        "category_id" : categoryID,
        //                        "title": trackName,
        //                        "artist_name": artistName,
        //                        "type": type.rawValue
        //                    ]
        //
        //                    if let songURL = song.url {
        //                        musics = [[songURL.description]]
        //                    }
        //                }
        //
        //
        //                SVProgressHUD.show()
        //                self.viewModel.addSongData(param: songParam,
        //                                           keysValue: keysValue,
        //                                           mimeTypes: mimeType,
        //                                           musics: musics)
        //                debugLog("Prepared param for \(trackName): \(songParam)")
        //            }
        //
        //        } else {
        //            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        //        }
    }
    
    //MARK: addFinalMusic
    private func addFinalMusic(){
        self.view.endEditing(true)
        if categoryMusicData.count == 0{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.addMusic)
        }else{
            if Reachability.isConnectedToNetwork() {
                SVProgressHUD.show()
               
                //                var musicData = [String: [Int]]()
                //                //add music data category wise in dict of array
                //                for item in uploadedMusicArray {
                //                    if let categoryId = item.category_id, let musicId = item.id {
                //                        //assuming category id is fixed
                //                        if let catData = musicData[categoryId] {
                //                            musicData[categoryId]!.append(musicId)
                //                        }
                //                        else {
                //                            musicData[categoryId] = [musicId]
                //                        }
                //                    }
                //                }
                //                var param =  [[String: Any]]()
                //                //traverse dict
                //                for (catId, musicArr) in musicData {
                //                    let data: [String: Any] = [
                //                        "category_id" : Int(catId)!,
                //                        "music_id" : musicArr
                //                    ]
                //                    param.append(data)
                //                }
                //                debugLog("Here is Your Param Data \(param)")
                //                var data: [addFinalMusicRequest] = []
                //                for item in uploadedMusicArray {
                //                    if let categoryId = item.category_id, let musicId = item.id {
                //                        //assuming category id is fixed
                //                        data.append(addFinalMusicRequest(category_id: Int(categoryId)!, music_id: [musicId]))
                //                        //todo: needed to manage multiple music ids
                //                    }
                //                }
//                let musicIds = localMusicArr[section - 2].compactMap { $0.id }
//                let categoryId = section - 1
//                let param = addFinalMusicRequest(category_id: categoryId, music_id: [musicIds])
//                print("categoryData: \(categoryMusicData)")
                self.viewModel.addFinalMusic(parameters: categoryMusicData)
            }else{
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    //MARK: successMuiscAddAlert
    func successMuiscAddAlert(){
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
        vc.image = UIImage(named: "ic_Success")
        vc.content = AppString.Alert.musicAdded
        vc.heading = AppString.Header.success
        vc.firstBtnTitle = AppString.BtnTitle.ok
        vc.isHiddenRequired = true
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            self.dismiss(animated: true)
            sceneDel.navigateToLandingScreen()
        }
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
        sheet.cornerRadius = Corner_32
        sheet.overlayColor = .black.withAlphaComponent(0.9)
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        self.present(sheet, animated: true, completion: nil)
    }
    
    private  func deleteMusicAlert( param : DeleteSongFromCategoryRequest){
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithDoubleButtonViewController") as! AlertWithDoubleButtonViewController
        vc.image = UIImage(named: "ic_bin")
        vc.content = AppString.Alert.areYouSureToRemoveFromCate
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
            self.dismiss(animated: true)
            if Reachability.isConnectedToNetwork(){
                DispatchQueue.main.async {
                    self.viewModel.deleteSongFromCategoryData(parameters: param)
                    SVProgressHUD.show()
                }
            }else{
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
        vc.secondBtnClosure = {
            self.dismiss(animated: true)
        }
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
        
        sheet.cornerRadius = Corner_32
        //sheet.overlayColor = .black.withAlphaComponent(0.9)
        sheet.dismissOnPull = true
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        self.present(sheet, animated: true, completion: nil)
    }
    
    private func deleteMusicAlertLocal(deleteAction: @escaping () -> Void) {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithDoubleButtonViewController") as! AlertWithDoubleButtonViewController
        vc.image = UIImage(named: "ic_bin")
        vc.content = AppString.Alert.areYouSureToRemoveFromCate
        vc.heading = AppString.Header.delete
        vc.firstBtnTitle = AppString.BtnTitle.yes
        vc.isHiddenRequired = false
        vc.secondBtnTitle = AppString.BtnTitle.no
        vc.titleColor2 = AppColor.dangerRed ?? .red
        vc.borderColor2 = AppColor.dangerRed ?? .red
        vc.firstBackColor = AppColor.dangerRed ?? .red
        vc.secondBackColor = .white

        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            // Call the provided delete action if the user taps "Yes"
            deleteAction()
            self.dismiss(animated: true)
        }
        vc.secondBtnClosure = {
            self.dismiss(animated: true)
        }
        
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
        sheet.cornerRadius = Corner_32
        sheet.dismissOnPull = true
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        
        self.present(sheet, animated: true, completion: nil)
    }
}

//MARK: UIDocumentPickerDelegate.
extension MyMusicViewController: UIDocumentPickerDelegate {
    
    func pickerAudioFile(){
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedURL = urls.first {
            // Extract track name and artist from the selected URL
            if let songData = extractArtistAndTrackName(from: selectedURL) {
                let artistName = songData.artist
                let trackName = songData.trackName
                
                // Create a new UploadSongModel and add to localMusicArr
                let newSong = UploadSongModel(artistName: artistName,
                                              url: selectedURL.absoluteString,
                                              trackName: trackName,
                                              categoryId: categoryID,
                                              appleMusicSongId: nil,
                                              type: .local)
                debugLog("Selected Song Detail: \(artistName), \(trackName), \(selectedURL.absoluteString), CategoryID: \(categoryID)")
                let allowedFileSize = 5.0 * 1024 * 1024
                let fileSize = selectedURL.fileSize
                debugLog("File Size: \(fileSize)")
                if fileSize > allowedFileSize {
                    debugLog("File is larger than 5 MB")
                    //show toast
                    DispatchQueue.main.async {
                        Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.greaterThan5MB)
                    }
                }else {
                    debugLog("File size is less than or equal to 5 MB")
                    if let section = self.selectedSection{
                        //                        localMusicArr[section].append(newSong)
                        tblView.reload()
                    }
                }
                //                sectionData[.musicList] = serverSongArr.count + localMusicArr.count
                //                let indexPath = IndexPath(row:serverSongArr.count + localMusicArr.count - 1, section: 2)
                //                tblView.insertRows(at: [indexPath], with: .automatic)
            }
            selectedMusicURL.append(contentsOf: urls)
            
            //API CALL TO ADD SONGS.
            if self.localMusicArr.contains(where: { !$0.isEmpty }) {
                if let section = self.selectedSection {
                    addMusicData(section: section)
                }
            } else {
                Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.chooseSongFirst)
            }
            tblView.reload()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancel action
        debugLog("User cancelled file selection.")
    }
}

//extension MyMusicViewController : MPMediaPickerControllerDelegate {
//
//    func openSongLibrary() {
//        let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
//        mediaPicker.delegate = self
//        mediaPicker.prompt = "Select any song!"
//        mediaPicker.allowsPickingMultipleItems = false  // Allow only one selection at a time
//        self.present(mediaPicker, animated: true, completion: nil)
//    }
//
//    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//        for item in mediaItemCollection.items {
//            let trackName = item.title ?? "Unknown Track"
//            let artistName = item.artist ?? "Unknown Artist"
//            let songURL = item.assetURL?.absoluteString ?? ""
//            let itemUrl = item.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL
//                        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
//                        musicPlayer.setQueue(with: mediaItemCollection)
//                            mediaPicker.dismiss(animated: true)
//                            // Begin playback.
//                            musicPlayer.play()
//            let librarySong = UploadSongModel(artistName: artistName, url: itemUrl?.absoluteString, trackName: trackName, categoryId: categoryID)
//            if let section = selectedSection {
//                self.localMusicArr[section].append(librarySong)
//            }
//            debugLog("Library Song Selected: \(artistName), \(trackName), \(songURL), CategoryID: \(categoryID)")
//        }
//        tblView.reloadData()
//        mediaPicker.dismiss(animated: true, completion: nil)
//    }
//
//    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
//        // If the user cancels, dismiss the picker
//        mediaPicker.dismiss(animated: true, completion: nil)
//    }
//}

//MARK: MPMediaPickerControllerDelegate
extension MyMusicViewController : MPMediaPickerControllerDelegate {
    
    func openSongLibrary() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .anyAudio)
        mediaPicker.delegate = self
        mediaPicker.prompt = "Select any song!"
        mediaPicker.allowsPickingMultipleItems = false  // Allow only one selection at a time
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func getMediaItem(with persistentID: Int64) -> MPMediaItem? {
        // Create a query for songs
        let query = MPMediaQuery.songs()
        
        // Create a predicate to filter by persistentID
        let predicate = MPMediaPropertyPredicate(value: persistentID, forProperty: MPMediaItemPropertyPersistentID)
        
        // Apply the predicate to the query
        query.addFilterPredicate(predicate)
        
        // Retrieve the filtered items (there should be only one)
        let items = query.items
        
        // Return the first item (if available)
        return items?.first
    }
    
    func playSong(using mediaItem: MPMediaItem) {
        // Create a music player instance
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        
        // Create a media item collection with the single song
        let mediaItemCollection = MPMediaItemCollection(items: [mediaItem])
        
        // Set the music player's queue to the song's media item collection
        musicPlayer.setQueue(with: mediaItemCollection)
        
        // Play the song
        musicPlayer.play()
    }
    
    func dismissPlayer() {
        //        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // Loop through selected items (even though we allow only one selection)
        for item in mediaItemCollection.items {
            let trackName = item.title ?? "Unknown Track"
            let artistName = item.artist ?? "Unknown Artist"
            let albumName = item.albumTitle ?? "Unknown Album"
            let persistentID: UInt64 = item.persistentID
            // Define the songURL safely
            var songURL: URL? = nil
            if let assetURL = item.assetURL {
                songURL = assetURL
                debugLog("Song URL (for playback): \(songURL?.absoluteString ?? "")")
            }
            // Prepare your song model for upload or other operations
            //            if let songURL = songURL {
            let song = UploadSongModel(artistName: artistName,
                                       url: nil,
                                       trackName: trackName,
                                       categoryId: categoryID,
                                       appleMusicSongId: persistentID,
                                       type: .apple
            )
            
            // Add the song to local array or other operations
            if let section = selectedSection {
                //                self.localMusicArr[section].append(song)
            }
            //API CALL TO ADD SONGS.
            if self.localMusicArr.contains(where: { !$0.isEmpty }) {
                if let section = self.selectedSection {
                    addMusicData(section: section)
                }
            } else {
                Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.chooseSongFirst)
            }
            
            debugLog("Library Song Selected: \(artistName), \(trackName), CategoryID: \(categoryID)")
            //            }
        }
        tblView.reloadData()
        
        // Dismiss the media picker after selection
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        // If the user cancels, dismiss the picker
        mediaPicker.dismiss(animated: true, completion: nil)
        debugLog("User canceled the media picker.")
    }
}

//MARK: UploadSongModel.
struct UploadSongModel{
    var artistName : String?
    var url : String?
    var trackName : String?
    var categoryId : Int?
    var appleMusicSongId: UInt64?
    var type: SongType? //apple_music,local_song,
}

enum SongType: String {
    case apple = "apple_music"
    case local = "local_song"
    case system = "system"
}
