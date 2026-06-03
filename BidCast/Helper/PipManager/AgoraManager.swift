////
////  AgoraManager.swift
////  BidCast
////
////  Created by Vivek_JAM-E_328 on 28/10/25.
////
//
//import Foundation
//import AgoraRtcKit
//import AVFoundation
//
//// MARK: - Agora Manager (for Live Streaming)
//class AgoraManager: NSObject, ObservableObject {
//    
//    // MARK: - Agora Credentials
//    struct AgoraCred {
//        static var appId = "6a0ab77ee15943df94524201d6c93877"
////        static var channelName = "room1"
////        static var token  = "007eJxTYHgSe7qis6f/s9mNyvXfu7QF2S/ZVm7ISrVXu6ljZKJabqvAYJZokJhkbp6aamhqaWKckmZpYmpkYmRgmGKWbGlsYW6+8S1jZkMgI0O7rzUTIwMEgvisDEX5+bmGDAwAMUEd9g=="
//    }
//    
//    // MARK: - Properties
//    private var agoraKit: AgoraRtcEngineKit?
//    @Published var isJoined: Bool = false
//    @Published var remoteUserId: UInt?
//    
//    // Video Views (bridged for SwiftUI)
//    @Published var localVideoView = UIView()
//    @Published var remoteVideoView = UIView()
//    
//    @Published private(set) var isAudioMuted = false
////    @Published private(set) var isVideoMuted = false
//    
//    @Published var isFrontCamera = true
//    
//    @Published var zoomFactor: Double = 1.0
//    
//    var isHost: Bool = false
//    
//    // MARK: - Designated Initializer
//    init(asHost: Bool) {
//        self.isHost = asHost
//        super.init()
//        initializeAgoraEngine()
////        if asHost {
////            self.setupLocalVideo()
////        }
//    }
//    
//    func setupVideoFrameDelegate() {
//        agoraKit?.setVideoFrameDelegate(self)
//    }
//    
//    // MARK: - Convenience Initializer (optional)
//    convenience override init() {
//        self.init(asHost: false)
//    }
//    
//    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer?
//    
//    // Add this method to get the sample buffer layer from Agora
//    func setupPiPLayer() -> AVSampleBufferDisplayLayer? {
//        let layer = AVSampleBufferDisplayLayer()
//        layer.videoGravity = .resizeAspectFill
//        sampleBufferDisplayLayer = layer
//        return layer
//    }
//    
//    func initializeAgoraEngine(asHost: Bool = false) {
//        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraCred.appId, delegate: self)
//        //step 1 -> Use Agora’s “Real-Time Interactive Mode”
//        agoraKit?.setChannelProfile(.liveBroadcasting)
//        agoraKit?.setParameters("{\"rtc.enable_low_latency_mode\":true}")
//        agoraKit?.setParameters("{\"che.audio.live_for_comm\":true}")
//        //step 2 -> Disable or Reduce Hardware Encoding Delay
//        agoraKit?.setParameters("{\"che.video.hardware_encoding\":false}")
//        //step 3 -> Set Ultra Low Latency Mode Explicitly
//        agoraKit?.setClientRole(.broadcaster)
//        agoraKit?.setParameters("{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}")
//        agoraKit?.setCameraZoomFactor(zoomFactor)
//        agoraKit?.enableVideo()
//        
//        // Set video encoder configuration
//        let videoConfig = AgoraVideoEncoderConfiguration(
//            size: CGSize(width: 1080, height: 1920),
//            frameRate: .fps30,
//            bitrate: AgoraVideoBitrateStandard,
//            orientationMode: .adaptative,
//            mirrorMode: .auto
//        )
//        agoraKit?.setVideoEncoderConfiguration(videoConfig)
//        
//        // Enable video frame delegate for PiP
//        setupVideoFrameDelegate()
//    }
//    
//    // MARK: - Join Channel
//    func joinChannel(asHost: Bool, channelName: String, token: String) {
//        guard let agoraKit = agoraKit else { return }
//        isHost = asHost
//        let options = AgoraRtcChannelMediaOptions()
//        options.clientRoleType = asHost ? .broadcaster : .audience
//        options.channelProfile = .liveBroadcasting
//        options.autoSubscribeAudio = true
//        options.autoSubscribeVideo = true
//        options.publishCameraTrack = asHost
//        options.publishMicrophoneTrack = asHost
//        options.audienceLatencyLevel = .ultraLowLatency
//        
//        agoraKit.joinChannel(
//            byToken: token,
//            channelId: channelName,
//            uid: 0,
//            mediaOptions: options
//        ) { [weak self] (channel, uid, elapsed) in
//            print("Joined channel: \(channel), UID: \(uid)")
//            DispatchQueue.main.async {
//                self?.isJoined = true
//                if asHost {
//                    self?.setupLocalVideo()
//                }
//            }
//        }
//        setupVideoFrameDelegate()
//    }
//    
//    func switchCamera() {
//        isFrontCamera.toggle()
//        agoraKit?.switchCamera()
//    }
//    
//    func adjustZoom(with factor: Double) {
//        zoomFactor = factor
//        agoraKit?.setCameraZoomFactor(factor)
//    }
//    
//    func toggleAudioMute() {
//        isAudioMuted.toggle()
//        agoraKit?.muteLocalAudioStream(isAudioMuted)
//    }
//    
//    // MARK: - Leave Channel
//    func leaveChannel() {
//
//        remoteUserId = nil
//        isJoined = false
//        
//        // Stop local video preview
//        agoraKit?.stopPreview()
//        // Leave the channel and release session-related resources
//        agoraKit?.leaveChannel(nil)
//        // Release all resources used by the Agora SDK
//        AgoraRtcEngineKit.destroy()
//    }
//    
//    func setupLocalVideo() {
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.uid = 0
//        videoCanvas.renderMode = .hidden
//        videoCanvas.view = localVideoView
//        // Set the local video view
//        agoraKit?.setupLocalVideo(videoCanvas)
//        // Enable the video module
//        agoraKit?.enableVideo()
////
//        // Start the local video preview
//        agoraKit?.startPreview()
//    }
//    
//    // MARK: - Setup Remote Video
//    private func setupRemoteVideo(uid: UInt) {
//        guard let agoraKit = agoraKit else { return }
//        
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.uid = uid
//        videoCanvas.view = remoteVideoView
//        videoCanvas.renderMode = .hidden
//        agoraKit.setupRemoteVideo(videoCanvas)
//    }
//}
//
//// MARK: - Agora Delegate
//extension AgoraManager: AgoraRtcEngineDelegate {
//    
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
//        DispatchQueue.main.async {
//            print("Remote user joined: \(uid)")
//            self.remoteUserId = uid
//            self.setupRemoteVideo(uid: uid)
//            
//            let videoCanvas = AgoraRtcVideoCanvas()
//            videoCanvas.uid = uid
//            videoCanvas.renderMode = .hidden
//            videoCanvas.view = self.remoteVideoView
//            self.agoraKit?.setupRemoteVideo(videoCanvas)
//            
//        }
//    }
//    
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
//        DispatchQueue.main.async {
//            print("Remote user left: \(uid)")
//            if self.remoteUserId == uid {
//                self.remoteUserId = nil
//                self.remoteVideoView.removeFromSuperview()
//            }
//        }
//    }
//    
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
//        DispatchQueue.main.async {
//            print("Left channel")
//            self.isJoined = false
//        }
//    }
//    
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
//        print("error: \(errorCode)")
//    }
//}
//
//
//extension AgoraManager: AgoraVideoFrameDelegate {
//    func onCapture(_ videoFrame: AgoraOutputVideoFrame, sourceType: AgoraVideoSourceType) -> Bool {
//        // Send frames to PiP if active
//        if AgoraPiPManager.shared.isPiPActive {
//            AgoraPiPManager.shared.processVideoFrame(videoFrame)
//        }
//        return true
//    }
//    
//    func onRenderVideoFrame(_ videoFrame: AgoraOutputVideoFrame, uid: UInt, channelId: String) -> Bool {
//        // Send remote user frames to PiP
//        if AgoraPiPManager.shared.isPiPActive {
//            AgoraPiPManager.shared.processVideoFrame(videoFrame)
//        }
//        return true
//    }
//    
//    func getVideoFormatPreference() -> AgoraVideoFormat {
//        return .I420
//    }
//}

import Foundation
import AgoraRtcKit
import AVFoundation

// MARK: - Agora Manager (for Live Streaming)
class AgoraManager: NSObject, ObservableObject {
    
    // MARK: - Agora Credentials
    struct AgoraCred {
        static var appId = "6a0ab77ee15943df94524201d6c93877"
    }
    
    // MARK: - Properties
    private var agoraKit: AgoraRtcEngineKit?
    @Published var isJoined: Bool = false
    @Published var remoteUserId: UInt?
    
    // Video Views (bridged for SwiftUI)
    @Published var localVideoView = UIView()
    @Published var remoteVideoView = UIView()
    
    @Published private(set) var isAudioMuted = false
    @Published var isFrontCamera = true
    @Published var zoomFactor: Double = 1.0
    
    var isHost: Bool = false
    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer?
    
    // MARK: - Designated Initializer
    init(asHost: Bool) {
        self.isHost = asHost
        super.init()
        initializeAgoraEngine()
    }
    
    // MARK: - Convenience Initializer
    convenience override init() {
        self.init(asHost: false)
    }
    
    func setupPiPLayer() -> AVSampleBufferDisplayLayer? {
        let layer = AVSampleBufferDisplayLayer()
        layer.videoGravity = .resizeAspectFill
        sampleBufferDisplayLayer = layer
        return layer
    }
    
    func initializeAgoraEngine(asHost: Bool = false) {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraCred.appId, delegate: self)
        
        // Step 1: Use Agora's "Real-Time Interactive Mode"
        agoraKit?.setChannelProfile(.liveBroadcasting)
        agoraKit?.setParameters("{\"rtc.enable_low_latency_mode\":true}")
        agoraKit?.setParameters("{\"che.audio.live_for_comm\":true}")
        
        // Step 2: Disable Hardware Encoding Delay
        agoraKit?.setParameters("{\"che.video.hardware_encoding\":false}")
        
        // Step 3: Set Ultra Low Latency Mode
        agoraKit?.setClientRole(.broadcaster)
        agoraKit?.setParameters("{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}")
        agoraKit?.setCameraZoomFactor(zoomFactor)
        agoraKit?.enableVideo()
        
        // Set video encoder configuration
        let videoConfig = AgoraVideoEncoderConfiguration(
            size: CGSize(width: 1080, height: 1920),
            frameRate: .fps30,
            bitrate: AgoraVideoBitrateStandard,
            orientationMode: .adaptative,
            mirrorMode: .auto
        )
        agoraKit?.setVideoEncoderConfiguration(videoConfig)
    }
    
    // MARK: - Join Channel
    func joinChannel(asHost: Bool, channelName: String, token: String) {
        guard let agoraKit = agoraKit else { return }
        isHost = asHost
        
        let options = AgoraRtcChannelMediaOptions()
        options.clientRoleType = asHost ? .broadcaster : .audience
        options.channelProfile = .liveBroadcasting
        options.autoSubscribeAudio = true
        options.autoSubscribeVideo = true
        options.publishCameraTrack = asHost
        options.publishMicrophoneTrack = asHost
        options.audienceLatencyLevel = .ultraLowLatency
        
        agoraKit.joinChannel(
            byToken: token,
            channelId: channelName,
            uid: 0,
            mediaOptions: options
        ) { [weak self] (channel, uid, elapsed) in
            print("✅ Joined channel: \(channel), UID: \(uid)")
            DispatchQueue.main.async {
                self?.isJoined = true
                if asHost {
                    self?.setupLocalVideo()
                } else {
                    // ✅ Setup remote video canvas immediately for viewers
                    self?.setupRemoteVideoCanvas()
                }
            }
        }
        
        // ✅ FIXED: Only enable PiP delegate when actually needed
        // Don't call setupVideoFrameDelegate() here - it can interfere with normal rendering
    }
    
    func setupVideoFrameDelegate() {
        // Only call this when PiP is actually needed
        agoraKit?.setVideoFrameDelegate(self)
    }
    
    func switchCamera() {
        isFrontCamera.toggle()
        agoraKit?.switchCamera()
    }
    
    func adjustZoom(with factor: Double) {
        zoomFactor = factor
        agoraKit?.setCameraZoomFactor(factor)
    }
    
    func toggleAudioMute() {
        isAudioMuted.toggle()
        agoraKit?.muteLocalAudioStream(isAudioMuted)
    }
    
    // MARK: - Leave Channel
    func leaveChannel() {
        remoteUserId = nil
        isJoined = false
        
        // Stop local video preview
        agoraKit?.stopPreview()
        // Leave the channel
        agoraKit?.leaveChannel(nil)
        // Basecamp #9958806477 (2026-06-03): DO NOT call AgoraRtcEngineKit.destroy()
        // here. destroy() tears down the PROCESS-WIDE shared engine singleton. Each
        // LiveStream view owns its own @StateObject AgoraManager and calls
        // sharedEngine() in init, but they all resolve to the SAME singleton. When a
        // viewer left one show and then joined another WITHOUT killing the app, the
        // previous leave had destroyed the shared engine, so the next join ran against
        // a torn-down engine -> no remote frames decoded -> BLACK video (everything
        // else worked because the socket/REST layer is independent). Only a full app
        // relaunch rebuilt the engine, which is exactly why "close and reopen the app"
        // fixed it. We now leave the channel but keep the engine alive for re-join.
        // (The engine is cheap to keep; it is recreated by sharedEngine() if the OS
        // ever reclaims it.)
    }
    
    func setupLocalVideo() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localVideoView
        agoraKit?.setupLocalVideo(videoCanvas)
        agoraKit?.enableVideo()
        agoraKit?.startPreview()
    }
    
    // MARK: - Setup Remote Video Canvas (call this early)
    func setupRemoteVideoCanvas() {
        // ✅ Setup the canvas immediately when joining as audience
        // This prepares the view to receive video before remote user joins
        if !isHost {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = 0 // 0 means "any remote user"
            videoCanvas.view = remoteVideoView
            videoCanvas.renderMode = .hidden
            agoraKit?.setupRemoteVideo(videoCanvas)
            print("✅ Remote video canvas prepared for incoming stream")
        }
    }
    
    // MARK: - Setup Remote Video
    private func setupRemoteVideo(uid: UInt) {
        guard let agoraKit = agoraKit else { return }
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
        
        print("✅ Remote video setup for UID: \(uid)")
    }
}

// MARK: - Agora Delegate
extension AgoraManager: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        DispatchQueue.main.async {
            print("✅ Remote user joined: \(uid)")
            self.remoteUserId = uid
            
            // ✅ FIXED: Only setup once
            self.setupRemoteVideo(uid: uid)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DispatchQueue.main.async {
            print("⚠️ Remote user left: \(uid)")
            if self.remoteUserId == uid {
                self.remoteUserId = nil
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        DispatchQueue.main.async {
            print("📤 Left channel")
            self.isJoined = false
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("❌ Agora Error: \(errorCode.rawValue)")
    }
    
    // ✅ NEW: Add these callbacks for better debugging
    func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed: Int) {
        print("📹 Remote video state changed - UID: \(uid), State: \(state.rawValue), Reason: \(reason.rawValue)")
        // Basecamp #9958806477 (2026-06-03): when the remote stream starts decoding
        // (.decoding == 2), make absolutely sure the canvas is bound to the on-screen
        // remoteVideoView. On a re-join within the same app session the SwiftUI view
        // may have been re-created after the initial setupRemoteVideo, leaving the
        // canvas pointed at a stale/detached view -> black. Re-binding here guarantees
        // the freshly-laid-out view receives frames.
        if state == .decoding || state == .starting {
            DispatchQueue.main.async {
                self.remoteUserId = uid
                self.setupRemoteVideo(uid: uid)
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        print("✅ First remote video frame decoded - UID: \(uid), Size: \(size)")
        // Re-bind the canvas to the current on-screen view on the first decoded
        // frame, covering the re-join-while-app-open black-video case (#9958806477).
        DispatchQueue.main.async {
            self.remoteUserId = uid
            self.setupRemoteVideo(uid: uid)
        }
    }
}

// MARK: - Video Frame Delegate (for PiP)
extension AgoraManager: AgoraVideoFrameDelegate {
    func onCapture(_ videoFrame: AgoraOutputVideoFrame, sourceType: AgoraVideoSourceType) -> Bool {
        // ✅ FIXED: Only process if PiP is actually active
        if AgoraPiPManager.shared.isPiPActive {
            AgoraPiPManager.shared.processVideoFrame(videoFrame)
        }
        return true // ✅ Always return true to allow normal rendering
    }
    
    func onRenderVideoFrame(_ videoFrame: AgoraOutputVideoFrame, uid: UInt, channelId: String) -> Bool {
        // ✅ FIXED: Only process if PiP is actually active
        if AgoraPiPManager.shared.isPiPActive {
            AgoraPiPManager.shared.processVideoFrame(videoFrame)
        }
        return true // ✅ Always return true to allow normal rendering
    }
    
    func getVideoFormatPreference() -> AgoraVideoFormat {
        return .I420
    }
}
