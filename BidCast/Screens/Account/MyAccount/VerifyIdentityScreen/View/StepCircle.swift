//
//  StepCircle.swift
//  BidCast
//
//  Created by JAM_E_329 on 12/06/25.
//

import SwiftUI

struct StepCircle: View {
    var step: String
    var label: String
    var isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.blue : Color.gray.opacity(0.4))
                .frame(width: 28, height: 28)
                .overlay(
                    Text(step)
                        .font(.caption)
                        .foregroundColor(.white)
                )
            Text(label)
                .font(.caption)
                .foregroundColor(isActive ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}
