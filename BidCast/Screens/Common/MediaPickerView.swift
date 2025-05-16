//
//  MediaPickerView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import SwiftUICore
import UIKit
import SwiftUI


import PhotosUI

struct MediaPickerView: View {
    let maxMediaCount = 8

    @State private var selectedMedia: [UIImage] = []

    @State private var showCameraPicker = false
    @State private var showPhotoLibrary = false
    @State private var showPickerOptions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Media".localized)
                    .font(.headline)
                Spacer()
                Text("\(selectedMedia.count)/\(maxMediaCount)")
                    .foregroundColor(.gray)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(100))], spacing: 16) {
                   
                    Button {
                        showCameraPicker = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                                .background(Color(.systemGray6))
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        .frame(width: 80, height: 80)
                    }
                    
                    if selectedMedia.count < maxMediaCount{
                        Button {
                        showPickerOptions = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .background(Color(.systemGray6))
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        .frame(width: 80, height: 80)
                    }
                }
                    
                    ForEach(selectedMedia.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: selectedMedia[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                                .cornerRadius(8)

                            Button(action: {
                                selectedMedia.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .offset(x: 6, y: -6)
                            .buttonStyle(PlainButtonStyle())
                            .font(.system(size: 20))
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.top, -14)
        }
//        .padding()
        .confirmationDialog("Select Media Source", isPresented: $showPickerOptions) {
            Button("Camera") {
                showCameraPicker = true
            }
            Button("Photo Library") {
                showPhotoLibrary = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(sourceType: .camera) { image in
                if let image = image, selectedMedia.count < maxMediaCount {
                    selectedMedia.append(image)
                }
            }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoPicker(count:8, onImagesPicked:  { images in
                let remaining = maxMediaCount - selectedMedia.count
                let limited = Array(images.prefix(remaining))
                selectedMedia.append(contentsOf: limited)
            })
        }
    }
}
