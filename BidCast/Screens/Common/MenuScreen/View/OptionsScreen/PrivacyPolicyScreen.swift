//
//  PrivacyPolicyScreen.swift
// BidSwipe
//
//  Created by Ankit-JAM-E-294 on 20/01/24.
//

import SwiftUI
import RichText
import SVProgressHUD

struct PrivacyPolicyScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var showhud: Bool = false
     @State var hudMsg: String = ""
    @State var viewModal = MenuOptionsViewModel()
    @State private var privacyPolicy: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            VStack{
                PrimaryHeader(
                    title: "Privacy Policy".localized,
                    isForLogo: false,
                    leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            .background(Color.white)
            
            VStack(alignment: .leading) {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                ScrollView(showsIndicators: false) {
                    RichText(html: privacyPolicy)
                        .customCSS("""
                                body { font-size: 16px; }
                            """)
                        .font(.custom(poppinsRegular, fixedSize: 16))
                        .multilineTextAlignment(.leading)
                        .padding([.leading, .trailing])
                        .padding(.all)
                }
                
                .background(Color.text.opacity(0.05))
                
//                Spacer()
            }
            .refreshable {
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await fetchPrivacyPolicy()
                let response = viewModal.privacyResponse
                
                await SVProgressHUD.dismiss()
                if response.status == "success" {
                    privacyPolicy = response.data?.page_content ?? ""
                    errorMessage = nil
                } else {
                    errorMessage = response.message ?? "Failed to load privacy policy"
                }
            }
        }
        
        .task {
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            await fetchPrivacyPolicy()
            let response = viewModal.privacyResponse
            await SVProgressHUD.dismiss()
            if response.status == "success" {
                privacyPolicy = response.data?.page_content ?? ""
                errorMessage = nil
            } else {
                errorMessage = response.message ?? "Failed to load privacy policy"
            }
        }
//        .onReceive(viewModal.$privacyResponse) { response in
//            
//            SVProgressHUD.dismiss()
//            if response.status == "success" {
//                privacyPolicy = response.data?.page_content ?? ""
//                errorMessage = nil
//            } else {
//                errorMessage = response.message ?? "Failed to load privacy policy"
//            }
//        }
//        .onReceive(viewModal.$errorMessage) { error in
//            if let error = error {
//                errorMessage = error
//                SVProgressHUD.dismiss()
//            }
//        }
    }
    
    @MainActor
    private func fetchPrivacyPolicy() async {
       guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await viewModal.getPrivacyDetails()
    }
}

#Preview {
    PrivacyPolicyScreen()
}
