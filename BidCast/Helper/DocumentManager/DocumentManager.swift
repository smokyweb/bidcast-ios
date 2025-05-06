//
//  DocumentManager.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 11/01/25.
//
import Foundation


class DocumentManager {
    
    //MARK: Document Directory

    let shared = DocumentManager()
    
    
    func SaveData(){
        let text = String(data: Data(), encoding: .utf8)
        let file = "test.txt"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try text?.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {}
        }
    }
    
    func GetData(fileName: String) -> String{
        let file = "\(fileName).txt"
        if let dir = FileManager.default.urls(for: .documentDirectory,     in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                return text
            }
            catch {
                return ""
            }
        }
        return ""
    }
    
    func DeleteData(fileName: String) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,includingPropertiesForKeys: nil,options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs {
                if fileURL.pathExtension == fileName {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch { debugLog(error)
            
        }
    }
    
    
    //MARK: Cache Directory
    
    func SaveCacheData(){
        var userCacheURL: URL?
        let userCacheQueue = OperationQueue()
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            userCacheURL = cacheURL.appendingPathComponent("users.json")
        }
        if (userCacheURL != nil) {
            var result : [String: Any]? = nil
            userCacheQueue.addOperation() {
                if let stream = InputStream(url: userCacheURL!) {
                    stream.open()
                    var users = (try? JSONSerialization.jsonObject(with: stream,    options: [])) as? [String: Any]
                    stream.close()
                    if let users = users {
                        result = users
                    } else {
//                        failedBlock(OverlayError.unexpected)
                    }
                }
            }
            
        }
    }
    
    func GetCacheData() {
        var userCacheURL: URL?
        let userCacheQueue = OperationQueue()
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            userCacheURL = cacheURL.appendingPathComponent("users.json")
        }
        if (userCacheURL != nil) {
            var result : [String: Any]? = nil
            userCacheQueue.addOperation() {
                if let stream = InputStream(url: userCacheURL!) {
                    stream.open()
                    var users = (try? JSONSerialization.jsonObject(with: stream,   options: [])) as? [String: Any]
                    if let users = users {
                        result = users
                    }
                    stream.close()
                }
            }
        }
    }
}
