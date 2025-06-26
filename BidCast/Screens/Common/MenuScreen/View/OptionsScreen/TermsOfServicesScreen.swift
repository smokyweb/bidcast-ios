////
////  TermsOfServicesScreen.swift
//// BidSwipe
////
////  Created by Abdul-JAM-E-157 on 20/01/24.
////
//
import SwiftUI
import RichText
import SwiftfulLoadingIndicators
import SVProgressHUD

struct TermsOfServicesScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModal = MenuOptionsViewModel()
    @State private var termsOfService: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack{
                PrimaryHeader(
                    title: "Terms and Conditions".localized,
                    isForLogo: false,
                    leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(Color.white)
            }
                
                VStack(alignment: .leading) {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    ScrollView(showsIndicators: false) {
                        RichText(html: termsOfService)
                            .customCSS("""
                                body { font-size: 16px; }
                            """)
                            .font(.custom(nunitoLight, fixedSize: 16))
                            .multilineTextAlignment(.leading)
                            .padding([.top, .leading, .trailing])
                    }
                    Spacer()
                }
                .padding(.bottom, bottomPadding)
                .background(Color.text.opacity(0.05))
                .padding(.top, 2)
                
                Spacer()
            }
            .refreshable {
                SVProgressHUD.show()
                await fetchTermsOfService()
                let response  = viewModal.termsResponse
                await SVProgressHUD.dismiss()
                if response.status == "success" {
                    termsOfService = response.data?.page_content ?? ""
                    errorMessage = nil
                } else {
                    errorMessage = response.message ?? "Failed to load terms of service"
                }
            }
            
          
        }
//        .edgesIgnoringSafeArea(.top)
        .task {
            SVProgressHUD.show()
            await fetchTermsOfService()
            let response  = viewModal.termsResponse
            await SVProgressHUD.dismiss()
            if response.status == "success" {
                termsOfService = response.data?.page_content ?? ""
                errorMessage = nil
            } else {
                errorMessage = response.message ?? "Failed to load terms of service"
            }
        }
    }
    
    @MainActor
    private func fetchTermsOfService() async {
        await viewModal.getTermsOfService()
    }
}

#Preview {
    TermsOfServicesScreen()
}
