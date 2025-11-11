//
//  EmailSupport.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 31/10/25.
//

import SwiftUI

struct EmailSupportView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ImageIconView(name: "mail")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.custom(poppinsBold, fixedSize: 16))
                    .bold()
                
                Text("support@company.com")
                    .font(.custom(poppinsSemiBold, fixedSize: 13))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading) // ✅ make full width
        .background(Color.platinum)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    EmailSupportView()
}


struct ImageIconView: View {
    let name: String
    var size: CGFloat = 24
    var foregroundColor: Color = .white
    var backgroundColor: Color = .clear
    var cornerRadius: CGFloat = 12
    var shadowColor: Color = .black.opacity(0.2)
    var shadowRadius: CGFloat = 4
    var shadowOffset: CGSize = .init(width: 0, height: 2)
    var padding: CGFloat = 8
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(foregroundColor)
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor,
                    radius: shadowRadius,
                    x: shadowOffset.width,
                    y: shadowOffset.height)
    }
}
