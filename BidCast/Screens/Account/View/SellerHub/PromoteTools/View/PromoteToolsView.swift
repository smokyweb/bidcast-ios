//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

// MARK: - Models

struct StatItem: Identifiable {
    let id = UUID()
    let value: String
    let label: String
}

struct ToolItem: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let subtitle: String
    let iconColor: Color
}


// MARK: - PromoteToolsView
struct PromoteToolsView: View {
    let stats: [StatItem] = [
        StatItem(value: "284", label: "Shows"),
        StatItem(value: "12.4K", label: "Views"),
        StatItem(value: "892", label: "Followers")
    ]
    @State private var navigateToLesson = false
    @Environment(\.presentationMode) var presentationMode
    
    let tools: [ToolItem] = [
        ToolItem(iconName: "square.and.arrow.up", title: AppString.share, subtitle: AppString.ShareYourShowOnSocialMedia, iconColor: .defaultTheme),
        ToolItem(iconName: "rectangle.stack.badge.plus", title: AppString.Ads, subtitle: AppString.CreateAdsForYourShows, iconColor: .defaultTheme),
        ToolItem(iconName: "person.2.fill", title: AppString.Audience, subtitle: AppString.GrowYourAudience, iconColor: .defaultTheme),
        ToolItem(iconName: "chart.bar.fill", title: AppString.Analytics, subtitle: AppString.TrackPerformance, iconColor: .defaultTheme)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack{
                // Fixed PrimaryHeader at the top
                PrimaryHeader(
                    title: AppString.Promote,
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
                VStack(spacing: 24) {
                    HStack{
                        Image("promote")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50,height: 50)
                            
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(AppString.PromoteYourShows)
                                .font(.custom(poppinsSemiBold, size: 18.0))
                                .fontWeight(.semibold)
                            Text(AppString.ReachMoreBuyersAndGrowYourAudience)
                                .font(.custom(poppinsRegular, size: 14.0))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        Spacer()
                    }.padding(.horizontal)
                    
                    // Stats
                    HStack {
                        ForEach(stats) { stat in
                            StatView(stat: stat)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tools Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(tools) { tool in
                            ToolGridItemView(tool: tool)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Learn More Section
                    VStack(spacing: 12) {
                        Text(AppString.LearnHowtoPromote)
                            .font(.custom(poppinsSemiBold, size: 16.0))
                            .foregroundColor(.white)
                        Text(AppString.GetTipsAndStrategiesToGrowYourLiveShows)
                            .font(.custom(poppinsSemiBold, size: 14.0))
                            .foregroundColor(.white.opacity(0.9))
                        Button(action: {
                            navigateToLesson = true
                        }) {
                            Text(AppString.startLearning)
                                .font(.custom(poppinsSemiBold, size: 13.0))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.defaultTheme)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(.defaultTheme)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
               
            }
        }
        CusNavLink(doNavigate: $navigateToLesson, destination: LessonScreen())
//        CusNavLink(doNavigate: $navigateToLesson, destination: CombinedLessonTipsView())
    }
    
}

// MARK: - Preview

struct PromoteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        PromoteToolsView()
    }
}
