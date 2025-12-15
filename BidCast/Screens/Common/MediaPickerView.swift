//
//  MediaPickerView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import UIKit
import AlertToast
import SwiftUI
import PhotosUI
import AVKit

// MARK: - Media Item Model
struct MediaItem: Identifiable, Equatable {
    let id = UUID()
    let type: MediaType
    let image: UIImage?
    let videoURL: URL?
    let thumbnailImage: UIImage?
    let urlString: String
    
    enum MediaType {
        case image
        case video
    }
    
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Media Picker View
struct MediaPickerView: View {
    let maxImageCount = 8
    let maxVideoCount = 1
    var title = "Media"
    
    @State private var selectedMedia: [MediaItem] = []
    @State private var showCameraPicker = false
    @State private var showPhotoLibrary = false
    @State private var showPickerOptions = false
    @State private var showVideoPicker = false
    @State private var cameraMediaType: UIImagePickerController.CameraCaptureMode = .photo
    
    @Binding var uploadedImageUrls: [String]
    @Binding var uploadedVideoUrls: [String]
    
    var deletedMediaClosure: ((Int, MediaItem.MediaType) -> Void)? = nil
    
    private var imageCount: Int {
        selectedMedia.filter { $0.type == .image }.count
    }
    
    private var videoCount: Int {
        selectedMedia.filter { $0.type == .video }.count
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                VStack {
                    HStack {
                        if title != "" {
                            Text(title.localized)
                                .font(.custom("Roboto-Medium", size: 16.0))
                                .background(.clear)
                        }
                        Spacer()
                        HStack(spacing: 12) {
                            // Image Counter
                            HStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.system(size: 12))
                                Text("\(imageCount)/\(maxImageCount)")
                                    .font(.custom("Roboto-Regular", size: 14.0))
                            }
                            .foregroundColor(imageCount >= maxImageCount ? .red : .gray)
                            
                            // Video Counter
                            HStack(spacing: 4) {
                                Image(systemName: "video")
                                    .font(.system(size: 12))
                                Text("\(videoCount)/\(maxVideoCount)")
                                    .font(.custom("Roboto-Regular", size: 14.0))
                            }
                            .foregroundColor(videoCount >= maxVideoCount ? .red : .gray)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            
                            // Add Media Button
                            if imageCount < maxImageCount || videoCount < maxVideoCount {
                                Button {
                                    showPickerOptions = true
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        VStack(spacing: 4) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 20))
                                            Text("Add")
                                                .font(.system(size: 12))
                                        }
                                        .foregroundColor(.black)
                                    }
                                    .frame(width: 80, height: 80)
                                }
                            }
                            
                            // Media Preview
                            ForEach(Array(selectedMedia.enumerated()), id: \.element.id) { index, item in
                                MediaThumbnailView(
                                    item: item,
                                    onDelete: {
                                        deleteMedia(at: index, item: item)
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.top, -14)
                }
                .padding(.all, 12)
            }
            .background(.white)
            .cornerRadius(12)
            .padding(.all, 12)
        }
        .onAppear {
            loadExistingMedia()
        }
        .background(.clear)
        .confirmationDialog("Select Media Source", isPresented: $showPickerOptions) {
            if imageCount < maxImageCount {
                Button("Take Photo") {
                    cameraMediaType = .photo
                    showCameraPicker = true
                }
                Button("Choose Photos") {
                    showPhotoLibrary = true
                }
            }
            if videoCount < maxVideoCount {
                Button("Record Video") {
                    cameraMediaType = .video
                    showCameraPicker = true
                }
                Button("Choose Video") {
                    showVideoPicker = true
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraPickerView(mediaType: cameraMediaType) { image, videoURL in
                handleCameraCapture(image: image, videoURL: videoURL)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoLibraryPicker(
                maxCount: maxImageCount - imageCount,
                mediaType: .image
            ) { items in
                handlePhotoLibrarySelection(items: items)
            }
        }
        .sheet(isPresented: $showVideoPicker) {
            PhotoLibraryPicker(
                maxCount: maxVideoCount - videoCount,
                mediaType: .video
            ) { items in
                handleVideoLibrarySelection(items: items)
            }
        }
    }
    
    private func loadExistingMedia() {
        selectedMedia.removeAll()
        
        // Load images
        for urlString in uploadedImageUrls {
            DownloadManager.shared.downloadImage(from: urlString) { image in
                if let img = image {
                    let item = MediaItem(
                        type: .image,
                        image: img,
                        videoURL: nil,
                        thumbnailImage: nil,
                        urlString: urlString
                    )
                    DispatchQueue.main.async {
                        selectedMedia.append(item)
                    }
                }
            }
        }
        
        // Load videos
        for urlString in uploadedVideoUrls {
            if let url = URL(string: urlString) {
                let thumbnail = generateThumbnail(from: url)
                let item = MediaItem(
                    type: .video,
                    image: nil,
                    videoURL: url,
                    thumbnailImage: thumbnail,
                    urlString: urlString
                )
                DispatchQueue.main.async {
                    selectedMedia.append(item)
                }
            }
        }
    }
    
    private func handleCameraCapture(image: UIImage?, videoURL: URL?) {
        if let image = image {
            // Save image to temporary location
            if let imageURL = saveImageToTemp(image) {
                let item = MediaItem(
                    type: .image,
                    image: image,
                    videoURL: nil,
                    thumbnailImage: nil,
                    urlString: imageURL.absoluteString
                )
                selectedMedia.append(item)
                uploadedImageUrls.append(imageURL.absoluteString)
            }
        } else if let videoURL = videoURL {
            let thumbnail = generateThumbnail(from: videoURL)
            let item = MediaItem(
                type: .video,
                image: nil,
                videoURL: videoURL,
                thumbnailImage: thumbnail,
                urlString: videoURL.absoluteString
            )
            selectedMedia.append(item)
            uploadedVideoUrls.append(videoURL.absoluteString)
        }
    }
    
    private func handlePhotoLibrarySelection(items: [MediaItem]) {
        for item in items {
            if imageCount < maxImageCount {
                selectedMedia.append(item)
                uploadedImageUrls.append(item.urlString)
            }
        }
    }
    
    private func handleVideoLibrarySelection(items: [MediaItem]) {
        for item in items {
            if videoCount < maxVideoCount {
                selectedMedia.append(item)
                uploadedVideoUrls.append(item.urlString)
            }
        }
    }
    
    private func deleteMedia(at index: Int, item: MediaItem) {
        selectedMedia.remove(at: index)
        
        if item.type == .image {
            if let urlIndex = uploadedImageUrls.firstIndex(of: item.urlString) {
                uploadedImageUrls.remove(at: urlIndex)
                deletedMediaClosure?(urlIndex, .image)
            }
        } else {
            if let urlIndex = uploadedVideoUrls.firstIndex(of: item.urlString) {
                uploadedVideoUrls.remove(at: urlIndex)
                deletedMediaClosure?(urlIndex, .video)
            }
        }
    }
    
    private func saveImageToTemp(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        return url
    }
    
    private func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}

// MARK: - Media Thumbnail View
struct MediaThumbnailView: View {
    let item: MediaItem
    let onDelete: () -> Void
    @State private var showVideoPlayer = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if item.type == .image {
                // Image Thumbnail
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    ShimmerView()
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
            } else {
                // Video Thumbnail
                Button(action: {
                    showVideoPlayer = true
                }) {
                    ZStack {
                        if let thumbnail = item.thumbnailImage {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            ShimmerView()
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        }
                        
                        // Play Icon Overlay
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                    }
                }
                .fullScreenCover(isPresented: $showVideoPlayer) {
                    if let videoURL = item.videoURL {
                        VideoPlayerView1(videoURL: videoURL.absoluteString)
                    }
                }
            }
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .frame(width: 28, height: 28)
            }
            .offset(x: 6, y: -6)
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Camera Picker View
struct CameraPickerView: UIViewControllerRepresentable {
    let mediaType: UIImagePickerController.CameraCaptureMode
    let completion: (UIImage?, URL?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera

        if mediaType == .photo {
            picker.mediaTypes = ["public.image"]
            picker.cameraCaptureMode = .photo
        } else {
            picker.mediaTypes = ["public.movie"]
            picker.cameraCaptureMode = .video
        }

        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completion: (UIImage?, URL?) -> Void
        
        init(completion: @escaping (UIImage?, URL?) -> Void) {
            self.completion = completion
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                completion(image, nil)
            } else if let videoURL = info[.mediaURL] as? URL {
                completion(nil, videoURL)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Photo Library Picker
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    let maxCount: Int
    let mediaType: MediaItem.MediaType
    let completion: ([MediaItem]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxCount
        config.filter = mediaType == .image ? .images : .videos
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(mediaType: mediaType, completion: completion)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let mediaType: MediaItem.MediaType
        let completion: ([MediaItem]) -> Void
        
        init(mediaType: MediaItem.MediaType, completion: @escaping ([MediaItem]) -> Void) {
            self.mediaType = mediaType
            self.completion = completion
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var items: [MediaItem] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                
                if mediaType == .image {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        defer { group.leave() }
                        
                        if let image = object as? UIImage,
                           let url = self.saveImageToTemp(image) {
                            let item = MediaItem(
                                type: .image,
                                image: image,
                                videoURL: nil,
                                thumbnailImage: nil,
                                urlString: url.absoluteString
                            )
                            items.append(item)
                        }
                    }
                } else {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                        defer { group.leave() }
                        
                        if let url = url {
                            let destURL = FileManager.default.temporaryDirectory
                                .appendingPathComponent(UUID().uuidString)
                                .appendingPathExtension("mov")
                            
                            try? FileManager.default.copyItem(at: url, to: destURL)
                            
                            let thumbnail = self.generateThumbnail(from: destURL)
                            let item = MediaItem(
                                type: .video,
                                image: nil,
                                videoURL: destURL,
                                thumbnailImage: thumbnail,
                                urlString: destURL.absoluteString
                            )
                            items.append(item)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.completion(items)
            }
        }
        
        private func saveImageToTemp(_ image: UIImage) -> URL? {
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            let filename = UUID().uuidString + ".jpg"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try? data.write(to: url)
            return url
        }
        
        private func generateThumbnail(from url: URL) -> UIImage? {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                return UIImage(cgImage: cgImage)
            } catch {
                return nil
            }
        }
    }
}

struct ShimmerView: View {
    @State private var isAnimating: Bool = false

    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .cornerRadius(8)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1), .gray.opacity(0.3)]),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                        .rotationEffect(.degrees(0))
                        .offset(x: isAnimating ? 300 : -300)
                )
                .mask(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                .frame(width: 80, height: 80)
                .clipped()
                .onAppear {
                    withAnimation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                        isAnimating.toggle()
                    }
                }
        }
    }
}

// MARK: - Video Player View
struct VideoPlayerView1: View {
    let videoURL: String
    @StateObject private var viewModel: VideoPlayerViewModel1
    @Environment(\.dismiss) private var dismiss
    
    init(videoURL: String) {
        self.videoURL = videoURL
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel1(videoURLString: videoURL))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding()
                .zIndex(1)
                
                Spacer()
                
                // Video Player
                ZStack {
                    Color.black
                    
                    if viewModel.isLoading {
                        // Loading
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(2)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text("Loading video...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        // Error
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    } else if let player = viewModel.player {
                        // Video Player
                        VideoPlayerLayer(player: player)
                            .aspectRatio(16/9, contentMode: .fit)
                    }
                }
                
                // Custom Controls
                if viewModel.player != nil && !viewModel.isLoading {
                    VideoControlsView1(viewModel: viewModel)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                }
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.loadVideo()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Video Player Layer
struct VideoPlayerLayer: UIViewRepresentable {
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
        context.coordinator.playerLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}

// MARK: - Custom Controls View
struct VideoControlsView1: View {
    @ObservedObject var viewModel: VideoPlayerViewModel1
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress Bar
            HStack(spacing: 8) {
                Text(timeString(from: viewModel.currentTime))
                    .font(.caption)
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                Slider(value: $viewModel.sliderValue, in: 0...1, onEditingChanged: { editing in
                    if !editing {
                        viewModel.seek(to: viewModel.sliderValue)
                    }
                })
                .accentColor(.blue)
                
                Text(timeString(from: viewModel.duration))
                    .font(.caption)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            // Control Buttons
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.seekBackward()
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    viewModel.seekForward()
                }) {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func timeString(from seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

import Combine

// MARK: - Video Player View Model
class VideoPlayerViewModel1: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var sliderValue: Double = 0
    
    private let videoURLString: String
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    init(videoURLString: String) {
        self.videoURLString = videoURLString
    }
    
    func loadVideo() {
        guard let url = URL(string: videoURLString) else {
            errorMessage = "Invalid video URL"
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        setupPlayer(with: url)
    }
    
    private func setupPlayer(with url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe player status
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                DispatchQueue.main.async {
                    if status == .readyToPlay {
                        self?.isLoading = false
                        self?.duration = playerItem.duration.seconds
                        self?.player?.play()
                        self?.isPlaying = true
                        self?.addTimeObserver()
                    } else if status == .failed {
                        self?.errorMessage = "Failed to load video"
                        self?.isLoading = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func addTimeObserver() {
        guard let player = player else { return }
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if self.duration > 0 {
                self.sliderValue = time.seconds / self.duration
            }
        }
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func seek(to value: Double) {
        guard let player = player else { return }
        let targetTime = duration * value
        let time = CMTime(seconds: targetTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time)
    }
    
    func seekForward() {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        player.seek(to: newTime)
    }
    
    func seekBackward() {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        player.seek(to: newTime)
    }
    
    func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player?.pause()
        player = nil
        cancellables.removeAll()
    }
    
    deinit {
        cleanup()
    }
}
