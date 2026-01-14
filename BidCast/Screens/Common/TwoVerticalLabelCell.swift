//
//  TwoVerticalLabelCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 15/05/25.
//

import Foundation
import SwiftUI

struct TwoVerticalLabelCell<T: Hashable & CustomStringConvertible>: View {
    let dataModel: [T]
    let topLabel: (T) -> String
    let bottomLabel: (T) -> String

    @Binding var selection: T?
    let onItemTap: ((T) -> Void)?

    var h1fontname = poppinsSemiBold
    var h1fontSize = 15.0
    var h2fontname = poppinsRegular
    var h2fontSize = 12.0

    let columns: [GridItem]

    init(
        dataModel: [T],
        topLabel: @escaping (T) -> String,
        bottomLabel: @escaping (T) -> String,
        selection: Binding<T?>? = nil,
        onItemTap: ((T) -> Void)? = nil,
        h1fontname: String = poppinsSemiBold,
        h1fontSize: Double = 15.0,
        h2fontname: String = poppinsRegular,
        h2fontSize: Double = 12.0,
        columnsPerRow: Int = 3, // 🔥 You can control columns here
        spacing: CGFloat = 16 // 🔥 Control item spacing here
    ) {
        self.dataModel = dataModel
        self.topLabel = topLabel
        self.bottomLabel = bottomLabel
        self._selection = selection ?? .constant(nil)
        self.onItemTap = onItemTap
        self.h1fontname = h1fontname
        self.h1fontSize = h1fontSize
        self.h2fontname = h2fontname
        self.h2fontSize = h2fontSize
        self.columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnsPerRow)
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 6) {
            ForEach(dataModel, id: \.self) { item in
                VStack(alignment: .center, spacing: 6) {
                    Text(topLabel(item))
                        .font(.custom(h1fontname, fixedSize: h1fontSize))
                        .foregroundColor(.black)

                    Text(bottomLabel(item))
                        .font(.custom(h2fontname, fixedSize: h2fontSize))
                        .foregroundColor(.lightText)
                }
                .frame(maxWidth: .infinity,minHeight: 70) // 🟢 Auto-stretch to fit the cell
                .aspectRatio(1, contentMode: .fill) // 🟢 Square cells
                .background(selection == item ? Color.defaultThemeLight : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selection == item ? Color.defaultTheme : Color.clear, lineWidth: 1)
                )
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .contentShape(Rectangle())
                .onTapGesture {
                    selection = item
                    onItemTap?(item) // 🔥 callback
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
