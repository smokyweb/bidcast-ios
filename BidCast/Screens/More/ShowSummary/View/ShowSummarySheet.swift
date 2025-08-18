//
//  ShowSummarySheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI


struct ShowSummarySheet: View {
    let avatarImage: Image
    let showTitle: String
    let showDuration: String
    let estimatedSales: String
    let salesGrowth: String
    let totalOrders: String
    let orderGrowth: String
    var onShare: () -> Void
    var onAnalytics: () -> Void
    var onSettings: () -> Void
    var onEndShow: () -> Void
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 10) {
                    avatarImage
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(showTitle)
                            .font(.headline)
                        Text("Show Time: \(showDuration)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(8)
                }
            }

            Divider()

            // Sales Info
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Estimated Sales")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        Text(estimatedSales)
                            .font(.title3).bold()
                        Text(salesGrowth)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Orders")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        Text(totalOrders)
                            .font(.title3).bold()
                        Text(orderGrowth)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Actions
            HStack(spacing: 32) {
                VStack {
                    Button(action: onShare) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 50, height: 50)
                            .overlay(
                                    Image(systemName: "arrowshape.turn.up.right.fill")
                                        .foregroundColor(.black)
                                )
                    }
                    Text("Share")
                        .font(.footnote)
                }

                VStack {
                    Button(action: onAnalytics) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 50, height: 50)
                            .overlay(
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.black)
                            )
                            
                            
                    }
                    Text("Analytics")
                        .font(.footnote)
                }

                VStack {
                    Button(action: onSettings) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 50, height: 50)
                            .overlay(
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.black)
                        )
                           
                    }
                    Text("Settings")
                        .font(.footnote)
                }
            }

            // End Show Button
            Button(action: onEndShow) {
                Text("End Show")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.defaultTheme)
                    .cornerRadius(40)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.top, 10)
    }
}
