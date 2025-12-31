//
//  PaymentAndShipping Screen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI
import SVProgressHUD


struct SalesTaxScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = ProfileViewModel()
    @State var profileData = ProfileModel()
    
    @State  var showhud = false
    @State  var hudMsg = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    
    @State var navigateToCreateAddress = false
      var body: some View {
          VStack {
              VStack{
              PrimaryHeader(
                title: "Sales Tax Exemption".localized,
                isForLogo : false, leadingImgArr: ["chevron.left"],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
              )
          }
              ScrollView(showsIndicators:false){
                  ListCell(image: profileData.profile_image ?? "",
                           title: profileData.name ?? "",
                           subLabel : profileData.bio ?? "",
                           isVectorImgHidden: true)
                      .padding(.all,1)
                      .padding([.leading,.trailing],12)
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
                                         .background(Color.darkGreen.opacity(0.2))
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
              TwoButton(titleOne: "Apply Now",
                        titleTwo: "Learn More")
//                         .padding()
              CusNavLink(doNavigate: $navigateToCreateAddress, destination: CreateAddress())
          }
          .onAppear {
              Task{
                  let id = UserDefaults.userId
                  if id != -1 {
                      SVProgressHUD.show()
                      guard Reachability.isConnectedToNetwork() else {
                          hudMsg = "No Internet Connection"
                          showhud = true
                          return
                      }
                      
                      await viewModel.getProfile(param: ProfileParamRequest(id: "\(id)"))
                      await SVProgressHUD.dismiss()
                      profileSuccess()
                  }
              }
              
          }
      }
    
    func profileSuccess() {
        let response = viewModel.getProfileDict
        if response.status == "success" {
            profileData = response.data ?? ProfileModel()
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
  }

#Preview {
    SalesTaxScreen()
}

