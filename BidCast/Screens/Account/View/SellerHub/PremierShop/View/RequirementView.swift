//
//  RequirementView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct RequirementView: View {
    let requirement: Requirement

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: requirement.isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(requirement.isMet ? .darkGreen : .gray)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(requirement.title)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    
                Text(requirement.description)
                    .font(.custom(poppinsRegular, size: 11.0))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading , 10)
    }
}

