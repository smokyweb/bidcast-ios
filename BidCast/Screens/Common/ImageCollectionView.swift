//
//  ImageCollectionView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//

import SwiftUICore


struct ImageCollectionView: View {
    
    var profileName = "Costa Sandra"
    var textSize = 18.0
    var image : ImageResource
    var category = "category"
    var title2 = "Stream Time"
    var categorySize = 13.0
    var title2Size = 15.0
    var onTap: () -> Void = {}

    var body: some View {
        
        VStack(alignment: .leading,spacing: 8){
            HStack(alignment:.center){
                Image(.defaultUser)
                    .resizable()
                    .frame(width: 40,height: 40)
                Text(profileName)
                    .bold()
                    .font(.custom(nunitoBlack, fixedSize: textSize))
                    .foregroundStyle(.black)
                    .foregroundColor(.black)
                Spacer()
            }
            Image(image)
                .resizable()
                .frame(maxWidth: .infinity)
            Text(title2)
                .bold()
                .font(.custom(nunitoBlack, fixedSize: title2Size))
                .foregroundStyle(.black)
                .foregroundColor(.black)
            Text(category)
                .font(.custom(nunitoBlack, fixedSize: categorySize))
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
