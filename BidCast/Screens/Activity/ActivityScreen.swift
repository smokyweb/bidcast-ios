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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
//        ZStack{
        VStack(spacing: 0) {
            // Fixed Header
            VStack{
                PrimaryHeader(
                    title: "Activity",
                    isForLogo : true, leadingImgArr: [.appName],
                    trailingImgArr: [.notification],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                //.frame(height: 80)
                .padding(.horizontal,12)
                .shadow(radius: 2)
                .background(Color.white)
               
            }
            .padding(.horizontal,12)
            .background(Color.white)
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    SegmentedControlView(
                        segments: Segment.allCases,
                        selectedSegment: $selected,
                        isWithBorder: false
                    )
                    .frame(height: 40)
                    ActivityCell(isFor: selected.rawValue)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.top)
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
