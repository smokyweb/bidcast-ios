//
//  DolbyManager.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/09/25.
//
//
//  MilliCastManager.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/09/25.
//

import Foundation
import AVFoundation
import MillicastSDK

@MainActor
class PublisherViewModel: ObservableObject {
    var renderer: MCVideoRenderer
    var publisher = MCPublisher()
    private var currentVideoSource: MCVideoSource?
    private var videoSources: [MCVideoSource] = []
    
    var videoTrack: MCVideoTrack?
    var audioTrack: MCAudioTrack?
    
    @Published private(set) var isPublishing = false
    @Published private(set) var isAudioMuted = false
    @Published private(set) var isVideoMuted = false
    
    init(renderer: MCVideoRenderer) {
        self.renderer = renderer
    }
    
    // MARK: - Preview
    func startPreview() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
        
        videoSources = MCMedia.getVideoSources()
        guard let videoSource = videoSources.last else {
            throw NSError(domain: "PreviewError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No video sources available"])
        }
        currentVideoSource = videoSource
        
        if let cap = videoSource.getCapabilities().first(where: { $0.width <= 1920 && $0.height <= 1080 }) {
            videoSource.setCapability(cap)
        }
        guard let track = videoSource.startCapture() as? MCVideoTrack else {
            throw NSError(domain: "PreviewError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to start video capture"])
        }
        track.add(renderer)
        self.videoTrack = track
    }
    
    // MARK: - Publish
    func publish(streamName: String) async throws {
        guard let videoTrack = self.videoTrack else {
            throw NSError(domain: "PublishError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Video track not ready"])
        }
        let audioSources = MCMedia.getAudioSources()
        guard let audioSource = audioSources.first,
              let audioTrack = audioSource.startCapture() as? MCAudioTrack else {
            throw NSError(domain: "PublishError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Audio source not available"])
        }
        self.audioTrack = audioTrack
        
        let creds = MCPublisherCredentials()
        creds.streamName = streamName
        creds.token = "703fbd09a9d532838e515014954f259cf1503d07438a70aef3e922df3aff3bcd"
        creds.apiUrl = "https://director.millicast.com/api/director/publish"
        try await publisher.setCredentials(creds)
        
        await publisher.addTrack(with: videoTrack)
        await publisher.addTrack(with: audioTrack)
        try await publisher.connect()
        try await publisher.publish()
        
        isPublishing = true
    }
    
    func unpublish() async throws {
        try await publisher.unpublish()
        try await publisher.disconnect()
        videoTrack = nil
        audioTrack = nil
        isPublishing = false
    }
    
    // MARK: - Controls
    func switchCamera() {
        guard !videoSources.isEmpty else { return }
        if let current = currentVideoSource,
           let index = videoSources.firstIndex(of: current) {
            let nextIndex = (index + 1) % videoSources.count
            current.stopCapture()
            currentVideoSource = videoSources[nextIndex]
            if let newTrack = currentVideoSource?.startCapture() as? MCVideoTrack {
                videoTrack?.remove(renderer)
                newTrack.add(renderer)
                videoTrack = newTrack
            }
        }
    }
    
    func toggleAudioMute() {
        guard let audioTrack = audioTrack else { return }
        isAudioMuted.toggle()
        if !isAudioMuted{
            audioTrack.setVolume(1)
        }else{
            audioTrack.setVolume(0)
        }
    }
}
