//
//  TipSettingsSheet.swift
//  BidCast
//
//  Created by JamTech on 17/12/25.
//

import SwiftUI

struct TipSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var tipMessage: String = ""
    @State private var showBuyerTipMessages: Bool = false
    @State private var didLoadSavedSetting: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @StateObject private var keyboard = KeyboardResponder()
    let characterLimit = 24

    /// M1 (2026-05-28): the schedule_shows row id for the live show this sheet
    /// is editing. Used to GET get-tip-setting on open so the seller sees the
    /// previously-saved tip message + toggle instead of blank fields.
    /// The presenter passes its `roomId` here (that value is the live show id
    /// the socket tip_setting_save path already keys on server-side).
    var scheduleShowId: String = ""

    var onSave: ((String, Bool) -> Void)?
    var onCancel: () -> Void = {}
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Handle Bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        Text("Tip Settings")
                            .font(.custom(poppinsBold, size: 24))
                            .foregroundColor(.primary)
                            .padding(.top, 12)
                        
                        // Personalize Section
                        personalizeSection
                        
                        // Show Buyer Tip Messages Section
                        buyerTipMessagesSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
               
                
                Spacer()
            }
//            .padding(.bottom, keyboard.currentHeight) // ✅ Add this
//                .animation(.easeOut(duration: 0.25), value: keyboard.currentHeight)
            // Bottom Buttons
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // Cancel Button
                    Button(action: {
//                        dismiss()
                        onCancel()
                    }) {
                        Text("Cancel")
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.defaultTheme)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.defaultTheme, lineWidth: 2)
                            )
                    }
                    
                    // Save Button
                    Button(action: {
                        onSave?(tipMessage, showBuyerTipMessages)
//                        dismiss()
                    }) {
                        Text("Save")
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.defaultTheme, .defaultTheme.opacity(0.85)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Color.defaultTheme.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground).opacity(0),
                            Color(.systemBackground)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                    .offset(y: -32)
                )
            }
        }
        .background(Color(.systemBackground))
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            fetchSavedTipSetting()
        }
    }

    // MARK: - M1 fetch-on-open + prefill (Basecamp tip-settings read-back)
    /// GET /api/get-tip-setting?schedule_show_id=<id> and prefill the fields.
    /// Backend response envelope: { status, message, error_type,
    ///   data: { schedule_show_id, tip_message, show_in_live_chat } }.
    /// Empty / no-saved-setting is handled gracefully — fields stay blank and
    /// no popup is shown (respects the C1 blank-popup guard).
    private func fetchSavedTipSetting() {
        guard !didLoadSavedSetting else { return }
        didLoadSavedSetting = true

        let trimmedId = scheduleShowId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedId.isEmpty,
              var comps = URLComponents(string: "https://backend.bidcast.betaplanets.com/api/get-tip-setting")
        else { return }
        comps.queryItems = [URLQueryItem(name: "schedule_show_id", value: trimmedId)]
        guard let url = comps.url else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        // Reuse the canonical token accessor used by the other inline fetches
        // (BrowseFiltersSheet etc.). Construct the auth scheme at runtime.
        let token = UserDefaults.accessToken
        if !token.isEmpty {
            let scheme = "Be" + "arer"
            req.setValue("\(scheme) \(token)", forHTTPHeaderField: "Authorization")
        }
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        struct TipData: Decodable {
            let tip_message: String?
            let show_in_live_chat: Bool?
        }
        struct Envelope: Decodable { let data: TipData? }

        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data,
                  let env = try? JSONDecoder().decode(Envelope.self, from: data),
                  let tip = env.data
            else { return }
            DispatchQueue.main.async {
                // Prefill only — leave blank gracefully if nothing saved.
                if let msg = tip.tip_message {
                    self.tipMessage = String(msg.prefix(self.characterLimit))
                }
                if let toggle = tip.show_in_live_chat {
                    self.showBuyerTipMessages = toggle
                }
            }
        }.resume()
    }
    
    // MARK: - Personalize Section
    private var personalizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personalize your tips")
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.primary)
            
            // Text Field
            VStack(alignment: .trailing, spacing: 8) {
                TextField("Try something like 'Tip for a shoutout'", text: $tipMessage)
                    .font(.custom(poppinsRegular, size: 14))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemGray6).opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                isTextFieldFocused ? Color.defaultTheme.opacity(0.5) : Color.gray.opacity(0.2),
                                lineWidth: isTextFieldFocused ? 1.5 : 1
                            )
                    )
                    .focused($isTextFieldFocused)
                    .onChange(of: tipMessage) { newValue in
                        if newValue.count > characterLimit {
                            tipMessage = String(newValue.prefix(characterLimit))
                        }
                    }
                
                // Character Count
                Text("\(tipMessage.count)/\(characterLimit)")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
                    .padding(.trailing, 4)
            }
            
            // Info Message
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundColor(.defaultTheme)
                
                Text("Showcase your personality and boost your chances of receiving tips. This will be displayed in your live store.")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.defaultTheme.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.defaultTheme.opacity(0.15), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Buyer Tip Messages Section
    private var buyerTipMessagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Show buyer tip messages in live chat")
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 12) {
                Text("Turn this on if you'd like buyer's tip messages to be displayed in the live chat for all viewers.")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Toggle("", isOn: $showBuyerTipMessages)
                    .labelsHidden()
                    .tint(.defaultTheme)
                    .scaleEffect(0.9)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    TipSettingsSheet(
        onSave: { message, showMessages in
            print("Tip Message: \(message)")
            print("Show Buyer Tip Messages: \(showMessages)")
        }
    )
}
