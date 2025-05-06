//import Foundation
//import UIKit
//import UserNotifications
//
//class NotificationScheduler : NotificationSchedulerDelegate
//{
//    // we need to request user for notifiction permission first
//    func requestAuthorization() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
//            (authorized, _) in
//            if authorized {
//                debugLog("notification authorized")
//            } else {
//                // may need to try other way to make user authorize your app
//                debugLog("not authorized")
//            }
//        }
//    }
//    
//    
//    func registerNotificationCategories() {
//        // Define the custom actions
//        let snoozeAction = UNNotificationAction(identifier: Identifier.snoozeActionIdentifier, title: "Snooze", options: [.foreground])
//        let stopAction = UNNotificationAction(identifier: Identifier.stopActionIdentifier, title: "OK", options: [.foreground])
//        
//        let snoonzeActions = [snoozeAction, stopAction]
//        let nonSnoozeActions = [stopAction]
//        
//        let snoozeAlarmCategory = UNNotificationCategory(identifier: Identifier.snoozeAlarmCategoryIndentifier,
//                                                         actions: snoonzeActions,
//                                                         intentIdentifiers: [],
//                                                         hiddenPreviewsBodyPlaceholder: "",
//                                                         options: .customDismissAction)
//
//        let nonSnoozeAlarmCategroy = UNNotificationCategory(identifier: Identifier.alarmCategoryIndentifier,
//                                                            actions: nonSnoozeActions,
//                                                            intentIdentifiers: [],
//                                                            hiddenPreviewsBodyPlaceholder: "",
//                                                            options: .customDismissAction)
//        // Register the notification category
//        UNUserNotificationCenter.current().setNotificationCategories([snoozeAlarmCategory, nonSnoozeAlarmCategroy])
//    }
//    
//    // sync alarm state to scheduled notifications for some situation (app in background and user didn't click notification to bring the app to foreground) that
//    // alarm state is not updated correctly
//    func syncAlarmStateWithNotification() {
//        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {
//            requests in
//            debugLog(requests)
//            let alarms = Store.shared.alarms
//            let uuidNotificationsSet = Set(requests.map({$0.content.userInfo["uuid"] as! String}))
//            let uuidAlarmsSet = alarms.uuids
//            let uuidDeltaSet = uuidAlarmsSet.subtracting(uuidNotificationsSet)
//            debugLog(uuidDeltaSet)
//            for uuid in uuidDeltaSet {
//                if let alarm = alarms.getAlarm(ByUUIDStr: uuid) {
//                    if alarm.enabled {
//                        alarm.enabled = false
//                        // since this method will cause UI change, make sure run on main thread
//                        DispatchQueue.main.async {
//                            alarms.update(alarm)
//                        }
//                    }
//                }
//            }
//        })
//    }
//    
//    private func getNotificationDates(baseDate date: Date, onWeekdaysForNotify weekdays:[Int]) -> [Date]
//    {
//        var notificationDates: [Date] = [Date]()
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        let now = Date()
//        let flags: NSCalendar.Unit = [NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.day]
//        let dateComponents = (calendar as NSCalendar).components(flags, from: date)
//        let weekday = dateComponents.weekday ?? 0
//        
//        //no repeat
//        if weekdays.isEmpty {
//            //scheduling date is eariler than current date
//            if date < now {
//                //plus one day, otherwise the notification will be fired righton
//                notificationDates.append((calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: 1, to: date, options:.matchStrictly)!)
//            } else {
//                notificationDates.append(date)
//            }
//        }
//        else {
//            let daysInWeek = 7
//            for wdIndex in weekdays {
//                // weekdays index start from 1 (Sunday)
//                let wd = wdIndex + 1
//                var wdDate: Date?
//                //schedule on next week
//                if compare(weekday: wd, with: weekday) == .before {
//                    wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd + daysInWeek - weekday, to: date, options:.matchStrictly)
//                }
//                //schedule on today or next week
//                else if compare(weekday: wd, with: weekday) == .same {
//                    //scheduling date is eariler than current date, then schedule on next week
//                    if date.compare(now) == .orderedAscending {
//                        wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: daysInWeek, to: date, options:.matchStrictly)
//                    }
//                    else {
//                        wdDate = date
//                    }
//                }
//                //schedule on next days of this week
//                else {
//                    wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd - weekday, to: date, options:.matchStrictly)
//                }
//                
//                //fix second component to 0
//                if let date = wdDate {
//                    let correctedDate = NotificationScheduler.correctSecondComponent(date: date, calendar: calendar)
//                    notificationDates.append(correctedDate)
//                }
//            }
//        }
//        return notificationDates
//    }
//    
//    //remove the second component from date
//    static func correctSecondComponent(date: Date, calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)) -> Date {
//        let second = calendar.component(.second, from: date)
//        let d = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.second, value: -second, to: date, options:.matchStrictly)!
//        return d
//    }
//    
//    func setNotification(date: Date, ringtoneName: String, repeatWeekdays: [Int], snoozeEnabled: Bool, onSnooze: Bool, uuid: String) {
//        
//        
//        let content = UNMutableNotificationContent()
//        content.title = NSString.localizedUserNotificationString(forKey: "Alarm", arguments: nil)
//        content.body = NSString.localizedUserNotificationString(forKey: "Wake Up", arguments: nil)
//        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "tickle.mp3")) // Specify your custom alarm sound
//        content.badge = 1
//        let identifier = UUID().uuidString
//        
//        //Receive notification after 5 sec
//        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        
//        //Receive with date
//        var dateInfo = DateComponents()
//
//        dateInfo.hour = 12 //Put your hour
//        dateInfo.minute = 16//Put your minutes
//        dateInfo.second = 10
//        
//        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        let calendar = Calendar.current
//        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: date)
//
//        // Access the individual components
//        if let hour = dateComponents.hour,
//           let minute = dateComponents.minute,
//           let second = dateComponents.second {
//            debugLog("Current time is: \(hour):\(minute):\(second)")
//        }
//        //specify if repeats or no
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
//        
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        let center = UNUserNotificationCenter.current()
//        debugLog(identifier)
//        center.add(request) { (error) in
//            if let error = error {
//                debugLog("Error \(error.localizedDescription)")
//            }else{
//                debugLog("send!!")
//            }
//        }
////        let datesForNotification = getNotificationDates(baseDate: date, onWeekdaysForNotify: repeatWeekdays)
////        
////        for d in datesForNotification {
////            let notificationContent = UNMutableNotificationContent()
////            notificationContent.title = "Alarm"
////            notificationContent.body = "Wake Up"
////            notificationContent.categoryIdentifier = snoozeEnabled ? Identifier.snoozeAlarmCategoryIndentifier
////                                                                   : Identifier.alarmCategoryIndentifier
////            notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: ringtoneName + ".mp3"))
////            notificationContent.userInfo = ["snooze" : snoozeEnabled, "uuid": uuid, "soundName": ringtoneName]
////            //repeat weekly if repeat weekdays are selected
////            //no repeat with snooze notification
////            let repeats = !repeatWeekdays.isEmpty && !onSnooze
////            // make dataComponents only contain [weekday, hour, minute] component to make it repeat weakly
////            let dateComponents = Calendar.current.dateComponents([.weekday,.hour,.minute], from: d)
////            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
////            let request = UNNotificationRequest(identifier: uuid,
////                                                content: notificationContent,
////                                                trigger: trigger)
////
////            // schedule notification by adding request to notification center
////            UNUserNotificationCenter.current().add(request) { error in
////                if let e = error {
////                    debugLog(e.localizedDescription)
////                }
////            }
////        }
//    }
//    
//    func setNotificationForSnooze(ringtoneName: String, snoozeMinute: Int, uuid: String) {
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        let now = Date()
//        let snoozeDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: snoozeMinute, to: now, options:.matchStrictly)!
//        setNotification(date: snoozeDate, ringtoneName: ringtoneName, repeatWeekdays: [], snoozeEnabled: true, onSnooze: true, uuid: uuid)
//    }
//    
//    func cancelNotification(ByUUIDStr uuid: String) {
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid])
//    }
//    
//    func updateNotification(ByUUIDStr uuid: String, date: Date, ringtoneName: String, repeatWeekdays: [Int], snoonzeEnabled: Bool) {
//        cancelNotification(ByUUIDStr: uuid)
//        setNotification(date: date, ringtoneName: ringtoneName, repeatWeekdays: repeatWeekdays, snoozeEnabled: snoonzeEnabled, onSnooze: false, uuid: uuid)
//    }
//    
//    enum weekdaysComparisonResult {
//        case before
//        case same
//        case after
//    }
//    
//    // 1 == Sunday, 2 == Monday and so on
//    func compare(weekday w1: Int, with w2: Int) -> weekdaysComparisonResult
//    {
//        if w1 != 1 && (w1 < w2 || w2 == 1) {return .before}
//        else if w1 == w2 {return .same}
//        else {return .after}
//    }
//}


import Foundation
import UIKit
import UserNotifications

class NotificationScheduler : NotificationSchedulerDelegate{
    
    // we need to request user for notifiction permission first
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            (authorized, _) in
            if authorized {
                debugLog("notification authorized")
            } else {
                // may need to try other way to make user authorize your app
                debugLog("not authorized")
            }
        }
//        
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            if settings.authorizationStatus == .authorized {
//                debugLog("Notifications are authorized")
//            } else {
//                debugLog("Notifications are not authorized")
//            }
//        }
    }
    // Inside NotificationScheduler class
    func rescheduleNotificationIfNeeded(uuid: String, soundName: String) {
        // Wait for 25 seconds before rescheduling the notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Call the function to reschedule the notification
            self.setNotificationForSnooze(ringtoneName: soundName, snoozeMinute: 9, uuid: uuid)
        }
    }
    
    
    func registerNotificationCategories() {
        // Define the custom actions
        let snoozeAction = UNNotificationAction(identifier: Identifier.snoozeActionIdentifier, title: "Snooze", options: [.foreground])
        let stopAction = UNNotificationAction(identifier: Identifier.stopActionIdentifier, title: "OK", options: [.foreground])
        
        let snoonzeActions = [snoozeAction, stopAction]
        let nonSnoozeActions = [stopAction]
        
        let snoozeAlarmCategory = UNNotificationCategory(identifier: Identifier.snoozeAlarmCategoryIndentifier,
                                                         actions: snoonzeActions,
                                                         intentIdentifiers: [],
                                                         hiddenPreviewsBodyPlaceholder: "",
                                                         options: .customDismissAction)

        let nonSnoozeAlarmCategroy = UNNotificationCategory(identifier: Identifier.alarmCategoryIndentifier,
                                                            actions: nonSnoozeActions,
                                                            intentIdentifiers: [],
                                                            hiddenPreviewsBodyPlaceholder: "",
                                                            options: .customDismissAction)
        // Register the notification category
        UNUserNotificationCenter.current().setNotificationCategories([snoozeAlarmCategory, nonSnoozeAlarmCategroy])
    }
    
    // sync alarm state to scheduled notifications for some situation (app in background and user didn't click notification to bring the app to foreground) that
    // alarm state is not updated correctly
    func syncAlarmStateWithNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {
            requests in
            debugLog(requests)
            print("Pending Notifications: \(requests)")
            let alarms = Store.shared.alarms
            let uuidNotificationsSet = Set(requests.map({$0.content.userInfo["uuid"] as! String}))
            let uuidAlarmsSet = alarms.uuids
            let uuidDeltaSet = uuidAlarmsSet.subtracting(uuidNotificationsSet)
            debugLog(uuidDeltaSet)
            for uuid in uuidDeltaSet {
                if let alarm = alarms.getAlarm(ByUUIDStr: uuid) {
                    if alarm.enabled {
                        alarm.enabled = false
                        // since this method will cause UI change, make sure run on main thread
                        DispatchQueue.main.async {
                            alarms.update(alarm)
                        }
                    }
                }
            }
        })
    }
    
    private func getNotificationDates(baseDate date: Date, onWeekdaysForNotify weekdays:[Int]) -> [Date]
    {
        var notificationDates: [Date] = [Date]()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let now = Date()
        let flags: NSCalendar.Unit = [NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.day]
        let dateComponents = (calendar as NSCalendar).components(flags, from: date)
        let weekday = dateComponents.weekday ?? 0
        
        //no repeat
        if weekdays.isEmpty {
            //scheduling date is eariler than current date
            if date < now {
                //plus one day, otherwise the notification will be fired righton
                notificationDates.append((calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: 1, to: date, options:.matchStrictly)!)
            } else {
                notificationDates.append(date)
            }
        }
        
        else {
            let daysInWeek = 7
            for wdIndex in weekdays {
                // weekdays index start from 1 (Sunday)
                let wd = wdIndex + 1
                var wdDate: Date?
                //schedule on next week
                if compare(weekday: wd, with: weekday) == .before {
                    wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd + daysInWeek - weekday, to: date, options:.matchStrictly)
                }
                //schedule on today or next week
                else if compare(weekday: wd, with: weekday) == .same {
                    //scheduling date is eariler than current date, then schedule on next week
                    if date.compare(now) == .orderedAscending {
                        wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: daysInWeek, to: date, options:.matchStrictly)
                    }
                    else {
                        wdDate = date
                    }
                }
                //schedule on next days of this week
                else {
                    wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd - weekday, to: date, options:.matchStrictly)
                }
                
                //fix second component to 0
                if let date = wdDate {
                    let correctedDate = NotificationScheduler.correctSecondComponent(date: date, calendar: calendar)
                    notificationDates.append(correctedDate)
                }
            }
        }
        return notificationDates
    }
    
    static func correctSecondComponent(date: Date, calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)) -> Date {
        let second = calendar.component(.second, from: date)
        let d = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.second, value: -second, to: date, options:.matchStrictly)!
        return d
    }
    
    func setNotification(date: Date, ringtoneName: String, repeatWeekdays: [Int], snoozeEnabled: Bool, onSnooze: Bool, uuid: String,title : String,description : String,type:String,id:Int) {
        let datesForNotification = getNotificationDates(baseDate: date, onWeekdaysForNotify: repeatWeekdays)
        
        for d in datesForNotification {
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title =  title
            notificationContent.body = description
            notificationContent.categoryIdentifier = snoozeEnabled ? Identifier.snoozeAlarmCategoryIndentifier
                                                                   : Identifier.alarmCategoryIndentifier
            // Download the audio file
            print(type)
            if type == "apple_music"{
                let aps = ["mutable-content": 1]
                let dict = ["aps": aps,"snooze" : snoozeEnabled, "uuid": uuid, "soundName": ringtoneName,"type": type,"id":id,"title": title,"description":description] as [AnyHashable : Any]
//                notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell" + ".mp3"))
                notificationContent.sound = nil
                notificationContent.userInfo = dict
                //repeat weekly if repeat weekdays are selected
                //no repeat with snooze notification
                let repeats = !repeatWeekdays.isEmpty && !onSnooze
                // make dataComponents only contain [weekday, hour, minute] component to make it repeat weakly
                let dateComponents = Calendar.current.dateComponents([.weekday,.hour,.minute,.second], from: d)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
                let request = UNNotificationRequest(identifier: uuid,
                                                    content: notificationContent,
                                                    trigger: trigger)

                // schedule notification by adding request to notification center
                UNUserNotificationCenter.current().add(request) { error in
                    if let e = error {
                        debugLog(e.localizedDescription)
                    }
                }
            }else if type == "system"{
                notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell" + ".mp3"))
                let aps = ["mutable-content": 1]
                let dict = ["aps": aps,"snooze" : snoozeEnabled, "uuid": uuid, "soundName": ringtoneName,"type": type,"id":id,"title": title,"description":description] as [AnyHashable : Any]
                notificationContent.userInfo = dict
                //repeat weekly if repeat weekdays are selected
                //no repeat with snooze notification
                let repeats = !repeatWeekdays.isEmpty && !onSnooze
                // make dataComponents only contain [weekday, hour, minute] component to make it repeat weakly
                let dateComponents = Calendar.current.dateComponents([.weekday,.hour,.minute,.second], from: d)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
                let request = UNNotificationRequest(identifier: uuid,
                                                    content: notificationContent,
                                                    trigger: trigger)

                // schedule notification by adding request to notification center
                UNUserNotificationCenter.current().add(request) { error in
                    if let e = error {
                        debugLog(e.localizedDescription)
                    }
                }
            }else{
                notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell" + ".mp3"))
                
                let aps = ["mutable-content": 1]
                let dict = ["aps": aps,"snooze" : snoozeEnabled, "uuid": uuid, "soundName": ringtoneName,"type": type,"id":id,"title": title,"description":description] as [AnyHashable : Any]
                notificationContent.userInfo = dict
                //repeat weekly if repeat weekdays are selected
                //no repeat with snooze notification
                let repeats = !repeatWeekdays.isEmpty && !onSnooze
                // make dataComponents only contain [weekday, hour, minute] component to make it repeat weakly
                let dateComponents = Calendar.current.dateComponents([.weekday,.hour,.minute,.second], from: d)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
                let request = UNNotificationRequest(identifier: uuid,
                                                    content: notificationContent,
                                                    trigger: trigger)
                
                // schedule notification by adding request to notification center
                UNUserNotificationCenter.current().add(request) { error in
                    if let e = error {
                        debugLog(e.localizedDescription)
                    }
                    else {
                        // Print successful notification scheduling
                        print("Notification scheduled successfully for UUID: \(uuid)")
                    }
                }
                
//                downloadAudioFile(from: URL(string: ringtoneName)!)  { result in
//                        switch result {
//                        case .success(let downloadedFilePath):
//                            let notificationSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: downloadedFilePath.lastPathComponent))
//                            notificationContent.sound = notificationSound
//                           
//                            
//                            
//                        case .failure(let error):
//                            // Print the error message if the download fails
//                            print("Error downloading audio: \(error.localizedDescription)")
//                            notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: ringtoneName + ".mp3"))
//                            let aps = ["mutable-content": 1]
//                            let dict = ["aps": aps,"snooze" : snoozeEnabled, "uuid": uuid, "soundName": "bell","type": type,"id":id,"title": title,"description":description] as [AnyHashable : Any]
//                            notificationContent.userInfo = dict
//                            //repeat weekly if repeat weekdays are selected
//                            //no repeat with snooze notification
//                            let repeats = !repeatWeekdays.isEmpty && !onSnooze
//                            // make dataComponents only contain [weekday, hour, minute] component to make it repeat weakly
//                            let dateComponents = Calendar.current.dateComponents([.weekday,.hour,.minute,.second], from: d)
//                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
//                            let request = UNNotificationRequest(identifier: uuid,
//                                                                content: notificationContent,
//                                                                trigger: trigger)
//                            
//                            // schedule notification by adding request to notification center
//                            UNUserNotificationCenter.current().add(request) { error in
//                                if let e = error {
//                                    debugLog(e.localizedDescription)
//                                }else {
//                                    // Print successful notification scheduling when using fallback sound
//                                    print("Notification scheduled successfully with fallback sound for UUID: \(uuid)")
//                                }
//                            }
//                            print("Error downloading audio: \(error)")
//                        }
//                }
            }
        }
    }
    
    
    
    func setNotificationForSnooze(ringtoneName: String, snoozeMinute: Int, uuid: String) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let now = Date()
        let snoozeDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: snoozeMinute, to: now, options:.matchStrictly)!
        setNotification(date: snoozeDate, ringtoneName: ringtoneName, repeatWeekdays: [], snoozeEnabled: true, onSnooze: true, uuid: uuid,title : "",description : "", type: "", id: 0)
    }
    
    
    func cancelNotification(ByUUIDStr uuid: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid])
    }
    
    func updateNotification(ByUUIDStr uuid: String, date: Date, ringtoneName: String, repeatWeekdays: [Int], snoonzeEnabled: Bool,title : String,description : String,type:String,id:Int) {
        cancelNotification(ByUUIDStr: uuid)
        setNotification(date: date, ringtoneName: ringtoneName, repeatWeekdays: repeatWeekdays, snoozeEnabled: snoonzeEnabled, onSnooze: false, uuid: uuid,title : title, description : description, type: type, id: id)
    }
    
    enum weekdaysComparisonResult {
        case before
        case same
        case after
    }
    
    // 1 == Sunday, 2 == Monday and so on
    func compare(weekday w1: Int, with w2: Int) -> weekdaysComparisonResult
    {
        if w1 != 1 && (w1 < w2 || w2 == 1) {return .before}
        else if w1 == w2 {return .same}
        else {return .after}
    }
    
    func downloadAudioFile(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "NetworkError", code: 1, userInfo: ["NSLocalizedDescription": "Invalid HTTP response"])))
                return
            }

//            guard let mimeType = response?.mimeType, mimeType.hasPrefix("audio") else {
//                completion(.failure(NSError(domain: "NetworkError", code: 2, userInfo: ["NSLocalizedDescription": "Invalid MIME type"])))
//                return
//            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NetworkError", code: 3, userInfo: ["NSLocalizedDescription": "No Data Recieved"])))
                return
            }

            let fileExtension = URL(fileURLWithPath: url.lastPathComponent).pathExtension.isEmpty ? "caf" : URL(fileURLWithPath: url.lastPathComponent).pathExtension //default to caf if no extension

            let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            let filePath = tempDirectory.appendingPathComponent(UUID().uuidString + "." + fileExtension)

            do {
                try data.write(to: filePath)
                completion(.success(filePath))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


