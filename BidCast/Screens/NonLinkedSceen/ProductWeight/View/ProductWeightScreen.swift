//
//  ProductWeightScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

struct ProductWeightScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var weight: String
    @Binding var selectedUnit: String
    @Binding var isHazardous: Bool

    var unitOptions: [String]
    var quickWeights: [String]
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Custom Primary Header
            PrimaryHeader(
                title: "Enter Product Weight",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)
            .frame(height: 40)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Info Box
                    HStack(alignment: .top) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("BidCast calculates shipping fees based on the product weight. You can adjust this later if needed.")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)

                    // Item Weight Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item Weight")
                            .font(.subheadline)

                        HStack(spacing: 10) {
                            TextField("0.00", text: $weight)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.black)
                                .cornerRadius(8)

                            Menu {
                                ForEach(unitOptions, id: \.self) { unit in
                                    Button(unit) {
                                        selectedUnit = unit
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedUnit)
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .foregroundColor(.black)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }

                    // Quick Weights
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(quickWeights, id: \.self) { qw in
                            Button(action: {
                                weight = qw.replacingOccurrences(of: " oz", with: "")
                            }) {
                                Text(qw)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }

                    // Hazardous Material Toggle
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hazardous Material")
                                .font(.subheadline)
                            Spacer()
                            Toggle("", isOn: $isHazardous)
                                .labelsHidden()
                        }

                        Text("Items containing flammable, explosive, or other dangerous materials. ")
                            .font(.caption)
                            + Text("Learn more about hazardous materials")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

                    Spacer(minLength: 100)
                }
                .padding()
            }

            // Continue Button
            VStack {
                Button(action: {
                    onContinue()
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 1.0, green: 0.4, blue: 0.4))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.white)
        }
        .padding()
    }
}
