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
                .font(.title2)
                .foregroundColor(tool.iconColor)
            Text(tool.title)
                .font(.headline)
            Text(tool.subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
