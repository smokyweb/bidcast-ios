//
//  ActivityScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUICore
import SwiftUI

struct ActivityScreen: View {
    @State private var selected: Segment = .message
    var lineLength: CGFloat = 32
    var divderHeight : CGFloat = 2

    var body: some View {
        VStack(spacing: 20) {
            SegmentedControlView(
                segments: Segment.allCases,
                selectedSegment: $selected,
                isWithBorder: false
            )
            ScrollView {
                ActivityCell(isFor: selected.rawValue)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}


// Enum for the segmented control (for illustration)
enum Segment: String, CaseIterable, CustomStringConvertible {
    case message = "Message"
    case bid = "Bids"
    case offer = "Offers"
    case purchases = "Purchases"
    case savedItems = "Saved Items"
    
    var description: String {
        return rawValue
    }
}
