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
    @Binding var backToTabBar : Bool
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
            
            ScrollView(showsIndicators:false) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Become a BidSwipe Seller")
                        .font(.custom(poppinsBold, size: 16.0))
                    Text("Before you start selling, please review and agree to our seller guidelines.")
                        .font(.custom(poppinsRegular, size: 12.0))
                        .foregroundColor(.gray)
                }
//                .padding(.horizontal,0)
                VStack(alignment: .leading,spacing: 16){
                    GuidelineRow(
                        icon: "cart",
                        iconColor: Color.defaultTheme.opacity(0.3),
                        title: "Honor Purchases & Freebies",
                        description: "Fulfill all orders promptly and honor your commitments"
                    )
                    
                    GuidelineRow(
                        icon: "nosign",
                        iconColor: Color.defaultTheme.opacity(0.3),
                        title: "Do Not Sell Counterfeits",
                        description: "Only sell authentic and legitimate products"
                    )
                    
                    GuidelineRow(
                        icon: "checklist",
                        iconColor: Color.yellow.opacity(0.3),
                        title: "Do Not Lie About Items",
                        description: "Provide accurate descriptions and images"
                    )
                    
                    GuidelineRow(
                        icon: "shippingbox",
                        iconColor: Color.darkGreen.opacity(0.3),
                        title: "Ship Quickly & Safely",
                        description: "Use appropriate packaging and ship within 3 days"
                    )
                    
                    
                }
            }
            .padding(.horizontal,12)
            VStack(alignment: .leading,spacing: 8){
                Toggle(isOn: $agreedToGuidelines) {
                    Text("I agree to follow these guidelines and understand that violations may result in account suspension")
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.black)
                }
                .toggleStyle(CheckboxToggleStyle())
                Button(action: {
                    navigateToLesson = true
                }) {
                    Text("Continue")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(agreedToGuidelines ? Color.defaultTheme : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                .disabled(!agreedToGuidelines)
            }
            .padding(.horizontal,12)
            CusNavLink(doNavigate: $navigateToLesson, destination: LessonScreen(backToTabBar: $backToTabBar))
//            CusNavLink(doNavigate: $navigateToLesson, destination: CombinedLessonTipsView())
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
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom(poppinsSemiBold, size: 14.0))
                    Text(description)
                        .font(.custom(poppinsRegular, size: 12.0))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 50)
            .padding()
            .background(Color.bg.opacity(0.5))
            .cornerRadius(12)
        }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top) {
            Button(action: {
                configuration.isOn.toggle()
            }) {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(.defaultTheme)
                    .font(.custom(poppinsRegular, size: 14.0))
            }
            configuration.label
        }
    }
}
