//
//  AgoraManager.swift
//  BidCast
//
//  Created by Vivek_JAM-E_328 on 28/10/25.
//

import Foundation
import AgoraRtcKit

/*
 App ID : 6a0ab77ee15943df94524201d6c93877
 Channel Name : room1
 Token : 007eJxTYHgSe7qis6f/s9mNyvXfu7QF2S/ZVm7ISrVXu6ljZKJabqvAYJZokJhkbp6aamhqaWKckmZpYmpkYmRgmGKWbGlsYW6+8S1jZkMgI0O7rzUTIwMEgvisDEX5+bmGDAwAMUEd9g==
 */

// MARK: - Agora Manager (for Live Streaming)
class AgoraManager: NSObject, ObservableObject {
    
    // MARK: - Agora Credentials
    struct AgoraCred {
        static var appId = "6a0ab77ee15943df94524201d6c93877"
//        static var channelName = "room1"
//        static var token  = "007eJxTYHgSe7qis6f/s9mNyvXfu7QF2S/ZVm7ISrVXu6ljZKJabqvAYJZokJhkbp6aamhqaWKckmZpYmpkYmRgmGKWbGlsYW6+8S1jZkMgI0O7rzUTIwMEgvisDEX5+bmGDAwAMUEd9g=="
    }
    
    // MARK: - Properties
    private var agoraKit: AgoraRtcEngineKit?
    @Published var isJoined: Bool = false
    @Published var remoteUserId: UInt?
    
    // Video Views (bridged for SwiftUI)
    @Published var localVideoView = UIView()
    @Published var remoteVideoView = UIView()
    
    @Published private(set) var isAudioMuted = false
//    @Published private(set) var isVideoMuted = false
    
    @Published var isFrontCamera = true
    
    var isHost: Bool = false
    
    // MARK: - Designated Initializer
    init(asHost: Bool) {
        self.isHost = asHost
        super.init()
        initializeAgoraEngine()
//        if asHost {
//            self.setupLocalVideo()
//        }
    }
    
    // MARK: - Convenience Initializer (optional)
    convenience override init() {
        self.init(asHost: false)
    }
    
    func initializeAgoraEngine(asHost: Bool = false) {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AgoraCred.appId, delegate: self)
        //step 1 -> Use Agora’s “Real-Time Interactive Mode”
        agoraKit?.setChannelProfile(.liveBroadcasting)
        agoraKit?.setParameters("{\"rtc.enable_low_latency_mode\":true}")
        agoraKit?.setParameters("{\"che.audio.live_for_comm\":true}")
        //step 2 -> Disable or Reduce Hardware Encoding Delay
        agoraKit?.setParameters("{\"che.video.hardware_encoding\":false}")
        //step 3 -> Set Ultra Low Latency Mode Explicitly
        agoraKit?.setClientRole(.broadcaster)
        agoraKit?.setParameters("{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}")
        
        agoraKit?.enableVideo()
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
            print("Joined channel: \(channel), UID: \(uid)")
            DispatchQueue.main.async {
                self?.isJoined = true
                if asHost {
                    self?.setupLocalVideo()
                }
            }
        }
    }
    
    func switchCamera() {
        isFrontCamera.toggle()
        agoraKit?.switchCamera()
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
        // Leave the channel and release session-related resources
        agoraKit?.leaveChannel(nil)
        // Release all resources used by the Agora SDK
        AgoraRtcEngineKit.destroy()
    }
    
    func setupLocalVideo() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localVideoView
        // Set the local video view
        agoraKit?.setupLocalVideo(videoCanvas)
        // Enable the video module
        agoraKit?.enableVideo()
//
        // Start the local video preview
        agoraKit?.startPreview()
    }
    
    // MARK: - Setup Remote Video
    private func setupRemoteVideo(uid: UInt) {
        guard let agoraKit = agoraKit else { return }
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }
}

// MARK: - Agora Delegate
extension AgoraManager: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        DispatchQueue.main.async {
            print("Remote user joined: \(uid)")
            self.remoteUserId = uid
            self.setupRemoteVideo(uid: uid)
            
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.renderMode = .hidden
            videoCanvas.view = self.remoteVideoView
            self.agoraKit?.setupRemoteVideo(videoCanvas)
            
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        DispatchQueue.main.async {
            print("Remote user left: \(uid)")
            if self.remoteUserId == uid {
                self.remoteUserId = nil
                self.remoteVideoView.removeFromSuperview()
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        DispatchQueue.main.async {
            print("Left channel")
            self.isJoined = false
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("error: \(errorCode)")
    }
}



