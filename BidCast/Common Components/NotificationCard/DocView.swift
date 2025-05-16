//
//  DocView.swift
//  imperium
//
//  Created by JAM-E-221 on 23/01/25.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

//struct DocView: View {
//    @State private var showingActionSheet = false
//    @State private var showingDocumentPicker = false
//    @State private var showingImagePicker = false
//    @State private var selectedFileName: String? = nil
//    @State private var selectedImage: UIImage? = nil
//    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    @Binding var selectedFileURL: URL?
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Text("Business Certificate")
//                .font(.custom("Nunito-Bold", fixedSize: 15))
//                .bold()
//                .foregroundStyle(.primary)
//            
//            Text("The acceptable documents include a document showing the EIN, a piece of mail reflecting the business name like a bill, or a document showing the EIN number.")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//
//            ZStack {
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color(UIColor.systemGray6))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.black.opacity(0.5), lineWidth: 1)
//                    )
//                    .shadow(radius: 2)
//                
//                VStack(spacing: 10) {
//                    Image(systemName: "doc.text.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(Color.black)
//                    Text("Tap to upload Certificate \n File must be jpg, png, jpeg, excel, pdf, txt")
//                        .font(.system(size: 16))
//                        .foregroundColor(Color.black)
////                        .padding(-20)
//                }
//                .padding()
//            }
//            .frame(height: UIScreen.main.bounds.height / 6)
//            .onTapGesture {
//                showingActionSheet = true
//            }
//
//            if let fileURL = selectedFileURL {
//                Text("Selected File: \(fileURL)")
//                    .font(.footnote)
//                    .foregroundColor(.gray)
//                    .padding()
//            }
//        }
//        .actionSheet(isPresented: $showingActionSheet) {
//            ActionSheet(title: Text("Select Option"), buttons: [
//                .default(Text("Camera")) {
//                    sourceType = .camera
//                    showingImagePicker = true
//                },
//                .default(Text("Gallery")) {
//                    sourceType = .photoLibrary
//                    showingImagePicker = true
//                },
//                .default(Text("Files")) {
//                    showingDocumentPicker = true
//                },
//                .cancel()
//            ])
//        }
//        .sheet(isPresented: $showingImagePicker) {
//            ImagePicker(selectedImage: $selectedImage, selectedFileURL: $selectedFileURL, sourceType: sourceType)
//        }
//        .sheet(isPresented: $showingDocumentPicker) {
//            DocumentPicker(selectedFileName: $selectedFileName, selectedFileURL: $selectedFileURL)
//        }
//    }
//}
////struct ImagePicker: UIViewControllerRepresentable {
////    @Binding var selectedImage: UIImage?
////    @Binding var selectedFileURL: URL? // Save the image path
////    var sourceType: UIImagePickerController.SourceType
////
////    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
////        let parent: ImagePicker
////
////        init(_ parent: ImagePicker) {
////            self.parent = parent
////        }
////
////        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
////            if let image = info[.originalImage] as? UIImage {
////                parent.selectedImage = image
////                if let url = saveImageToDocumentsDirectory(image: image) {
////                    parent.selectedFileURL = url
////                }
////            }
////            picker.dismiss(animated: true)
////        }
////
////        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
////            picker.dismiss(animated: true)
////        }
////
////        private func saveImageToDocumentsDirectory(image: UIImage) -> URL? {
////            let fileName = UUID().uuidString + ".jpg"
////            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
////
////            if let data = image.jpegData(compressionQuality: 0.8) {
////                try? data.write(to: fileURL)
////                return fileURL
////            }
////            return nil
////        }
////    }
////
////    func makeCoordinator() -> Coordinator {
////        Coordinator(self)
////    }
////
////    func makeUIViewController(context: Context) -> UIImagePickerController {
////        let picker = UIImagePickerController()
////        picker.delegate = context.coordinator
////        picker.sourceType = sourceType
////        return picker
////    }
////
////    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
////}
////
////struct DocumentPicker: UIViewControllerRepresentable {
////    @Binding var selectedFileName: String?
////    @Binding var selectedFileURL: URL?
////
////    class Coordinator: NSObject, UIDocumentPickerDelegate {
////        let parent: DocumentPicker
////
////        init(_ parent: DocumentPicker) {
////            self.parent = parent
////        }
////
////        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
////            guard let firstURL = urls.first else { return }
////            parent.selectedFileName = firstURL.lastPathComponent
////            parent.selectedFileURL = firstURL
////        }
////
////        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
////            print("Document picker was cancelled")
////        }
////    }
////
////    func makeCoordinator() -> Coordinator {
////        Coordinator(self)
////    }
////
////    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
////        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
////            UTType.image,
////            UTType.pdf,
////            UTType.plainText,
////            UTType.spreadsheet
////        ])
////        picker.delegate = context.coordinator
////        return picker
////    }
////
////    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
////}
