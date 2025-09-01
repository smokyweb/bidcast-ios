//
//  RequirementView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

// MARK: - Requirement View
struct RequirementView: View {
    let requirement: PremierRequirement
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 6) {
                Text(requirement.platform ?? "")
                    .font(.custom(poppinsMedium, size: 16))
                Text(requirement.url ?? "")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading , 10)
    }
}
