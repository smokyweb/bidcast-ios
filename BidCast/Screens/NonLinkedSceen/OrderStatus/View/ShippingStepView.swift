//
//  ShippingStepView.swift
//  BidCast
//
//  Created by jam 1 TB on 11/06/25.
//

import SwiftUI

struct ShippingStepView: View {
    var icon: String
    var title: String
    var subtitle: String
    var iconColor: Color
 
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
 
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
    }
}

