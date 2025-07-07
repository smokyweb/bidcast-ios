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
var yPosition = screenHeight/3
    var body: some View {
        GeometryReader { geometry in
                  VStack(spacing: 16) {
                      Image(imageName)
                          .resizable()
                          .scaledToFit()
                          .frame(width: 150, height: 150)
                          .foregroundColor(.gray.opacity(0.6))

                      Text(message)
                          .font(.custom(poppinsSemiBold, size: 16))
                          .foregroundColor(.gray)
                          .multilineTextAlignment(.center)
                  }
                  .frame(width: geometry.size.width, height: geometry.size.height)
                  .position(x: geometry.size.width / 2, y:yPosition )
              }
    }
}
