//
//  BoostCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct BoostCardView: View {
    let boost: BoostModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(boost.title ?? "")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                        .foregroundColor(.white)
                    Text(boost.sub_title ?? "")
                        .font(.custom(poppinsSemiBold, size: 12.0))
                        .foregroundColor(.white.opacity(0.8))
                    Text(boost.description ?? "")
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                CustomProfileImage(url: boost.icon ?? "",isCircular: false, size: 48)
                
            }

            Button(action: boost.action ?? {}) {
                Text("Select • \(boost.price ?? "")")
                    .font(.custom(poppinsSemiBold, size: 14.0))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    hexToColor(boost.colors?.start ?? "#000000"),
                    hexToColor(boost.colors?.end ?? "#000000")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
    func hexToColor(_ hex: String) -> Color {
           var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
           var int: UInt64 = 0
           Scanner(string: hex).scanHexInt64(&int)
           let a, r, g, b: UInt64
           switch hex.count {
           case 3: // RGB (12-bit)
               (a, r, g, b) = (255, (int >> 8 * 17), (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
           case 6: // RGB (24-bit)
               (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
           case 8: // ARGB (32-bit)
               (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
           default:
               return Color.black
           }
           return Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
       }
}

