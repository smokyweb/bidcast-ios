//
//  MoreOptionsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

struct MoreOptionsScreen: View {
    @State private var selectedOption: String? = nil
    @State private var toggleScale: CGFloat = 1.0

    @Binding var isPresented: Bool
    @Binding var isVerifiedBuyersOn: Bool
    @Binding var isMicOn : Bool

    var onEndShow: () -> Void
    var onCloneItems: () -> Void
    var onTipSettings: () -> Void
    var onMulticast: () -> Void
    var onAddCoupons: () -> Void
    var onClickRandomizer: () -> Void
    var onRaid: () -> Void
    var onCreatePoll: () -> Void
    var onZoomOut: () -> Void
    var onZoomIn: () -> Void
    var onMicToggle: () -> Void
    var onVerifiedBuyerToggle: ((Bool) -> Void)? = nil

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                // Header
                HStack {
                    Text("More Options")
                        .font(.custom(poppinsBold, size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .renderingMode(.template)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Verified Buyers Toggle Card
                        VStack(spacing: 0) {
                            Toggle(isOn: Binding(
                                get: { isVerifiedBuyersOn },
                                set: { newValue in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        toggleScale = 0.95
                                        isVerifiedBuyersOn = newValue
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            toggleScale = 1.0
                                        }
                                    }
                                    onVerifiedBuyerToggle?(newValue)
                                }
                            )) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.defaultThemeLight)
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "checkmark.shield.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.defaultTheme)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text("Verified Buyers")
                                                .font(.custom(poppinsSemiBold, size: 14))
                                                .foregroundColor(.black)
                                            
                                            Image(systemName: "questionmark.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray.opacity(0.5))
                                        }
                                        
                                        Text("Allows bids from verified buyers only")
                                            .font(.custom(poppinsRegular, size: 12))
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .defaultTheme))
                            .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isVerifiedBuyersOn ? Color.defaultTheme.opacity(0.3) : Color.clear, lineWidth: 2)
                                .animation(.easeInOut(duration: 0.3), value: isVerifiedBuyersOn)
                        )
                        .scaleEffect(toggleScale)
                        .padding(.horizontal, 20)
                        
                        // Options Grid Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.defaultTheme)
                                
                                Text("Quick Actions")
                                    .font(.custom(poppinsSemiBold, size: 15))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                OptionGridButtonView(label: "End Show", icon: "stop.fill", isSelected: selectedOption == "End Show", action: {
                                    selectedOption = "End Show"
                                    onEndShow()
                                })
//                                OptionGridButtonView(label: "Clone Items", icon: "doc.on.doc", isSelected: selectedOption == "Clone Items", action: {
//                                    selectedOption = "Clone Items"
//                                    onCloneItems()
//                                })
                                OptionGridButtonView(label: "Tip Settings", icon: "dollarsign.circle", isSelected: selectedOption == "Tip Settings", action: {
                                    selectedOption = "Tip Settings"
                                    onTipSettings()
                                })
//                                OptionGridButtonView(label: "Multicast", icon: "rectangle.stack", isSelected: selectedOption == "Multicast", action: {
//                                    selectedOption = "Multicast"
//                                    onMulticast()
//                                })
//                                OptionGridButtonView(label: "Add Coupons", icon: "tag", isSelected: selectedOption == "Add Coupons", action: {
//                                    selectedOption = "Add Coupons"
//                                    onAddCoupons()
//                                })
                                OptionGridButtonView(label: "Raid", icon: "paperplane", isSelected: selectedOption == "Raid", action: {
                                    selectedOption = "Raid"
                                    onRaid()
                                })
                                OptionGridButtonView(label: "Create Poll", icon: "list.bullet", isSelected: selectedOption == "Create Poll", action: {
                                    selectedOption = "Create Poll"
                                    onCreatePoll()
                                })
                                OptionGridButtonView(label: "Freebie", icon: "tag", isSelected: selectedOption == "Freebie", action: {
                                    selectedOption = "Freebie"
                                    onClickRandomizer()
                                })
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                        )
                        .padding(.horizontal, 20)

                        // Broadcasting Options Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                
                                Text("Broadcasting Options")
                                    .font(.custom(poppinsSemiBold, size: 15))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)

                            HStack(spacing: 12) {
                                OptionButtonView(label: "Zoom Out", icon: "minus.magnifyingglass", action: onZoomOut)
                                OptionButtonView(label: "Zoom In", icon: "plus.magnifyingglass", action: onZoomIn)
                                OptionButtonView(label: "Mic", icon: isMicOn ? "mic.fill" : "mic.slash.fill", isActive: isMicOn, action: onMicToggle)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .background(.clear)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.bottom, 0)
        }
        .background(Color.backGround)
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Option Grid Button View
struct OptionGridButtonView: View {
    let label: String
    let icon: String
    var isSelected: Bool = false
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.defaultTheme.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .shadow(color: isSelected ? Color.defaultTheme.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .blue : .black)
                }
                
                Text(label)
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.defaultTheme.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// MARK: - Option Button View
struct OptionButtonView: View {
    let label: String
    let icon: String
    var isActive: Bool = false
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isActive ? Color.defaultTheme.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isActive ? .blue : .black)
                }
                
                Text(label)
                    .font(.custom(poppinsRegular, size: 11))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.defaultTheme.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}
