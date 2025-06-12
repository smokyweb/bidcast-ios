//
//  PhotoPicker.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//


import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: For Multi Selection
struct PhotoPicker: UIViewControllerRepresentable {
    var count: Int = 0
    var onImagesPicked: ([UIImage], [String]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagesPicked: onImagesPicked)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = count // 0 = unlimited
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onImagesPicked: ([UIImage], [String]) -> Void

        init(onImagesPicked: @escaping ([UIImage], [String]) -> Void) {
            self.onImagesPicked = onImagesPicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let group = DispatchGroup()
            var images: [UIImage] = []
            var urls: [String] = []

            for result in results {
                group.enter()

                if let itemProvider = result.itemProvider.copy() as? NSItemProvider {
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                            defer { group.leave() }
                            guard let fileURL = url else { return }

                            let targetURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileURL.lastPathComponent)

                            do {
                                if FileManager.default.fileExists(atPath: targetURL.path) {
                                    try FileManager.default.removeItem(at: targetURL)
                                }
                                try FileManager.default.copyItem(at: fileURL, to: targetURL)

                                if let data = try? Data(contentsOf: targetURL),
                                   let image = UIImage(data: data),
                                   let compressedData = image.jpegData(compressionQuality: 0.6) {

                                    let compressedURL = FileManager.default.temporaryDirectory.appendingPathComponent("compressed_\(UUID().uuidString).jpg")
                                    try compressedData.write(to: compressedURL)

                                    urls.append(compressedURL.path)
                                    images.append(UIImage(data: compressedData) ?? image)
                                }
                            } catch {
                                print("❌ Error copying or compressing image:", error.localizedDescription)
                            }
                        }
                    } else {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.onImagesPicked(images, urls)
            }
        }
    }
}

// MARK: For Single Selection
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var cameraDevice: UIImagePickerController.CameraDevice = .rear // ✅ Added
    var onImagePicked: (UIImage?, String?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType

        // ✅ Apply selected camera (front or rear)
        if sourceType == .camera, UIImagePickerController.isCameraDeviceAvailable(cameraDevice) {
            picker.cameraDevice = cameraDevice
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var onImagePicked: (UIImage?, String?) -> Void

        init(onImagePicked: @escaping (UIImage?, String?) -> Void) {
            self.onImagePicked = onImagePicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                if let imageData = selectedImage.jpegData(compressionQuality: 0.6) {
                    if let compressedImage = UIImage(data: imageData) {
                        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
                            .appendingPathComponent("compressedImage_\(UUID().uuidString).jpg")

                        do {
                            try imageData.write(to: tempURL)
                            print("Compressed image URL: \(tempURL)")
                            self.onImagePicked(compressedImage, "\(tempURL)")
                        } catch {
                            print("Failed to write imageData to disk: \(error.localizedDescription)")
                            self.onImagePicked(nil, nil)
                        }
                    }
                } else {
                    if let imageData = selectedImage.jpegData(compressionQuality: 0.6) {
                        let tempDirectoryURL = FileManager.default.temporaryDirectory
                        let imageURL = tempDirectoryURL.appendingPathComponent("selectedImage.jpg")

                        do {
                            try imageData.write(to: imageURL)
                            self.onImagePicked(selectedImage, "\(imageURL)")
                            print("Temporary Image URL: \(imageURL)")
                        } catch {
                            print("Error saving image to temporary file: \(error)")
                            self.onImagePicked(nil, nil)
                        }
                    }
                }

                print("Image selected: \(selectedImage)")
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            onImagePicked(nil, nil)
        }
    }
}
