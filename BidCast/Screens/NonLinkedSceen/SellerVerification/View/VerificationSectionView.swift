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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.gray.opacity(0.2)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).foregroundColor(.gray)
                }

                Spacer()

                if let statusText = statusText {
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else if status == .completed {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                } else if let label = actionLabel {
                    if label == "Verify" {
                        Button(action: {
                            // Handle verify action
                        }) {
                            Text(label)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    } else {
                        Button(label) {
                            // Handle other button action
                        }
                        .foregroundColor(.blue)
                    }
                }

            }

            if let actions = actions {
                HStack(spacing: 16) {
                    ForEach(actions, id: \.self) { action in
                        Button(action: {
                            // Handle action here
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: action == "ID Card" ? "doc.text.viewfinder" : "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                Text(action)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
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
                                .font(.subheadline)
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
