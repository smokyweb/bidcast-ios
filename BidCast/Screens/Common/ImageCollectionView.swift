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

