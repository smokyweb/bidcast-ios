//
//  SheetHeader.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 15/01/26.
//

import Foundation

import SwiftUI

struct PrimarySheetHeader: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {

            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            HStack  {
                // Title (centered)
                Text(title)
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.primary)

                // Close Button (right aligned)
               
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.custom(poppinsSemiBold, size: 24.0))
                            .foregroundColor(.black)
                    }
                
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
        }
    }
}
