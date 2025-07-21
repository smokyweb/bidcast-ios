//
//  SummaryRow.swift
//  BidCast
//
//  Created by JAM_E_329 on 11/06/25.
//

import SwiftUI

// MARK: - SummaryRow
struct SummaryRow: View {
    var label: String
    var value: Double
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.custom(isBold ? poppinsBold : poppinsSemiBold, size: 13.0))
            Spacer()
            Text(String(format: "$%.2f", value))
                .font(.custom(isBold ? poppinsBold : poppinsSemiBold, size: 13.0))
        }
    }
}

