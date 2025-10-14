//
//  DownloadManager.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 14/10/25.
//

import Foundation
import UserNotifications
import UIKit

class FileDownloader: NSObject, URLSessionDownloadDelegate {
    static let shared = FileDownloader()
    
    private var session: URLSession!
    private var downloadTask: URLSessionDownloadTask?

    private override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func startDownload(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        downloadTask = session.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    // MARK: - Delegate
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        sendProgressNotification(progress: progress)
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = docsURL.appendingPathComponent("downloaded-receipt.pdf")
        
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            sendCompletionNotification(filePath: destinationURL.path)
        } catch {
            print("Error saving file:", error)
        }
    }
    
    // MARK: - Notifications
    
    private func sendProgressNotification(progress: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Downloading Receipt..."
        content.body = "Progress: \(Int(progress * 100))%"
        content.sound = .default
        let request = UNNotificationRequest(identifier: "progressNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func sendCompletionNotification(filePath: String) {
        let content = UNMutableNotificationContent()
        content.title = "Download Complete"
        content.body = "Tap to open the receipt."
        content.categoryIdentifier = "DOWNLOAD_COMPLETE"
        content.userInfo = ["filePath": filePath]
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
