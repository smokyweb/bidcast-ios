//
//  PaymentAndShipping Screen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI


struct SalesTaxScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    
    @State var navigateToCreateAddress = false
      var body: some View {
          VStack {
              PrimaryHeader(
                  title: "Sales Tax Exemption".localized,
                  isForLogo : false, leadingImgArr: [.icBack],
                  trailingImgArr: [],
                  onClickLeading: { _ in
                      self.presentationMode.wrappedValue.dismiss()
                  },
                  count: .constant(0)
              )
              .background(.white)
              .frame(height: 50)
              ScrollView(showsIndicators:false){
                  ListCell(image: "defaultUser", title: "John Smith",subLabel : "ID: #12345678",isVectorImgHidden: true)
                      .padding(.all,1)
                      .padding([.leading,.trailing],0)
                      .frame(height: 80)
                  VStack(alignment: .leading, spacing: 12) {
                                 HStack {
                                     Text("Exemption Status")
                                         .font(.headline)
                                     Spacer()
                                     Text("Active")
                                         .font(.subheadline)
                                         .foregroundColor(.green)
                                         .padding(.horizontal, 12)
                                         .padding(.vertical, 4)
                                         .background(Color.green.opacity(0.2))
                                         .cornerRadius(20)
                                 }
                                 
                                 HStack {
                                     Text("Issue Date")
                                         .foregroundColor(.gray)
                                     Spacer()
                                     Text("Jan 15, 2025")
                                         .bold()
                                 }
                                 
                                 HStack {
                                     Text("Expiration Date")
                                         .foregroundColor(.gray)
                                     Spacer()
                                     Text("Jan 15, 2026")
                                         .bold()
                                 }
                             }
                             .padding()
                             .background(Color(.systemBackground))
                             .cornerRadius(12)
                             .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                             .padding(.horizontal)
                             
                             // Certificate File Info
                             VStack(alignment: .leading, spacing: 12) {
                                 Text("Certificate Details")
                                     .font(.headline)
                                 
                                 HStack {
                                     Image(systemName: "doc.fill")
                                         .foregroundColor(.gray)
                                     
                                     Text("Tax_Exemption_2025.pdf")
                                         .font(.subheadline)
                                         .lineLimit(1)
                                     
                                     Spacer()
                                     
                                     Image(systemName: "arrow.down.circle.fill")
                                         .foregroundColor(.red)
                                 }
                                 .padding()
                                 .background(Color(.secondarySystemBackground))
                                 .cornerRadius(10)
                             }
                             .padding()
                             .background(Color(.systemBackground))
                             .cornerRadius(12)
                             .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                             .padding(.horizontal)
                             
                             Spacer()
                             
                             // Bottom Buttons
                 
              }
              .background(.bg.opacity(0.6))
              TwoButton(titleOne: "Apply Now",titleTwo: "Learn More",firstBtnTitleColor: .white,secBtnTitleColor: .defaultTheme, firstBtnBgColor: .defaultTheme,secBtnBgColor: .white)
//                         .padding()
              CusNavLink(doNavigate: $navigateToCreateAddress, destination: CreateAddress())
          }
      }
  }

#Preview {
    SalesTaxScreen()
}

