//
//  ToolGridAnalyticsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUICore
import SwiftUI

struct ToolGridAnalyticsView: View {
    let tool: ToolItem

    var body: some View {
        Image(tool.iconName)
            .resizable()
            .scaledToFill()
            .frame(height: 150)
            .clipped()
            .cornerRadius(12)
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

