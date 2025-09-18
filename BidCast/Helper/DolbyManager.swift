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
    
    // This renderer is the adapter that receives frames from the video track
    // and provides it to an attached view.
     var renderer: MCVideoRenderer
     var publisher: MCPublisher = .init()

     var videoTrack: MCVideoTrack?
     var audioTrack: MCAudioTrack?
    @Published private(set) var isPublishing: Bool = false

    init(renderer: MCVideoRenderer) {
        self.renderer = renderer
    }
    
    func publish() async throws {
        // 1. Configure the audio session for recording and playback
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
        
        // 2. Set the credentials
        let credentials = MCPublisherCredentials()
        credentials.token = "703fbd09a9d532838e515014954f259cf1503d07438a70aef3e922df3aff3bcd"
        credentials.streamName = ".*"
//        credentials.streamName = "256ee8a979b44a309c9e94a65f7de614"
        credentials.apiUrl = "https://director.millicast.com/api/director/publish"
        try await publisher.setCredentials(credentials)
        
        // 3. Capture the first video/audio source available.
        // IMPORTANT: Make sure your app provides camera/mic permissions.
        // Otherwise, the startCapture call will crash.
        let videoSources = MCMedia.getVideoSources()
        guard let videoSource = videoSources.last else {
            fatalError("No Video sources available")
        }
        
        // 3.a (Optional) Select the capabilities of the video
        // source (before attempting to capture)
//        for capability in videoSource.getCapabilities() {
//            if capability.width < 4032 && capability.height < 3024 {
//                videoSource.setCapability(capability)
//                break
//            }
//        }
        if let cap = videoSource.getCapabilities()
                  .first(where: { $0.width <= 1920 && $0.height <= 1080 && $0.fps <= 60 }) {
                  videoSource.setCapability(cap)
              }
        guard let videoTrack = videoSource.startCapture() as? MCVideoTrack else {
            fatalError("Could not capture video track")
        }
        
        let audioSources = MCMedia.getAudioSources()
        guard let audioSource = audioSources.first,
                let audioTrack = audioSource.startCapture() as? MCAudioTrack else {
            fatalError("No Audio sources available")
        }
        
        // 3.b Attach a renderer to display the local video track
        videoTrack.add(self.renderer)
        
        // 3.c Keep a reference to the tracks. Otherwise,
        // they will be destroyed and the feed won't work.
        self.videoTrack = videoTrack
        self.audioTrack = audioTrack
        
        // 3.d Attach those tracks to the publisher for publishing.
        await publisher.addTrack(with: videoTrack)
        await publisher.addTrack(with: audioTrack)
        
        // 4. connect and publish
        try await publisher.connect()
        try await publisher.publish()
        
        isPublishing = true
    }
    
    func unpublish() async throws {
        // 1. unpublish
        try await publisher.unpublish()

        // 2. disconnect the websocket connection with the millicast server
        try await publisher.disconnect()

        videoTrack = nil
        audioTrack = nil
        isPublishing = false
    }
}
