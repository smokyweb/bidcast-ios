//
//  ToolGridItemView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUICore

struct ToolGridItemView: View {
    let tool: ToolItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: tool.iconName)
                .font(.custom(poppinsSemiBold, size: 16.0))
                .foregroundColor(tool.iconColor)
            Text(tool.title)
                .font(.custom(poppinsSemiBold, size: 16.0))
            Text(tool.subtitle)
                .font(.custom(poppinsRegular, size: 14.0))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
