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
    var categorySize = 12.0
    var title2Size = 14.0
    var liveCount = 0
    var isLive : Bool = false
    
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
                HStack(alignment: .center,spacing: 10) {
                    CustomProfileImage(url: profileImg, isCircular: true, size: 40, defaultImage: "person.crop.circle.fill")
                    Text(profileName)
                        .bold()
                        .font(.custom(poppinsBold, fixedSize: textSize))
                        .foregroundStyle(.black)
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
                        CustomProfileImage(url: imageURLString, isCircular: false, size: geometry.size.width, height: 220, defaultImage: "defaultUser")
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                    } else {
                       
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: 220)
                            .foregroundColor(.gray)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    if isLive{
                        LiveBadgeView(count: liveCount)
                              .padding(6)
                    }
                }
                .frame(maxWidth: .infinity,minHeight: 220)
            }
//            .buttonStyle(.plain)
            
            // ───────── Title & Category ─────────
            VStack(alignment: .leading, spacing: 4) {
                Text(title2.capitalized)
                    .font(.custom(poppinsSemiBold, fixedSize: title2Size))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                Button(action: {
                    self.onTapCategory()
                }) {
                    Text(category.capitalized)
                        .font(.custom(poppinsSemiBold, fixedSize: categorySize))
                        .foregroundStyle(.defaultTheme)
                        .lineLimit(2)
                }
            }
            
        }
        .padding(8)
    }
}

struct ClipsGridView: View {

    let imageURLs: [String]

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(imageURLs, id: \.self) { url in
                ClipImage(url: url)
            }
        }
        .padding(.horizontal, 12)
    }
}

struct ClipImage: View {

    let url: String

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Thumbnail image
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: geo.size.width, height: geo.size.width)
                .clipped()
                .cornerRadius(12)

                // Dark overlay (optional, improves contrast)
                Color.black.opacity(0.15)
                    .cornerRadius(12)

                // ▶ Play Icon
                Image(systemName: "play.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.22,
                           height: geo.size.width * 0.22)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(
                                width: geo.size.width * 0.35,
                                height: geo.size.width * 0.35
                            )
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}




struct LiveBadgeView: View {
    var count: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Text("LIVE")
                .font(.custom(poppinsSemiBold, size: 14.0))
            Circle()
                .frame(width: 3, height: 3)
            Text("\(count)")
                .font(.custom(poppinsSemiBold, size: 14.0))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(6)
    }
}

