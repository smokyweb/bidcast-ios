//
//  AnalyticsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

// MARK: - AnalyticsScreen
struct AnalyticsScreen: View {
    let stats: [StatItem] = [
        StatItem(value: "284", label: "Shows"),
        StatItem(value: "12.4k", label: "Views"),
        StatItem(value: "892", label: "Followers")
    ]
    
    @State private var navigateToLesson = false
    @State var segment : AnalyticsSegment = .overall
    @Environment(\.presentationMode) var presentationMode

    let tools: [ToolItem] = [
        ToolItem(iconName: "square.and.arrow.up", title: "Share", subtitle: "Share your show on social media", iconColor: .red),
        ToolItem(iconName: "rectangle.stack.badge.plus", title: "Ads", subtitle: "Create ads for your shows", iconColor: .red),
        ToolItem(iconName: "person.2.fill", title: "Audience", subtitle: "Grow your audience", iconColor: .red),
        ToolItem(iconName: "chart.bar.fill", title: "Analytics", subtitle: "Track performance", iconColor: .red)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Fixed PrimaryHeader at the top
            VStack{
                PrimaryHeader(
                    title: "Analytics",
                    isForBoth: true,
                    leadingImgArr: [.icBack,.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            
            // Scrollable content below the header
            ScrollView {
                VStack(spacing: 8) {
                    
                    ListCell(image: UserDefaults.profileURL, title: UserDefaults.userName,subLabel : "Seller since 2025",isVectorImgHidden: true)
                        .padding(.bottom,1)
                        .frame(height: 80)
                    
                    CustomSegmentedControl(preselectedIndex: $segment ,
                                           options: AnalyticsSegment.allCases)
                    .padding(.horizontal , 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                            
                            VStack(spacing: 16) {
                                ToolGridAnalyticsView(
                                    title: "Sales Performance",
                                    chartData: [0.3, 0.7, 0.5, 0.9, 0.4],
                                    chartType: .bar
                                )

                                ToolGridAnalyticsView(
                                    title: "Visitor Analytics",
                                    chartData: [0.2, 0.4, 0.6, 0.3, 0.8],
                                    chartType: .line
                                )
                            }
                            .padding(.vertical)
                        }
//                        .padding(.horizontal)
                        .padding(.top,10)
                        
                        // Tools Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(tools) { tool in
                                ToolGridItemView(tool: tool)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
    }

}


//MARK: AnalyticsSegment
enum AnalyticsSegment : String, CaseIterable, CustomStringConvertible{
    case overall = "Overall"
    case livestream = "Livestream"
    case promote = "Promote"
    case trust = "Trust"
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}
