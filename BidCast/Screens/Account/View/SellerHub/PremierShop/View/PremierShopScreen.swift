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
        StatMetric(label: "Rating", value: "4.2"),
        StatMetric(label: "Response", value: "89%"),
        StatMetric(label: "Delivery", value: "95%")
    ]
    
    let benefits: [Benefit] = [
        Benefit(icon: "percent", title: "Reduced Commission", description: "Pay only 5% commission on sales"),
        Benefit(icon: "person.crop.circle.badge.checkmark", title: "Unique Profile ID", description: "Custom URL for your shop"),
        Benefit(icon: "megaphone.fill", title: "Marketing Boost", description: "Priority in search results"),
        Benefit(icon: "headphones", title: "Priority Support", description: "24/7 dedicated assistance")
    ]
    
    let requirements: [Requirement] = [
        Requirement(title: "Minimum 4.5 Rating", description: "Maintain high customer satisfaction", isMet: true),
        Requirement(title: "90% Response Rate", description: "Quick replies to customer inquiries", isMet: true),
        Requirement(title: "95% On-time Delivery", description: "Consistent shipping performance", isMet: true),
        Requirement(title: "3 Months Active", description: "Regular selling history", isMet: true)
    ]
    
    // Progress simulation
    let progress: Double = 0.75
    let daysUntilReview: Int = 7
    
    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Premier Shop",
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
                            Text("Become a Premier Shop")
                                .font(.custom(poppinsBold, size: 14.0))
                                .foregroundColor(.white)
                            Text("Join the elite sellers and unlock exclusive benefits")
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
                                    Text("Your Shop")
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                    Text("Regular Member")
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
                        Text("Premier Benefits")
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
                        Text("Requirements")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        ForEach(requirements) { req in
                            RequirementView(requirement: req)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Review Process
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review Process")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.defaultTheme)
                                VStack(alignment: .leading) {
                                    Text("Monthly Evaluation")
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                        .fontWeight(.semibold)
                                    Text("Performance reviewed every 30 days")
                                        .font(.custom(poppinsRegular, size: 11.0))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack {
                                Text("Current Progress")
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
                        Text("Apply for Premier Status")
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
