//
//  ProductDetailSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AVKit

struct CreateClipBottomSheetView: View {
    @Binding var isPresented: Bool
    let videoURL: URL
    var onCreateClip: (CMTime, CMTime) -> Void

    @State private var player: AVPlayer?

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Text("Create Clip")
                    .font(.custom(poppinsBold, size: 16.0))
                Spacer()
            }
            .padding(.top,-12)
            .padding(.horizontal)

            // Video Player
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 200)
                    .cornerRadius(16)
            } else {
                Color.black.opacity(0.1)
                    .frame(height: 200)
                    .overlay(Text("Loading..."))
                    .cornerRadius(16)
            }

            // Clip Details
            HStack(alignment: .center) {
                Image(systemName: "scissors")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)
                VStack(alignment: .leading) {
                    Text("Trim Clip")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    Text("Last 30 seconds")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Button("Edit") {
                    // Future enhancement: custom trimming
                }
                .foregroundColor(.red)
            }

            // Create Clip Button
            Button(action: {
                if let duration = player?.currentItem?.duration {
                    let totalSeconds = CMTimeGetSeconds(duration)
                    let end = CMTime(seconds: totalSeconds, preferredTimescale: 600)
                    let start = CMTime(seconds: max(0, totalSeconds - 30), preferredTimescale: 600)
                    onCreateClip(start, end)
                    isPresented = false
                }
            }) {
                Text("Create Clip")
                    .font(.custom(poppinsBold, size: 14.0))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.defaultTheme)
                    .cornerRadius(20)
            }

        }
        .edgesIgnoringSafeArea(.top)
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            player = AVPlayer(url: videoURL)
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}


extension AVPlayer {
    var durationSeconds: Double {
        currentItem?.duration.seconds ?? 0
    }
}
