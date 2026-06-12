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
    
    // Basecamp #9986388919 (2026-06-11): fix blurry buyer video on iOS.
    // Removed two parameters that degraded encode quality:
    //   1. che.video.hardware_encoding:false — this disabled hardware H.264
    //      encoding, forcing software encoding which runs at lower bitrate
    //      under CPU pressure and can produce a noticeably softer image.
    //      Hardware encoding is the correct default for live streaming.
    //   2. che.video.lowBitRateStreamParameter (320x180 @ 15fps/140kbps) —
    //      this pre-configures the low-quality dual-stream layer. Leaving it
    //      present is harmless only if dual-stream is never enabled, but it
    //      suggested intent to use dual-stream at a very low quality, risking
    //      future mis-configuration. Removed for clarity.
    // The main VideoEncoderConfiguration (1080x1920, fps30, standard bitrate,
    // orientationMode .adaptative) is correct and unchanged.
    //
    // Basecamp #9986387480 (round 4, 2026-06-12): RAID VIDEO FIX.
    // This function previously ALWAYS called setClientRole(.broadcaster)
    // regardless of whether `asHost` was true or false (the parameter was
    // accepted but never used). The Agora engine is a process-wide singleton
    // (AgoraRtcEngineKit.sharedEngine). When a seller hosted their own show
    // as a broadcaster and then raided another show, initializeAgoraEngine()
    // was called again on the new AgoraManager(asHost: false) instance —
    // but it unconditionally set .broadcaster again, leaving the engine in
    // broadcaster mode. joinChannel() does pass options.clientRoleType=.audience
    // correctly, but the engine-level setClientRole(.broadcaster) overrides
    // that for the JOIN phase, causing the seller to arrive as an accidental
    // broadcaster rendering their own frozen camera frame instead of the
    // remote seller's stream.
    //
    // FIX: use `self.isHost` (set in init before this is called) to set the
    // correct engine-level client role at initialization time. joinChannel()
    // also sets options.clientRoleType correctly, so both layers are now
    // consistent for both paths.
    func initializeAgoraEngine(asHost: Bool = false) {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraCred.appId, delegate: self)

        // Step 1: Use Agora's "Real-Time Interactive Mode"
        agoraKit?.setChannelProfile(.liveBroadcasting)
        agoraKit?.setParameters("{\"rtc.enable_low_latency_mode\":true}")
        agoraKit?.setParameters("{\"che.audio.live_for_comm\":true}")

        // Step 2: Set the correct engine-level client role.
        // MUST match the join intent: broadcaster for hosts, audience for viewers.
        // self.isHost is set in init(asHost:) before initializeAgoraEngine() is called.
        let engineRole: AgoraClientRole = self.isHost ? .broadcaster : .audience
        agoraKit?.setClientRole(engineRole)
        print("RAID_QA: initializeAgoraEngine — isHost=\(self.isHost), engineRole=\(self.isHost ? "broadcaster" : "audience")")

        agoraKit?.setCameraZoomFactor(zoomFactor)
        agoraKit?.enableVideo()

        // Set video encoder configuration: 1080x1920 portrait HD, 30 fps,
        // standard bitrate (~2000 kbps at this resolution), adaptive orientation.
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

        // Basecamp #9958806477 ROUND 3 (2026-06-03): The previous rounds established
        // that (a) the engine must NOT be destroyed between joins, and (b) the delegate
        // must be re-pointed to THIS instance on each join. Both of those remain.
        //
        // Round 3 fixes the root cause that Round 2 accidentally introduced:
        // leaveChannel() set `remoteUserId = nil` at the TOP of the function and then
        // read `remoteUserId ?? 0` for the clear-canvas call — so the canvas clear ALWAYS
        // used uid=0 instead of the real seller uid. The actual seller canvas
        // (uid=<sellerUID> → old detached UIView) was NEVER cleared in the engine.
        // On the next join the engine still held the stale canvas pointing at the
        // deallocated/detached view; even though we called setupRemoteVideo with the
        // new view in didJoinedOfUid, Agora SDK 4.6.0 would not properly transition the
        // render pipeline away from the stale canvas → black.
        //
        // Additional Round 3 fix: the uid=0 canvas calls (setupRemoteVideoCanvas) are
        // a no-op in Agora SDK 4.x — uid=0 in setupRemoteVideo means "canvas for uid 0"
        // not "any remote user". Removed to reduce confusion. We wait for didJoinedOfUid
        // to get the real uid before calling setupRemoteVideo.
        //
        // Defensive additions:
        //   • disableVideo + enableVideo to flush any stale video pipeline state
        //   • muteAllRemoteVideoStreams(false) to unblock subscription in case a prior
        //     mute state persisted through the channel leave
        //   • explicit muteRemoteVideoStream(uid, mute: false) in setupRemoteVideo(uid:)

        // Always re-point delegate to THIS instance (engine is a shared singleton).
        agoraKit.delegate = self

        // Flush stale video pipeline state from previous session.
        agoraKit.disableVideo()
        agoraKit.enableVideo()

        if !asHost {
            // Unblock any muted remote video subscriptions left over from the last session.
            agoraKit.muteAllRemoteVideoStreams(false)
        }

        let options = AgoraRtcChannelMediaOptions()
        options.clientRoleType = asHost ? .broadcaster : .audience
        options.channelProfile = .liveBroadcasting
        options.autoSubscribeAudio = true
        options.autoSubscribeVideo = true
        options.publishCameraTrack = asHost
        options.publishMicrophoneTrack = asHost
        options.audienceLatencyLevel = .ultraLowLatency

        // RAID_QA: log the join parameters for diagnosability.
        print("RAID_QA: joinChannel — channel=\(channelName), asHost=\(asHost), tokenEmpty=\(token.isEmpty), publishCamera=\(asHost), role=\(asHost ? "broadcaster" : "audience")")

        agoraKit.joinChannel(
            byToken: token,
            channelId: channelName,
            uid: 0,
            mediaOptions: options
        ) { [weak self] (channel, uid, elapsed) in
            print("RAID_QA: joinChannel callback — channel=\(channel), uid=\(uid), asHost=\(asHost)")
            print("✅ Joined channel: \(channel), UID: \(uid)")
            DispatchQueue.main.async {
                self?.isJoined = true
                if asHost {
                    self?.setupLocalVideo()
                }
                // For viewers we do NOT call setupRemoteVideo here —
                // we wait for didJoinedOfUid which delivers the real uid.
            }
        }
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
        // Basecamp #9958806477 ROUND 3 (2026-06-03): PRIMARY BUG FIX.
        // Round 2 introduced a regression: it set `remoteUserId = nil` at the top
        // of this function and then immediately read `remoteUserId ?? 0` for the
        // clear-canvas call. That expression ALWAYS evaluates to 0, so the canvas for
        // the real seller uid was NEVER cleared. The Agora engine kept a stale canvas
        // (uid=<sellerUID> → old detached UIView) registered across sessions.
        // When the next show joined and didJoinedOfUid fired with the same or a new
        // seller uid, Agora SDK 4.6.0 would not properly transition its internal
        // render pipeline away from the stale canvas → black video.
        //
        // FIX: capture remoteUserId BEFORE clearing it, then use the captured value.
        let lastRemoteUid = remoteUserId  // capture BEFORE nil-assignment
        remoteUserId = nil
        isJoined = false

        // Stop local video preview.
        agoraKit?.stopPreview()

        // Explicitly unbind the remote canvas with the REAL seller uid (not 0).
        // This tells the engine to stop rendering to our UIView, preventing the stale
        // canvas from blocking the next session’s canvas binding.
        if let uid = lastRemoteUid, uid != 0 {
            let clearCanvas = AgoraRtcVideoCanvas()
            clearCanvas.uid = uid
            clearCanvas.view = nil
            agoraKit?.setupRemoteVideo(clearCanvas)
            print("🧹 Cleared Agora canvas for uid \(uid) on leave")
        }
        // Also clear any uid=0 canvas that was registered (from old setupRemoteVideoCanvas calls).
        let clearZero = AgoraRtcVideoCanvas()
        clearZero.uid = 0
        clearZero.view = nil
        agoraKit?.setupRemoteVideo(clearZero)

        // Leave the channel.
        agoraKit?.leaveChannel(nil)
        // Basecamp #9958806477 (round 1, 2026-06-03): DO NOT call AgoraRtcEngineKit.destroy().
        // The engine is a PROCESS-WIDE singleton; destroying it tears it down for all
        // subsequent joins within the same app lifecycle. Keep it alive for re-join.
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
    
    // MARK: - Setup Remote Video
    // Binds the Agora engine’s render canvas for `uid` to THIS instance’s
    // remoteVideoView (the UIView that is live in the UIKit hierarchy via
    // VideoContainerView). Must be called with the real remote uid (not 0).
    // Also explicitly un-mutes the remote video subscription so frames flow.
    private func setupRemoteVideo(uid: UInt) {
        guard let agoraKit = agoraKit else { return }
        // Guard against uid=0: in Agora SDK 4.x, setupRemoteVideo(uid=0) creates a
        // canvas for the literal uid 0, not "any remote user". Binding to uid 0 is a
        // no-op for real sellers and can confuse the engine’s canvas registry.
        guard uid != 0 else {
            print("⚠️ setupRemoteVideo called with uid=0 — skipping (not a valid remote uid)")
            return
        }

        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)

        // Explicitly un-mute the remote video stream for this uid.
        // If a prior session left the engine with a muted subscription, this
        // ensures frames actually flow to the newly bound canvas.
        agoraKit.muteRemoteVideoStream(uid, mute: false)

        print("RAID_QA: setupRemoteVideo — uid=\(uid), view=\(remoteVideoView)")
        print("✅ Remote video canvas bound: uid=\(uid), view=\(remoteVideoView)")
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
