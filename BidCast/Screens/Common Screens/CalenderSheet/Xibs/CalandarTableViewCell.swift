//
//  CalandarTableViewCell.swift
//  Discover Healing
//
//  Created by Vivek-JAM-E-32806 on 30/03/23.
//

import UIKit
import FSCalendar
import SVProgressHUD

class CalandarTableViewCell: UITableViewCell{
    
    // MARK: IBOutlets
    @IBOutlet weak var btnNextMonthClick: UIButton!
    @IBOutlet weak var btnPrevMonthClick: UIButton!
    @IBOutlet weak var rightBtnBgVIew: UIView!
    @IBOutlet weak var leftBtnBgView: UIView!
    @IBOutlet weak var calandarView: FSCalendar!
    
    
    //MARK: Properties
    static let identifier = "CalandarTableViewCell"
    var changedMonth :(String) -> () = { _ in }
    var selectedDate : (String) -> () = { _ in }
    var startDate:String = "Date()"  // declare your start Date
    var endDate = Date()  // declare your end Date
    var iscoming = ""
    var userId = String()
    var dayName = [String]()
    var multipleSelection = false
    var datesArr = [String]()
    enum DataAvailability {
        case available
        case notAvailable
    }
    var dateColorMapping: [Date: UIColor] = [:] // Date to color mapping
    // For minimum date
    func minimumDate(for calendar: FSCalendar) -> Date {
        if iscoming == "Session"{
            return Date.distantPast
        }else{
            return Date.distantPast
        }
    }
    
    func dayFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let dayComponent = calendar.component(.day, from: date)
        return dayComponent
    }
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.leftBtnBgView.makeCornerRounded(ofSize: self.leftBtnBgView.bounds.height/2)
        self.leftBtnBgView.makeCircular()
        self.rightBtnBgVIew.makeCircular()
//        self.rightBtnBgVIew.makeCornerRounded(ofSize: self.rightBtnBgVIew.bounds.height/2)
        calandarView.calendarHeaderView.backgroundColor = .white
        calandarView.calendarHeaderView.layer.cornerRadius = 22
//        self.calandarView.appearance.headerTitleFont = UIFont(name: "Montserrat-SemiBold",  size: 18.0)
//        self.calandarView.appearance.headerTitleFont = MontserratFont.defaultSemiBold(size: 18.0).value
        self.calandarView.appearance.headerTitleColor = UIColor.black
        self.calandarView.appearance.headerTitleAlignment = .left
        self.calandarView.appearance.headerTitleOffset = CGPoint(x: -64, y: 0)
//        self.calandarView.appearance.weekdayFont = MontserratFont.defaultSemiBold(size: 12.0).value
//        self.calandarView.appearance.weekdayFont =  UIFont(name: "Montserrat-SemiBold",  size: 12.0)
        self.calandarView.appearance.selectionColor = .darkGray
        self.calandarView.appearance.titleSelectionColor = UIColor.white
        self.calandarView.appearance.titleTodayColor = UIColor.black
        //        self.calandarView.appearance.todayColor = UIColor(r: 114, g: 176, b: 156, alpha: 0.5)
        self.calandarView.appearance.todayColor = UIColor(hex: "#DDF8E3")
        self.calandarView.appearance.borderSelectionColor = .darkGray
        self.calandarView.appearance.calendar.adjustMonthPosition()
        calandarView.scope = .month
        
        self.calandarView.appearance.borderRadius = 1
        self.calandarView.appearance.headerMinimumDissolvedAlpha = 0.0
        setUpCalender()
        debugLog(dayName)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: setUpCalender
    func setUpCalender() {
        self.calandarView.allowsMultipleSelection = multipleSelection
        self.calandarView.appearance.caseOptions = .headerUsesUpperCase
        self.calandarView.appearance.caseOptions = .weekdayUsesUpperCase
        self.calandarView.delegate = self
        self.calandarView.dataSource = self
        self.calandarView.reloadData()
    }
    
    //MARK: showMonth
    func showMonth(from dateString: String) {
        // Create and configure DateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        
        // Convert the date string to a Date object
        if let date = dateFormatter.date(from: dateString) {
            // Set the FSCalendar to display this specific month
            self.calandarView.setCurrentPage(date, animated: true)
        } else {
            debugLog("Invalid date format")
        }
    }
    
    //MARK: IBAction.
    @IBAction func btnPrevClick(_ sender: Any) {
        self.stepCalendarView(index: -1)
    }
    @IBAction func btnNextClick(_ sender: Any) {
        self.stepCalendarView(index: 1)
    }
    
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

//MARK: FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance.
extension CalandarTableViewCell: FSCalendarDelegate, FSCalendarDataSource,FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        if iscoming == "Session"{
            let dateSelection = date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateSelect = dateFormatter.string(from: dateSelection)
            selectedDate(dateSelect)
        }else{
            let dateSelection = date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateSelect = dateFormatter.string(from: dateSelection)
            selectedDate(dateSelect)
        }
        
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if self.iscoming == "Session" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dayInWeek = dateFormatter.string(from: date)
            
            if self.dayName.contains(dayInWeek){
                return .red
            }
        }
        return nil
        
        
    }
    //    
    //    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
    //            // Return the desired background color for the specific date
    //            // Example: Change the background color of weekends
    //        
    //        
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "EEEE"
    //        let dayInWeek = dateFormatter.string(from: date)
    //        if self.dayName.contains(dayInWeek) {
    //            return .clear
    //            }
    //            return nil // Return nil to keep default background color
    //        }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date)
        let currentComponents = calendar.dateComponents([.month], from: calandarView.currentPage)
        
        if iscoming == "BookSession"{
            let currentDate = Calendar.current.startOfDay(for: Date())
            
            if date >= currentDate {
                // Allow selection only for dates on or after the current date
                return true
            } else {
                // Disallow selection for dates before the current date
                
                return true
            }
        }
        return components.month == currentComponents.month
        
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, shouldUseCustomRadiusFor date: Date) -> Bool {
        return calendar.today == date
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        return calendar.today == date ? 2.0 : 2.0 // Adjust the radius as per your preference
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        return calendar.today == date ? .darkGray : nil // Set the border color for the current date
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        let currentPage = calendar.currentPage
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        let formattedDate = dateFormatter.string(from: currentPage)
        debugLog("Current page changed to: \(formattedDate)")
        // You can perform any additional tasks here
        self.changedMonth(formattedDate)
    }
    
    private func stepCalendarView(index: Int) {
        let previousMonth = Calendar.current.date(byAdding: self.calandarView.scope.asCalendarComponent(), value: index, to: calandarView.currentPage)
        calandarView.setCurrentPage(previousMonth!, animated: true)
    }
    
}

//MARK: FSCalendarScope.
extension FSCalendarScope {
    func asCalendarComponent() -> Calendar.Component {
        switch (self) {
        case .month: return .month
        case .week: return .weekOfYear
        default: return .month
            
        }
    }
}

//MARK: Date.
extension Date {
    static func getCurrentDate() -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        return dateFormatter.string(from: Date())
        
    }
}
