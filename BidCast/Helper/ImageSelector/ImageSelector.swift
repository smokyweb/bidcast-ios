//
//  ImageSelector.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 24/01/24.
//

import Foundation
import SwiftUI
import UIKit

struct ImageSelector: UIViewControllerRepresentable {
    
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var isPresented: Bool
    @State var onImageSelected: ((UIImage?, String?) -> Void)?
    
    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(isPresented: $isPresented, onImageSelected: $onImageSelected)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            pickerController.sourceType = sourceType
        } else {
            pickerController.sourceType = .savedPhotosAlbum
        }
        pickerController.delegate = context.coordinator
        pickerController.allowsEditing = true
        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
            // Nothing to update here
    }
    
}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var isPresented: Bool
    @Binding var onImageSelected: ((UIImage?, String?) -> Void)?
    
    init(isPresented: Binding<Bool>, onImageSelected: Binding<((UIImage?, String?) -> Void)?>) {
        _isPresented = isPresented
        _onImageSelected = onImageSelected
    }
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var image = UIImage()
        var imageURL = ""
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = img
        }
        
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            imageURL = url.absoluteString
        }
        
        if imageURL == "" {
            let imageName = "IMG_" + Date().getTimeStamp() + ".png"
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
            }
            
            imageURL = imagePath.absoluteString
        }
        
        self.onImageSelected?(image, imageURL)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        withAnimation(.easeIn) {
            self.isPresented = false
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
