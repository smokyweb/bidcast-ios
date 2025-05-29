//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI

struct GetStartedScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var agreedToGuidelines = false
    @State var navigateToLesson = false
    var body: some View {
      
            VStack {
                VStack{
                    PrimaryHeader(
                        title: "Let's Get Started".localized,
                        isForLogo : false, leadingImgArr: [.sideArrow],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }
                .frame(height: 50)
                .background(.white)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Become a BidCast Seller")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Before you start selling, please review and agree to our seller guidelines.")
                            .font(.body)
                            .foregroundColor(.gray)

                        GuidelineRow(
                            icon: "handshake",
                            iconColor: Color.blue.opacity(0.2),
                            title: "Honor Purchases & Freebies",
                            description: "Fulfill all orders promptly and honor your commitments"
                        )

                        GuidelineRow(
                            icon: "nosign",
                            iconColor: Color.red.opacity(0.2),
                            title: "Do Not Sell Counterfeits",
                            description: "Only sell authentic and legitimate products"
                        )

                        GuidelineRow(
                            icon: "checklist",
                            iconColor: Color.yellow.opacity(0.2),
                            title: "Do Not Lie About Items",
                            description: "Provide accurate descriptions and images"
                        )

                        GuidelineRow(
                            icon: "shippingbox",
                            iconColor: Color.green.opacity(0.2),
                            title: "Ship Quickly & Safely",
                            description: "Use appropriate packaging and ship within 3 days"
                        )

                        Toggle(isOn: $agreedToGuidelines) {
                            Text("I agree to follow these guidelines and understand that violations may result in account suspension")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                        .padding(.top, 16)
                    }
                    .padding()
                }

                Button(action: {
                    navigateToLesson = true
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(agreedToGuidelines ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(!agreedToGuidelines)
                CusNavLink(doNavigate: $navigateToLesson, destination: CombinedLessonTipsView())
        }
    }
}

struct GuidelineRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    var description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top) {
            Button(action: {
                configuration.isOn.toggle()
            }) {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            configuration.label
        }
    }
}
