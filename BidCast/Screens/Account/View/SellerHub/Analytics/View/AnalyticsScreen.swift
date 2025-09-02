//
//  AnalyticsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

struct AnalyticsScreen: View {
    let stats: [StatItem] = [
        StatItem(label: AppString.Shows, value: "284"),
        StatItem(label: AppString.Views, value: "12.4k"),
        StatItem(label: AppString.Followers, value: "892")
    ]
    
    @State private var navigateToLesson = false
    @State var segment : AnalyticsSegment = .overall
    @Environment(\.presentationMode) var presentationMode
    
    struct ToolItem: Identifiable {
        let id = UUID()
        let iconName: String
        let title: String
        let subtitle: String
        let iconColor: Color
    }

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
                                ToolGridItemsView(tool: tool)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
    }
    
    struct ToolGridItemsView: View {
        let tool: ToolItem

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: tool.iconName)
                    .font(.custom(poppinsSemiBold, size: 16.0))
                    .foregroundColor(tool.iconColor)
                Text(tool.title)
                    .font(.custom(poppinsSemiBold, size: 16.0))
                Text(tool.subtitle)
                    .font(.custom(poppinsRegular, size: 14.0))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color(.systemGray6))
            .cornerRadius(12)
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







