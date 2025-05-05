import Foundation
import SwiftUI
import AVFoundation
import Photos

struct VideoRecorderHelper: UIViewControllerRepresentable {
    
    @State var isForRecording: Bool = false
    @State var sourceType: UIImagePickerController.SourceType = .camera
    @State var onRecordingCancel: (() -> Void)?
    @State var onRecordingSuccess: ((URL) -> Void)?
    
    func makeCoordinator() -> VideoRecorderViewCoordinator {
        return VideoRecorderViewCoordinator(onRecordingCancel: $onRecordingCancel, onRecordingSuccess: $onRecordingSuccess)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            pickerController.sourceType = sourceType
            pickerController.mediaTypes = ["public.movie"]
            pickerController.allowsEditing = true
            pickerController.delegate = context.coordinator
            pickerController.videoQuality = .typeMedium

            if isForRecording {
                checkPermissions { granted in
                    if granted {
                        DispatchQueue.main.async {
                            pickerController.cameraDevice = .front
                            pickerController.videoMaximumDuration = 240.0
                            pickerController.startVideoCapture()
                        }
                    } else {
                        // Handle the case where permissions were not granted
                        onRecordingCancel?()
                    }
                }
            }
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    private func checkPermissions(completion: @escaping (Bool) -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        
        switch (cameraStatus, microphoneStatus) {
        case (.authorized, .granted):
            completion(true)
        case (.notDetermined, _):
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.requestMicrophonePermission(completion: completion)
                } else {
                    completion(false)
                }
            }
        case (_, .undetermined):
            requestMicrophonePermission(completion: completion)
        default:
            completion(false)
        }
    }
    
    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
}

class VideoRecorderViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var onRecordingCancel: (() -> Void)?
    @Binding var onRecordingSuccess: ((URL) -> Void)?
    
    init(onRecordingCancel: Binding<(() -> Void)?>, onRecordingSuccess: Binding<((URL) -> Void)?>) {
        _onRecordingCancel = onRecordingCancel
        _onRecordingSuccess = onRecordingSuccess
    }
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            withAnimation(.easeOut) {
                self.onRecordingSuccess?(videoURL)
            }
        } else {
            print("Error while getting video URL")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        withAnimation(.easeOut) {
            self.onRecordingCancel?()
        }
    }
}
