//
//  LanguagePickerView.swift
//  BidCast
//
//  Created by JAM_E_329 on 14/05/25.
//

import SwiftUI

struct LanguagePickerView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    let languages = ["en": "English", "ar": "Arabic"]
    
    var body: some View {
        VStack {
            Menu {
                ForEach(languages.keys.sorted(), id: \.self) { code in
                    Button(action: {
                        languageManager.selectedLanguage = code
                    }) {
                        Text(languages[code] ?? code)
                    }
                }
            } label: {
                Text("change_language".localized)
                    .font(.body) 
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
