//
//  ImageCollectionView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//

import SwiftUI


struct ImageCollectionView: View {
    var profileImg = "defaultUser"
    var profileName = "Costa Sandra"
    var textSize = 16.0
    var image = ""
    var category = "category"
    var title2 = "Stream Time"
    var categorySize = 14.0
    var title2Size = 16.0
    var liveCount = 0
    
    var onTapProfile: () -> Void = {}
    var onTapProfileName : () -> Void = {}
    var onTapMainImage: () -> Void = {}
    var onTapCategory: () -> Void = {}
  
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // ───────── Profile Row Button ─────────
            Button {
                onTapProfile()
            } label: {
                HStack(alignment: .center,spacing: 16) {
                    if let profileURL = URL(string: profileImg),
                       !profileImg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        AsyncImage(url: profileURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                    
                    
                    Text(profileName)
                        .bold()
                        .font(.custom(poppinsBold, fixedSize: textSize))
                        .foregroundStyle(.black)
                        .foregroundColor(.black)
                        .onTapGesture {
                            onTapProfileName()
                        }
                    
                    Spacer()
                }
            }
//            .buttonStyle(.plain)
            
            Button {
                onTapMainImage()
            } label: {
                GeometryReader { geometry in
                    if let imageURLString = image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       !image.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                       let imageURL = URL(string: imageURLString) {
                        
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: geometry.size.width, height: 220)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: 220)
                                    .cornerRadius(8)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: 220)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                    } else {
                       
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: 220)
                            .foregroundColor(.gray)
                    }
                    if liveCount > 0 {
                        LiveBadgeView(count: liveCount)
                              .padding(6)
                    }
                }
                .frame(maxWidth: .infinity,minHeight: 220)
            }
//            .buttonStyle(.plain)
            
            // ───────── Title & Category ─────────
            VStack(alignment: .leading, spacing: 8) {
                Text(title2.capitalizingFirstLetter())
                    .font(.custom(poppinsSemiBold, fixedSize: title2Size))
                    .foregroundStyle(.black)
                    .foregroundColor(.black)
                    .lineLimit(2)
                Button(action: {
                    self.onTapCategory()
                }) {
                    Text(category)
                        .font(.custom(poppinsSemiBold, fixedSize: categorySize))
                        .foregroundStyle(.defaultTheme)
                        .foregroundColor(.defaultTheme)
                        .lineLimit(2)
                }
            }
            
        }
        .padding(8)
    }
}


struct LiveBadgeView: View {
    var count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text("LIVE")
                .font(.custom(poppinsSemiBold, size: 16.0))
            Circle()
                .frame(width: 5, height: 5)
            Text("\(count)")
                .font(.custom(poppinsSemiBold, size: 16.0))
        }
        .font(.system(size: 12))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(6)
    }
}

