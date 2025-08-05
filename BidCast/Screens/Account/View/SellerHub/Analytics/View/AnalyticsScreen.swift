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
        StatItem(value: "284", label: AppString.Shows),
        StatItem(value: "12.4k", label: AppString.Views),
        StatItem(value: "892", label: AppString.Followers)
    ]
    
    @State private var navigateToLesson = false
    @State var segment : AnalyticsSegment = .overall
    @Environment(\.presentationMode) var presentationMode

    let tools: [ToolItem] = [
        ToolItem(iconName: "square.and.arrow.up", title: AppString.Shows, subtitle: AppString.ShareYourShowOnSocialMedia, iconColor: .defaultTheme),
        ToolItem(iconName: "rectangle.stack.badge.plus", title: AppString.Ads, subtitle: AppString.CreateAdsForYourShows, iconColor: .defaultTheme),
        ToolItem(iconName: "person.2.fill", title: AppString.Audience, subtitle: AppString.GrowYourAudience, iconColor: .defaultTheme),
        ToolItem(iconName: "chart.bar.fill", title: AppString.Analytics, subtitle: AppString.TrackPerformance, iconColor: .defaultTheme)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Fixed PrimaryHeader at the top
            VStack{
                PrimaryHeader(
                    title: AppString.Analytics,
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
                    
                    ListCell(image: UserDefaults.profileURL, title: UserDefaults.fullName,subLabel : "Seller since 2025",isVectorImgHidden: true)
                        .padding(.bottom,1)
                        .frame(height: 80)
                    
                    CustomSegmentedControl(preselectedIndex: $segment ,
                                           options: AnalyticsSegment.allCases)
                    .padding(.horizontal , 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                            
                            VStack(spacing: 16) {
                                ToolGridAnalyticsView(
                                    title: AppString.SalePerformance,
                                    chartData: [0.3, 0.7, 0.5, 0.9, 0.4],
                                    chartType: .bar
                                )

                                ToolGridAnalyticsView(
                                    title: AppString.VisitorAnalytics,
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
        return NSLocalizedString(rawValue, comment: "").localized
    }
}
