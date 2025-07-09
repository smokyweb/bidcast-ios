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
    var textSize = 12.0
    var image = ""
    var category = "category"
    var title2 = "Stream Time"
    var categorySize = 8.0
    var title2Size = 12.0
    
    var onTapProfile: () -> Void = {}
    var onTapMainImage: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // ───────── Profile Row Button ─────────
            Button {
                onTapProfile()
            } label: {
                HStack(alignment: .center) {
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
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
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
                                    .frame(width: geometry.size.width, height: 160)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: 160)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: 160)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                    } else {
                       
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: 160)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 160)
            }
            .buttonStyle(.plain)
            
            // ───────── Title & Category ─────────
            VStack(alignment: .leading, spacing: 4) {
                Text(title2)
                    .font(.custom(poppinsSemiBold, fixedSize: title2Size))
                    .foregroundStyle(.black)
                    .foregroundColor(.black)
                
                Text(category)
                    .font(.custom(poppinsRegular, fixedSize: categorySize))
                    .foregroundStyle(.black)
                    .foregroundColor(.black)
            }
            
        }
        .padding(8)
    }
}
