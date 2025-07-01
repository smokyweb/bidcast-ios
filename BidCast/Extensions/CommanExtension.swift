//
//  CommanExtension.swift
//  MrsHoneyBee
//
//  Created by Jamtech06 on 10/11/22.
//

import Foundation


extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: self)

        }
    
    func stringISOToDate(format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func isValidLinkedIn() -> Bool {
        let pattern = #"^https?:\/\/(www\.)?linkedin\.com\/in\/[a-zA-Z0-9-]{5,30}\/?$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension Date {
    func today(format: String = "dd-MM-yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func daysBetween(startDate: String, endDate: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let start = dateFormatter.date(from: startDate.isEmpty ? Date().today() : startDate) ?? Date()
        let end = dateFormatter.date(from: endDate.isEmpty ? Date().today() : endDate) ?? Date()
        
        let calendar = Calendar.current
        
            // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: end)
        
        let diff = calendar.dateComponents([.day], from: date1, to: date2)
        return diff.value(for: .day)!
    }
    
    func toMMYY(_format: String = "MM/yyyy") -> String {
        let format = DateFormatter()
        format.dateFormat = _format
        return format.string(from: self)
    }
    
    func forInterview() -> String {
        let format = DateFormatter()
        format.dateFormat = "MMMM dd, yyyy @ h:mm a" //"dd-MM-yyyy"
        return format.string(from: self)
    }
    
    func getTimeStamp() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format.string(from: self).replacingOccurrences(of: " ", with: "_")
    }
    
    func convertToISOTime(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
    
    func toYYYMMDD() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: self)
    }

}

extension Notification.Name {
    static let swipeLeftJob = Notification.Name("swipeLeftJob")
    static let swipeRightJob = Notification.Name("swipeRightJob")
    static let swipeLeftEmployee = Notification.Name("swipeLeftEmployee")
    static let swipeRightEmployee = Notification.Name("swipeRightEmployee")
}

extension Date {
    func offsetFrom() -> String {
        let components: Set<Calendar.Component> = [.day, .hour, .minute, .second, .weekOfYear, .month]
        let difference = Calendar.current.dateComponents(components, from: self, to: Date())
        
        let seconds = "\(difference.second ?? 0) sec"
        let minutes = "\(difference.minute ?? 0) mins"
        let hours = "\(difference.hour ?? 0) hours"
        let days = "\(difference.day ?? 0) days"
        let weeks = "\(difference.weekOfYear ?? 0) weeks"
        let months = "\(difference.month ?? 0) months"
        
        if let month = difference.month, month > 0 { return months + " ago" }
        if let week = difference.weekOfYear, week > 0 { return weeks + " ago" }
        if let day = difference.day, day > 0 { return days + " ago" }
        if let hour = difference.hour, hour > 0 { return hours + " ago" }
        if let minute = difference.minute, minute > 0 { return minutes + " ago" }
        if let second = difference.second, second > 0 { return seconds + " ago" }
        
        return "Just now"
    }

}
