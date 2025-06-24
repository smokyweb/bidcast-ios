//
//  SegmentedControlView.swift
//  BidCast
//
//  Created by JAM_E_329 on 12/05/25.
//

import SwiftUI

struct SegmentedControlView<T: Hashable & CustomStringConvertible>: View {
    let segments: [T]
    @Binding var selectedSegment: T
    var isWithBorder: Bool = false
    var onSegmentChanged: ((T) -> Void)?
    var fontTitle : String = poppinsRegular
    var fontSize : Double = 13.0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) { // Make the HStack scrollable
            HStack(spacing: 8) {
                ForEach(segments.indices, id: \.self) { index in
                    let segment = segments[index]
                    VStack(alignment:.leading) {
                        Button(action: {
                            selectedSegment = segment
                            onSegmentChanged?(segment)
                        }) {
                            Text(segment.description)
                                .font(.custom(fontTitle, size: fontSize))
                                .foregroundColor(getForegroundColor(for: segment))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 6)
                                .background(
                                    Capsule()
                                        .fill(getBackgroundColor(for: segment))
                                )
                               
                        }
                        
                        .frame(height: 40)
                        .padding(.vertical,2)
                        
                        // Line under selected segment
                        if !isWithBorder {
                            if selectedSegment == segment {
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(getLineColor(for: segment))
                                    .padding(.bottom, -1)
                            }
                        }
                    }
                }
            }
//            .padding(.horizontal) // Add horizontal padding around the entire HStack for spacing
        }
//        .frame(maxWidth: .infinity) // Make sure it takes up full width
    }
    
    //MARK: getForegroundColor.
    private func getForegroundColor(for segment: T) -> Color {
        if isWithBorder {
            return selectedSegment == segment ? .white : .mediumGray
        } else {
            return selectedSegment == segment ? .darkBlue : .mediumGray
        }
    }
    
    //MARK: getBackgroundColor.
    private func getBackgroundColor(for segment: T) -> Color {
        if isWithBorder {
            return selectedSegment == segment ? .defaultTheme : .bg
        } else {
            return selectedSegment == segment ? .clear : .clear
        }
    }
    
    //MARK: getLineColor.
    private func getLineColor(for segment: T) -> Color {
        if isWithBorder {
            return selectedSegment == segment ? .clear : .clear
        } else {
            return selectedSegment == segment ? .darkBlue : .clear
        }
    }
}
