//
//  PipManager.swift
//  BidCast
//
//  Created by JamTech on 20/11/25.
//

import AVKit
import AVFoundation
import UIKit

class PiPManager: NSObject, ObservableObject {
    static let shared = PiPManager()
    
    @Published var isPiPActive = false
    @Published var isPiPSupported = false
    
    private var pipController: AVPictureInPictureController?
    private var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer?
    private var pipVideoCallViewController: AVPictureInPictureVideoCallViewController?
    
    override init() {
        super.init()
        checkPiPSupport()
        setupAudioSession()
    }
    
    func checkPiPSupport() {
        isPiPSupported = AVPictureInPictureController.isPictureInPictureSupported()
        print("📱 PiP Supported: \(isPiPSupported)")
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers, .allowAirPlay])
            try audioSession.setActive(true)
            print("✅ Audio session configured for PiP")
        } catch {
            print("❌ Failed to configure audio session: \(error)")
        }
    }
    
    func setupPiP(with videoView: UIView) {
        guard isPiPSupported else {
            print("❌ PiP not supported on this device")
            return
        }
        
        // Create sample buffer display layer
        let layer = AVSampleBufferDisplayLayer()
        layer.videoGravity = .resizeAspectFill
        layer.frame = videoView.bounds
        self.sampleBufferDisplayLayer = layer
        
        // Create PiP video call view controller
        let pipVC = AVPictureInPictureVideoCallViewController()
        pipVC.preferredContentSize = CGSize(width: 1920, height: 1080)
        
        // Add the video view as a subview (for Agora rendering)
        pipVC.view.addSubview(videoView)
        videoView.frame = pipVC.view.bounds
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.pipVideoCallViewController = pipVC
        
        // Create content source
        let contentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: pipVC.view,
            contentViewController: pipVC
        )
        
        // Create PiP controller
        pipController = AVPictureInPictureController(contentSource: contentSource)
        pipController?.delegate = self
        pipController?.canStartPictureInPictureAutomaticallyFromInline = false
        
        print("✅ PiP setup complete")
        print("📊 isPictureInPicturePossible: \(pipController?.isPictureInPicturePossible ?? false)")
    }
    
    func startPiP() {
        guard let pipController = pipController else {
            print("❌ PiP controller not initialized")
            return
        }
        
        guard isPiPSupported else {
            print("❌ PiP not supported on this device")
            return
        }
        
        guard !isPiPActive else {
            print("⚠️ PiP already active")
            return
        }
        
        // Force check if possible
        print("📊 Checking PiP status:")
        print("   - isPictureInPicturePossible: \(pipController.isPictureInPicturePossible)")
        print("   - isPictureInPictureActive: \(pipController.isPictureInPictureActive)")
        print("   - isPictureInPictureSuspended: \(pipController.isPictureInPictureSuspended)")
        
        if pipController.isPictureInPicturePossible {
            pipController.startPictureInPicture()
            print("🎥 Starting PiP...")
        } else {
            print("❌ PiP is not possible right now - trying workaround...")
            
            // Workaround: Try again after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if pipController.isPictureInPicturePossible {
                    pipController.startPictureInPicture()
                    print("🎥 Starting PiP (retry)...")
                } else {
                    print("❌ PiP still not possible after retry")
                }
            }
        }
    }
    
    func stopPiP() {
        guard let pipController = pipController, isPiPActive else { return }
        pipController.stopPictureInPicture()
    }
    
    func cleanup() {
        stopPiP()
        pipController = nil
        sampleBufferDisplayLayer = nil
        pipVideoCallViewController = nil
    }
}

extension PiPManager: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("🎥 PiP will start")
        DispatchQueue.main.async {
            self.isPiPActive = true
        }
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("✅ PiP started successfully")
        DispatchQueue.main.async {
            self.isPiPActive = true
        }
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("🎥 PiP will stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("❌ PiP stopped")
        DispatchQueue.main.async {
            self.isPiPActive = false
        }
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("❌ PiP failed to start: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isPiPActive = false
        }
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("🔄 Restoring UI from PiP")
        completionHandler(true)
    }
}
//
//struct VideoContainerView: UIViewRepresentable {
//    let uiView: UIView
//    
//    func makeUIView(context: Context) -> UIView {
//        let containerView = UIView()
//        containerView.backgroundColor = .black
//        
//        // Add the Agora video view
//        containerView.addSubview(uiView)
//        uiView.frame = containerView.bounds
//        uiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        return containerView
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        // Update if needed
//    }
//    
//    // Add this to get the container view reference
//    static func extractView(from uiView: UIView) -> UIView? {
//        return uiView.subviews.first
//    }
//}
