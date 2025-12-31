//
//  PromoteShowSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import SVProgressHUD


extension BoostModel {

    static let dummyBoosts: [BoostModel] = [
        BoostModel(
            id: 1,
            title: "Boost Visibility",
            sub_title: "Reach more viewers",
            description: "Your show will be highlighted and shown to more users for a limited time.",
            price: "$9.99",
            gradient_colors: "purple_pink",
            icon: "bolt.fill",
            colors: nil,
            action: {
                print("Boost Visibility tapped")
            }
        ),
        BoostModel(
            id: 2,
            title: "Top Placement",
            sub_title: "Appear at top",
            description: "Your show will appear at the top of the discover page.",
            price: "$19.99",
            gradient_colors: "orange_red",
            icon: "star.fill",
            colors: nil,
            action: {
                print("Top Placement tapped")
            }
        ),
        BoostModel(
            id: 3,
            title: "Premium Promotion",
            sub_title: "Maximum exposure",
            description: "Get premium promotion across the app for maximum engagement.",
            price: "$29.99",
            gradient_colors: "blue_teal",
            icon: "crown.fill",
            colors: nil,
            action: {
                print("Premium Promotion tapped")
            }
        )
    ]
}
//
//struct PromoteShowSheet: View {
//    @Binding var  boosts : [BoostModel]
//    var onClose: () -> Void
//    var onBoostCardClick: (BoostModel) -> Void
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Text("Promote Show")
//                    .font(.custom(poppinsBold, size: 16.0))
//                Spacer()
//                Button(action: onClose) {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal)
//            
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    ForEach(0 ..< boosts.count,id: \.self) { index in
//                        let boost = boosts[index]
//                        BoostCardView(boost: boost) { data in
//                            onBoostCardClick(data)
//                        }
//                    }
//                }
//                .padding([.horizontal, .bottom])
//            }
//        }
//        .edgesIgnoringSafeArea(.top)
//        .background(Color.white)
//        .cornerRadius(20)
////        .padding()
//    }
//    
//}
//




import SwiftUI

struct PromoteShowSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var  boosts : [BoostModel]
    
    var onPromotionSelected: ((BoostModel) -> Void)?
        var onClose: () -> Void
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Promote Show")
                        .font(.custom(poppinsBold, size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(.white))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(0 ..< boosts.count,id: \.self) { index in
                            let boost = boosts[index]
                            PromotionCard(
                                option: boost,
                                onTap: {
                                    onPromotionSelected?(boost)
//                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                
                // Footer Note
                Text("Prices shown in USD. Actual boost duration may vary.")
                    .font(.custom(poppinsRegular, size: 11))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
//                    .background(Color(.systemGray6).opacity(0.3))
            }
        }
        .background(.backGround)
    }
}

// MARK: - Promotion Card
struct PromotionCard: View {
    let option: BoostModel
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.defaultTheme.opacity(0.8),
                                    Color.defaultTheme
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    CustomProfileImage(url: option.icon ?? "",isCircular:  true,size: 18)
//                    Image(systemName: option.icon ?? "")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.white)
                }
                
                Text(option.title ?? "")
                    .font(.custom(poppinsSemiBold, size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            
            // Description
            Text(option.description ?? "")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.gray)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            // Promote Button
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Text("Promote Show")
                        .font(.custom(poppinsSemiBold, size: 14))
                    
                    Text("•")
                        .font(.custom(poppinsSemiBold, size: 14))
                    
                    Text(option.price ?? "0.00")
                        .font(.custom(poppinsSemiBold, size: 14))
                }
                .foregroundColor(.white)
                .frame(width: 200)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.defaultTheme,
                                    Color.defaultTheme.opacity(0.85)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(
                    color: Color.defaultTheme.opacity(0.3),
                    radius: isPressed ? 8 : 12,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.75)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.15),
                            Color.gray.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
//
//#Preview {
//
//    PromoteShowSheet(
//        boosts: .constant(BoostModel.dummyBoosts),
//        onPromotionSelected: { selectedBoost in
//            print("Selected: \(selectedBoost.title) - \(selectedBoost.price)")
//        },
//        onClose: { print(" Close") }
//    )
//}
