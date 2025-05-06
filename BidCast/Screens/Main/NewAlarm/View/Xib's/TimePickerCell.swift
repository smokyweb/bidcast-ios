//
//  TimePickerCell.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 28/12/24.
//

import UIKit

//MARK: OLD Func Using INDIAN TIME ZONE.
//
class TimePickerCell: UITableViewCell {

    // MARK: IBOutlets.
    @IBOutlet var pickerInnerView: UIView!
    @IBOutlet var innerViewOlt: UIView!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var titleLbl: UILabel!
    
    var selectedTime: String? {
        didSet {
            onTimeSelected?(self.selectedTime ?? "")
        }
    }
    
    // MARK: Properties.
    static let identifier = "TimePickerCell"
    
    var onTimeSelected: ((String) -> Void)?
    var initialTime: ((String) -> Void)?// Closure to pass the selected time back
    
    var is12HourFormat = true  // To toggle between 12-hour and 24-hour formats
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timePicker.setValue(UIColor.black, forKey: "textColor")
        timePicker.date = Date()
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
    }

    // MARK: - Selector method to handle time changes
    @objc private func timeChanged() {
        let formatter = DateFormatter()
        
        // Adjust date format based on whether it's 12-hour or 24-hour format
        if is12HourFormat {
            formatter.dateFormat = "hh:mm:ss a"  // 12-hour format with AM/PM
        } else {
            formatter.dateFormat = "HH:mm:ss"    // 24-hour format
        }
        self.selectedTime = formatter.string(from: timePicker.date)
    }
    
    func setTime(_ time: String, is12Hour: Bool = true) {
        let formatter = DateFormatter()
        is12HourFormat = is12Hour
        if is12HourFormat {
            formatter.dateFormat = "hh:mm a"  // 12-hour format with AM/PM
        } else {
            formatter.dateFormat = "HH:mm"    // 24-hour format
        }
        
        if let date = formatter.date(from: time) {
            timePicker.setDate(date, animated: false) // Set the time on the picker
        }
    }
    

    // MARK: - Method to toggle time format
    func toggleTimeFormat(is12Hour: Bool) {
        is12HourFormat = is12Hour
        // Update the picker view display (if necessary)
        timePicker.datePickerMode = is12Hour ? .time : .countDownTimer
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


//MARK: Func is used to set american Time Zone.
//class TimePickerCell: UITableViewCell {
//
//    // MARK: IBOutlets.
//    @IBOutlet var pickerInnerView: UIView!
//    @IBOutlet var innerViewOlt: UIView!
//    @IBOutlet var timePicker: UIDatePicker!
//    @IBOutlet var titleLbl: UILabel!
//
//    var selectedTime: String? {
//        didSet {
//            onTimeSelected?(self.selectedTime ?? "")
//        }
//    }
//
//    // MARK: Properties.
//    static let identifier = "TimePickerCell"
//
//    var onTimeSelected: ((String) -> Void)?
//    var initialTime: ((String) -> Void)?
//
//    var is12HourFormat = true
//    let timeZone = TimeZone(identifier: "America/New_York")
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        timePicker.setValue(UIColor.black, forKey: "textColor")
//        timePicker.date = Date()
//        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
//
//        // Set the time zone of the UIDatePicker to the USA time zone (Eastern Time in this case)
//        if let timeZone = timeZone {
//            timePicker.timeZone = timeZone
//        }
//    }
//
//    // MARK: - Selector method to handle time changes
//    @objc private func timeChanged() {
//        let formatter = DateFormatter()
//        if let timeZone = timeZone {
//            formatter.timeZone = timeZone
//        }
//
//        if is12HourFormat {
//            formatter.dateFormat = "hh:mm:ss a"  // 12-hour format with AM/PM
//        } else {
//            formatter.dateFormat = "HH:mm:ss"    // 24-hour format
//        }
//
//        self.selectedTime = formatter.string(from: timePicker.date)
//    }
//
//    func setTime(_ time: String, is12Hour: Bool = true) {
//        let formatter = DateFormatter()
//        is12HourFormat = is12Hour
//
//        if let timeZone = timeZone {
//            formatter.timeZone = timeZone
//        }
//
//        if is12HourFormat {
//            formatter.dateFormat = "hh:mm a"  // 12-hour format with AM/PM
//        } else {
//            formatter.dateFormat = "HH:mm"    // 24-hour format
//        }
//
//        if let date = formatter.date(from: time) {
//            timePicker.setDate(date, animated: false)
//        }
//    }
//
//
//    // MARK: - Method to toggle time format
//    func toggleTimeFormat(is12Hour: Bool) {
//        is12HourFormat = is12Hour
//        timePicker.datePickerMode = is12Hour ? .time : .countDownTimer
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//}



//if let timeZone = timeZone {
//    timePicker.timeZone = timeZone
//}
