//
//  VerificationSectionView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct VerificationSectionView: View {
    var icon: String
    var title: String
    var subtitle: String
    var status: VerificationStatus? = nil
    var statusText: String? = nil
    var actions: [String]? = nil
    var actionLabel: String? = nil
    var showDashedCard: Bool = false
    var isActionEnabled: Bool = true
    var onAction: ((String) async -> Void)? = nil
    var onActionTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.gray.opacity(0.2)))

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom(poppinsSemiBold, size: 14.0))
                    Text(subtitle)
                        .font(.custom(poppinsRegular, size: 13.0))
                        .foregroundColor(.gray)
                }

                Spacer()

                if let statusText = statusText {
                    Text(statusText)
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.gray)
                } else if status == .completed {
                    Image(systemName: "checkmark").foregroundColor(.green)
                } else if let label = actionLabel {
                    Button(action: {
                        if isActionEnabled {
                            onActionTap?()
                        }
                    }) {
                        Text(label)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(isActionEnabled ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }.disabled(!isActionEnabled)
                }
            }

            if let actions = actions {
                HStack(spacing: 16) {
                    ForEach(actions, id: \.self) { action in
                        Button {
                            Task { await onAction?(action) }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: action == "ID Card" ? "doc.text.viewfinder" : "camera.fill")
                                    .font(.system(size: 20))
                                Text(action)
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
                        }
                    }
                }
            }

            if showDashedCard {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .frame(height: 80)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                            Text("No payment method added")
                                .font(.custom(poppinsSemiBold, size: 13.0))
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        
    }
}
