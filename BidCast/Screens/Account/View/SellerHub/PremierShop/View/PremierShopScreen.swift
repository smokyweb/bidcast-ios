//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

import SwiftUI

// MARK: - StatMetric
struct StatMetric: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

// MARK: - Benefit
struct Benefit: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

// MARK: - Requirement
struct Requirement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isMet: Bool
}

// MARK: - MetricView
struct MetricView: View {
    let metric: StatMetric
    
    var body: some View {
        VStack {
            Text(metric.value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(metric.label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - PremierShopScreen
struct PremierShopScreen: View {
    // Dynamic content
    @Environment(\.presentationMode) var presentationMode
    let stats: [StatMetric] = [
        StatMetric(label: AppString.Rating, value: "4.2"),
        StatMetric(label: AppString.Response, value: "89%"),
        StatMetric(label: AppString.Delivery, value: "95%")
    ]
    
    let benefits: [Benefit] = [
        Benefit(icon: "percent", title: AppString.ReducedCommission, description: AppString.PayOnlyCommission),
        Benefit(icon: "person.crop.circle.badge.checkmark", title: AppString.UniqueProfileID, description: AppString.CustomURLForYourShop),
        Benefit(icon: "megaphone.fill", title: AppString.MarketingBoost, description: AppString.PriorityInSearchResults),
        Benefit(icon: "headphones", title: AppString.PrioritySupport, description: AppString.DedicatedAssistance)
    ]
    
    let requirements: [Requirement] = [
        Requirement(title: AppString.MinimumRating, description: AppString.MaintainHighCustomerSatisfaction, isMet: true),
        Requirement(title: AppString.ResponseRate, description: AppString.QuickRepliesToCustomerInquiries, isMet: true),
        Requirement(title: AppString.OnTimeDelivery, description: AppString.ConsistentShippingPerformance, isMet: true),
        Requirement(title: AppString.MonthsActive, description: AppString.RegularSellingHistory, isMet: true)
    ]
    
    // Progress simulation
    let progress: Double = 0.75
    let daysUntilReview: Int = 7
    
    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: AppString.PremierShop,
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                count: .constant(0)
            )
            .padding(.horizontal)
            .frame(height: 50)
            .background(Color(.systemBackground))
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    ZStack(alignment: .top) {
                        VStack(spacing: 8) {
                            Image(.shop)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(height: 40)
                            Text(AppString.BecomeAPremierShop)
                                .font(.custom(poppinsBold, size: 14.0))
                                .foregroundColor(.white)
                            Text(AppString.JoinTheEliteEellers)
                                .font(.custom(poppinsRegular, size: 12.0))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .padding(.bottom,80)
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .background(LinearGradient(colors: [Color.defaultTheme.opacity(0.9), Color.defaultTheme], startPoint: .top, endPoint: .bottom))
                        Spacer()
                        // Shop Status Card
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "bag.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.defaultTheme)
                                VStack(alignment: .leading) {
                                    Text(AppString.YourShop)
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                    Text(AppString.RegularMember)
                                        .font(.custom(poppinsRegular, size: 12.0))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            
                            HStack {
                                ForEach(stats) { stat in
                                    MetricView(metric: stat)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .offset(y: 150)
                    }
                    .padding(.bottom, 50)
                    
                    
                    // Benefits Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppString.PremierBenefits)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(benefits) { benefit in
                                BenefitView(benefit: benefit)
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Requirements Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppString.Requirements)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        ForEach(requirements) { req in
                            RequirementView(requirement: req)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Review Process
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppString.ReviewProcess)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.defaultTheme)
                                VStack(alignment: .leading) {
                                    Text(AppString.MonthlyEvaluation)
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                        .fontWeight(.semibold)
                                    Text(AppString.PerformanceReviewed)
                                        .font(.custom(poppinsRegular, size: 11.0))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack {
                                Text(AppString.CurrentProgress)
                                    .font(.custom(poppinsRegular, size: 13.0))
                                Spacer()
                                Text("\(Int(progress * 100))%")
                            }
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .defaultTheme))
                            
                            Text("Next review in \(daysUntilReview) days")
                                .font(.custom(poppinsRegular, size: 11.0))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Action Button
                    Button(action: {
                        // Action: Apply for Premier Status
                    }) {
                        Text(AppString.ApplyForPremierStatus)
                            .foregroundColor(.white)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.defaultTheme)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - Preview
struct PremierShopView_Previews: PreviewProvider {
    static var previews: some View {
        PremierShopScreen()
    }
}
