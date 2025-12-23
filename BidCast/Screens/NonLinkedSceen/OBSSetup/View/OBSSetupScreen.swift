//
//  OBSSetupScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

struct OBSSetupScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    let streamKey: String
    let onCopyStreamKey: () -> Void
    let onDownloadOBS: () -> Void
    let onStartStreaming: () -> Void
    let onMoreInfo: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Primary Header
            PrimaryHeader(
                title: "OBS Setup",
                isForLogo: false,
                leadingImgArr: ["chevron.left"],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 40)
            .background(Color.white)
            

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // What is OBS?
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What is OBS?")
                            .font(.headline)
                        Text("OBS (Open Broadcaster Software) is a free streaming and recording program that lets you share your live content with your audience.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: onMoreInfo) {
                            Text("More Info")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.defaultTheme.opacity(0.1))
                    .cornerRadius(12)

                    // Stream Key
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Stream Key")
                            .font(.headline)
                        
                        HStack {
                            Text(streamKey)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button(action: onCopyStreamKey) {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Never share your stream key with anyone")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Setup Instructions")
                            .font(.headline)
                        ForEach(1..<5) { step in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(Color.defaultTheme)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text("\(step)")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    )

                                Text(instructionText(for: step))
                                    .font(.subheadline)
                            }
                        }
                    }

                    // Download OBS
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Get OBS Studio")
                            .font(.headline)

                        Button(action: onDownloadOBS) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Download OBS Studio")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.defaultTheme)
                            .cornerRadius(10)
                        }
                    }

                    // Start Streaming
                    Button(action: onStartStreaming) {
                        Text("Start Streaming")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.defaultTheme)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .background(Color.white)
        }
        .background(Color(red: 0.93, green: 0.96, blue: 1.0)) // light blue background
        .cornerRadius(16)
        .padding()
    }

    // Dynamic instructions
    private func instructionText(for step: Int) -> String {
        switch step {
        case 1: return "Open OBS Studio on your computer"
        case 2: return "Go to Settings > Stream"
        case 3: return "Select \"Custom\" as Service"
        case 4: return "Paste your stream key and click \"Apply\""
        default: return ""
        }
    }
}
