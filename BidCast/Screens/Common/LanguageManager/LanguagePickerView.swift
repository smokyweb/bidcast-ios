//
//  LanguagePickerView.swift
//  BidCast
//
//  Created by JAM_E_329 on 14/05/25.
//


import SwiftUI

struct LanguagePickerView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @State var navigateTotab: Bool = false

    @State private var languages = [
        "en": "English",            // English
        "ar": "Arabic",             // Arabic
        "es": "Spanish",            // Spanish
        "hi": "Hindi",              // Hindi
        "pt": "Portuguese (Brazil)",// Portuguese (Brazil)
        "ru": "Russian",            // Russian
        "ja": "Japanese",           // Japanese
        "vi": "Vietnamese",         // Vietnamese
        "ko": "Korean",             // Korean
        "zh-Hans": "Chinese (Simplified)" // Chinese (Simplified)
    ]
    @State private var selectedLanguage = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Primary Header
            PrimaryHeader(
                title: AppString.forgotPassword.localized,
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 80)
            
            // MARK: - Title with Line
            TitleWithLine(title: AppString.selectALanguage.localized, lineLength: 48)

            // MARK: - Dropdown
            DropDownTextField(
                hint: "Select Language",
                text: $selectedLanguage,
                options: .constant(Array(languages.values)),
                leadingIcon: .location,
                showLeadingIcon: true,
                showTrailingIcon: false,
                showDropDownIcon: true,
                anchor: .bottom
            )
            .onChange(of: selectedLanguage) { newValue in
                if let selectedCode = languages.first(where: { $0.value == newValue })?.key {
                    languageManager.selectedLanguage = selectedCode
                    withAnimation(.snappy) { navigateTotab = true }
                }
            }

            Spacer()
            CusNavLink(doNavigate: $navigateTotab, destination: TabbarScreen())
        }
        .padding()
        .zIndex(1400.0)
    }
}
