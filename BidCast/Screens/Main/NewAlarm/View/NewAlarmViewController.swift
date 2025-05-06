//
//  NewAlarmViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import UIKit
import SVProgressHUD
import Security

enum AlarmSection: Int,CaseIterable {
    case newAlarmHeader
    case timePicker
    case detailHeader
    case selectDay
    case descriptions
    
    func numberOfRows(data: [AlarmSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

enum DayType: Int {
    case mon = 0
    case tue
    case wed
    case thu
    case fri
    case sat
    case sun
    
    static func getRawValue(_ day: String) -> Int? {
        switch day {
        case "Mon":
            return DayType.mon.rawValue
        case "Tue":
            return DayType.tue.rawValue
        case "Wed":
            return DayType.wed.rawValue
        case "Thu":
            return DayType.thu.rawValue
        case "Fri":
            return DayType.fri.rawValue
        case "Sat":
            return DayType.sat.rawValue
        case "Sun":
            return DayType.sun.rawValue
        default:
            return nil
        }
    }
}


class NewAlarmViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet var newAlramBtn: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    var alarmModel: AlarmModel?

    // MARK: Properties
    var alarmTitle = ""
    var alarmtime = ""
    var alarmDays: [String] = [] // Selected days
    var comment = ""
    var isNavFor = ""
    var alarmId: Int?
    
    let viewModel = NewAlarmViewModel()

    // MARK: Properties
    var sectionData: [AlarmSection: Int] = [
        .newAlarmHeader: 1,
        .timePicker: 1,
        .detailHeader : 1,
        .selectDay: 1,
        .descriptions : 1
    ]
    var selectedDays = Set<Int>()
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.tblView.reloadData()
        self.initViewModel()
        if let model = alarmModel {
            alarmTitle = model.title ?? ""
            alarmtime = model.time ?? ""
            self.alarmId = model.id
            alarmDays = model.days ?? []
            selectedDays = prepareSet(alarmDays)
            debugLog("selectedDays: \(selectedDays)")
            comment = model.comment ?? ""
            tblView.reload()
        }
    }
    
    
    //please pass day as mon, tue, wed and so on
    func prepareSet(_ days:[String]) -> Set<Int>{
        var res = Set<Int>()
        days.forEach { day in
            let data = DayType.getRawValue(day)
            if data != nil {
                res.insert(data!)
            }
        }
        return res
    }
    
    
    func convertToDate(from timeString: String) -> Date? {
        // Create a DateFormatter instance
        let dateFormatter = DateFormatter()
        
        // Set the date format based on the time string
        dateFormatter.dateFormat = "h mm a"
        
        // Optionally, set the locale to ensure AM/PM is handled correctly
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Convert the time string to Date and return it
        return dateFormatter.date(from: timeString)
    }
    
    @IBAction func newAlarmTapped(_ sender: UIButton) {
        self.submit()
        //convert alarmtime to date
//        if let alarm = currentAlarm {
//            debugLog("alarmtime: \(convertToDate(from: alarmtime))")
//            alarm.date = convertToDate(from: alarmtime) ?? Date()
//            alarm.enabled = true
//            alarm.snoozeEnabled = snoozeEnabled
//            alarm.label = label
//            alarm.mediaID = mediaID
//            alarm.mediaLabel = mediaLabel
//            alarm.repeatWeekdays = [0,1]
////            if isEditMode {
////                alarms?.update(alarm)
////            }
////            else {
//                alarms?.add(alarm)
////            }
//        }
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.configTblView()
        
        //register cells
        let cellIds = [SubmitCell.identifier,
                       TextFieldWithoutTittleCell.identifier,
                       SelectDaySliderCell.identifier,TitleAndDescriptionCell.identifier,TimePickerCell.identifier,AppHeaderCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.backgroundColor = AppColor.lightGray
        newAlramBtn.makeCornerRounded(ofSize: Corner_26)
        configureHeaderView()
        
    }
    
    //MARK: configureHeaderView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(rightButtonHidden: false,
                                        leftButtonHidden: false,
                                        headerName: isNavFor == AppString.navigateFrom.editAlarm ? AppString.VCName.editAlarm : AppString.VCName.newAlarm,rightButtonAction: didTapSideMenu,leftButtonAction: didTabBack)
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        viewModel.userDelegate = self
    }
    
    //MARK: - didtapBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    //MARK: submit
    private func submit(){
        self.view.endEditing(true)
        if self.alarmtime == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmTime)
        }else if self.alarmDays == [""] {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmDays)
        }
//        else if self.alarmTitle == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmTitle)
//        }else if self.comment == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmComment)
//        }
        else{
            if Reachability.isConnectedToNetwork() {
                //sign in
                if isNavFor == AppString.navigateFrom.editAlarm  {
                    //edit case
                    if let id = alarmId {
                        SVProgressHUD.show()
//                        let newAlarmParam = NewAlarmRequest(alarm_id: id, title: alarmTitle, time: alarmtime, days: alarmDays, comment: comment)
                        self.addAlarmData()
                    }
                }
                else  {
                    //add case
                    SVProgressHUD.show()
//                    let newAlarmParam = NewAlarmRequest(title: alarmTitle,time: alarmtime,days: alarmDays,comment: comment)
                    self.addAlarmData()
                }
            }
            else {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
            
            self.view.endEditing(true)
            
        }
    }
    
    //MARK: didTabBack.
    @objc private func didTapSideMenu(){
        self.openSideMenu()
    }
    
    //MARK: addAlarmData.
    func addAlarmData() {
          self.view.endEditing(true)
  
          if Reachability.isConnectedToNetwork() {
  
              let currentDate = createDateFromCurrentDateAndTime(timeString: alarmtime)
  
              var mimeType: [String] = []
              var musics: [[String]] = [[]]
              var keysValue: [String] = []
  
              if let id = alarmId {
                  //                      var songParam: [String: Any] = [
                  //                          "alarm_id" : alarmId ?? 0,
                  //                          "title" : alarmTitle,
                  //                          "time": alarmtime,
                  //                          "days": alarmDays,
                  //                          "comment": comment
                  //                      ]
                  let alarmRequest = AlarmRequest(title: alarmTitle,
                                                  time: alarmtime,
                                                  comment: comment,
                                                  days: alarmDays.convertToStringWithoutBracket,
                                                  alarm_id: id)
                  
                  SVProgressHUD.show()
                  self.viewModel.newAlarmRequest(request: alarmRequest)
              }else{
//                      var songParam: [String: Any] = [
//                          "title" : alarmTitle,
//                          "time": alarmtime,
                  //                          "days": alarmDays,
                  //                          "comment": comment
                  //                      ]
                  let alarmRequest = AlarmRequest(title: alarmTitle,
                                                  time: alarmtime,
                                                  comment: comment,
                                                  days: alarmDays.convertToStringWithoutBracket)
                  SVProgressHUD.show()
                  self.viewModel.newAlarmRequest(request: alarmRequest)
              }
              
          } else {
              Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
          }
      }
    
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension NewAlarmViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AlarmSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = AlarmSection(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = AlarmSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AlarmSection")
        }
        
        switch rowType {
        case .newAlarmHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = isNavFor == AppString.navigateFrom.editAlarm ? AppString.VCName.editAlarm : AppString.VCName.newAlarm
            return cell
            
        case .timePicker:
            let cell = tblView.dequeueCell(with: TimePickerCell.self)
            cell.toggleTimeFormat(is12Hour: true)  // Enable 12-hour format (with AM/PM)
            debugLog("alarm Time: \(self.alarmtime)")
            if isNavFor == AppString.navigateFrom.editAlarm {
                debugLog("reached Here")
                cell.setTime(alarmtime)  // Pass the alarm time to the cell
            }
            if alarmtime == "" {
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm:ss a"
                self.alarmtime = formatter.string(from: Date())
            }
            
            cell.onTimeSelected = { [weak self] selectedTime in
                guard let self = self else { return }
                self.alarmtime = selectedTime
            }
            cell.selectionStyle = .none
            return cell
            
        case .detailHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = AppColor.lightGray
            cell.titleOlt.text = AppString.Header.details
            return cell
        case .selectDay:
            let cell = tblView.dequeueCell(with: SelectDaySliderCell.self)
            cell.contentView.backgroundColor = AppColor.lightGray
//            cell.selectedDays = isNavFrom == AppString.navigateFrom.home
//                ? Set(self.alarmDays.compactMap { daysArr.firstIndex(of: $0) }) // Map alarmDays to indexes
//                : []
            cell.selectedDays = isNavFor == AppString.navigateFrom.editAlarm ? self.selectedDays : []
            cell.onDaysSelected = { [weak self] selectedDays in
                self?.alarmDays = selectedDays
            }
            cell.selectionStyle = .none
            return cell
        case .descriptions:
            let cell = tblView.dequeueCell(with: TitleAndDescriptionCell.self)
            cell.contentView.backgroundColor = AppColor.lightGray
            
            cell.textViewOlt.text = isNavFor == AppString.navigateFrom.editAlarm ? self.comment : alarmModel?.comment
            
            cell.titleTxtFieldOlt.text = isNavFor == AppString.navigateFrom.editAlarm ? self.alarmTitle : alarmModel?.title
            
            if alarmTitle != ""{
                cell.titleTxtFieldOlt.text = self.alarmTitle
            }else{
                cell.titleTxtFieldOlt.placeholder = "Enter Title here..."
            }
            
            cell.enterTitletext = { [weak self] tf in
                guard let self = self else { return }
                self.alarmTitle = tf.text ?? ""
            }
            
            cell.enterDesctext = { [weak self] tf in
                guard let self = self else { return }
                self.comment = tf.text ?? ""
            }
            
            if self.comment != "" {
                cell.textViewOlt.text = self.comment
            }else{
                cell.textViewOlt.text = "Type here..."
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = AlarmSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AlarmSection")
        }
        switch rowType {
        case .newAlarmHeader:
            return Const.Height.header
        case .timePicker:
            return Const.Height.timePicker
        case .detailHeader:
            return Const.Height.header
        case .selectDay:
            return Const.Height.sliderDays
        case .descriptions:
            return Const.Height.AutomaticDimension
        }
    }
}


//MARK: - Model Management
extension NewAlarmViewController : UserServices {
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
    
    func reloadData() {
        if let dict = self.viewModel.NewAlarmStatusDict {
            let statusType = APIResponseStatus(rawValue: dict.status ?? "")
            switch statusType {
            case .success:
                //success API Response
                print("success API Response")
                SVProgressHUD.dismiss()
                DispatchQueue.main.async {
                    self.goToBack()
                }
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






//MARK: This Controller is Used to Manged Alaram Local + API(Currently Not in Used)

//import Security
//import UIKit
//import SVProgressHUD
//import FittedSheets
//import MobileCoreServices
//import UniformTypeIdentifiers
//import MediaPlayer
//
//enum AlarmSection: Int,CaseIterable {
//    case newAlarmHeader
//    case timePicker
//    case detailHeader
//    case selectDay
//    case addSong
//    case descriptions
//    
//    func numberOfRows(data: [AlarmSection: Int]) -> Int {
//        return data[self] ?? 1 // Default to 1 if no data provided
//    }
//}
//
//enum DayType: Int {
//    case mon = 0
//    case tue
//    case wed
//    case thu
//    case fri
//    case sat
//    case sun
//    
//    // Method to get string representation for the enum's raw value
//    func stringValue() -> String {
//        switch self {
//        case .mon:
//            return "mon"
//        case .tue:
//            return "tue"
//        case .wed:
//            return "wed"
//        case .thu:
//            return "thu"
//        case .fri:
//            return "fri"
//        case .sat:
//            return "sat"
//        case .sun:
//            return "sun"
//        }
//    }
//    
//    static func integerValue(_ day: String) -> Int {
//        if day == "mon" { return 0 }
//        else if day == "tue" { return 1 }
//        else if day == "wed" { return 2 }
//        else if day == "thu" { return 3 }
//        else if day == "fri" { return 4 }
//        else if day == "sat" { return 5 }
//        else if day == "sun" { return 6 }
//        return -1
//    }
//
//    // Static method to get the enum case from a raw Int value
//    static func fromRawValue(_ rawValue: Int) -> DayType? {
//        return DayType(rawValue: rawValue)
//    }
//}
//
//
//
//class NewAlarmViewController: UIViewController {
//    
//    // MARK: IBOutlets.
//    @IBOutlet var newAlramBtn: UIButton!
//    @IBOutlet weak var tblView: UITableView!
//    @IBOutlet weak var headerView: HeaderView!
//    
//    var alarmModel: AlarmModel?
//    
//    //set alarm locally
//    var alarms: Alarms?
//    var currentAlarm: Alarm?
//    var isEditMode = false
//    
//    var snoozeEnabled = false
//    var label = ""
//    var repeatWeekdays: [Int] = []
//    var alarmDays: [String] = [] // Selected days
//    var mediaLabel = ""
//    var mediaID = ""
//    var descriptions = ""
//    var alarmtime = ""
//    var songTitle = ""
//    var isNavFor = ""
//    var alarmId : Int?
//    var selectedMusicURL:[URL] = []
//    var localMusicArr: [UploadAlarmSongModel] = []
//
//    // MARK: Properties
////    var alarmTitle = ""
////    var alarmtime = ""
////    var alarmDays: [Int] = [] // Selected days
////    var comment = ""
//
////    var alarmId: Int?
//    
//    let viewModel = NewAlarmViewModel()
//
//    // MARK: Properties
//    var sectionData: [AlarmSection: Int] = [
//        .newAlarmHeader: 1,
//        .timePicker: 1,
//        .detailHeader : 1,
//        .selectDay: 1,
//        .addSong : 0,
//        .descriptions : 1
//    ]
//    
//    //MARK: ViewLife Cycle Methods.
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.configureTableView()
//        self.tblView.reloadData()
//        self.initViewModel()
//        self.clearLocalMusicArr()
//        //update alarm
////        if let alarm = currentAlarm {
////            snoozeEnabled = alarm.snoozeEnabled
////            label = alarm.label
////            repeatWeekdays = alarm.repeatWeekdays
////            mediaLabel = alarm.mediaLabel
////            mediaID = alarm.mediaID
////            alarmtime = alarm.formattedTime
////            descriptions = alarm.descriptions
////        }
//        
////        self.updateAlarm(alarm: alarmModel)
////        if let model = alarmModel {
////            alarmTitle = model.title ?? ""
////            alarmtime = model.time ?? ""
////            self.alarmId = model.id
////            alarmDays = model.days ?? []
////            selectedDays = prepareSet(alarmDays)
////            debugLog("selectedDays: \(selectedDays)")
////            comment = model.comment ?? ""
////            tblView.reload()
////        }
//        
//    }
//    
////    func updateAlarm(alarm: AlarmModel?) {
////        snoozeEnabled = false
////        label = ""
////        repeatWeekdays = Array(selectedDays)
////        mediaLabel = ""
////        mediaID = ""
////    }
//    
//    //please pass day as mon, tue, wed and so on
////    func prepareSet(_ days:[String]) -> Set<Int>{
////        var res = Set<Int>()
////        days.forEach { day in
////            let data = DayType.getRawValue(day)
////            if data != nil {
////                res.insert(data!)
////            }
////        }
////        return res
////    }
//    
//    func convertToDate(from timeString: String) -> Date? {
//        // Create a DateFormatter instance
//        let dateFormatter = DateFormatter()
//        
//        // Set the date format based on the time string
//        dateFormatter.dateFormat = "h mm a"
//        
//        // Optionally, set the locale to ensure AM/PM is handled correctly
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        
//        // Convert the time string to Date and return it
//        return dateFormatter.date(from: timeString)
//    }
//    
//    func convertToStringWeekdays(_ weekdays: [Int]) -> [String] {
//        return weekdays.compactMap { DayType.fromRawValue($0)?.stringValue() }
//    }
//    func convertIntToWeekdays(_ weekdays: [Int]) -> [String] {
//        return weekdays.compactMap { DayType.fromRawValue($0)?.stringValue() }
//    }
//
//
//    @IBAction func newAlarmTapped(_ sender: UIButton) {
////        self.submit()
//        self.addEditNewAlarm()
//    }
//    
//    func addEditNewAlarm() {
//        self.view.endEditing(true)
//        if self.alarmtime == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmTime)
//        } else if self.repeatWeekdays == [] {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmDays)
//        } else if self.label == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmTitle)
//        } else if self.descriptions == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmComment)
//        }else {
//            
//            // Prepare the alarm for the API request
//            if isNavFor == AppString.navigateFrom.editAlarm  {
//                //edit case
//                self.addAlarmData()
////                if let id = alarmId {
////                    SVProgressHUD.show()
////                    let newAlarmParam = NewAlarmRequest(alarm_id: id, title: label, time: alarmtime, days: apiWeekdays, comment: descriptions)
////                    self.viewModel.newAlarmRequest(parameters: newAlarmParam)
////                }
//            }
//            else  {
//                //add case
//                self.addAlarmData()
////                SVProgressHUD.show()
////                let newAlarmParam = NewAlarmRequest(title: label,time: alarmtime,days: apiWeekdays,comment: descriptions)
////                self.viewModel.newAlarmRequest(parameters: newAlarmParam)
//            }
//        }
//    }
//
//    //MARK: configureTableView.
//    private func configureTableView(){
//        self.tblView.delegate = self
//        self.tblView.dataSource = self
//        self.tblView.configTblView()
//        
//        //register cells
//        let cellIds = [SubmitCell.identifier,
//                       TextFieldWithoutTittleCell.identifier,
//                       SelectDaySliderCell.identifier,TitleAndDescriptionCell.identifier,TimePickerCell.identifier,AppHeaderCell.identifier,LocationNameCell.identifier]
//        tblView.registerCells(for: cellIds)
//        tblView.backgroundColor = AppColor.lightGray
//        newAlramBtn.makeCornerRounded(ofSize: Corner_26)
//        configureHeaderView()
//        
//    }
//    
//    //MARK: configureHeaderView.
//    private func configureHeaderView() {
//        self.headerView.headerViewSetup(rightButtonHidden: false,
//                                        leftButtonHidden: false,
//                                        headerName: isEditMode ? AppString.VCName.editAlarm : AppString.VCName.newAlarm,rightButtonAction: didTapSideMenu,leftButtonAction: didTabBack)
//    }
//    
//    //MARK: initViewModel.
//    func initViewModel() {
//        viewModel.userDelegate = self
//    }
//    
//    //MARK: - didtapBack.
//    @objc private func didTabBack(){
//        self.goToBack()
//    }
//    
//    //MARK: submit
////    private func submit(){
////        self.view.endEditing(true)
////        if self.alarmtime == "" {
////            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmTime)
////        }else if self.repeatWeekdays == [] {
////            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmDays)
////        }else if self.label == "" {
////            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmTitle)
////        }else if self.descriptions == "" {
////            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyAlarmComment)
////        }
////        else{
////            if Reachability.isConnectedToNetwork() {
////                //sign in
////                let apiWeekdays = convertToStringWeekdays(repeatWeekdays)
////                if isNavFor == AppString.navigateFrom.editAlarm  {
////                    //edit case
////                    if let id = alarmId {
////                        SVProgressHUD.show()
////                        let newAlarmParam = NewAlarmRequest(alarm_id: id, title: label, time: alarmtime, days: apiWeekdays, comment: descriptions)
////                        self.viewModel.newAlarmRequest(parameters: newAlarmParam)
////                    }
////                }
////                else  {
////                    //add case
////                    SVProgressHUD.show()
////                    let newAlarmParam = NewAlarmRequest(title: label,time: alarmtime,days: apiWeekdays,comment: descriptions)
////                    self.viewModel.newAlarmRequest(parameters: newAlarmParam)
////                }
////            }
////            else {
////                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
////            }
////
////            self.view.endEditing(true)
////
////        }
////    }
//    
//    //MARK: didTabBack.
//    @objc private func didTapSideMenu(){
//        self.openSideMenu()
//    }
//    
//    //MARK: - clearLocalMusicArr
//    func clearLocalMusicArr() {
//        self.localMusicArr = []
//        self.selectedMusicURL.removeAll()
//    }
//
//}
//
////MARK: UITableViewDelegate,UITableViewDataSource
//extension NewAlarmViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return AlarmSection.allCases.count
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sectionType = AlarmSection(rawValue: section) else { return 0 }
//        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
//        return sectionType.numberOfRows(data: sectionData)
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let rowType = AlarmSection.allCases[safe: indexPath.section] else {
//            fatalError("Invalid index for AlarmSection")
//        }
//        
//        switch rowType {
//        case .newAlarmHeader:
//            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
//            cell.outerViewOlt.backgroundColor = .ultraLightGray
//            cell.titleOlt.text = AppString.Header.newAlarm
//            return cell
//        case .timePicker:
//            let cell = tblView.dequeueCell(with: TimePickerCell.self)
//            cell.toggleTimeFormat(is12Hour: true)  // Enable 12-hour format (with AM/PM)
//            debugLog("alarm Time: \(self.alarmtime)")
//            if isEditMode {
//                debugLog("reached Here")
//                cell.setTime(alarmtime)  // Pass the alarm time to the cell
//            }
//            cell.onTimeSelected = { [weak self] selectedTime in
//                self?.alarmtime = selectedTime
//            }
//            cell.selectionStyle = .none
//            return cell
//        case .detailHeader:
//            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
//            cell.outerViewOlt.backgroundColor = AppColor.lightGray
//            cell.titleOlt.text = AppString.Header.details
//            return cell
//        case .selectDay:
//            let cell = tblView.dequeueCell(with: SelectDaySliderCell.self)
//            cell.contentView.backgroundColor = AppColor.lightGray
//            cell.weekdays = isEditMode ? repeatWeekdays : []
//            cell.onDaysSelected = { [weak self] selectedDays in
//                self?.repeatWeekdays = selectedDays
//            }
//            cell.selectionStyle = .none
//            return cell
//        case .addSong:
//            let cell = tblView.dequeueCell(with: LocationNameCell.self)
//            cell.descriptionOlt.isHidden = true
//            cell.titleOlt.font = AppFont.LblTitleBold_15
////            if isNavFor == AppString.navigateFrom.editAlarm{
////                cell.titleOlt.text = songTitle
////            }
//            if localMusicArr.count == 0{
//                cell.titleOlt.text = AppString.Title.addSong
//            }else{
//                cell.titleOlt.text = localMusicArr[indexPath.row].trackName
//            }
//           
//            cell.outerViewOlt.backgroundColor = AppColor.lightGray
//            cell.selectionStyle = .none
//            return cell
//            
//        case .descriptions:
//            let cell = tblView.dequeueCell(with: TitleAndDescriptionCell.self)
//            cell.contentView.backgroundColor = AppColor.lightGray
//            cell.textViewOlt.text = isEditMode ? self.descriptions : ""
//            cell.titleTxtFieldOlt.text = isEditMode ? self.label : ""
//            if self.descriptions != "" {
//                cell.textViewOlt.text = self.descriptions
//            }else{
//                cell.textViewOlt.text = "Type here..."
//            }
//            cell.enterDesctext = { [weak self] tf in
//                guard let self = self else { return }
//                self.descriptions = tf.text ?? ""
//            }
//            cell.enterTitletext = { [weak self] tf in
//                guard let self = self else { return }
//                self.label = tf.text ?? ""
//            }
//            return cell
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let rowType = AlarmSection.allCases[safe: indexPath.section] else {
//            fatalError("Invalid index for AlarmSection")
//        }
//        switch rowType {
//        case .newAlarmHeader:
//            return Const.Height.header
//        case .timePicker:
//            return Const.Height.timePicker
//        case .detailHeader:
//            return Const.Height.header
//        case .selectDay:
//            return Const.Height.sliderDays
//        case .addSong:
//            return Const.Height.listing
//        case .descriptions:
//            return Const.Height.AutomaticDimension
//        }
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let rowType = AlarmSection.allCases[safe: indexPath.section] else {
//            fatalError("Invalid index for AlarmSection")
//        }
//        switch rowType {
//        case .addSong:
//            self.openSongOption()
//        default:
//            debugLog("")
//        }
//    }
//}
//
//
////MARK: - Model Management
//extension NewAlarmViewController : UserServices {
//    func showError(error: String) {
//        //handle error
//        DispatchQueue.main.async {
//            SVProgressHUD.dismiss()
//            Utilities.sharedInstance.showToast(source: self, message: error)
//        }
//    }
//    
//    func reloadData() {
//        self.sucessNewAlarm()
//    }
//}
//
////MARK: - success API Call
//extension NewAlarmViewController {
//    private func sucessNewAlarm() {
//        if viewModel.NewAlarmStatusDict?.status == "success" {
////            let currentDate = createDateFromCurrentDateAndTime(timeString: alarmtime)
////            if let alarm = currentAlarm {
////                alarm.date = currentDate ?? Date()
////                alarm.enabled = true
////                alarm.snoozeEnabled = true
////                alarm.label = label
////                alarm.mediaID = ""
////                alarm.mediaLabel = "bell"
////                alarm.descriptions = descriptions
////                alarm.repeatWeekdays = repeatWeekdays
////                if isEditMode {
////                    alarms?.update(alarm)
////                    debugLog("\(currentDate),\(label),\(descriptions), \(repeatWeekdays)")
////                } else {
////                    alarms?.add(alarm)
////                }
////        }
//                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss()
//                    self.goToBack()
//                }
//           
//        }else{
//            DispatchQueue.main.async {
//                SVProgressHUD.dismiss()
//                Utilities.sharedInstance.showToast(source: self, message: self.viewModel.NewAlarmStatusDict?.message ?? "")
//            }
//        }
//    }
//}
//
//extension NewAlarmViewController{
//    func openSongOption(){
//        let alertController = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
//        
//        // documentAction action
//        let documentAction = UIAlertAction(title: "Choose From Files", style: .default) { _ in
//            self.pickerAudioFile()
//        }
//        
//        // library action
//        let libraryAction = UIAlertAction(title: "Choose From Apple Music", style: .default) { _ in
//            self.openSongLibrary()
//        }
//        
//        // Cancel action
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alertController.addAction(documentAction)
//        alertController.addAction(libraryAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true, completion: nil)
//    }
//}
////MARK: UIDocumentPickerDelegate.
//extension NewAlarmViewController: UIDocumentPickerDelegate {
//    
//    func pickerAudioFile(){
//        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio], asCopy: true)
//        documentPicker.delegate = self
//        documentPicker.allowsMultipleSelection = false
//        present(documentPicker, animated: true, completion: nil)
//    }
//    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        if let selectedURL = urls.first {
//            // Extract track name and artist from the selected URL
//            if let songData = extractArtistAndTrackName(from: selectedURL) {
//                let artistName = songData.artist
//                let trackName = songData.trackName
//                
//                // Create a new UploadSongModel and add to localMusicArr
//                let newSong = UploadAlarmSongModel(url: selectedURL.absoluteString, trackName: trackName)
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
//                    debugLog("File size is less than or equal to 5 MB")
//                    localMusicArr.append(newSong)
//                    tblView.reload()
//                }
//            }
//            selectedMusicURL.append(contentsOf: urls)
//            tblView.reload()
//        }
//    }
//    
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        // Handle cancel action
//        debugLog("User cancelled file selection.")
//    }
//}
//
//extension NewAlarmViewController : MPMediaPickerControllerDelegate {
//    
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
//            let librarySong = UploadAlarmSongModel(trackName: trackName)
//            self.localMusicArr.append(librarySong)
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
//
//extension NewAlarmViewController{
//    func extractArtistAndTrackName(from url: URL) -> (artist: String, trackName: String)? {
//        let urlString = url.absoluteString
//        let components = urlString.split(separator: "/")
//        if components.count > 2 {
//            let artistName = components[components.count - 2]
//            let trackNameWithExtension = components.last?.split(separator: ".").first ?? ""
//            
//            return (artist: String(artistName), trackName: String(trackNameWithExtension))
//        }
//        
//        return nil
//    }
//}
//
////MARK: UploadSongModel.
//struct UploadAlarmSongModel{
//    var url : String?
//    var trackName : String?
//}
//extension NewAlarmViewController{
//    func addAlarmData() {
//        self.view.endEditing(true)
//        
//        if Reachability.isConnectedToNetwork() {
//            
//            let currentDate = createDateFromCurrentDateAndTime(timeString: alarmtime)
//            
//            // Convert repeatWeekdays [Int] to [String] for the API
//            let apiWeekdays = convertToStringWeekdays(repeatWeekdays)
//            
//            var mimeType: [String] = []
//            var musics: [[String]] = [[]]
//            var keysValue: [String] = []
//            
////            for song in localMusicArr{
////                guard let trackName = song.trackName else {
////                    continue
////                }
////                
////                mimeType.append("audio/mp3")
////                keysValue.append("song")
////                
////                if let songURL = song.url {
////                    musics = [[songURL.description]]
////                }
//                if let id = alarmId {
//                    var songParam: [String: Any] = [
//                        "alarm_id" : alarmId ?? 0,
//                        "title" : label,
//                        "time": alarmtime,
//                        "days": apiWeekdays,
//                        "comment": descriptions
////                        "song_title" : trackName
//                    ]
//                    debugLog("Upload Song Param \(songParam)")
////                    if !localMusicArr.isEmpty {
//                        SVProgressHUD.show()
//                        self.viewModel.newAlarmRequest(param: songParam,
//                                                   keysValue: keysValue,
//                                                   mimeTypes: mimeType,
//                                                   musics: musics)
////                    }else {
////                        debugLog("No songs to upload.")
////                    }
//                    
//                }else{
//                    var songParam: [String: Any] = [
//                        "title" : label,
//                        "time": alarmtime,
//                        "days": apiWeekdays,
//                        "comment": descriptions
////                        "song_title" : trackName
//                    ]
//                    
//                    debugLog("Upload Song Param \(songParam)")
////                    if !localMusicArr.isEmpty {
//                        SVProgressHUD.show()
//                        self.viewModel.newAlarmRequest(param: songParam,
//                                                   keysValue: keysValue,
//                                                   mimeTypes: mimeType,
//                                                   musics: musics)
////                    }else {
////                        debugLog("No songs to upload.")
////                    }
//                }
////            }
//            
//        } else {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
//        }
//    }
//}
//
//

import Foundation

extension Array {
    var convertToString: String {
        var res = "["
        for i in 0 ..< self.count {
            if i == self.count - 1 {
                res += "\(self[i])]"
            }
            else {
                res += "\(self[i]), "
            }
        }
        return res
    }
    var convertToStringWithoutBracket: String {
        var res = ""
        for i in 0 ..< self.count {
            if i == self.count - 1 {
                res += "\(self[i])"
            }
            else {
                res += "\(self[i]),"
            }
        }
        return res
    }
}
