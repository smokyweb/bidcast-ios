//
//  PromoteShowSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import SVProgressHUD

struct ShowBoost: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let price: String
    let iconName: String
    let gradient: LinearGradient
    let action: () -> Void
}

struct PromoteShowSheet: View {
    @Binding var  boosts : [BoostModel]
    var onClose: () -> Void
    var onBoostCardClick: (BoostModel) -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Promote Show")
                    .font(.custom(poppinsBold, size: 16.0))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(0 ..< boosts.count,id: \.self) { index in
                        let boost = boosts[index]
                        Button {
                            onBoostCardClick(boost)
                        } label: {
                            BoostCardView(boost: boost)
                        }

                       
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.white)
        .cornerRadius(20)
//        .padding()
    }
   
}
