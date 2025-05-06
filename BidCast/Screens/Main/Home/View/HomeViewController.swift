//
//  HomeViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import UIKit
import SVProgressHUD
import Security
import FittedSheets
import OneSignalExtension

enum HomeSection: Int,CaseIterable {
    case alarmHeader
    case alarmHeaderTitle
    case myalarmHeader
    case myAlarmList
    case newAlarmButton
    
    func numberOfRows(data: [HomeSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}


class HomeViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    @IBOutlet var myMuiscBtn: UIButton!
    
    // MARK: Properties
    let viewModel = HomeViewModel()
    let profileViewModel = ProfileViewModel()
    let subscriptionViewModel = SubscriptionViewModel()
    var alarmData:[AlarmModel] = []
    var currentWeatherDataArr : CurrentWeatherModel?
    var isFirstTimeLogin: Bool = false
    var isInitial = true
    var player: AVPlayer?
    var lat : Double?
    var long : Double?

    
    private let alarmDelegate: AlarmApplicationDelegate = AppDelegate()
    private let scheduler: NotificationSchedulerDelegate = NotificationScheduler()
    private let alarms: Alarms = Store.shared.alarms
    private var selectedIndexPath: IndexPath?
    
    var deletedAlarmIndex: Int?
    
    //MARK: sectionData
    lazy var sectionData: [HomeSection: Int] = [
        .alarmHeader: 1,
        .alarmHeaderTitle : 0,
        .myalarmHeader: 1,
        .myAlarmList: alarmData.count,
        .newAlarmButton : 1
    ]
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInit()
        //add notification handler
        debugLog("Alaram Local Data \(alarms.count)")
        debugLog("Alaram API Data \(alarmData.count)")

//        // Example usage:
//        let songURL = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3" // Replace with a valid audio file URL
//        // Request permission and then call the function:
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//            if granted {
//                print("Notification permission granted.")
//                // Schedule the notification with the sound from the URL.
//                self.scheduleNotificationWithSoundFromURL(urlString: songURL)
//            } else {
//                print("Notification permission denied.")
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                }
//            }
//        }
    }
//    override func viewDidAppear(_ animated: Bool) {
//        if let soundURL = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3") {
//            URLSession.shared.dataTask(with: soundURL) { (data, response, error) in
//                if let error = error {
//                    print("Error downloading audio: \(error.localizedDescription)")
//                    return
//                }
//                if let data = data {
//                    do {
//                        let player = try AVAudioPlayer(data: data)
//                        DispatchQueue.main.async { // Update UI on the main thread
//                            player.prepareToPlay()
//                            player.play()
//                        }
//                    } catch let audioError as NSError {
//                        print("Audio Player Error: \(audioError.localizedDescription)")
//                        print("Error Domain: \(audioError.domain)")
//                        print("Error Code: \(audioError.code)")
//                    }
//                }
//            }.resume()
//        }
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        if let soundURL = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") {
//            print("Attempting to download audio from: \(soundURL)")
//            //            let url = URL(string: "
//            //            https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3")
//            
//            let playerItem: AVPlayerItem = AVPlayerItem(url: soundURL)
//            if let player = player {
//                player.replaceCurrentItem(with: playerItem)
//            } else {
//                player = AVPlayer(playerItem: playerItem)
//            }
//            
//            playerItem.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
//        } else {
//            print("Invalid sound URL.")
//        }
//    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status = player?.currentItem?.status
            switch status {
            case .readyToPlay:
                // Player is ready to play
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    self.player?.play() // Play after a short delay
                }
            case .failed:
                // Handle the error
                print("Error playing audio: \(player?.currentItem?.error?.localizedDescription ?? "Unknown error")")
            case .unknown:
                // Handle the unknown status
                print("Unknown status")
            default:
                // Handle other statuses
                print("Other status: \(status)")
            }
        }
    }
    
    
    
//    func reinitalizeLocalAlarms() {
//        //check if user is first time login -> delete all local alarms and reinitialize with all alarms coming from API for that user
//        if !alarmData.isEmpty && isFirstTimeLogin{
//            //delete all old alarms
//            debugLog("reinitalizeLocalAlarms")
//            self.deleteAllLocalAlarms()
//            //add all alarms coming from api to local
//            self.addAlarms(self.alarmData)
//        }
//    }
    
//    private func deleteAllLocalAlarms() {
//        alarms.removeAllAlarm()
//    }

//    private func addAlarms(_ alarmArr: [AlarmModel]) {
//        for al in alarmArr {
//            let alarm = Alarm()
//            let currentDate = createDateFromCurrentDateAndTime(timeString: al.time ?? "")
//            alarm.date = currentDate ?? Date()
//            alarm.enabled = true
//            alarm.snoozeEnabled = true
//            alarm.label = al.title ?? ""
//            alarm.mediaID = ""
//            alarm.mediaLabel = "bell"
//            alarm.descriptions = al.comment ?? ""
//            alarm.repeatWeekdays = al.days?.compactMap({DayType.integerValue($0)}) ?? []
//            alarms.add(alarm)
//        }
//    }
    
    //MARK: - Configure view Method.
    private func loadInit(){
        self.initialViewModel()
        self.configureTableView()
        self.tblView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchApi()
        sectionData[.myAlarmList] = self.alarmData.count > 0 ? self.alarmData.count : 0
        tblView.reload()
    }
    
    @objc func handleChangeNotification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        // Handle changes to contents
        if let changeReason = userInfo[Alarm.changeReasonKey] as? String {
            let newValue = userInfo[Alarm.newValueKey]
            let oldValue = userInfo[Alarm.oldValueKey]
            switch (changeReason, newValue, oldValue) {
            case let (Alarm.removed, (uuid as String)?, (oldValue as Int)?):
                
                DispatchQueue.main.async {
                   // self.tblView.deleteRows(at: [IndexPath(row: oldValue, section: 3)], with: .fade)
                    self.tblView.reloadData()
                    self.dismiss(animated: true)
                }
                scheduler.cancelNotification(ByUUIDStr: uuid)
            case let (Alarm.added, (index as Int)?, _):
                
                self.tblView.reload()
                let alarm = alarms[index]
                scheduler.setNotification(date: alarm.date, ringtoneName: alarm.mediaLabel, repeatWeekdays: alarm.repeatWeekdays, snoozeEnabled: alarm.snoozeEnabled, onSnooze: false, uuid: alarm.uuid.uuidString,title : alarm.label,description : alarm.descriptions, type: alarm.type,id: alarm.alarmId)
                
            case let (Alarm.updated, (index as Int)?, _):
                let alarm = alarms[index]
                let uuid = alarm.uuid.uuidString
                if alarm.enabled {
                    scheduler.updateNotification(ByUUIDStr: uuid, date: alarm.date, ringtoneName: alarm.mediaLabel, repeatWeekdays: alarm.repeatWeekdays, snoonzeEnabled: alarm.snoozeEnabled,title : alarm.label,description : alarm.descriptions, type: alarm.type,id: alarm.alarmId)
                } else {
                    scheduler.cancelNotification(ByUUIDStr: uuid)
                }
                
                
                //                DispatchQueue.main.async {
                //                    self.tblView.reloadRows(at: [IndexPath(row: index, section: 3)], with: .automatic)
                //                }
                //                self.tblView.reload()
            default: tblView.reloadData()
            }
        }
        
        else {
            tblView.reloadData()
        }
    }
    
    @IBAction func muMusicTapped(_ sender: UIButton) {
        self.pushVC(with: MyMusicViewController.self, storyboardName: .main)
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.configTblView(bgColor: AppColor.lightGray ?? .lightGray)
        //register cells
        let cellIds = [DetailValueCell.identifier,
                       AppHeaderCell.identifier,
                       AlarmCell.identifier,LocationNameCell.identifier,SubmitCell.identifier,WeatherDetailTblCell.identifier]
        tblView.registerCells(for: cellIds)
        myMuiscBtn.makeCornerRounded(ofSize: Corner_26)
        configureHeaderView()
        
    }
    //MARK: configureHeaderView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(rightButtonHidden: false,
                                        leftButtonHidden: true,
                                        headerName: AppString.VCName.home,rightButtonAction: didTapSideMenu)
        self.headerView.bottomLbl.isHidden = false
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchWithLabel : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.notNotchCenter : 0
        self.headerView.bottomLbl.text = AppString.VCName.riseShineSwing
    }
    
    
    //MARK: fetch api .
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            if isInitial{
                isInitial = !isInitial
                SVProgressHUD.show()
            }
            self.getAlarmData()
            self.getCurrentWeatherData()
            self.fetchSubscriptionApi()
            self.fetchUserDataApi()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    //MARK: getAlarmData API
    private func getAlarmData(){
        if Reachability.isConnectedToNetwork(){
//            SVProgressHUD.show()
            self.viewModel.getAlarmData()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    //MARK: getCurrentWeatherData API
    private func getCurrentWeatherData(){
        if Reachability.isConnectedToNetwork(){
//            SVProgressHUD.show()
            let param = CurrentWeatherRequest(lat: lat ?? 0.0, long: long ?? 0.0 ,current_weather: "true")
            self.viewModel.getCurrentWeatherData(parameters: param)
            print("Current Weather Param \(param)")
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    //MARK: fetchUserDataApi API
    private func fetchUserDataApi(){
        if Reachability.isConnectedToNetwork(){
//            SVProgressHUD.show()
            self.profileViewModel.getUserData()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }

    
    //MARK: fetchSubscription API
    private func fetchSubscriptionApi(){
        if Reachability.isConnectedToNetwork(){
//            SVProgressHUD.show()
            self.subscriptionViewModel.validateSubscriptionRequest()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    // MARK: initialViewModel
    func initialViewModel(){
        viewModel.userDelegate = self
        profileViewModel.userDelegate = self
        subscriptionViewModel.userDelegate = self
    }
    
    //MARK: didTabBack.
    @objc private func didTapSideMenu(){
        self.openSideMenu()
    }
    
    //MARK: changeAlarmStatus.
    func changeAlarmStatus(alarmId: Int, status: String) {
        let changeAlarmParam = changeAlarmRequest(alarm_id: alarmId, status: status)
        if Reachability.isConnectedToNetwork() {
//            SVProgressHUD.show()
            self.viewModel.changeAlarmRequest(parameters: changeAlarmParam)
        } else {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = HomeSection(rawValue: section) else { return 0 }
//        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for HomeSection")
        }
        switch rowType {
        case .alarmHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = AppString.Header.home
            return cell
        case .alarmHeaderTitle:
            let cell = tblView.dequeueCell(with: WeatherDetailTblCell.self)
            let currentWeatherData = currentWeatherDataArr
            cell.temperatureLbl.text = "\(currentWeatherData?.temperature ?? 0)"
            cell.weatherName.text = currentWeatherData?.category
            cell.temperatureValueLbl.text = "\(currentWeatherData?.temperature ?? 0 )"
            cell.valueOne.text = "\(currentWeatherData?.dewpoint ?? 0)"
            cell.valueTwo.text = currentWeatherData?.humidity
            cell.valueThree.text = currentWeatherData?.wind?.speed
            if let sunsetTimestamp = currentWeatherData?.sunset {
                cell.valueFour.text = convertUTCToNewYorkTimeAMPM(sunsetTimestamp)
            }
            cell.roadDetailLbl.text = currentWeatherData?.shortForecast
            if let imageUrl = currentWeatherData?.icon {
                Utilities.sharedInstance.setImageWithUrl(imgStr: imageUrl, imgView: cell.weatherImgOlt)
            } else {
                cell.weatherImgOlt.image = UIImage(named: "ic_weather")
            }
            cell.contentView.backgroundColor = .clear
            cell.selectionStyle  = .none
            return cell
            
            
            
//            let cell = tblView.dequeueCell(with: LocationNameCell.self)
//            cell.titleOlt.text = UserDefaults.name
//            cell.titleOlt.font = AppFont.LblTitleBold_15
//            cell.descriptionOlt.isHidden = true
//            if UserDefaults.isSubscribe{
//                if !UserDefaults.isSubscriptionExpired{
//                    cell.descriptionOlt.text = UserDefaults.getReadableSubscriptionType()
//                    cell.descriptionOlt.textColor = AppColor.yellow
//                }
//            }else{
//                cell.descriptionOlt.textColor = AppColor.secondary
//                cell.descriptionOlt.text = AppString.Description.noSubscriptionsAvailable
//            }
//            cell.descriptionOlt.font = AppFont.LblTitleBold_15
//            cell.hideImage()
//            cell.outerViewOlt.backgroundColor = .ultraLightGray
//            cell.selectionStyle = .none
//            return cell
        case .myalarmHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = AppColor.lightGray
            cell.titleOlt.font = OutFitFont.defaultBold(size: 19.0).value
            cell.titleOlt.text = AppString.Header.myAlarms
            return cell
        case .myAlarmList:
            let cell = tblView.dequeueCell(with: AlarmCell.self)
//            let alarms = alarms[indexPath.row]
//            cell.titleOlt.text = alarms.formattedTime
//            cell.descriptionOlt.text = self.alarms[indexPath.row].descriptions
//            if alarms.enabled{
//                cell.alarmSwitch.isOn = true
//                cell.descriptionOlt.textColor = AppColor.secondary
//            }
//            else{
//                cell.alarmSwitch.isOn = false
//                cell.descriptionOlt.textColor = AppColor.mediumGray
//            }
            if !self.alarmData.isEmpty && indexPath.row < self.alarmData.count{
                cell.titleOlt.text = self.alarmData[indexPath.row].time ?? ""
//                if  self.alarmData[indexPath.row].title == ""{
//                    cell.descHeightConst.constant = 27.0
//                }
                cell.descriptionOlt.text = self.alarmData[indexPath.row].title
                if self.alarmData[indexPath.row].status == "on" {
                    cell.alarmSwitch.isOn = true
                    cell.descriptionOlt.textColor = AppColor.secondary
                }else{
                    cell.alarmSwitch.isOn = false
                    cell.descriptionOlt.textColor = AppColor.mediumGray
                }
            }
            cell.alarmSwitch.tag = indexPath.row
            cell.alarmSwitch.addTarget(self, action: #selector(toggleAlarmSwitch(_:)), for: .valueChanged)
            cell.selectionStyle = .none
            cell.outerViewOlt.backgroundColor = AppColor.lightGray
            DispatchQueue.main.async {
                self.setupUI(cell: cell, indexPath: indexPath)
            }
            return cell
            
        case .newAlarmButton:
            let cell = tblView.dequeueCell(with: LocationNameCell.self)
            cell.descriptionOlt.isHidden = true
            cell.titleOlt.font = AppFont.LblTitleBold_15
            cell.titleOlt.text = AppString.Title.newAlarm
            cell.outerViewOlt.backgroundColor = AppColor.lightGray
            cell.selectionStyle = .none
            cell.showImage()
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for HomeSection")
        }
        switch rowType {
        case .alarmHeader:
            return Const.Height.header
        case .alarmHeaderTitle:
            return 300.0
        case .myalarmHeader:
            return Const.Height.header
        case .myAlarmList:
            return Const.Height.AutomaticDimension
        case .newAlarmButton:
            return Const.Height.listing
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tblView.dequeueCell(with: AlarmCell.self)
        let numberOfRows = self.alarmData.count
        if numberOfRows <= 1 {
            // Only one row, apply corner radius to all corners
            cell.innerViewOlt.makeCornerRounded(ofSize: Corner_16)
            cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.top, .bottom, .left, .right])
//            debugLog("Only one row in section: Corner radius applied to all corners")
            cell.innerVwTopConstraint.constant = 8
            cell.innnerVwBottomConstraint.constant = 6
            cell.sepratorBottomConstraint.constant = 0
        } else {
            // Three or more rows, apply top corner to first, bottom corner to last, and no corners to the middle rows
            if indexPath.row == 0 {
                cell.addTopCorner(to: cell.innerViewOlt, cornerRadius: Corner_16)
                cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.top])
                cell.innerVwTopConstraint.constant = 8
                cell.innnerVwBottomConstraint.constant = 0
                cell.sepratorBottomConstraint.constant = 0
            } else if indexPath.row == numberOfRows - 1 {
                // Last row of the section, apply bottom corner
                cell.addBottomCorner(to: cell.innerViewOlt, cornerRadius: Corner_16)
                cell.sepratorBottomConstraint.constant = 0
                cell.innerVwTopConstraint.constant = 0
                cell.innnerVwBottomConstraint.constant = 8
                cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.bottom])
            } else {
                // Middle rows, no corners
                cell.innerVwTopConstraint.constant = 0
                cell.innnerVwBottomConstraint.constant = 0
                cell.sepratorBottomConstraint.constant = 0
                cell.addBottomCorner(to: cell.innerViewOlt, cornerRadius: 0.0)
                cell.addTopCorner(to: cell.innerViewOlt, cornerRadius: 0.0)
                cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_00, sides: [.left, .right])
//                debugLog("Middle row: No corners, bottom constant set to 0")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for HomeSection")
        }
        switch rowType {
        case .myAlarmList:
            //MARK: Not In Used
//            self.pushVCWithValue(with: NewAlarmViewController.self, storyboardName: .main) { value in
//                value.alarms = alarms
//                value.isEditMode = true
//                value.currentAlarm = alarms[indexPath.row]
//                value.alarmId = alarmData[indexPath.row].id
//                value.label = alarmData[indexPath.row].title ?? ""
//                value.descriptions = alarmData[indexPath.row].comment ?? ""
//                value.alarmtime =  alarmData[indexPath.row].time ?? ""
//                value.isNavFor = AppString.navigateFrom.editAlarm
//                let daysString = alarmData[indexPath.row].days ?? []
//                let cleanedDaysString = daysString.first?.replacingOccurrences(of: "[\"", with: "").replacingOccurrences(of: "\"]", with: "").split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
//                let daysInt = cleanedDaysString?.compactMap { DayType.integerValue($0) } ?? []
//
//                debugLog("DaysInt Value \(daysInt)")
//
//                value.repeatWeekdays = daysInt
//
//            }
            self.pushVCWithValue(with: NewAlarmViewController.self, storyboardName: .main) { value in
                let alarmModel = self.alarmData[indexPath.row]
                value.alarmModel = alarmModel
                value.isNavFor = AppString.navigateFrom.editAlarm
            }
        case .newAlarmButton:
            self.pushVCWithValue(with: NewAlarmViewController.self, storyboardName: .main) { value in
            }
        default:
            "No Navigation"
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 3 && self.alarmData.count != 0{
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
                guard let self = self else { return }
                let index = indexPath.row
                self.deletedAlarmIndex = index
                let alarmID = self.alarmData[indexPath.row].id ?? 0
                self.deleteAlarmAlert(index: index, param: deleteAlarmRequest(alarmId: alarmID))
            }
            
            deleteAction.image = createDeleteImage()
            deleteAction.backgroundColor = .pearl
            
            let swipeActionConfig = UISwipeActionsConfiguration(actions: [deleteAction])
            swipeActionConfig.performsFirstActionWithFullSwipe = false
            return swipeActionConfig
        }
        return nil
    }
    
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            if indexPath.section == 3 && self.alarms.count != 0{
    //                let index = indexPath.row
    //                self.deleteAlarmAlert(param: index)
    //            }
    //        }
    //    }
    
    private func createDeleteImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 50))
        return renderer.image { _ in
            let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .small)
            let newImage = UIImage(named: "trash")?.withTintColor(.danger).withConfiguration(configuration)
            newImage?.draw(in: CGRect(x: 0, y: 0, width: 50, height: 50))
        }
    }
    
    @objc func toggleAlarmSwitch(_ sender: UISwitch) {
        let rowIndex = sender.tag
        //API change Alarm Status
        if rowIndex >= 0 && rowIndex < self.alarmData.count {
            let alarm = self.alarmData[rowIndex]
            let alarmId = alarm.id ?? 0
            let status = sender.isOn ? "on" : "off"
            changeAlarmStatus(alarmId: alarmId, status: status)
        }
    }
    
    
    // Move this function outside of cellForRowAt
    func setupUI(cell: AlarmCell, indexPath: IndexPath) {
        let numberOfRows = self.alarmData.count
        if numberOfRows <= 1 {
            // Only one row, apply corner radius to all corners
            cell.innerViewOlt.makeCornerRounded(ofSize: Corner_16)
            cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.top, .bottom, .left, .right])
//            debugLog("Only one row in section: Corner radius applied to all corners")
            cell.innerVwTopConstraint.constant = 8
            cell.innnerVwBottomConstraint.constant = 6
            cell.sepratorBottomConstraint.constant = 0
        } else {
            // Three or more rows, apply top corner to first, bottom corner to last, and no corners to the middle rows
            if indexPath.row == 0 {
                cell.addTopCorner(to: cell.innerViewOlt, cornerRadius: Corner_16)
                cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.top])
                cell.innerVwTopConstraint.constant = 8
                cell.innnerVwBottomConstraint.constant = 0
                cell.sepratorBottomConstraint.constant = 0
            } else if indexPath.row == numberOfRows - 1 {
                // Last row of the section, apply bottom corner
                cell.addBottomCorner(to: cell.innerViewOlt, cornerRadius: Corner_16)
                cell.sepratorBottomConstraint.constant = 0
                cell.innerVwTopConstraint.constant = 0
                cell.innnerVwBottomConstraint.constant = 8
                cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_12, sides: [.bottom])
            } else {
                // Middle rows, no corners
                cell.innerVwTopConstraint.constant = 0
                cell.innnerVwBottomConstraint.constant = 0
                cell.sepratorBottomConstraint.constant = 0
                cell.addBottomCorner(to: cell.innerViewOlt, cornerRadius: 0.0)
                cell.addTopCorner(to: cell.innerViewOlt, cornerRadius: 0.0)
                cell.applySideShadow(to: cell.innerViewOlt, opacity: Opacity_05, shadowRadius: Radius_04, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey, cornerRadius: Corner_00, sides: [.left, .right])
//                debugLog("Middle row: No corners, bottom constant set to 0")
            }
        }
    }
}

//MARK: API CALL.
extension HomeViewController: UserServices {
    func reloadData() {

        //MARK: alarmDict.
        if self.viewModel.requestType == .getAlarm {
            if let dict = self.viewModel.alarmDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
//                    debugLog("success API Response")
                    //update aray and sectionDict
                    
                    self.alarmData = (dict.data ?? []) ?? []
//                    self.processAndSaveAlarms(self.alarmData)
                    sectionData[.myAlarmList] = self.alarmData.count > 0 ? self.alarmData.count : 0
                    SVProgressHUD.dismiss()
//                    debugLog("Total Alarm Count \(alarmData.count)")
                    
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
        
        //MARK: getCurrentWeather.
        if self.viewModel.requestType == .getCurrentWeather {
            if let dict = self.viewModel.getCurrentWeatherDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //update aray and sectionDict
                    self.currentWeatherDataArr = dict.data
                    sectionData[.alarmHeaderTitle] = self.currentWeatherDataArr == nil ?  0 : 1
                    SVProgressHUD.dismiss()
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
        
        //MARK: DeleteAlarm.
        if self.viewModel.requestType == .deleteAlarm {
            if let dict = self.viewModel.deleteAlarmDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
//                    debugLog("success API Response")
                    //need to work here
                    SVProgressHUD.dismiss()
                    if let index = self.deletedAlarmIndex {
//                        debugLog("Index Value \(index)")
                        DispatchQueue.main.async {
                            self.alarmData.remove(at: index) //API
//                            self.alarms.remove(at: index) //Local
                            self.sectionData[.myAlarmList] = self.alarmData.count
                            self.tblView.deleteRows(at: [IndexPath(row: index, section: 3)], with: .fade)
                        }
                    }
             

                    self.viewModel.requestType = .none
                    self.fetchApi()
                    self.tblView.reload()
//                    self.tblView.setNeedsLayout()
//                    self.tblView.layoutIfNeeded()
                    
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //MARK: SubscriptionValidation.
        if self.subscriptionViewModel.requestType == .validateSubscriptions {
            if let dict = self.subscriptionViewModel.validateSubscriptionDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
//                    debugLog("success Validation API Response")
                    SVProgressHUD.dismiss()
                    if let subscriptionData = dict.data {
                        UserDefaults.isSubscribe = subscriptionData?.isSubscribed ?? false
                        UserDefaults.isSubscriptionExpired = (subscriptionData?.subscription?.isExpired ?? "") == "yes" ? true : false
                        UserDefaults.subscribeType = subscriptionData?.subscription?.subscriptionType ?? ""
//                        UserDefaults.subscriptionMessage = UserDefaults.isSubscriptionExpired ? "Subscription Expired" : subscriptionViewModel.validateSubscriptionDict?.message ?? ""
                    }
                    self.subscriptionViewModel.requestType = .none
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
        
        //MARK: ChangeAlarmStatusDict.
        if self.viewModel.requestType == .changeAlarmStatus {
            if let dict = self.viewModel.changeAlarmStatusDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
//                    debugLog("success API Response")
                    //update sttaus for Array
                    SVProgressHUD.dismiss()
                    if let row = dict.data, let id = row?.id {
                        for (index, data) in alarmData.enumerated() {
                            if data.id == id {
                                alarmData[index].status = row?.status ?? ""
                                //change status in local Alarm too
                                let rowIndex = index
                                if rowIndex >= 0 && rowIndex < self.alarms.count {
                                    let alarm = alarms[rowIndex]
                                    alarm.enabled = (row?.status ?? "") == "on" ? true : false
                                    alarms.update(alarm)
                                }
                            }
                        }
                    }
                    
//                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? ""  ,backgroundColor : .success.withAlphaComponent(0.8))
                    self.viewModel.requestType = .none
//                    self.tblView.reload()
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //MARK: getProfile.
        if self.profileViewModel.requestType == .getProfile {
            if let dict = self.profileViewModel.getUserDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
//                    debugLog("success API Response")
                    SVProgressHUD.dismiss()
                    if let userData = dict.data {
                        UserDefaults.firstName = userData.firstName ?? ""
                        UserDefaults.name = userData.name ?? ""
                        UserDefaults.lastName =  userData.lastName ?? ""
                        UserDefaults.email =  userData.email ?? ""
                        UserDefaults.profileImage = userData.profile_image ?? ""
                    }
                    self.profileViewModel.requestType = .none
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
        
        //Get Weather Data.
        if self.viewModel.requestType == .getWeather {
            if let dict = self.viewModel.weatherDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
                    //update aray and sectionDict
                    SVProgressHUD.dismiss()
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
    }
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
}

//MARK: calldeleteApiforFieldGroup.
extension HomeViewController{
    
    private  func deleteAlarmAlert( index : Int,param : deleteAlarmRequest){
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithDoubleButtonViewController") as! AlertWithDoubleButtonViewController
        vc.image = UIImage(named: "ic_bin")
        vc.content = AppString.Alert.deleteAlarm
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
                    self.viewModel.deleteAlarmData(parameters: param)
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
    
    // Your existing DayType enum
    enum DayType: Int {
        case mon = 0
        case tue
        case wed
        case thu
        case fri
        case sat
        case sun

        static func getRawValue(_ day: String) -> Int? {
            switch day.lowercased() {
            case "mon":
                return DayType.mon.rawValue
            case "tue":
                return DayType.tue.rawValue
            case "wed":
                return DayType.wed.rawValue
            case "thu":
                return DayType.thu.rawValue
            case "fri":
                return DayType.fri.rawValue
            case "sat":
                return DayType.sat.rawValue
            case "sun":
                return DayType.sun.rawValue
            default:
                return nil
            }
        }
    }

    // In your processAndSaveAlarms function
    private func processAndSaveAlarms(_ alarmsData: [AlarmModel]) {
        let notificationScheduler = NotificationScheduler()

        for alarmModel in alarmsData {
            let newAlarm = Alarm()
            
            // Assuming your AlarmModel structure includes relevant fields
            newAlarm.date = createDateFromCurrentDateAndTimeForLocal(timeString: alarmModel.time ?? "") ?? Date()
            print("Scheduling alarm for date: \(newAlarm.date)")
            newAlarm.label = alarmModel.title ?? ""
            newAlarm.mediaID =  "" // Assuming media ID exists
            newAlarm.mediaLabel = "bell" // or any custom label
            newAlarm.descriptions = alarmModel.comment ?? ""
            newAlarm.repeatWeekdays = alarmModel.days?.compactMap { DayType.getRawValue($0) } ?? []
            newAlarm.alarmId = alarmModel.id ?? 0 // Assuming id exists
            
            // Add the alarm, handle duplicates inside Alarms class
            alarms.add(newAlarm)
            NotificationCenter.default.addObserver(self, selector: #selector(handleChangeNotification(_:)), name: Store.changedNotification, object: nil)
        }
    }
}

import UserNotifications
import AVFoundation


extension HomeViewController {
    
//    func scheduleNotificationWithSoundFromURL(urlString: String) {
//        // 1. Get the shared URLSession.
//        let session = URLSession.shared
//
//        // 2. Create a URL from the URL string.
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL: \(urlString)")
//            return
//        }
//
//        // 3. Create a download task.
//        let downloadTask = session.downloadTask(with: url) { (location, response, error) in
//            // 4. Handle errors.
//            if let error = error {
//                print("Error downloading sound file: \(error.localizedDescription)")
//                // IMPORTANT:  If the download fails, you *must* use the default sound or
//                //  handle this error appropriately (e.g., show an alert to the user).
//                //  You cannot proceed with a nil or invalid sound file.  Returning here.
//                DispatchQueue.main.async {
//                    self.scheduleNotificationWithDefaultSound(title: "Error", body: "Failed to download custom sound. Using default.")
//                }
//                return
//            }
//
//            // 5. Ensure a file was downloaded.
//            guard let location = location else {
//                print("Downloaded file location is nil.")
//                DispatchQueue.main.async {
//                    self.scheduleNotificationWithDefaultSound(title: "Error", body: "No file downloaded. Using default.")
//                }
//                return
//            }
//            //Get file extension
//            let fileExtension = response?.suggestedFilename?.components(separatedBy: ".").last ?? "caf"
//
//            // 6. Create a temporary file URL in your app's cache directory.  Important to use a location your app can write to.
//            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_sound.\(fileExtension)")
//
//            do {
//                // 7. Move the downloaded file to the temporary location.
//                try FileManager.default.moveItem(at: location, to: tempFileURL)
//
//                // 8. Get the file path.
//                let localFilePath = tempFileURL.path
//
//                // 9.  Check the file exists
//                 if !FileManager.default.fileExists(atPath: localFilePath) {
//                    print("File does not exist at path: \(localFilePath)")
//                     DispatchQueue.main.async {
//                        self.scheduleNotificationWithDefaultSound(title: "Error", body: "Downloaded file not found. Using default.")
//                    }
//                    return
//                }
//
//                // 10. Schedule the notification with the downloaded sound.  This MUST be done on the main thread.
//                DispatchQueue.main.async {
//                    self.scheduleNotificationWithCustomSound(soundPath: localFilePath)
//                }
//
//            } catch {
//                // 11. Handle file move errors.
//                print("Error moving downloaded file: \(error.localizedDescription)")
//                 DispatchQueue.main.async {
//                     self.scheduleNotificationWithDefaultSound(title: "Error", body: "Error saving downloaded sound. Using default.")
//                 }
//                return
//            }
//        }
//
//        // 12. Start the download task.
//        downloadTask.resume()
//    }
    
    
    func scheduleNotificationWithSoundFromURL(urlString: String) {
        // 1. Get the shared URLSession.
        let session = URLSession.shared

        // 2. Create a URL from the URL string.
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        // 3. Create a download task.
        let downloadTask = session.downloadTask(with: url) { (location, response, error) in
            // 4. Handle errors.
            if let error = error {
                print("Error downloading sound file: \(error.localizedDescription)")
                // IMPORTANT:  If the download fails, you *must* use the default sound or
                //  handle this error appropriately (e.g., show an alert to the user).
                //  You cannot proceed with a nil or invalid sound file.  Returning here.
                DispatchQueue.main.async {
                    self.scheduleNotificationWithDefaultSound(title: "Error", body: "Failed to download custom sound. Using default.")
                }
                return
            }

            // 5. Ensure a file was downloaded.
            guard let location = location else {
                print("Downloaded file location is nil.")
                DispatchQueue.main.async {
                    self.scheduleNotificationWithDefaultSound(title: "Error", body: "No file downloaded. Using default.")
                }
                return
            }
            //Get file extension
            let fileExtension = response?.suggestedFilename?.components(separatedBy: ".").last ?? "caf"

            // 6. Create a temporary file URL in your app's cache directory.  Important to use a location your app can write to.
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_sound.\(fileExtension)")

            do {
                // 7. Remove any existing file at the destination URL before moving the downloaded file.
                if FileManager.default.fileExists(atPath: tempFileURL.path) {
                    try FileManager.default.removeItem(at: tempFileURL)
                    print("Existing file removed at: \(tempFileURL.path)")
                }
                // 8. Move the downloaded file to the temporary location.
                try FileManager.default.moveItem(at: location, to: tempFileURL)

                // 9. Get the file path.
                let localFilePath = tempFileURL.path

                // 10.  Check the file exists
                 if !FileManager.default.fileExists(atPath: localFilePath) {
                    print("File does not exist at path: \(localFilePath)")
                     DispatchQueue.main.async {
                        self.scheduleNotificationWithDefaultSound(title: "Error", body: "Downloaded file not found. Using default.")
                    }
                    return
                }

                // 11. Schedule the notification with the downloaded sound.  This MUST be done on the main thread.
                DispatchQueue.main.async {
                    self.scheduleNotificationWithCustomSound(soundPath: localFilePath)
                }

            } catch {
                // 12. Handle file move errors.
                print("Error moving downloaded file: \(error.localizedDescription)")
                 DispatchQueue.main.async {
                     self.scheduleNotificationWithDefaultSound(title: "Error", body: "Error saving downloaded sound: \(error.localizedDescription)")
                 }
                return
            }
        }

        // 13. Start the download task.
        downloadTask.resume()
    }




    func scheduleNotificationWithCustomSound(soundPath: String) {
        // 1. Create the notification content.
        let content = UNMutableNotificationContent()
        content.title = "Custom Sound Notification"
        content.body = "This notification uses a custom sound."
        //content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "my_custom_sound.caf"))
         let soundURL = URL(fileURLWithPath: soundPath)
            do {
                let customSound = try UNNotificationSound(named: UNNotificationSoundName(rawValue: soundURL.lastPathComponent))
                 content.sound = customSound
            }
            catch{
                 print("Error creating sound: \(error.localizedDescription)")
                 content.sound = .default
            }


        // 2. Create a trigger (e.g., a time interval trigger).
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // Trigger after 5 seconds

        // 3. Create the notification request.
        let request = UNNotificationRequest(identifier: "customSoundNotification", content: content, trigger: trigger)

        // 4. Get the notification center.
        let center = UserNotifications.UNUserNotificationCenter.current()

        // 5. Add the notification request.
        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification with custom sound scheduled from path: \(soundPath)")
            }
        }
    }

    func scheduleNotificationWithDefaultSound(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "defaultSoundNotification", content: content, trigger: trigger)
        let center = UserNotifications.UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print("Error scheduling default notification: \(error)")
            } else {
                print("Default notification scheduled")
            }
        }
    }

}
