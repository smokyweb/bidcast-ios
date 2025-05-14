//
//  LanguageManager.swift
//  BidCast
//
//  Created by JAM_E_329 on 14/05/25.
//

import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            Bundle.setLanguage(selectedLanguage)
        }
    }

    init() {
        let current = Locale.preferredLanguages.first ?? "en"
        self.selectedLanguage = current.contains("ar") ? "ar" : "en"
        Bundle.setLanguage(selectedLanguage)
    }
}
