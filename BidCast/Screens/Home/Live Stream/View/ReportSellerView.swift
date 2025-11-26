//
//  ReportSellerView.swift
//  BidCast
//
//  Created by JamTech on 25/11/25.
//

import SwiftUI

struct ReportSellerView: View {
    
    @State private var selectedReason: String = ""
    @State private var showReasonDropdown = false
    @State private var message: String = "Write Something"
    
    @State private var reasons: [String] = [
        "Fake Product",
        "Fraud / Scam",
        "Inappropriate Behaviour",
        "Violating Terms",
        "Other"
    ]
    
    var body: some View {
        ScrollView(showsIndicators:false) {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Title
                Text("Report Seller")
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(.black)
                    .padding(.top, 10)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                // MARK: - Reason Label
                //            Text("Reason")
                //                .font(.custom("Poppins-SemiBold", size: 15))
                //                .foregroundColor(.black)
                
                DropDownSelection(
                    options: $reasons, floatingLabel:"Reason",
                    hint: "Select",
                    selected: $selectedReason,
                    anchor: .top,
                    custFontName: robotoMedium,
                    custFontSize:  14.0,
                    custCategory : robotoRegular,
                    custCategorySize : 13.0,
                    onOptionSelected: { value in
                        selectedReason = value
                    }
                )
                .background(.clear)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                // MARK: - Tell us more
//                Text("Tell us more")
//                    .font(.custom("Poppins-SemiBold", size: 15))
//                    .foregroundColor(.black)
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 12)
//                
                DescriptionFieldView(
                    description:$message,
                    title: "Tell us more",
                    custFontName : robotoMedium,
                    custFontSize : 14.0
                )
                { msg in
                    self.message = msg
                }
                .padding(.vertical, 12)
                
                // MARK: - Submit Button
                Button {
                    print("Submit Report tapped")
                } label: {
                    Text("Submit Report")
                        .font(.custom("Poppins-SemiBold", size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                .padding(.top, 10)
                
                Spacer(minLength: 20)
            }
        }
        .padding(.top, 10)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

extension View {
    func keyboardAwarePadding() -> some View {
        self
            .padding(.bottom, 0)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                UIApplication.shared.windows.first?.rootViewController?.view.frame.origin.y = -50
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                UIApplication.shared.windows.first?.rootViewController?.view.frame.origin.y = 0
            }
    }
}
