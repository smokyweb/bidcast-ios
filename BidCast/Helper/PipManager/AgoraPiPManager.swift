//
//  PipVideoCallViewController.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import UIKit
import AVKit
import AgoraRtcKit

class AgoraPiPManager: NSObject, ObservableObject {
    static let shared = AgoraPiPManager()
    
    @Published var isPiPActive = false
    @Published var isPiPSupported = false
    
    private var pipController: AVPictureInPictureController?
    private var pipViewController: AVPictureInPictureVideoCallViewController?
    private var containerView: AgoraPiPContainerView?
    
    private override init() {
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
    
    func setupPiP() {
        guard isPiPSupported else {
            print("❌ PiP not supported on this device")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let rootView = UIApplication.shared.connectedScenes
                      .compactMap({ $0 as? UIWindowScene })
                      .flatMap({ $0.windows })
                      .first(where: { $0.isKeyWindow })?.rootViewController?.view else {
                return
            }
            
            // Create container view
            let container = AgoraPiPContainerView(frame: UIScreen.main.bounds)
            self.containerView = container
            
            // Create PiP view controller
            let pipVC = AVPictureInPictureVideoCallViewController()
            pipVC.preferredContentSize = CGSize(width: 1080, height: 1920)
            
            // Add container to PiP view controller
            pipVC.view.addSubview(container)
            container.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: pipVC.view.topAnchor),
                container.bottomAnchor.constraint(equalTo: pipVC.view.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: pipVC.view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: pipVC.view.trailingAnchor)
            ])
            
            // Create content source
            let contentSource = AVPictureInPictureController.ContentSource(
                activeVideoCallSourceView: rootView,
                contentViewController: pipVC
            )
            
            // Create PiP controller
            self.pipController = AVPictureInPictureController(contentSource: contentSource)
            self.pipController?.delegate = self
            self.pipController?.canStartPictureInPictureAutomaticallyFromInline = true
            self.pipViewController = pipVC
            
            print("✅ PiP setup complete")
        }
    }
    
    func startPiP() {
        guard let pipController = pipController else {
            print("⚠️ PiP controller not initialized, setting up now...")
            setupPiP()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.attemptStartPiP()
            }
            return
        }
        
        attemptStartPiP()
    }
    
    private func attemptStartPiP() {
        guard let pipController = pipController else { return }
        
        print("📊 PiP Status:")
        print("   - isPictureInPicturePossible: \(pipController.isPictureInPicturePossible)")
        print("   - isPictureInPictureActive: \(pipController.isPictureInPictureActive)")
        
        if pipController.isPictureInPicturePossible {
            pipController.startPictureInPicture()
            print("🎥 Starting PiP...")
        } else {
            print("❌ PiP is not possible right now")
        }
    }
    
    func stopPiP() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let pipController = self.pipController,
                  pipController.isPictureInPictureActive else { return }
            
            pipController.stopPictureInPicture()
        }
    }
    
    func processVideoFrame(_ videoFrame: AgoraOutputVideoFrame) {
        containerView?.processVideoFrame(videoFrame)
    }
    
    func cleanup() {
        stopPiP()
        containerView?.cleanup()
        containerView = nil
        pipViewController = nil
        pipController = nil
    }
}

// MARK: - AVPictureInPictureControllerDelegate

extension AgoraPiPManager: AVPictureInPictureControllerDelegate {
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
            self.containerView?.removeFromSuperview()
            self.pipViewController = nil
            self.pipController = nil
        }
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("❌ PiP failed to start: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isPiPActive = false
            self.containerView?.cleanup()
            self.containerView = nil
            self.pipViewController = nil
            self.pipController = nil
        }
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("🔄 Restoring UI from PiP")
        completionHandler(true)
    }
}
