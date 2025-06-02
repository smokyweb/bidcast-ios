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
    var textSize = 18.0
    var image = ""
    var category = "category"
    var title2 = "Stream Time"
    var categorySize = 13.0
    var title2Size = 15.0
    var onTap: () -> Void = {}

    var body: some View {
        
        VStack(alignment: .leading,spacing: 8){
            HStack(alignment:.center){
                AsyncImage(url: URL(string: profileImg)) { phase in
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
                Text(profileName)
                    .bold()
                    .font(.custom(poppinsBold, fixedSize: textSize))
                    .foregroundStyle(.black)
                    .foregroundColor(.black)
                Spacer()
            }
            GeometryReader { geometry in
                AsyncImage(url: URL(string: image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) { phase in
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
            }
            .frame(height: 160)

            Text(title2)
                .font(.custom(poppinsRegular, fixedSize: title2Size))
                .foregroundStyle(.black)
                .foregroundColor(.black)
            Text(category)
                .font(.custom(poppinsRegular, fixedSize: categorySize))
                .foregroundStyle(.black)
                .foregroundColor(.black)
        }
        .padding(.all,8)
        .onTapGesture {
                    onTap()
                }
    }
}

//#Preview {
//    ImageCollectionView()
//}
