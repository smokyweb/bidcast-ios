//
//  ActitivityCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 13/05/25.
//

import SwiftUI

struct ActivityCell: View {
    var isFor: String?
    
    var body: some View {
        VStack(spacing: 10) {
            
            // ── First row ─────────────────────────────
            if isFor == "Message" || isFor == "Bids" || isFor == "Offers" || isFor == "OffersScreen" {
                HStack(alignment: .center, spacing: 10) {
                    Image("IMG_2678")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .padding(.leading, 16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TitleWithLine(title: "Testing", lineLength: 0, textColor: .black, fontValue: 12, divderHeight: 0)
                        TitleWithLine(title: "TestingTwo", lineLength: 0, textColor: .lightGray, fontValue: 12, divderHeight: 0)
                    }
                    
                    if isFor != "OffersScreen" {
                        SingleTitleLabel(title: "Testing", lineLength: 0, textColor: .black, fontValue: 12)
                            .padding(.trailing, 20)
                    }
                }
                .frame(height: 50)
                .padding([.top, .bottom], 12)
            }
            
            // ── Second row ─────────────────────────────
            if isFor == "Bids" || isFor == "Offer" || isFor == "Purchases" || isFor == "Saved Items" || isFor == "Offers" || isFor == "OffersScreen"  {
                HStack(alignment: .center, spacing: 10) {
                    Image(.dummy1)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .cornerRadius(12)
                        .padding(.leading, 16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TitleWithLine(title: "Testing", lineLength: 0, textColor: .black, fontValue: 12, divderHeight: 0)
                        TitleWithLine(title: "TestingTwo", lineLength: 0, textColor: .lightGray, fontValue: 12, divderHeight: 0)
                        
                        if isFor == "OffersScreen" {
                            TitleWithLine(title: "TestingThree", lineLength: 0, textColor: .lightGray, fontValue: 12, divderHeight: 0)
                        }
                    }
                    if isFor != "OffersScreen" {
                        SingleTitleLabel(title: "Testing", lineLength: 0, textColor: .success, fontValue: 12)
                            .padding(.trailing, 20)
                    }
                }
                .padding([.top, .bottom], 16)
            }
            
            // ── Third row ─────────────────────────────
            if isFor == "Offers" || isFor == "OffersScreen" {
                HStack(alignment: .center, spacing: 10) {
                    TwoButton()
                }
                .frame(height: 50)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
        .padding(5)
        .shadow(color: .squirrelGrey.opacity(0.5), radius: 2, x: 0, y: 0)
    }
}

#Preview {
    ActivityCell(isFor: "OffersScreen")
}
