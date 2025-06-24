//
//  NoDataView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 24/06/25.
//



import SwiftUI

struct NoDataView: View {
    var imageName: String = "noData" // Provide your asset name
    var message: String = "No Data Found"

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.gray.opacity(0.6))

            Text(message)
                .font(.custom(poppinsRegular, size: 16))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
