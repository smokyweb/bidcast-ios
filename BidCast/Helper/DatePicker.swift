import UIKit

class DatePicker : UIPickerView {
    
    var dateCollection = [Date]()
    var monthCollection = [Date]()
    
    var type = "Daily"
    
    func selectedDate()->Int{
        dateCollection = buildDateCollection()
        var row = 0
        for index in dateCollection.indices{
            let today = Date()
            if Calendar.current.compare(today, to: dateCollection[index], toGranularity: .day) == .orderedSame{
                row = index
            }
        }
        return row
    }
    func selectedMonth()->Int{
        monthCollection = buildMonthCollection()
        var row = 0
        for index in monthCollection.indices{
            let today = Date()
            if Calendar.current.compare(today, to: monthCollection[index], toGranularity: .day) == .orderedSame{
                row = index
            }
        }
        return row
    }
    
    func buildDateCollection()-> [Date]{
        dateCollection.append(contentsOf: Date.previousYear())
        dateCollection.append(contentsOf: Date.nextYear())
        return dateCollection
    }
    
    func buildMonthCollection()-> [Date]{
        monthCollection.append(contentsOf: Date.previousMonths())
        monthCollection.append(contentsOf: Date.nextMonths())
        return monthCollection
    }
}

// MARK - UIPickerViewDelegate
extension DatePicker : UIPickerViewDelegate{
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.type == "Monthly"{
            let date = formatDate(date: self.monthCollection[row])
            NotificationCenter.default.post(name: .dateChanged, object: nil, userInfo:["date":date])
        }else{
            let date = formatDate(date: self.dateCollection[row])
            NotificationCenter.default.post(name: .dateChanged, object: nil, userInfo:["date":date])
        }
    }
    
    func formatDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        if self.type == "Monthly"{
            dateFormatter.dateFormat = "MM"
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        return dateFormatter.string(from: date)
       
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36
    }
}

// MARK - UIPickerViewDataSource
extension DatePicker : UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.type == "Monthly"{
            return monthCollection.count
        }else{
            return dateCollection.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var label = ""
        if self.type == "Monthly"{
            label = formatDatePicker(date: monthCollection[row])
            let date = formatDate(date: self.monthCollection[row])
            NotificationCenter.default.post(name: .dateChanged, object: nil, userInfo:["date":date])
        }else{
            label = formatDatePicker(date: dateCollection[row])
            let date = formatDate(date: self.dateCollection[row])
            NotificationCenter.default.post(name: .dateChanged, object: nil, userInfo:["date":date])
        }
        return label
        
    }
    
    func formatDatePicker(date: Date) -> String{
        let dateFormatter = DateFormatter()
        if self.type == "Monthly"{
            dateFormatter.dateFormat = "MMMM    yyyy"
        }else{
            dateFormatter.dateFormat = "dd    MMMM    yyyy"
        }
    return dateFormatter.string(from: date)
    }
    
}

// MARK - Observer Notification Init
extension Notification.Name{
    static var dateChanged : Notification.Name{
        return .init("dateChanged")
    }
    
}

// MARK - Date extension
extension Date {
    
    static func nextYear() -> [Date]{
        return Date.next(numberOfDays: 365, from: Date())
    }
    
    static func previousYear()-> [Date]{
        return Date.next(numberOfDays: 365, from: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
    }
    
    static func nextMonths() -> [Date]{
        return Date.nextMonth(numberOfDays: 12, from: Date())
    }
    
    static func previousMonths()-> [Date]{
        return Date.nextMonth(numberOfDays: 12, from: Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
    }
    
    static func nextSevenDays() -> [Date]{
        return Date.next(numberOfDays: 7, from: Date())
    }
    
    static func next(numberOfDays: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfDays {
            if let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
    static func nextMonth(numberOfDays: Int, from startDate: Date) -> [Date]{
        var dates = [Date]()
        for i in 0..<numberOfDays {
            if let date = Calendar.current.date(byAdding: .month, value: i, to: startDate) {
                dates.append(date)
            }
        }
        return dates
    }
}
