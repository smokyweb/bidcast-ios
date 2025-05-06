//
//  localNoti.swift
//  Rise Shine Swing
//
//  Created by Abdul-JAM-E-157 on 01/05/25.
//
import UIKit



class LocalNotificationScheduler {
//    static let shared = LocalNotificationScheduler()
//    private init() {} // Singleton pattern

    func scheduleMultipleNotifications(count: Int, title: String, body: String) {
        let center = UNUserNotificationCenter.current()

        for i in 0..<count {
            let content = UNMutableNotificationContent()
            content.title = "\(title) (\(i + 1))"
            content.body = body
            content.sound = UNNotificationSound.default

            // Calculate the trigger time
            let triggerTime = Date().addingTimeInterval(TimeInterval(i * 5))
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerTime), repeats: false)

            // Create the request
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // Schedule the notification
            center.add(request) { (error) in
                if let error = error {
                    print("Error scheduling notification \(i + 1): \(error)")
                } else {
                    print("Notification \(i + 1) scheduled for \(triggerTime)")
                }
            }
        }
    }

    // Optional: Method to request authorization if you haven't already
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Notification authorization denied: \(error)")
            }
        }
    }
}
