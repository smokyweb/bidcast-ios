//
//  priceCardView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/12/25.
//

import SwiftUI

struct priceCardView: View {
    let amount: String
       let label: String
       var onMoreTapped: () -> Void
    var body: some View {
        HStack(alignment: .center) {
                  VStack(alignment: .leading, spacing: 2) {
                      Text("$\(amount)")
                          .font(.custom(poppinsBold, size: 24))
                          .foregroundColor(.black)
                      
                      Text(label)
                          .font(.custom(poppinsRegular, size: 12))
                          .foregroundColor(.gray)
                  }
                  
                  Spacer()
                  
                  Button(action: onMoreTapped) {
                      HStack(spacing: 4) {
                          Text("More")
                              .font(.custom(poppinsSemiBold, size: 14))
                              .foregroundColor(.defaultTheme)
                          
                          Image(systemName: "chevron.down")
                              .font(.system(size: 12, weight: .semibold))
                              .foregroundColor(.blue)
                      }
                  }
              }
              .padding(20)
              .background(Color.white)
              .cornerRadius(12)
              .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
          
    }
}

//#Preview {
//    priceCardView()
//}
