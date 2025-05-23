//
//  CustomVideoPlayer.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 31/01/24.
//

import Foundation
import SwiftUI
import AVKit

struct CustomVideoPlayer : UIViewControllerRepresentable {
    var player : AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true //Important to not show any native videoplayer controls
        controller.videoGravity = .resizeAspect
        controller.showsTimecodes = true
        
        player?.currentItem?.preferredForwardBufferDuration = 3
        
        loopVideo(player: player)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
    
    func loopVideo(player p: AVPlayer?) {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: p?.currentItem, queue: nil) { notification in
            p?.seek(to: .zero)
            p?.play()
        }
    }
}
