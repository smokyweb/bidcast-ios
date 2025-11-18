//
//  PillSelectorView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

struct PillsSelectorView: View {
    let titles: [String]
    @Binding var selectedIndex: Int
    var isPillRequired: Bool = true

    var body: some View {
        HStack(spacing: 10) {
            ForEach(titles.indices, id: \.self) { index in
                let isSelected = selectedIndex == index
                if isPillRequired {
                    Text(titles[index])
                        .font(.custom(poppinsMedium, size: 14.0))
                        .foregroundColor(isSelected ? .white : .black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            isSelected
                            ? Color.defaultTheme
                            : Color.gray.opacity(0.1)  // light yellow
                        )
                        .clipShape(Capsule())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                selectedIndex = index
                            }
                        }
                }
                else {
                    Text(titles[index])
                        .font(.custom(poppinsBold, size: 14.0))
                        .foregroundColor(isSelected ? .black : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 1)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                selectedIndex = index
                            }
                        }
                }
            }
        }
    }
}
