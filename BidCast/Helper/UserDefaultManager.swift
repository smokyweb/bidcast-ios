//
//  UserDefaultManager.swift
//  imperium
//
//  Created by JAM-E-282 on 18/01/24.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() { }
    
        //MARK: - Set Value
    func setValue<T>(_ value: T, forKey key: UserDefaultKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
        // MARK: - Get value
    func value<T>(forKey key: UserDefaultKey) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    
        // MARK: - Set model using enum key
    func setModel<T: Codable>(_ model: T, forKey key: UserDefaultKey) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(model)
            UserDefaults.standard.set(encodedData, forKey: key.rawValue)
            UserDefaults.standard.synchronize()
        } catch {
            print("Error encoding model: \(error)")
        }
    }
    
        // MARK: - Get model using enum key
    func getModel<T: Codable>(forKey key: UserDefaultKey) -> T? {
        if let savedData = UserDefaults.standard.data(forKey: key.rawValue) {
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(T.self, from: savedData)
                return model
            } catch {
                print("Error decoding model: \(error)")
            }
        }
        return nil
    }
    
    
        // MARK: - Remove model using enum key
    func remove(forKey key: UserDefaultKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
        // MARK: - Clear all values
    func clearAllValues() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
        }
    }
}


enum UserDefaultKey: String {
    case userDetail
    case userRoleId
    case firstName
    case lastName
    case email
    case password
    case location
    case isLoggedIn
    case employerRightSwipe
    case token
    case videoExample
    case yourVideo
    case rememberMe
    case mailId
    case userRole
    case userVideoResumeURL
    case deviceToken
    case combineData
    case UserAcceess
    case employerId
    case isSubscribed
    case subscriptionType
    case isLinkedInLogin
    case linkedInData
    case videoURLs
    case showMatchingSheet
    case companyNameList
    case editWorkHistory
    case startTimeSlot
    case endTimeSlot
}
