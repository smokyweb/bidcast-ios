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
        Requirement(title: "Minimum 4.5 Rating", description: "Maintain high customer satisfaction", isMet: false),
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
                    VStack(spacing: 8) {
                        Image(.shop)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(height: 20)
                        Text("Become a Premier Shop")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        Text("Join the elite sellers and unlock exclusive benefits")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity,maxHeight: 200)
                    .background(Color.red)
                    
                    // Shop Status Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "bag.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text("Your Shop")
                                    .font(.headline)
                                Text("Regular Member")
                                    .font(.caption)
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
                    
                    // Benefits Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Premier Benefits")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(benefits) { benefit in
                                BenefitView(benefit: benefit)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Requirements Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requirements")
                            .font(.headline)
                        ForEach(requirements) { req in
                            RequirementView(requirement: req)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Review Process
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review Process")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.red)
                                VStack(alignment: .leading) {
                                    Text("Monthly Evaluation")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("Performance reviewed every 30 days")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack {
                                Text("Current Progress")
                                Spacer()
                                Text("\(Int(progress * 100))%")
                            }
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .red))
                            
                            Text("Next review in \(daysUntilReview) days")
                                .font(.caption)
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
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
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
