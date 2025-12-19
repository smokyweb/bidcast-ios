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
    
    let videoURL: String
    let videoTitle: String
    
    init(videoURL: String, videoTitle: String = "Video Receipt") {
        self.videoURL = videoURL
        self.videoTitle = videoTitle
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(urlString: videoURL))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VideoPlayerHeader(
                    title: videoTitle,
                    onBack: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
                
                Spacer()
                
                // Video Player Container
                if viewModel.isDownloading {
                    VStack(spacing: 20) {
                        ProgressView(value: viewModel.downloadProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .padding(.horizontal)
                        
                        Text("Downloading... \(Int(viewModel.downloadProgress * 100))%")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else {
                    VStack(spacing: 20) {
                        // Video Display
                        VideoPlayerView(player: viewModel.player)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(color: .white.opacity(0.1), radius: 20, x: 0, y: 10)
                            .padding(.horizontal, 16)
                        
                        // Controls
                        VideoControlsView(viewModel: viewModel)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }

              
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.setupPlayer()
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
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.5))
    }
}

// MARK: - Video Player View (AVPlayer Wrapper)
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        
        context.coordinator.playerLayer = playerLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = context.coordinator.playerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var playerLayer: AVPlayerLayer?
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
            }
            .padding(.vertical, 10)
        }
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
                                colors: [Color.blue, Color.blue.opacity(0.8)],
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
                            colors: [Color.blue, Color.cyan],
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
    
    let originalURL: String
    let downloader = VideoDownloader()
    
    var player = AVPlayer()
    private var timeObserver: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    init(urlString: String) {
        self.originalURL = urlString
    }
    
    func setupPlayer() {
        let localURL = localFileURL()
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            // play local file
            playVideo(url: localURL)
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
    }
    
    private func observePlayer(item: AVPlayerItem) {
        
        let interval = CMTime(seconds: 0.2, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
        
        item.observe(\.duration, options: [.new]) { item, _ in
            DispatchQueue.main.async {
                self.duration = item.duration.seconds
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying { player.pause() }
        else { player.play() }
        isPlaying.toggle()
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
        }
        playerItemStatusObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        cleanup()
    }

}


// MARK: - Preview
struct VideoPlayerScreen_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerScreen(
            videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            videoTitle: "Sample Video"
        )
    }
}

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
//
//
//import SwiftUI
//import AVKit
//import Combine
//
//// MARK: - Video Player View with Custom Controls
//struct VideoPlayerScreen: View {
//    @Binding var videoURL: String
//    @StateObject private  var viewModel: VideoPlayerViewModel = VideoPlayerViewModel()
//    @Environment(\.dismiss) private var dismiss
//    
//    
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        Image(systemName: "xmark")
//                            .font(.title3)
//                            .foregroundColor(.white)
//                            .padding(8)
//                            .background(Color.black.opacity(0.5))
//                            .clipShape(Circle())
//                    }
//                    
//                    Spacer()
//                }
//                .padding()
//                .zIndex(1)
//                
//                Spacer()
//                
//                // Video Player
//                ZStack {
//                    Color.black
//                    
//                    if viewModel.isDownloading {
//                        // Download Progress
//                        VStack(spacing: 24) {
//                            ProgressView(value: viewModel.downloadProgress, total: 1.0)
//                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
//                                .scaleEffect(x: 1, y: 2, anchor: .center)
//                                .frame(width: 200)
//                            
//                            Text("Downloading...")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                            
//                            Text("\(Int(viewModel.downloadProgress * 100))%")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.blue)
//                        }
//                        .padding()
//                    } else if viewModel.isLoading {
//                        // Loading
//                        VStack(spacing: 20) {
//                            ProgressView()
//                                .scaleEffect(2)
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            
//                            Text("Loading video...")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                        }
//                    } else if let errorMessage = viewModel.errorMessage {
//                        // Error
//                        VStack(spacing: 16) {
//                            Image(systemName: "exclamationmark.triangle.fill")
//                                .font(.system(size: 50))
//                                .foregroundColor(.red)
//                            
//                            Text(errorMessage)
//                                .font(.body)
//                                .foregroundColor(.white)
//                                .multilineTextAlignment(.center)
//                                .padding()
//                            
//                            Button(action: {
//                                viewModel.downloadAndPlay()
//                            }) {
//                                Text("Retry")
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 32)
//                                    .padding(.vertical, 12)
//                                    .background(Color.blue)
//                                    .cornerRadius(25)
//                            }
//                        }
//                    } else if let player = viewModel.player {
//                        // Video Player
//                        VideoPlayerLayer(player: player)
//                            .aspectRatio(16/9, contentMode: .fit)
//                    }
//                }
//                
//                // Custom Controls
//                if viewModel.player != nil && !viewModel.isDownloading && !viewModel.isLoading {
//                    VideoControlsView(viewModel: viewModel)
//                        .padding()
//                        .background(
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
//                                startPoint: .bottom,
//                                endPoint: .top
//                            )
//                        )
//                }
//                
//                Spacer()
//            }
//        }
//        .onAppear {
//            viewModel.videoURLString = videoURL
//            viewModel.downloadAndPlay()
//        }
//        .onDisappear {
//            viewModel.cleanup()
//        }
//    }
//}
//
//// MARK: - Video Player Layer
//struct VideoPlayerLayer: UIViewRepresentable {
//    let player: AVPlayer
//    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.videoGravity = .resizeAspect
//        view.layer.addSublayer(playerLayer)
//        context.coordinator.playerLayer = playerLayer
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        context.coordinator.playerLayer?.frame = uiView.bounds
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//    
//    class Coordinator {
//        var playerLayer: AVPlayerLayer?
//    }
//}
//
//// MARK: - Custom Controls View
//struct VideoControlsView: View {
//    @ObservedObject var viewModel: VideoPlayerViewModel
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            // Progress Bar
//            HStack(spacing: 8) {
//                Text(timeString(from: viewModel.currentTime))
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .monospacedDigit()
//                
//                Slider(value: $viewModel.sliderValue, in: 0...1, onEditingChanged: { editing in
//                    if !editing {
//                        viewModel.seek(to: viewModel.sliderValue)
//                    }
//                })
//                .accentColor(.blue)
//                
//                Text(timeString(from: viewModel.duration))
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .monospacedDigit()
//            }
//            
//            // Control Buttons
//            HStack(spacing: 40) {
//                Button(action: {
//                    viewModel.seekBackward()
//                }) {
//                    Image(systemName: "gobackward.10")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                }
//                
//                Button(action: {
//                    viewModel.togglePlayPause()
//                }) {
//                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
//                        .font(.title)
//                        .foregroundColor(.white)
//                }
//                
//                Button(action: {
//                    viewModel.seekForward()
//                }) {
//                    Image(systemName: "goforward.10")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                }
//            }
//        }
//    }
//    
//    private func timeString(from seconds: Double) -> String {
//        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
//        let totalSeconds = Int(seconds)
//        let minutes = totalSeconds / 60
//        let secs = totalSeconds % 60
//        return String(format: "%d:%02d", minutes, secs)
//    }
//}
//
//// MARK: - View Model
//class VideoPlayerViewModel: ObservableObject {
//    @Published var player: AVPlayer?
//    @Published var isDownloading = false
//    @Published var isLoading = false
//    @Published var downloadProgress: Double = 0.0
//    @Published var errorMessage: String?
//    @Published var isPlaying = false
//    @Published var currentTime: Double = 0
//    @Published var duration: Double = 0
//    @Published var sliderValue: Double = 0
//    
//    var videoURLString: String = ""
//    private var localVideoURL: URL?
//    private var timeObserver: Any?
//    private var downloadTask: URLSessionDownloadTask?
//    
//    func downloadAndPlay() {
//        guard let url = URL(string: videoURLString) else {
//            errorMessage = "Invalid video URL"
//            return
//        }
//        
//        errorMessage = nil
//        isDownloading = true
//        downloadProgress = 0.0
//        
//        // Create download task
//        let session = URLSession(configuration: .default, delegate: DownloadDelegate(viewModel: self), delegateQueue: nil)
//        downloadTask = session.downloadTask(with: url)
//        downloadTask?.resume()
//    }
//    
//    func videoDownloaded(at location: URL) {
//        DispatchQueue.main.async {
//            self.isDownloading = false
//            self.isLoading = true
//            
//            // Move file to documents directory
//            let fileManager = FileManager.default
//            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let destinationURL = documentsPath.appendingPathComponent("downloaded_video.mp4")
//            
//            // Remove old file if exists
//            try? fileManager.removeItem(at: destinationURL)
//            
//            do {
//                try fileManager.moveItem(at: location, to: destinationURL)
//                self.localVideoURL = destinationURL
//                self.setupPlayer(with: destinationURL)
//            } catch {
//                self.errorMessage = "Failed to save video: \(error.localizedDescription)"
//                self.isLoading = false
//            }
//        }
//    }
//    
//    func downloadFailed(with error: Error) {
//        DispatchQueue.main.async {
//            self.isDownloading = false
//            self.errorMessage = "Download failed: \(error.localizedDescription)"
//        }
//    }
//    
//    private func setupPlayer(with url: URL) {
//        let playerItem = AVPlayerItem(url: url)
//        player = AVPlayer(playerItem: playerItem)
//        
//        // Observe player status
//        playerItem.publisher(for: \.status)
//            .sink { [weak self] status in
//                DispatchQueue.main.async {
//                    if status == .readyToPlay {
//                        self?.isLoading = false
//                        self?.duration = playerItem.duration.seconds
//                        self?.player?.play()
//                        self?.isPlaying = true
//                        self?.addTimeObserver()
//                    } else if status == .failed {
//                        self?.errorMessage = "Failed to load video"
//                        self?.isLoading = false
//                    }
//                }
//            }
//            .store(in: &cancellables)
//    }
//    
//    private var cancellables = Set<AnyCancellable>()
//    
//    private func addTimeObserver() {
//        guard let player = player else { return }
//        
//        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
//            guard let self = self else { return }
//            self.currentTime = time.seconds
//            if self.duration > 0 {
//                self.sliderValue = time.seconds / self.duration
//            }
//        }
//    }
//    
//    func togglePlayPause() {
//        guard let player = player else { return }
//        
//        if isPlaying {
//            player.pause()
//        } else {
//            player.play()
//        }
//        isPlaying.toggle()
//    }
//    
//    func seek(to value: Double) {
//        guard let player = player else { return }
//        let targetTime = duration * value
//        let time = CMTime(seconds: targetTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        player.seek(to: time)
//    }
//    
//    func seekForward() {
//        guard let player = player else { return }
//        let currentTime = player.currentTime()
//        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
//        player.seek(to: newTime)
//    }
//    
//    func seekBackward() {
//        guard let player = player else { return }
//        let currentTime = player.currentTime()
//        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
//        player.seek(to: newTime)
//    }
//    
//    func cleanup() {
//        downloadTask?.cancel()
//        if let observer = timeObserver {
//            player?.removeTimeObserver(observer)
//        }
//        player?.pause()
//        player = nil
//        cancellables.removeAll()
//    }
//    
//    deinit {
//        cleanup()
//    }
//}
//
//// MARK: - Download Delegate
//class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
//    weak var viewModel: VideoPlayerViewModel?
//    
//    init(viewModel: VideoPlayerViewModel) {
//        self.viewModel = viewModel
//    }
//    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        viewModel?.videoDownloaded(at: location)
//    }
//    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
//        DispatchQueue.main.async {
//            self.viewModel?.downloadProgress = progress
//        }
//    }
//    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        if let error = error {
//            viewModel?.downloadFailed(with: error)
//        }
//    }
//}
//
//// MARK: - Caller View Example
////struct CallerView: View {
////    @State private var showPlayer = false
////    
////    var body: some View {
////        NavigationView {
////            VStack(spacing: 20) {
////                Text("Video Gallery")
////                    .font(.largeTitle)
////                    .fontWeight(.bold)
////                
////                Button(action: {
////                    showPlayer = true
////                }) {
////                    HStack {
////                        Image(systemName: "play.circle.fill")
////                            .font(.title)
////                            .foregroundColor(.blue)
////                        
////                        VStack(alignment: .leading) {
////                            Text("Sample Video")
////                                .font(.headline)
////                                .foregroundColor(.primary)
////                            
////                            Text("Big Buck Bunny")
////                                .font(.caption)
////                                .foregroundColor(.gray)
////                        }
////                        
////                        Spacer()
////                        
////                        Image(systemName: "arrow.down.circle")
////                            .foregroundColor(.gray)
////                    }
////                    .padding()
////                    .background(Color.gray.opacity(0.1))
////                    .cornerRadius(12)
////                }
////                .padding(.horizontal)
////            }
////            .padding()
////        }
////        .fullScreenCover(isPresented: $showPlayer) {
////            VideoPlayerScreen(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
////        }
////    }
////}
//
