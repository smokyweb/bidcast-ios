//
//  ListCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI


struct ListCell: View {
    
    var isComeFrom : String = ""
    var image : String = ""
    var title = "Gaming"
    var vectorImg : ImageResource?
    var subLabel = "Live"
    var tintColot = ""
    var titleFontName = poppinsMedium
    var titleFontSize = 16.0
    var subLabelFontName = poppinsRegular
    var subLabelFontSize = 14.0
    var isVectorImgHidden : Bool = false
    var onTapMenuCell: (() -> Void)? = nil
    var body: some View {
        HStack(alignment: .center,spacing: 10){
            HStack{
                if isComeFrom != "Wallet"{
                    AsyncImage(url: URL(string:image.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 30,height: 30)
                            
                        default:
                            Image(image)
                                .resizable()
                        }
                    }
                    .scaledToFill()
                    .frame(width: 40,height: 40)
                    .background(Color(hex: tintColot) ?? .clear)
                    .mask {
                        if isComeFrom == "ShippingScreen" {
                            Circle()
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                        }
                    }
                    .padding(.leading ,10)
                }
//                Image(image)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 40,height: 40)
//                    .padding(.leading ,10)
                VStack(alignment: .leading,spacing: 6) {
                    Text(title)
                        .font(.custom(titleFontName, fixedSize: titleFontSize))
                        .foregroundStyle(.black)
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    Text(subLabel)
                        .font(.custom(subLabelFontName, fixedSize: subLabelFontSize))
                        .foregroundStyle(.black.opacity(0.6))
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                }
                Spacer()
                if !isVectorImgHidden{
                    Image(vectorImg ?? .defaultUser )
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24,height: 24)
                        .rotationEffect(Angle(degrees: 90.0))
                        .padding(.trailing ,8)
                }
            }
            .frame(maxWidth: .infinity )
        }
        .frame(height: 60)
        .background(.white)
        .cornerRadius(8.0)
        .padding([.leading,.trailing], 0)
        .edgesIgnoringSafeArea(.all)
        .shadow(color: .squirrelGrey.opacity(0.5), radius: 2, x: 0, y: 0)
        .onTapGesture {
            self.onTapMenuCell?()
        }
    }
}

//#Preview {
//    ListCell(image: .user1, vectorImg: .arrowForward)
//}
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
