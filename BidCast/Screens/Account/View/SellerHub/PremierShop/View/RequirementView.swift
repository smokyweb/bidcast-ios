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
                .foregroundColor(requirement.isMet ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(requirement.title)
                    .font(.subheadline)
                    .bold()
                Text(requirement.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading , 10)
    }
}

