
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

enum AddMusicSection: Int,CaseIterable {
    case addMusicHeader
    case addSongRow
    case songCountRow
    case songListRow
    
    func numberOfRows(data: [AddMusicSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}


class AddMusicViewController: UIViewController {
    
    @IBOutlet var btnSubmit: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    //MARK: sectionData
    lazy var sectionData: [AddMusicSection: Int] = [
        .addMusicHeader: 1,
        .addSongRow : 1,
        .songCountRow : 1,
        .songListRow: 1
    ]
    
    //MARK: Properties
    var localMusicArr: [AddSongModel] = []  // Array of localMusicArr.
    var selectedMusicURL:[URL] = []
    var serverSongArr: [SongModel] = [] // Array of categories (from your API)
    var viewModel = MyMusicViewModel()
    var uploadedMusicArray: [AddAllMusicModel] = []
    
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
        self.configureTableView()
        self.initialViewModel()
    }

    @IBAction func submitBtnTapped(_ sender: UIButton) {
        if self.localMusicArr.count != 0 {
            addMusicData()
        } else {
            Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.chooseSongFirst)
        }
    }
    
    //MARK: - Configure TableView Method
    private func configureTableView() {
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.configTblView(bgColor: .ultraLightGray)
        
        // Register cells and headers/footers
        let cellIds = [
            AddSongCell.identifier,AppHeaderCell.identifier,AddSongList.identifier,NoDataTableViewCell.identifier,LabelCell.identifier
        ]
        tblView.registerCells(for: cellIds)
        btnSubmit.makeCornerRounded(ofSize: Corner_26)
        btnSubmit.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        configureHeaderView()
    }
    
    //MARK: - configureHeaderView
    private func configureHeaderView() {
        self.headerView.headerViewSetup(rightButtonHidden: true,
                                        leftButtonHidden: false,
                                        headerName: AppString.VCName.addMusic, rightButtonAction: didTapSideMenu, leftButtonAction: didTabBack)
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: - clearLocalMusicArr
    func clearLocalMusicArr() {
        self.localMusicArr = []
        self.selectedMusicURL.removeAll()
    }
    
    //MARK: - didtapBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    // MARK: didTapSideMenu
    @objc private func didTapSideMenu() {
        self.openSideMenu()
    }
    
    //MARK: Fetch API
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getSongListData()
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
    
    //MARK: manageRowCount.
    private func manageRowCount(){
        let serverSong = serverSongArr.count
        let localSong = localMusicArr.count
        let count = serverSong + localSong
        sectionData[.songListRow] = count == 0 ? 1 : count
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource.
extension AddMusicViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AddMusicSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = AddMusicSection(rawValue: section) else { return 0 }
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = AddMusicSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AddMusicSection")
        }
        switch rowType {
        case .addMusicHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = AppString.Header.addMusic
            return cell
        case .addSongRow:
            let cell = tblView.dequeueCell(with: AddSongCell.self)
            cell.selectionStyle = .none
            cell.outerView.backgroundColor = .ultraLightGray
            cell.outerView.makeCornerRounded(ofSize: Corner_12)
            cell.didTapSubscription = { sender in
//                self.pushVC(with: OurSubscriptionViewController.self, storyboardName: .main)
            }
            cell.didTapSum = { sender in
                self.checkSongUploadLimit()
            }
            let totalTitles = 0 //serverSongArr.count + localMusicArr.count
            cell.totalCount.isHidden = true
            //FOR hide addSubscription Button.
            if !UserDefaults.isSubscriptionExpired {
                if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                    UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                    cell.addSubscription.isHidden = true
                }else{
                    cell.addSubscription.isHidden = false
                }
            }else{
                cell.addSubscription.isHidden = false
            }
            if UserDefaults.isSubscribe{
                if !UserDefaults.isSubscriptionExpired {
                    if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                        UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                        
                        cell.totalCount.text = "Song Count: \(totalTitles) of 25"
                    }
                    else if UserDefaults.subscribeType == AppString.subscriptionType.onetime{
                        cell.totalCount.text = "Song Count: \(totalTitles) of 25"
                    }
                }else{
                    cell.totalCount.text = "Song Count: \(totalTitles) of 5"
                }
            }else{
                cell.totalCount.text = "Song Count: \(totalTitles) of 5"
            }
            return cell
        case .songCountRow:
            let cell = tblView.dequeueCell(with: LabelCell.self)
            let totalTitles = serverSongArr.count + localMusicArr.count
            if UserDefaults.isSubscribe{
                if !UserDefaults.isSubscriptionExpired {
                    if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                        UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                        cell.titleOlt.text = "Song Count : (\(totalTitles) of 25)"
                    }
                    else if UserDefaults.subscribeType == AppString.subscriptionType.onetime{
                        cell.titleOlt.text = "Song Count : (\(totalTitles) of 25)"
                    }
                }else{
                    cell.titleOlt.text = "Song Count : (\(totalTitles) of 5)"
                }
            }else{
                cell.titleOlt.text = "Song Count : (\(totalTitles) of 5)"
            }
            cell.txtColor = AppColor.black ?? .black
            cell.contentView.backgroundColor = .ultraLightGray
            cell.innerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.font = OutFitFont.defaultBold(size: 13.0).value
            return cell
        case .songListRow:
            if self.serverSongArr.count == 0  && self.localMusicArr.count == 0  {
                //todo: manage local image count
                let cell = tblView.dequeueCell(with: NoDataTableViewCell.self)
                cell.labelOlt.text = AppString.Description.noMusicAvailable
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tblView.dequeueCell(with: AddSongList.self)
                if indexPath.row < serverSongArr.count {
                    // Case for server-side music data
                    let musicData = serverSongArr[indexPath.row]
                    cell.titleOlt.text = musicData.title
                    cell.subTitleOlt.text = musicData.artistName
                    cell.didTapDeleteImg = { [weak self] sender in
                        guard let self = self else { return }
                        let musicId = musicData.id ?? -1
                        if musicId != -1 {
                            self.deleteMusicAlert(param: DeleteSongRequest(musicId: musicId))
                        }
                    }
                } else {
                    // Case for local music data
                    let localIndex = indexPath.row - serverSongArr.count
                    if localIndex >= 0 && localIndex < localMusicArr.count {
                        let localSong = localMusicArr[localIndex]
                        cell.titleOlt.text = localSong.trackName
                        cell.subTitleOlt.text = localSong.artistName
                        cell.didTapDeleteImg = { [weak self] sender in
                            guard let self = self else { return }
                            if localIndex >= 0 && localIndex < localMusicArr.count {
                                localMusicArr.remove(at: localIndex)
                                manageRowCount()
                                tblView.reload()
                            }
                        }
                    }
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = AddMusicSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AddMusicSection")
        }
        switch rowType {
        case .addMusicHeader:
            return Const.Height.header
        case .songCountRow:
            return Const.Height.AutomaticDimension
        case .addSongRow:
            return 63
        case .songListRow:
            return Const.Height.listing
        }
    }
}

//MARK: API CALL.
extension AddMusicViewController: UserServices {
    func reloadData() {
        //FOR : deleteSong
        if self.viewModel.requestType == .deleteSong {
            if let dict = self.viewModel.deleteSongDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success Delet Music API Response")
//                    SVProgressHUD.dismiss()
                    //update aray and sectionDict
//                    if SelectedRow != nil && self.deleteSectionIndex != nil {
//                        if var music = self.categoryArr[deleteSectionIndex!].music {
//                            music.remove(at: SelectedRow!)
//                            self.categoryArr[deleteSectionIndex!].music = music
//                            self.categoryArr.removeAll()
//                        }
//                    }
                    self.fetchApi()
                    self.viewModel.requestType = .none
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
//                    self.clearLocalMusicArr()
                    self.serverSongArr = (dict.data ?? []) ?? []
                    manageRowCount()
                    self.viewModel.requestType = .none
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
        if self.viewModel.requestType == .addAllMusic {
            if let dict = viewModel.addAllMusic {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
                    SVProgressHUD.dismiss()
                    if let data = dict.data {
                        self.uploadedMusicArray = data
                    }
                    self.successMuiscAddAlert()
                    self.viewModel.requestType = .none
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

//MARK: AddMusicViewController.
extension AddMusicViewController{
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
//        alertController.addAction(documentAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}


//MARK: UIDocumentPickerDelegate.
extension AddMusicViewController: UIDocumentPickerDelegate {
    
    func pickerAudioFile(){
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        if let selectedURL = urls.first{
//            // Extract track name and artist from the selected URL
//            if let songData = extractArtistAndTrackName(from: selectedURL) {
//                let artistName = songData.artist
//                let trackName = songData.trackName
//                
//                let newSong = AddSongModel(artistName: artistName,
//                                           url: selectedURL.absoluteString,
//                                           trackName: trackName,
//                                           appleMusicSongId: nil,
//                                           type: .local)
//                
//                debugLog("Selected Song Detail: \(artistName), \(trackName), \(selectedURL.absoluteString)")
//                let allowedFileSize = 5.0 * 1024 * 1024
//                let fileSize = selectedURL.fileSize
//                debugLog("File Size: \(fileSize)")
//                if fileSize > allowedFileSize {
//                    debugLog("File is larger than 5 MB")
//                    //show toast
//                    DispatchQueue.main.async {
//                        Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.greaterThan5MB)
//                    }
//                }else {
//                    let isURLInLocalArray = localMusicArr.contains(where: { $0.url == selectedURL.absoluteString })
//                    let isURLInServerArray = serverSongArr.contains(where: { $0.url == selectedURL.absoluteString })
//
//                    if !isURLInLocalArray && !isURLInServerArray {
//                        localMusicArr.append(newSong)
//                    } else {
//                        Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.songAlreadyExistInLibrary)
//                    }
//                }
//            }
//            selectedMusicURL.append(contentsOf: urls)
//            manageRowCount()
//            tblView.reload()
//        }
//    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedURL = urls.first {
            // Extract track name and artist from the selected URL
            if let songData = extractArtistAndTrackName(from: selectedURL) {
                let artistName = songData.artist
                let trackName = songData.trackName

                let newSong = AddSongModel(artistName: artistName,
                                           url: selectedURL.absoluteString,
                                           trackName: trackName,
                                           appleMusicSongId: nil,
                                           type: .local)

                debugLog("Selected Song Detail: \(artistName), \(trackName), \(selectedURL.absoluteString)")
                let allowedFileSize = 5.0 * 1024 * 1024
                let fileSize = selectedURL.fileSize
                debugLog("File Size: \(fileSize)")

                if fileSize > allowedFileSize {
                    debugLog("File is larger than 5 MB")
                    // Show toast
                    DispatchQueue.main.async {
                        Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.greaterThan5MB)
                    }
                }else if !selectedURL.absoluteString.lowercased().contains(".mp3") {
                    DispatchQueue.main.async {
                        Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.chooseMp3Song)
                    }
                }else {
                    let isTitleInServerArray = serverSongArr.contains(where: { $0.title == trackName && $0.artistName == artistName })
                    let isTitleInLocalArray = localMusicArr.contains(where: { $0.trackName == trackName && $0.artistName == artistName })
                    if isTitleInServerArray || isTitleInLocalArray{
                        Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.songAlreadyExistInLibrary)
                    } else {
                        localMusicArr.append(newSong)
                        debugLog("File size is less than or equal to 5 MB and not in local/server arrays")
                    }
                }
            }
            
            // Add the selected URLs to selectedMusicURL (if not already added)
            let isURLInSelectedMusicArray = selectedMusicURL.contains { $0.absoluteString == selectedURL.absoluteString }
            if !isURLInSelectedMusicArray {
                selectedMusicURL.append(contentsOf: urls)
            }

            manageRowCount()
            tblView.reload()
        }
    }



    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancel action
        debugLog("User cancelled file selection.")
    }
}

//MARK: MPMediaPickerControllerDelegate
extension AddMusicViewController : MPMediaPickerControllerDelegate {
    
    func openSongLibrary() {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
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
            let trackName = item.title?.replacingOccurrences(of: ",", with: "") ?? "Unknown Track"
            
            let artistName = item.artist?.replacingOccurrences(of: ",", with: "") ?? "Unknown Artist"
            
            let albumName = item.albumTitle?.replacingOccurrences(of: ",", with: "") ?? "Unknown Album"
            
            let persistentID: UInt64 = item.persistentID
            // Define the songURL safely
            var songURL: URL? = nil
            if let assetURL = item.assetURL {
                songURL = assetURL
                debugLog("Song URL (for playback): \(songURL?.absoluteString ?? "")")
            }

            let song = AddSongModel(artistName: artistName,
                                    url: nil,
                                    trackName: trackName,
                                    appleMusicSongId: persistentID,
                                    type: .apple)
            let isTitleInServerArray = serverSongArr.contains(where: { $0.title == trackName && $0.artistName == artistName })
            let isTitleInLocalArray = localMusicArr.contains(where: { $0.trackName == trackName && $0.artistName == artistName })
            if isTitleInServerArray || isTitleInLocalArray{
                Utilities.sharedInstance.showToast(source: self, message: AppString.Alert.songAlreadyExistInLibrary)
            }else {
                self.localMusicArr.append(song)
                debugLog("File size is less than or equal to 5 MB and not in local/server arrays")
            }
            manageRowCount()
            debugLog("Library Song Selected: \(artistName), \(trackName)")
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

//MARK: AddMusicViewController.
extension AddMusicViewController{
    private  func deleteMusicAlert( param : DeleteSongRequest){
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithDoubleButtonViewController") as! AlertWithDoubleButtonViewController
        vc.image = UIImage(named: "ic_bin")
        if !UserDefaults.isSubscriptionExpired {
            if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                vc.heading = AppString.Header.delete
                vc.content = AppString.Alert.deleteMusic
            }else{
                vc.heading = AppString.Header.upgrade
                vc.content = AppString.Alert.deleteMusicWithoutSub
            }
        }else{
            vc.heading = AppString.Header.upgrade
            vc.content = AppString.Alert.deleteMusicWithoutSub
        }
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
                    SVProgressHUD.show()
                    if !UserDefaults.isSubscriptionExpired {
                        if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                            UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                            self.viewModel.deleteSongData(parameters: param)
                        }else{
                           //For UNSubscribe User.
                            self.pushVC(with: OurSubscriptionViewController.self, storyboardName: .main)
                        }
                    }else{
                        //For UNSubscribe User.
                        self.pushVC(with: OurSubscriptionViewController.self, storyboardName: .main)
                    }
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
}

//MARK: AddMusicViewController
extension AddMusicViewController {
    func addMusicData() {
        self.view.endEditing(true)
        
        if Reachability.isConnectedToNetwork() {
            //        case apple = "apple_music"
            //        case local = "local_song"
            var mimeType: [String] = []
            var musics: [[String]] = []
            var keysValue: [String] = []
            var songParam = [String: Any]()
            var appleMusicIds = [String]()
            var types = [String]()
            var appleMusicUploaded: Bool = false
            let title = localMusicArr.compactMap({$0.trackName}).convertToStringWithoutBracket
            let artist = localMusicArr.compactMap({$0.artistName}).convertToStringWithoutBracket
            print("Title: \(title)")
            print("Artist: \(artist)")
            for song in localMusicArr.map({ $0 }) {
                if song.type == .local {
                    if let songURL = song.url {
                        musics.append([songURL.description])
                    }
                    mimeType.append("audio/mp3")
                    keysValue.append("song[]")
                    types.append(SongType.local.rawValue)
                }
                else  {
                    types.append(SongType.apple.rawValue)
                    appleMusicUploaded = true
                    appleMusicIds.append(song.appleMusicSongId?.description ?? "")
                }
            }
            
            songParam = [
                "title": title,
                "artist_name": artist,
                "type": types.convertToStringWithoutBracket
            ]
            
            if appleMusicUploaded {
                songParam["apple_music_id"] = appleMusicIds.convertToStringWithoutBracket
            }
           
            
//            if !localMusicArr.isEmpty {
//                let song =  {
//                    switch type {
//                    case .apple:
//                        songParam = [
//                            "title": title,
//                            "artist_name": artist,
//                            "type": ,
//                            "apple_music_id":
//                        ]
//                        
//                    case .local:
//                        
////                        if let songURL = song.url {
////                            musics = [[songURL.description]]
////                        }
//                    }
//                }
//            }
            
//            let parameters: [String: Any] = [
//                "title": "title1,title2",
//                "artist_name": "artist1,artist2"
//            ]

           
//
            print("paramemter: \(songParam)")
            SVProgressHUD.show()
            self.viewModel.addAllMusicData(param: songParam,
                                           keysValue: keysValue,
                                           mimeTypes: mimeType,
                                           musics: musics)
            debugLog("Prepared param for \(title): \(songParam)")
        }
        else {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
  
}

extension AddMusicViewController{
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
            self.goToBack()
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

//MARK: AddSongModel.
struct AddSongModel{
    var artistName : String?
    var url : String?
    var trackName : String?
    var appleMusicSongId: UInt64?
    var type: SongType? //apple_music,local_song,
}


//MARK: AddMusicViewController.
extension AddMusicViewController {
    
    func checkSongUploadLimit() {
        
        let musicCount = self.localMusicArr.count + self.serverSongArr.count
        
        // Get the song limit based on the subscription status
        var limit: Int = getSongLimit()
        
        // Check subscription status
        if !UserDefaults.isSubscriptionExpired {
            if UserDefaults.subscribeType == AppString.subscriptionType.annually ||
                UserDefaults.subscribeType == AppString.subscriptionType.monthly{
                if musicCount < 25 {
                    self.openSongOption()
                }
                else{
                    Utilities.sharedInstance.showToast(source: self, message: Toast.Message.limitReached)
                }
            }
            else if musicCount < 5 {
                self.openSongOption()
            }
            else {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Message.limitReached)
            }
        }else{
            if musicCount < 5{
                self.openSongOption()
            }else{
                Utilities.sharedInstance.showToast(source: self, message: Toast.Message.limitReached)
            }
        }
    }
    
    
    private func getSongLimit() -> Int {
        var limit: Int = 0
        
        // Check if the user has a valid subscription and set limit accordingly
        if !UserDefaults.isSubscriptionExpired {
            // User has an active subscription, set limit to 25
            limit = 25
        } else {
            // No subscription, set limit to 5
            limit = 5
        }
        
        return limit
    }
}
