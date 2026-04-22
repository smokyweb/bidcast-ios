//
//  BidcastAgoraEngine.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 2, milestone 2:
//  Thin wrapper around AgoraRtcKit that mirrors the Android Agora glue in
//  `AgoraPublisherActivity.kt` / `WatchStreamFragment.kt` just enough to let
//  iOS host and viewer screens join a channel, render local/remote video,
//  and leave cleanly.
//
//  Intentional scope: this is MVP scaffolding, not feature-complete. Cover
//  join/leave + render. Full publisher controls (switch camera, mic mute,
//  resolution profile) land in later milestones.
//

import Foundation
import UIKit
#if canImport(AgoraRtcKit)
import AgoraRtcKit
#endif

public protocol BidcastAgoraEngineDelegate: AnyObject {
    func agoraJoined(channel: String, uid: UInt)
    func agoraLeft(channel: String)
    func agoraRemoteJoined(uid: UInt)
    func agoraRemoteLeft(uid: UInt)
    func agoraError(_ error: String)
    /// Optional: Agora connection state transitions (reconnecting, failed, etc.)
    /// Has a default empty implementation so existing conformers don't break.
    func agoraConnectionStateChanged(state: Int, reason: Int)
}

public extension BidcastAgoraEngineDelegate {
    func agoraConnectionStateChanged(state: Int, reason: Int) {}
}

public enum BidcastAgoraRole {
    case broadcaster
    case audience
}

/// iOS mirror of the Android Agora glue. Singleton because Android also
/// treats the RTC engine as app-wide.
///
/// Build note: every `AgoraRtcKit`-typed reference is wrapped in
/// `#if canImport(AgoraRtcKit)` so the file compiles before CocoaPods
/// installs the pod. When the pod is absent all public methods are
/// no-ops that surface a friendly error via the delegate.
public final class BidcastAgoraEngine: NSObject {

    public static let shared = BidcastAgoraEngine()

    // MARK: State
    #if canImport(AgoraRtcKit)
    private var engine: AgoraRtcEngineKit?
    #endif
    private var currentAppId: String = ""
    private(set) public var currentChannel: String = ""
    private(set) public var currentUid: UInt = 0
    public weak var delegate: BidcastAgoraEngineDelegate?

    private override init() { super.init() }

    // MARK: Lifecycle

    public func configure(appId: String) {
        guard !appId.isEmpty else {
            #if DEBUG
            print("[BidcastAgora] configure called with empty appId")
            #endif
            return
        }
        #if canImport(AgoraRtcKit)
        if engine == nil || currentAppId != appId {
            currentAppId = appId
            engine = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        }
        #else
        currentAppId = appId
        #if DEBUG
        print("[BidcastAgora] AgoraRtcKit pod missing; configure is a no-op.")
        #endif
        #endif
    }

    public func joinChannel(
        token: String,
        channel: String,
        uid: UInt,
        role: BidcastAgoraRole,
        localVideoView: UIView?
    ) {
        #if canImport(AgoraRtcKit)
        guard let engine = engine else {
            delegate?.agoraError("Agora not configured. Call configure(appId:) first.")
            return
        }
        engine.setChannelProfile(.liveBroadcasting)
        engine.setClientRole(role == .broadcaster ? .broadcaster : .audience)

        if role == .broadcaster {
            engine.enableVideo()
            engine.enableAudio()

            if let localVideoView = localVideoView {
                let canvas = AgoraRtcVideoCanvas()
                canvas.uid = uid
                canvas.view = localVideoView
                canvas.renderMode = .hidden
                engine.setupLocalVideo(canvas)
                engine.startPreview()
            }
        } else {
            engine.enableVideo()
            engine.disableAudio()
        }

        let options = AgoraRtcChannelMediaOptions()
        options.clientRoleType = role == .broadcaster ? .broadcaster : .audience
        options.channelProfile = .liveBroadcasting
        options.publishCameraTrack = role == .broadcaster
        options.publishMicrophoneTrack = role == .broadcaster
        options.autoSubscribeAudio = true
        options.autoSubscribeVideo = true

        let result = engine.joinChannel(
            byToken: token,
            channelId: channel,
            uid: uid,
            mediaOptions: options,
            joinSuccess: nil
        )
        if result < 0 {
            delegate?.agoraError("Agora joinChannel failed with code \(result)")
            return
        }
        currentChannel = channel
        currentUid = uid
        #else
        delegate?.agoraError("AgoraRtcKit not linked — run pod install.")
        #endif
    }

    public func bindRemoteView(uid: UInt, into view: UIView) {
        #if canImport(AgoraRtcKit)
        guard let engine = engine else { return }
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = uid
        canvas.view = view
        canvas.renderMode = .hidden
        engine.setupRemoteVideo(canvas)
        #endif
    }

    public func leaveChannel() {
        #if canImport(AgoraRtcKit)
        guard let engine = engine else { return }
        engine.stopPreview()
        engine.leaveChannel(nil)
        let channel = currentChannel
        currentChannel = ""
        currentUid = 0
        delegate?.agoraLeft(channel: channel)
        #endif
    }

    public func setMicrophoneMuted(_ muted: Bool) {
        #if canImport(AgoraRtcKit)
        engine?.muteLocalAudioStream(muted)
        #endif
    }

    public func switchCamera() {
        #if canImport(AgoraRtcKit)
        engine?.switchCamera()
        #endif
    }

    /// Renew the Agora RTC token mid-channel (called when backend emits a
    /// new token before the old one expires). No-op if not currently joined.
    public func renewToken(_ token: String) {
        #if canImport(AgoraRtcKit)
        engine?.renewToken(token)
        #endif
    }
}

#if canImport(AgoraRtcKit)
// MARK: - AgoraRtcEngineDelegate

extension BidcastAgoraEngine: AgoraRtcEngineDelegate {

    public func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        delegate?.agoraJoined(channel: channel, uid: uid)
    }

    public func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        delegate?.agoraRemoteJoined(uid: uid)
    }

    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        delegate?.agoraRemoteLeft(uid: uid)
    }

    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        delegate?.agoraError("Agora error code \(errorCode.rawValue)")
    }

    public func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState, reason: AgoraConnectionChangedReason) {
        delegate?.agoraConnectionStateChanged(state: state.rawValue, reason: reason.rawValue)
    }
}
#endif
