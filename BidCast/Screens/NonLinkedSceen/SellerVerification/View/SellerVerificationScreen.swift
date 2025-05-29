//
//  SellerVerificationScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

enum VerificationStatus {
    case completed, pending, notStarted
}

struct VerificationStep: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    var actionTitle: String
    var status: VerificationStatus
    var action: () -> Void
}


struct SellerVerificationScreen: View {
    @Binding var isPresented: Bool

    @State private var steps: [VerificationStep] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Text("Seller Verification")
                    .font(.title3.bold())
                Spacer()
            }

            // Progress
            Text("Verification Progress")
                .font(.subheadline)
                .foregroundColor(.gray)

            ProgressView(value: Double(steps.filter { $0.status == .completed }.count),
                         total: Double(steps.count))
                .accentColor(.blue)

            Text("\(steps.filter { $0.status == .completed }.count) of \(steps.count)")
                .font(.caption)
                .foregroundColor(.gray)

            // Step List
            ForEach(steps) { step in
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: step.icon)
                            .font(.title3)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text(step.title).bold()
                            Text(step.subtitle).font(.subheadline).foregroundColor(.gray)
                        }

                        Spacer()

                        if step.status == .completed {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        } else {
                            Button(step.actionTitle) {
                                step.action()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    Divider()
                }
            }

            // Complete Button
            Button(action: {
                // Complete Verification Logic
                isPresented = false
            }) {
                Text("Complete Verification")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }

        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            setupSteps()
        }
    }

    private func setupSteps() {
        steps = [
            VerificationStep(title: "ID Verification", subtitle: "Upload your ID card & take a selfie", icon: "person.text.rectangle", actionTitle: "ID Card", status: .completed) {
                print("ID Card tapped")
            },
            VerificationStep(title: "Phone Verification", subtitle: "Verify your phone number", icon: "phone.fill", actionTitle: "Verify", status: .notStarted) {
                print("Verify phone tapped")
            },
            VerificationStep(title: "Payment Method", subtitle: "Add your payment details", icon: "creditcard", actionTitle: "Add", status: .notStarted) {
                print("Add payment method tapped")
            },
            VerificationStep(title: "Manual Verification", subtitle: "Final review by our team", icon: "person.crop.circle.badge.checkmark", actionTitle: "Pending", status: .pending) {
                print("Manual verification tapped")
            }
        ]
    }
}
