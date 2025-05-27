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
        StatItem(value: "12.4k", label: "Views"),
        StatItem(value: "892", label: "Followers")
    ]
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
                PrimaryHeader(
                    title: "Promote",
                    isForLogo: true,
                    leadingImgArr: [.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .padding(.horizontal)
                .padding(.bottom, 10)
                .frame(height: 50)

                // Scrollable content below the header
                ScrollView {
                    VStack(spacing: 24) {
                        
//                        ForEach(0 ..< categoryList.count, id: \.self) { ind in
//    //                            print("\(ind)")
//    //                            print(self.title[ind])
//                            ListCell( isComeFrom: "ShippingScreen",image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : "BidSwipe",tintColot: categoryList[ind].color ?? "")
//                               
//                           
//                        }
                        
                        // Stats
                        HStack {
                            ForEach(stats) { stat in
                                StatView(stat: stat)
                            }
                        }
                        .padding(.horizontal)

                        // Tools Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(tools) { tool in
                                ToolGridItemView(tool: tool)
                            }
                        }
                        .padding(.horizontal)

                        // Learn More Section
                        VStack(spacing: 12) {
                            Text("Learn How to Promote")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Get tips and strategies to grow your live shows")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            Button(action: {}) {
                                Text("Start Learning")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .foregroundColor(.red)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color.red)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
    }

}

// MARK: - Preview

struct PromoteToolsView_Previews: PreviewProvider {
    static var previews: some View {
        PromoteToolsView()
    }
}
