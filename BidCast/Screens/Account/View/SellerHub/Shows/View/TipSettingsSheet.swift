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
    @FocusState private var isTextFieldFocused: Bool
    
    let characterLimit = 24
    
    var onSave: ((String, Bool) -> Void)?
    
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
            
            // Bottom Buttons
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // Cancel Button
                    Button(action: {
                        dismiss()
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
                        dismiss()
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
