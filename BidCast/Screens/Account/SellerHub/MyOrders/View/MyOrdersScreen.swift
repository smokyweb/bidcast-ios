//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

struct Order: Identifiable {
    let id = UUID()
    let orderNumber: String
    let date: String
    let name: String
    let location: String
    let image: Image
    let amount: String
    let status: String
    let statusColor: Color
}

// MARK: - MyOrdersScreen
struct MyOrdersScreen: View {
    @Environment(\.presentationMode) var presentationMode

    let orders: [Order] = [
        Order(orderNumber: "#ORD–2025–0123", date: "Jan 23, 2025, 14:30", name: "John Anderson", location: "Los Angeles, CA", image: Image("john"), amount: "$249.99", status: "Delivered", statusColor: .green),
        Order(orderNumber: "#ORD–2025–0122", date: "Jan 22, 2025, 09:15", name: "Sarah Miller", location: "New York, NY", image: Image("sarah"), amount: "$189.99", status: "Processing", statusColor: .blue),
        Order(orderNumber: "#ORD–2025–0121", date: "Jan 21, 2025, 16:45", name: "Emma Wilson", location: "Chicago, IL", image: Image("emma"), amount: "$329.99", status: "Pending", statusColor: .yellow)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // MARK: - Top Header (fixed)
                PrimaryHeader(
                    title: "My Orders",
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
                .frame(height: 30)


                // MARK: - Scrollable Order List
                ScrollView {
                    VStack(spacing: 16) {
                        TwoVerticalLabelCell(dataModel: MyOrderValue.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
                        ForEach(orders) { order in
                            OrderCardView(order: order)
                                .padding([.leading , .trailing] , 0)
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                }
            }
        }
        .background(Color.blue.opacity(0.05).ignoresSafeArea())
    }
}


// MARK: - MyOrderValue
enum MyOrderValue: String, CaseIterable, CustomStringConvertible {
    case newOrders, processing, completed

    var labelOlt: String {
        switch self {
        case .newOrders: return "24"
        case .processing: return "156"
        case .completed: return "892"
        }
    }

    var description: String {
        switch self {
        case .newOrders: return "New Orders"
        case .processing: return "Processing"
        case .completed: return "Completed"
        }
    }
}
#Preview {
    MyOrdersScreen()
}
