//
//  MediaPickerView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import UIKit
import SwiftUI


import PhotosUI
import AlertToast

struct MediaPickerView: View {
    let maxMediaCount = 8
    var title = "Media"
    @State private var selectedMedia: [UIImage] = []
    @State private var showCameraPicker = false
    @State private var showPhotoLibrary = false
    @State private var showPickerOptions = false
    
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    
//    @Binding var isImageSizeExceeding: Bool
    
//    var maxImageSizeLimit: Double = 5.0 // in MB
    
    @Binding var uploadedImageUrls: [String]
    
    var deletedImageClosure: ((Int) -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                VStack{
                    HStack {
                        if title != ""{
                            Text(title.localized)
                                .font(.custom(robotoMedium, size: 16.0))
                                .background(.clear)
                        }
                        Spacer()
                        Text("\(uploadedImageUrls.count)/\(maxMediaCount)")
                            .foregroundColor(.gray)
                            .font(.custom(robotoRegular, size: 14.0))
                    }
                    .padding(.bottom , 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            
//                            // Camera Button
//                            Button {
//                                showCameraPicker = true
//                            } label: {
//                                ZStack {
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .stroke(Color.blue, lineWidth: 2)
//                                        .background(Color(.systemGray6))
//                                        .cornerRadius(12)
//                                    Image(systemName: "camera.fill")
//                                        .font(.system(size: 24))
//                                        .foregroundColor(.black)
//                                }
//                                .frame(width: 80, height: 80)
//                            }
                            
                            // Photo Library Picker
                            if uploadedImageUrls.count < maxMediaCount {
                                Button {
                                    showPickerOptions = true
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 80, height: 80)
                                }
                            }
                            
                            // Media Preview
                            ForEach(uploadedImageUrls.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    if index < selectedMedia.count {
                                        // ✅ Image is downloaded
                                        Image(uiImage: selectedMedia[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(8)
                                    } else {
                                        // ⏳ Show shimmer while downloading
                                        ShimmerView()
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(8)
                                    }

                                    // ❌ Delete Button
                                    Button(action: {
                                        if index < selectedMedia.count {
                                            selectedMedia.remove(at: index)
                                        }
                                        uploadedImageUrls.remove(at: index)
                                        deletedImageClosure?(index)
                                    }) {
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
        .onFirstAppear {
            selectedMedia.removeAll()
            for item in uploadedImageUrls {
                DownloadManager.shared.downloadImage(from: item) { image in
                    if let img = image {
                        selectedMedia.append(img)
                    }
                }
            }
        }
        .background(.clear)
        .confirmationDialog("Select Media Source", isPresented: $showPickerOptions) {
            Button("Camera") {
                showCameraPicker = true
            }
            Button("Photo Library") {
                showPhotoLibrary = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            ImagePicker(sourceType: .camera) { image,url  in
                if let image = image, let url = url {
//                    if image.getImageSize(unit: .mb) > maxImageSizeLimit {
//                        isImageSizeExceeding = true
//                    }
//                    else  {
                        if selectedMedia.count < maxMediaCount,
                           !selectedMedia.contains(image) {
                            selectedMedia.append(image)
                        }
                        self.uploadedImageUrls.append(url)
//                    }
                }
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showPhotoLibrary) {
            PhotoPicker(count: maxMediaCount) { images,urls in
                let remaining = maxMediaCount - selectedMedia.count
                let limitedImages = Array(images.prefix(remaining))
                let limitedUrls = Array(urls.prefix(remaining))
//                let index = findLargeImageIndex(in: limitedImages)
//                if index != -1 {
//                    isImageSizeExceeding = true
//                }
//                else  {
                    selectedMedia.append(contentsOf: limitedImages)
                    uploadedImageUrls.append(contentsOf: limitedUrls)
//                }
                
                
            }
            .ignoresSafeArea()
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
