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
    @Published  var isFrontCamera = true
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
//        if let sdCap = videoSource.getCapabilities().first(where: {
//            $0.width <= 854 && $0.height <= 480
//        }) {
//            videoSource.setCapability(sdCap)
//            print("Switched to 480p: \(sdCap.width)x\(sdCap.height) @\(sdCap.fps)fps")
//        }
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
//        creds.token = "703fbd09a9d532838e515014954f259cf1503d07438a70aef3e922df3aff3bcd"
//          creds.token = "7c963b9175d4006b4f57ccc95749252065ddff636b0b4e0fe4b7caebe710e763"
        creds.token = "3355b11d1201319117ffc14cef3f55ffe9c1054651735e8a03b0d09608a4127e"
        creds.apiUrl = "https://director.millicast.com/api/director/publish"
        try await publisher.setCredentials(creds)
        
//        await publisher.addTrack(with: videoTrack)
//        await publisher.addTrack(with: audioTrack)
//        try await publisher.connect()
        //        try await publisher.publish()
        
        await publisher.addTrack(with: videoTrack)
        await publisher.addTrack(with: audioTrack)
        
        let publisherOptions = MCClientOptions()
        publisherOptions.recordStream = true
        
        try await publisher.connect()
        // Wait for the onConnected callback
        try await publisher.publish(with: publisherOptions)
         
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
//    @MainActor
    func switchCamera() {
        guard let current = currentVideoSource, videoSources.count > 1 else { return }

        // Determine next source
        guard let currentIndex = videoSources.firstIndex(where: { $0.getUniqueId() == current.getUniqueId() }) else { return }
        let nextIndex = currentIndex == 0 ? 1 : 0
        let nextSource = videoSources[nextIndex]

      
            current.change(true)
        

        // Update front/back flag
        let name = nextSource.getName() ?? ""
        isFrontCamera = name.lowercased().contains("front")

        print("Camera switched to: \(name)")
        print("Is front camera? \(isFrontCamera)")
    }
    
  
    
    func toggleAudioMute() {
        guard let audioTrack = audioTrack else { return }
        isAudioMuted.toggle()
            audioTrack.enable(!isAudioMuted)
    }
}


@MainActor
class SubscriberViewModel: ObservableObject {
    
    var renderer: MCVideoRenderer
    var subscriber: MCSubscriber?
    
    @Published private(set) var isSubscribed: Bool = false
    private var trackTasks: [Task<Void, Error>] = [] // Keep references to cancel later
    
    init(renderer: MCVideoRenderer) {
        self.renderer = renderer
    }
    
    func subscribe(streamName:String) async throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
        
        let subscriber = MCSubscriber()
        self.subscriber = subscriber
        
        let credentials = MCSubscriberCredentials()
        credentials.accountId = "227tmE"
        credentials.streamName = streamName
        credentials.apiUrl = "https://director.millicast.com/api/director/subscribe"
        
        try await subscriber.setCredentials(credentials)
        
        Task {
            // In a multi view scenario, you might be receiving
            // multiple audio/video tracks, therefore you should
            // use a unique renderer for each video track, i.e. only
            // enabling the video track with a unique renderer.
            for await track in subscriber.rtsRemoteTrackAdded() {
                if let videoTrack = track.asVideo() {
                    try await videoTrack.enable(renderer: renderer)
                    
                    Task {
                        for await activity in videoTrack.activity() {
                            switch activity {
                            case .inactive:
                                // 4a. Optional.
                                // The SDK automatically restores the state of the track when it transitions to `active` from an `inactive` state.
                                // You can optionally disable the video track when it becomes inactive. This step is optional. This gives you control on when to enable the track when it comes back active.
                                try await videoTrack.disable()
                                
                            case .active:
                                // 4b. Optional.
                                // If you choose to disable a track when it became inactive, you have to enable the video track back after it is active again.
                                // At any point in time when you wish to start receive video from the track, call -
                                try await videoTrack.enable(renderer: renderer)
                            }
                        }
                    }
                } else if let audioTrack = track.asAudio() {
                    try await audioTrack.enable()
                    
                    Task {
                        for await activity in audioTrack.activity() {
                            switch activity {
                            case .inactive:
                                // 4c. Optional.
                                // The SDK automatically restores the state of the track when it
                                // transitions to `active` from an `inactive` state.
                                // You can optionally disable the audio track when it becomes inactive,
                                // so that the responsibility is on you to enable the track
                                // when it becomes active.
                                try await audioTrack.disable()
                                
                            case .active:
                                // 4d. Optional.
                                // At any point in time where you wish to play audio from the track
                                try await audioTrack.enable()
                            }
                        }
                    }
                }
            }
        }
        
        // 5. connect and subscribe
        try await subscriber.connect()
        try await subscriber.subscribe()
        
        isSubscribed = true
    }
    
    func unsubscribe() async throws {
        trackTasks.forEach { $0.cancel() }
        trackTasks.removeAll()
        
        try await subscriber?.unsubscribe()
        try await subscriber?.disconnect()
        isSubscribed = false
    }
}
