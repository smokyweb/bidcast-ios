//
//  VideoPlayerView.swift
//  BidCast
//
//  Created by JamTech on 01/12/25.
//

import SwiftUI
import AVKit
import AVFoundation

// MARK: - Video Player Screen
struct VideoPlayerScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: VideoPlayerViewModel
    
   
    let videoTitle: String
    
    @Binding var videoURL: String

       init(
           videoURL: Binding<String>,
           videoTitle: String = "Show Clip"
       ) {
           self._videoURL = videoURL
           self.videoTitle = videoTitle
           _viewModel = StateObject(
               wrappedValue: VideoPlayerViewModel(urlString: videoURL.wrappedValue)
           )
       }
    
    var body: some View {
        VStack(spacing: 0) {

            // Header
            VideoPlayerHeader(
                title: videoTitle,
                onBack: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .background(Color.white)
            .zIndex(1)

            // Main Content
            VStack(spacing: 0) {

                // Fullscreen Player
                ZStack {
                    Color.black

                    VideoPlayerView(player: viewModel.player)
                        .ignoresSafeArea(edges: .bottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Controls BELOW player
                if !viewModel.isDownloading {
                    VideoControlsView(viewModel: viewModel)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.black)
                }

                // Downloading state
                if viewModel.isDownloading {
                    VStack(spacing: 16) {
                        ProgressView(value: viewModel.downloadProgress)
                            .progressViewStyle(
                                LinearProgressViewStyle(tint: .white)
                            )

                        Text("Downloading... \(Int(viewModel.downloadProgress * 100))%")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black)
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color.black)
        .onAppear {
            viewModel.setupPlayer(url: videoURL)
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }

}

// MARK: - Video Player Header
struct VideoPlayerHeader: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
            }
            
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Video Player View (AVPlayer Wrapper)
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.player = player
    }
}

// MARK: - PlayerView
final class PlayerView: UIView {

    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspect
    }
}


// MARK: - Video Controls View
struct VideoControlsView: View {
    @ObservedObject var viewModel: VideoPlayerViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress Bar
            VideoProgressBar(
                currentTime: viewModel.currentTime,
                duration: viewModel.duration,
                onSeek: { newTime in
                    viewModel.seek(to: newTime)
                }
            )
            
            // Time Labels
            HStack {
                Text(formatTime(viewModel.currentTime))
                    .font(.custom("Poppins-Medium", size: 13))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(formatTime(viewModel.duration))
                    .font(.custom("Poppins-Medium", size: 13))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Playback Controls
            HStack(spacing: 40) {
                // Backward 15s
                ControlButton(
                    systemName: "gobackward.15",
                    size: 32,
                    action: {
                        viewModel.skipBackward()
                    }
                )
                
                // Play/Pause
                ControlButton(
                    systemName: viewModel.isPlaying ? "pause.fill" : "play.fill",
                    size: 50,
                    isPrimary: true,
                    action: {
                        viewModel.togglePlayPause()
                    }
                )
                
                // Forward 15s
                ControlButton(
                    systemName: "goforward.15",
                    size: 32,
                    action: {
                        viewModel.skipForward()
                    }
                )
                
                // QA #23 — fast-forward speed toggle (1x → 1.5x → 2x)
                Button(action: { viewModel.cyclePlaybackRate() }) {
                    Text(playbackRateLabel(viewModel.playbackRate))
                        .font(.custom("Poppins-Bold", size: 13))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 32)
                        .background(
                            Capsule().fill(Color.white.opacity(0.18))
                        )
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 10)
        }
    }
    
    private func playbackRateLabel(_ rate: Float) -> String {
        // 1.0 -> "1x", 1.5 -> "1.5x", 2.0 -> "2x"
        if rate == 1.0 { return "1x" }
        if rate == 2.0 { return "2x" }
        // Drop trailing zero for fractional rates (e.g. 1.5 not 1.50).
        let trimmed = String(format: "%g", rate)
        return "\(trimmed)x"
    }
    
    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite else { return "00:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Control Button
struct ControlButton: View {
    let systemName: String
    var size: CGFloat = 40
    var isPrimary: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            ZStack {
                if isPrimary {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size + 20, height: size + 20)
                        .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 5)
                }
                
                Image(systemName: systemName)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Video Progress Bar
struct VideoProgressBar: View {
    let currentTime: Double
    let duration: Double
    let onSeek: (Double) -> Void
    
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return isDragging ? dragValue : currentTime / duration
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 6)
                
                // Progress Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color.defaultTheme, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: isDragging ? 20 : 16, height: isDragging ? 20 : 16)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: geometry.size.width * CGFloat(progress) - (isDragging ? 10 : 8))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let newValue = min(max(0, value.location.x / geometry.size.width), 1)
                        dragValue = newValue
                    }
                    .onEnded { value in
                        isDragging = false
                        let newValue = min(max(0, value.location.x / geometry.size.width), 1)
                        onSeek(newValue * duration)
                    }
            )
        }
        .frame(height: 20)
    }
}

class VideoPlayerViewModel: ObservableObject {
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    // QA #23 — fast-forward speed cycle: 1x → 1.5x → 2x → 1x.
    @Published var playbackRate: Float = 1.0
    
    let originalURL: String
    let downloader = VideoDownloader()
    
    var player = AVPlayer()
    private var timeObserver: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    init(urlString: String) {
        self.originalURL = urlString
    }
    
    func setupPlayer(url : String) {
        let localURL = localFileURL()
        let videoUrl = URL(string: url) ?? URL(fileURLWithPath: "")
        if  !url.isEmpty{
            // play local file
            playVideo(url: videoUrl)
        } else {
            downloadVideo()
        }
    }
    
    private func downloadVideo() {
        isDownloading = true
        
        downloader.downloadVideo(from: originalURL) { [weak self] fileURL in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isDownloading = false
                
                if let fileURL = fileURL {
                    self.playVideo(url: fileURL)
                }
            }
        }
        
        downloader.$progress.assign(to: &$downloadProgress)
    }
    
    private func localFileURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("downloadedVideo.mp4")
    }
    
    private func playVideo(url: URL) {
        
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        
        observePlayer(item: item)
        player.play()
        isPlaying = true
    }
    
    private func observePlayer(item: AVPlayerItem) {
        
        // Remove old observer
          if let observer = timeObserver {
              player.removeTimeObserver(observer)
              timeObserver = nil
          }

          let interval = CMTime(seconds: 0.2, preferredTimescale: 600)
          timeObserver = player.addPeriodicTimeObserver(
              forInterval: interval,
              queue: .main
          ) { [weak self] time in
              self?.currentTime = time.seconds
          }

          playerItemStatusObserver = item.observe(\.duration, options: [.new]) { [weak self] item, _ in
              DispatchQueue.main.async {
                  self?.duration = item.duration.seconds
              }
          }
    }
    
    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            // QA #23 — setting player.rate also starts playback at the chosen rate.
            player.rate = playbackRate
        }
        isPlaying.toggle()
    }

    // QA #23 — cycle fast-forward speed; only push rate to the player if it is currently playing,
    // otherwise we'd resume playback unintentionally.
    func cyclePlaybackRate() {
        switch playbackRate {
        case 1.0:  playbackRate = 1.5
        case 1.5:  playbackRate = 2.0
        default:   playbackRate = 1.0
        }
        if isPlaying { player.rate = playbackRate }
    }
    
    func skipForward() {
        let newTime = min(currentTime + 15, duration)
        seek(to: newTime)
    }
    
    func skipBackward() {
        let newTime = max(currentTime - 15, 0)
        seek(to: newTime)
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: cmTime)
    }
    
    func cleanup() {
        player.pause()

          if let observer = timeObserver {
              player.removeTimeObserver(observer)
              timeObserver = nil
          }

          playerItemStatusObserver?.invalidate()
          playerItemStatusObserver = nil
    }
    
    deinit {
        cleanup()
    }

}


// MARK: - Preview
//struct VideoPlayerScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPlayerScreen(
//            videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
//            videoTitle: "Sample Video"
//        )
//    }
//}

import Foundation

class VideoDownloader: NSObject, URLSessionDownloadDelegate, ObservableObject {
    
    @Published var progress: Double = 0
    var completionHandler: ((URL?) -> Void)?
    
    func downloadVideo(from urlString: String, completion: @escaping (URL?) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        self.completionHandler = completion
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    // progress
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        DispatchQueue.main.async {
            self.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        }
    }
    
    // completed download
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        let fileName = "downloadedVideo.mp4"
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destURL = docsURL.appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: destURL)
        
        do {
            try FileManager.default.moveItem(at: location, to: destURL)
            DispatchQueue.main.async {
                self.completionHandler?(destURL)
            }
        } catch {
            DispatchQueue.main.async {
                self.completionHandler?(nil)
            }
        }
    }
}
