//
//  FAQCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//


import SwiftUI

struct FAQCell: View {
    let title: String
    let content: String
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.mediumLightGray)
            }
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }

            // Expandable Content
            if isExpanded {
                Text(content)
                    .font(.body)
                    .transition(.opacity.combined(with: .slide))
                    .padding(.top , 10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

