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
    
    // MC cmpfokfm2001joohgb7e3ueqj (2026-05-22): make `service` non-optional.
    // Passing Optional<String> into the SecItem dictionary works at runtime
    // but is fragile — Bundle.main.bundleIdentifier is non-nil on a real
    // app target, so a plain String is correct here.
    private var service: String {
        return Bundle.main.bundleIdentifier ?? "com.bidcast.app"
    }

    // MC cmpfokfm2001joohgb7e3ueqj (2026-05-22): the previous SecItemAdd
    // call did NOT set kSecAttrAccessible, which means the entry defaulted
    // to kSecAttrAccessibleWhenUnlocked. That class is not always migrated
    // across iCloud / encrypted-backup restores and can become unreadable
    // on some restore flows — a classic cause of "Remember Me silently
    // breaks after device restore". Use kSecAttrAccessibleAfterFirstUnlock
    // so the entry persists across reboots and survives encrypted backup
    // restores. Note: existing entries saved under the old class are NOT
    // auto-upgraded; users will need to log in once after this update so
    // the app re-saves the entry under the new accessibility class.
    // MARK: - Save Credentials
    func save(email: String, password: String) -> Bool {
        let passwordData = password.data(using: .utf8)!

        // Delete existing item first
        delete(email: email)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
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
