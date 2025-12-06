//
//  FreeShippingView.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI


//
//// MARK: - 4. Domestic Shipments Screen
//struct DomesticShipmentsScreen: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedMethod: String? = nil
//    
//    let shipmentMethods = [
//        ShipmentMethod(
//            category: "Eligible Shipments under 3 oz",
//            methods: [
//                Method(icon: "envelope.fill", name: "USPS First-Class Mail Letter", description: "For shipments under $20 that weigh 3 oz or less in Trading Card Games, Sports Cards, or Stickers categories. View the full criteria here.")
//            ]
//        ),
//        ShipmentMethod(
//            category: "Domestic Shipments from 1 to 5 lbs",
//            methods: [
//                Method(icon: "box.truck.fill", name: "USPS Priority Mail", description: "Arrives in 1-3 business days. Best for time-sensitive shipments."),
//                Method(icon: "shippingbox.fill", name: "USPS Flat-Rate Boxes", description: "Ships at a fixed rate within the United States, regardless of weight or distance. Learn More")
//            ]
//        ),
//        ShipmentMethod(
//            category: "Domestic Shipments over 5 lbs",
//            methods: [
//                Method(icon: "box.truck.fill", name: "USPS Priority Mail", description: "Arrives in 1-3 business days. Best for time-sensitive shipments."),
//                Method(icon: "shippingbox.fill", name: "USPS Flat-Rate Boxes", description: "Ships at a fixed rate within the United States, regardless of weight or distance. Learn More"),
//                Method(icon: "cube.box.fill", name: "USPS Ground Advantage", description: "Best for shipping heavier items that aren't time-sensitive. Learn More")
//            ]
//        )
//    ]
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header
//            HStack {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.primary)
//                }
//                
//                Spacer()
//                
//                Text("Domestic Shipments")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 20))
//                    .opacity(0)
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//            .background(Color(.systemBackground))
//            
//            Divider()
//            
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Info Box
//                    HStack(spacing: 12) {
//                        Image(systemName: "info.circle.fill")
//                            .font(.system(size: 20))
//                            .foregroundColor(.blue)
//                        
//                        Text("All orders falling outside of your shipping preferences will default to USPS Ground Advantage. Eligible sellers will default to Media Mail shipping.")
//                            .font(.system(size: 14, weight: .regular))
//                            .foregroundColor(.secondary)
//                            .fixedSize(horizontal: false, vertical: true)
//                    }
//                    .padding(16)
//                    .background(
//                        RoundedRectangle(cornerRadius: 14)
//                            .fill(Color.blue.opacity(0.05))
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 14)
//                            .stroke(Color.blue.opacity(0.1), lineWidth: 1)
//                    )
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                    
//                    // Shipment Methods
//                    ForEach(shipmentMethods) { shipmentMethod in
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text(shipmentMethod.category)
//                                .font(.system(size: 18, weight: .bold))
//                                .foregroundColor(.primary)
//                                .padding(.horizontal, 20)
//                            
//                            VStack(spacing: 12) {
//                                ForEach(shipmentMethod.methods) { method in
//                                    Ship
