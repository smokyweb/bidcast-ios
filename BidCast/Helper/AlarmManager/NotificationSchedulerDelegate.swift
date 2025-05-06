import Foundation
import UIKit

protocol NotificationSchedulerDelegate {
    func requestAuthorization()
    func registerNotificationCategories()
    func setNotification(date: Date, ringtoneName: String, repeatWeekdays: [Int], snoozeEnabled: Bool, onSnooze: Bool, uuid: String,title : String,description : String,type:String,id:Int)
    func setNotificationForSnooze(ringtoneName: String, snoozeMinute: Int, uuid: String)
    func cancelNotification(ByUUIDStr uuid: String)
    func updateNotification(ByUUIDStr uuid: String, date: Date, ringtoneName: String, repeatWeekdays: [Int], snoonzeEnabled: Bool,title : String,description : String,type:String,id:Int)
    func syncAlarmStateWithNotification()
    func rescheduleNotificationIfNeeded(uuid: String, soundName: String)
}

