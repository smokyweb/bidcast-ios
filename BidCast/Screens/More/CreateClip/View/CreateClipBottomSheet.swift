//
//  ProductDetailSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//
import SwiftUI
import AVKit
import Photos

// MARK: - Create Clip Bottom Sheet
struct CreateClipBottomSheetView: View {
    @Binding var isPresented: Bool
    let videoURL: URL
    var onCreateClip: (CMTime, CMTime) -> Void
    var onEditClip: () -> () = { }

    @State private var player: AVPlayer?

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                PrimarySheetHeader(title: "Create Clip", onClose: {
                    isPresented = false
                })
            }
            
            VStack {
                ScrollView {
                    if let player = player {
                        VideoPlayer(player: player)
                            .aspectRatio(9/16, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height * 0.55)
                            .clipped()
                            .cornerRadius(16)
                    } else {
                        Color.black.opacity(0.1)
                            .frame(height: UIScreen.main.bounds.height * 0.55)
                            .overlay(Text("Loading..."))
                            .cornerRadius(16)
                    }
                    
                    PrimaryButton(title: "Edit Clip", onButtonClick: {
                        isPresented = false
                        onEditClip()
                    })
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, -30)
        .edgesIgnoringSafeArea(.top)
        .background(.backGround)
        .onAppear {
            player = AVPlayer(url: videoURL)
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
}

// MARK: - Edit Clip Screen (Main Screen)
struct EditClipScreen: View {
    @Binding var videoURL: String
    var onSave: (URL) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var localVideoURL: URL?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea()

            if isLoading {
                ProgressView("Preparing video…")
                    .foregroundColor(.black)
            } else if let localVideoURL {
                VideoTrimmerView(
                    localVideoURL: localVideoURL,
                    onComplete: { trimmedURL in
                        onSave(trimmedURL)
                        presentationMode.wrappedValue.dismiss()
                    },
                    onCancel: {
                        presentationMode.wrappedValue.dismiss()
                    },
                    onError: { error in
                        alertMessage = error
                        showAlert = true
                    }
                )
                .ignoresSafeArea()
            }
        }
        .onAppear {
            guard let remoteURL = URL(string: videoURL) else {
                alertMessage = "Invalid video URL"
                showAlert = true
                return
            }

            downloadVideo(from: remoteURL) { url in
                DispatchQueue.main.async {
                    guard let url else {
                        alertMessage = "Failed to download video"
                        showAlert = true
                        return
                    }
                    self.localVideoURL = url
                    self.isLoading = false
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage))
        }
        .navigationBarHidden(true)
    }
    func downloadVideo(from remoteURL: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.downloadTask(with: remoteURL) { localURL, _, _ in
            guard let localURL else {
                completion(nil)
                return
            }

            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent(remoteURL.lastPathComponent)

            try? FileManager.default.removeItem(at: destination)
            do {
                try FileManager.default.moveItem(at: localURL, to: destination)
                completion(destination)
            } catch {
                completion(nil)
            }
        }.resume()
    }

}


// MARK: - Video Trimmer View (UIKit Wrapper)
struct VideoTrimmerView: UIViewControllerRepresentable {
    let localVideoURL: URL
    var onComplete: (URL) -> Void
    var onCancel: () -> Void
    var onError: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIVideoEditorController {
        let editor = UIVideoEditorController()

        guard UIVideoEditorController.canEditVideo(atPath: localVideoURL.path) else {
            DispatchQueue.main.async {
                onError("This video cannot be edited")
            }
            return editor
        }

        editor.videoPath = localVideoURL.path   // ✅ MUST be set BEFORE return
        editor.videoQuality = .typeHigh
        editor.videoMaximumDuration = 60
        editor.delegate = context.coordinator

        return editor
    }

    func updateUIViewController(_ uiViewController: UIVideoEditorController, context: Context) {}

    class Coordinator: NSObject, UIVideoEditorControllerDelegate,UINavigationControllerDelegate {
        let parent: VideoTrimmerView
        init(_ parent: VideoTrimmerView) { self.parent = parent }

        func videoEditorController(_ editor: UIVideoEditorController,
                                   didSaveEditedVideoToPath editedVideoPath: String) {
            parent.onComplete(URL(fileURLWithPath: editedVideoPath))
        }

        func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
            parent.onCancel()
        }

        func videoEditorController(_ editor: UIVideoEditorController,
                                   didFailWithError error: Error) {
            parent.onError(error.localizedDescription)
        }
    }
}


// MARK: - Helper Extension
extension AVPlayer {
    var durationSeconds: Double {
        currentItem?.duration.seconds ?? 0
    }
}

