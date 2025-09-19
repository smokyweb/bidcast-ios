//
//  MediaPickerView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import UIKit
import SwiftUI


import PhotosUI

struct MediaPickerView: View {
    let maxMediaCount = 8
    var title = "Media"
    @State private var selectedMedia: [UIImage] = []
    @State private var showCameraPicker = false
    @State private var showPhotoLibrary = false
    @State private var showPickerOptions = false
    
    @Binding var uploadedImageUrls: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                VStack{
                    HStack {
                        if title != ""{
                            Text(title.localized)
                                .font(.custom(robotoMedium, size: 16.0))
                        }
                        Spacer()
                        Text("\(selectedMedia.count)/\(maxMediaCount)")
                            .foregroundColor(.gray)
                            .font(.custom(robotoRegular, size: 14.0))
                    }
                    .padding(.bottom , 10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            
                            // Camera Button
                            Button {
                                showCameraPicker = true
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, lineWidth: 2)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.black)
                                }
                                .frame(width: 80, height: 80)
                            }
                            
                            // Photo Library Picker
                            if selectedMedia.count < maxMediaCount {
                                Button {
                                    showPickerOptions = true
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                        Image(systemName: "plus")
                                            .font(.system(size: 24))
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 80, height: 80)
                                }
                            }
                            
                            // Media Preview
                            ForEach(selectedMedia.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: selectedMedia[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    // Delete Button
                                    Button(action: {
                                        selectedMedia.remove(at: index)
                                        uploadedImageUrls.remove(at: index)
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
                if let image = image,
                           selectedMedia.count < maxMediaCount,
                           !selectedMedia.contains(image) {
                            selectedMedia.append(image)
                        }

                        if let url = url {
                            uploadedImageUrls.append(url)
                        }
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showPhotoLibrary) {
            PhotoPicker(count: maxMediaCount) { images,urls in
                let remaining = maxMediaCount - selectedMedia.count
                let limitedImages = Array(images.prefix(remaining))
                let limitedUrls = Array(urls.prefix(remaining))
                
                selectedMedia.append(contentsOf: limitedImages)
                uploadedImageUrls.append(contentsOf: limitedUrls)
                
                
            }
            .ignoresSafeArea()
        }
    }
}
