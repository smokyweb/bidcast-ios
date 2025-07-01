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
    var fontTitle: String = poppinsRegular
    var fontSize: Double = 13.0

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(segments.indices, id: \.self) { index in
                    let segment = segments[index]
                    VStack(spacing: 0) {
                        Button(action: {
                            selectedSegment = segment
                            onSegmentChanged?(segment)
                        }) {
                            Text(segment.description)
                                .font(.custom(fontTitle, size: fontSize))
                                .foregroundColor(getForegroundColor(for: segment))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16) // Dynamic width padding
                                .background(
                                    Capsule()
                                        .fill(getBackgroundColor(for: segment))
                                )
                        }
                        .padding(.vertical, 2)

                        // Line under selected segment
                        if !isWithBorder && selectedSegment == segment {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(getLineColor(for: segment))
                                .padding(.top, 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    //MARK: getForegroundColor.
    private func getForegroundColor(for segment: T) -> Color {
        if isWithBorder {
            return selectedSegment == segment ? .white : .navyBlue
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
