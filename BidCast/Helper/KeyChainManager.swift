//
//  KeyChainManager.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 16/10/25.
//

import Foundation
import Security

class KeychainManager {
    
    static let shared = KeychainManager()
    private init() {} // Singleton
    
    private var service: String? {
        let bundleID = Bundle.main.bundleIdentifier
        return bundleID
    }
    
    // MARK: - Save Credentials
    func save(email: String, password: String) -> Bool {
        let passwordData = password.data(using: .utf8)!

        // Delete existing item first
        delete(email: email)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Retrieve Password
    func getPassword(email: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess,
           let retrievedData = dataTypeRef as? Data,
           let password = String(data: retrievedData, encoding: .utf8) {
            return password
        }

        return nil
    }

    // MARK: - Delete Credentials
    func delete(email: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    // MARK: - Clear All (Optional Helper)
    func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
