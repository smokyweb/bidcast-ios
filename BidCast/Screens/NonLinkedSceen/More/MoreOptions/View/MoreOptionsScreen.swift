//
//  MoreOptionsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

struct MoreOptionsScreen: View {
    @State private var selectedOption: String? = nil

    @Binding var isPresented: Bool
    @Binding var isVerifiedBuyersOn: Bool
    @Binding var isMicOn : Bool

    var onEndShow: () -> Void
    var onCloneItems: () -> Void
    var onTipSettings: () -> Void
    var onMulticast: () -> Void
    var onAddCoupons: () -> Void
    var onRaid: () -> Void
    var onCreatePoll: () -> Void
    var onRotateCamera: () -> Void
    var onZoomIn: () -> Void
    var onMicToggle: () -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
      
            VStack(spacing: 12) {
                // Header
                HStack {
                    Text("More Options")
                        .font(.custom(poppinsBold, size: 16.0))
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .fontWeight(.heavy)
                            .font(.custom(poppinsExtraBold, size: 22.0))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                ScrollView {
                // Verified Buyers Toggle
                Toggle(isOn: $isVerifiedBuyersOn) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Verified Buyers")
                                .font(.custom(poppinsSemiBold, size: 13.0))
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                        }
                        Text("When on, allows bids from verified buyers only")
                            .font(.custom(poppinsRegular, size: 11.0))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal,4)
                Divider()

                // Option Buttons Grid
                LazyVGrid(columns: columns, spacing: 12) {
                    OptionGridButtonView(label: "End Show", icon: "stop.fill", isSelected: selectedOption == "End Show", action: {
                        selectedOption = "End Show"
                        onEndShow()
                    })
                    OptionGridButtonView(label: "Clone Items", icon: "doc.on.doc", isSelected: selectedOption == "Clone Items", action: {
                        selectedOption = "Clone Items"
                        onCloneItems()
                    })
                    OptionGridButtonView(label: "Tip Settings", icon: "dollarsign.circle", isSelected: selectedOption == "Tip Settings", action: {
                        selectedOption = "Tip Settings"
                        onTipSettings()
                    })
                    OptionGridButtonView(label: "Multicast", icon: "rectangle.stack", isSelected: selectedOption == "Multicast", action: {
                        selectedOption = "Multicast"
                        onMulticast()
                    })
                    OptionGridButtonView(label: "Add Coupons", icon: "tag", isSelected: selectedOption == "Add Coupons", action: {
                        selectedOption = "Add Coupons"
                        onAddCoupons()
                    })
                    OptionGridButtonView(label: "Raid", icon: "paperplane", isSelected: selectedOption == "Raid", action: {
                        selectedOption = "Raid"
                        onRaid()
                    })
                    OptionGridButtonView(label: "Create Poll", icon: "list.bullet", isSelected: selectedOption == "Create Poll", action: {
                        selectedOption = "Create Poll"
                        onCreatePoll()
                    })
                }

                Divider()

                // Broadcasting Options
                VStack(spacing: 12) {
                    Text("Broadcasting Options")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 0)

                    HStack(spacing: 16) {
                        OptionButtonView(label: "Rotate Camera", icon: "arrow.triangle.2.circlepath.camera", action: onRotateCamera)
                        OptionButtonView(label: "Zoom In", icon: "magnifyingglass", action: onZoomIn)
                        OptionButtonView(label: "Mic", icon: isMicOn ? "mic.fill" : "mic.slash.fill", action: onMicToggle)
                    }
                }

                Spacer(minLength: 16)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
//        .padding(.top,-12)
        .background(Color.white)
        .cornerRadius(20)
    }
}
