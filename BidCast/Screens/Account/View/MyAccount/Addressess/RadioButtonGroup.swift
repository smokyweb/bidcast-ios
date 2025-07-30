//
//  RadioButtonGroup.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 30/07/25.
//

import SwiftUI

struct RadioButtonGroup: View {
    var options: [String]
    @Binding var selected: String
    var onSelect: ((String) -> Void)? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(options, id: \.self) { type in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .strokeBorder(selected == type ? .defaultTheme : Color.gray.opacity(0.4), lineWidth: 2)
                                .frame(width: 20, height: 20)

                            if selected == type {
                                Circle()
                                    .fill(.defaultTheme)
                                    .frame(width: 10, height: 10)
                            }
                        }

                        Text(type)
                            .font(.custom(poppinsBold, size: 13.0))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.clear)
                    .cornerRadius(10)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(selected == type ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 1)
//                    )
                    .onTapGesture {
                        selected = type
                        onSelect?(type)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
