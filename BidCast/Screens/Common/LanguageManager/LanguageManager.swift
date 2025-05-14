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
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            Bundle.setLanguage(selectedLanguage)
            // Trigger refresh
            languageChanged.toggle()
        }
    }

    // This forces views to re-render
    @Published var languageChanged = false

    private init() {
        self.selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        Bundle.setLanguage(selectedLanguage)
    }
}

