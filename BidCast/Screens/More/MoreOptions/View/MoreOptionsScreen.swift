//
//  MoreOptionsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

//struct MoreOptionsScreen: View {
//    @State private var selectedOption: String? = nil
//  
//
//    @Binding var isPresented: Bool
//    @Binding var isVerifiedBuyersOn: Bool
//    @Binding var isMicOn : Bool
//
//    var onEndShow: () -> Void
//    var onCloneItems: () -> Void
//    var onTipSettings: () -> Void
//    var onMulticast: () -> Void
//    var onAddCoupons: () -> Void
//    var onRaid: () -> Void
//    var onCreatePoll: () -> Void
//    var onZoomOut: () -> Void
//    var onZoomIn: () -> Void
//    var onMicToggle: () -> Void
//    var onVerifiedBuyerToggle: ((Bool) -> Void)? = nil
//
//    let columns = [GridItem(.flexible()), GridItem(.flexible())]
//
//    var body: some View {
//      
//            VStack(spacing: 12) {
//                // Header
//                HStack {
//                    Text("More Options")
//                        .font(.custom(poppinsBold, size: 16.0))
//                    Spacer()
//                    Button(action: {
//                        isPresented = false
//                    }) {
//                        Image(systemName: "xmark")
//                            .fontWeight(.heavy)
//                            .font(.custom(poppinsExtraBold, size: 22.0))
//                            .foregroundColor(.black)
//                    }
//                }
//                .padding(.horizontal)
//                ScrollView {
//                // Verified Buyers Toggle
//                    Toggle(isOn: $isVerifiedBuyersOn) {
//                        VStack(alignment: .leading, spacing: 4) {
//                            HStack {
//                                Text("Verified Buyers")
//                                    .font(.custom(poppinsSemiBold, size: 13.0))
//                                Image(systemName: "questionmark.circle")
//                                    .foregroundColor(.gray)
//                            }
//                            Text("When on, allows bids from verified buyers only")
//                                .font(.custom(poppinsRegular, size: 11.0))
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .padding(.horizontal, 4)
//                    Divider()
//                        .onChange(of: isVerifiedBuyersOn) { newValue in
//                            onVerifiedBuyerToggle?(newValue)
//                        }
//                    
//                // Option Buttons Grid
//                LazyVGrid(columns: columns, spacing: 12) {
//                    OptionGridButtonView(label: "End Show", icon: "stop.fill", isSelected: selectedOption == "End Show", action: {
//                        selectedOption = "End Show"
//                        onEndShow()
//                    })
//                    OptionGridButtonView(label: "Clone Items", icon: "doc.on.doc", isSelected: selectedOption == "Clone Items", action: {
//                        selectedOption = "Clone Items"
//                        onCloneItems()
//                    })
//                    OptionGridButtonView(label: "Tip Settings", icon: "dollarsign.circle", isSelected: selectedOption == "Tip Settings", action: {
//                        selectedOption = "Tip Settings"
//                        onTipSettings()
//                    })
//                    OptionGridButtonView(label: "Multicast", icon: "rectangle.stack", isSelected: selectedOption == "Multicast", action: {
//                        selectedOption = "Multicast"
//                        onMulticast()
//                    })
//                    OptionGridButtonView(label: "Add Coupons", icon: "tag", isSelected: selectedOption == "Add Coupons", action: {
//                        selectedOption = "Add Coupons"
//                        onAddCoupons()
//                    })
//                    OptionGridButtonView(label: "Raid", icon: "paperplane", isSelected: selectedOption == "Raid", action: {
//                        selectedOption = "Raid"
//                        onRaid()
//                    })
//                    OptionGridButtonView(label: "Create Poll", icon: "list.bullet", isSelected: selectedOption == "Create Poll", action: {
//                        selectedOption = "Create Poll"
//                        onCreatePoll()
//                    })
//                }
//
//                Divider()
//
//                // Broadcasting Options
//                VStack(spacing: 12) {
//                    Text("Broadcasting Options")
//                        .font(.custom(poppinsSemiBold, size: 13.0))
//                        .foregroundColor(.gray)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal, 0)
//
//                    HStack(spacing: 16) {
//                        OptionButtonView(label: "Zoom Out", icon: "minus.magnifyingglass", action: onZoomOut)
//                        OptionButtonView(label: "Zoom In", icon: "plus.magnifyingglass", action: onZoomIn)
//                        OptionButtonView(label: "Mic", icon: isMicOn ? "mic.fill" : "mic.slash.fill", action: onMicToggle)
//                    }
//                }
//
//                Spacer(minLength: 16)
//            }
//            .padding()
//        }
//        .edgesIgnoringSafeArea(.top)
////        .padding(.top,-12)
//        .background(Color.white)
//        .cornerRadius(20)
//    }
//}

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
    var onRaid: () -> Void
    var onCreatePoll: () -> Void
    var onZoomOut: () -> Void
    var onZoomIn: () -> Void
    var onMicToggle: () -> Void
    var onVerifiedBuyerToggle: ((Bool) -> Void)? = nil

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("More Options")
                        .font(.custom(poppinsBold, size: 18))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
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
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "checkmark.shield.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text("Verified Buyers")
                                                .font(.custom(poppinsSemiBold, size: 14))
                                                .foregroundColor(.primary)
                                            
                                            Image(systemName: "questionmark.circle.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray.opacity(0.5))
                                        }
                                        
                                        Text("Allows bids from verified buyers only")
                                            .font(.custom(poppinsRegular, size: 12))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isVerifiedBuyersOn ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                                .animation(.easeInOut(duration: 0.3), value: isVerifiedBuyersOn)
                        )
                        .scaleEffect(toggleScale)
                        .padding(.horizontal, 20)
                        
                        // Options Grid Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                
                                Text("Quick Actions")
                                    .font(.custom(poppinsSemiBold, size: 15))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
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
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
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
                                    .foregroundColor(.primary)
                                
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
                        .background(.clear
//                            RoundedRectangle(cornerRadius: 16)
//                                .fill(Color(.systemBackground))
//                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                        )
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGroupedBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
        .edgesIgnoringSafeArea(.top)
    }
}
om 
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
                        .fill(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .shadow(color: isSelected ? Color.blue.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .blue : .primary)
                }
                
                Text(label)
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
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
                        .fill(isActive ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isActive ? .blue : .primary)
                }
                
                Text(label)
                    .font(.custom(poppinsRegular, size: 11))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}
