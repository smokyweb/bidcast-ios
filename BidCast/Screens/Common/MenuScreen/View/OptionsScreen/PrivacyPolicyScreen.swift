////
////  PrivacyPolicyScreen.swift
////  imperium
////
////  Created by Abdul-JAM-E-157 on 20/01/24.
////
//
import SwiftUI
import RichText

struct PrivacyPolicyScreen: View {
    
        //MARK: - Vairable Initialised
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State var privacyPolicy: String = ""
    @State var navigateToMenu: Bool = false
    @State var navigateToNotification: Bool = false
    @State var notiCount: Int = 0
        //MARK: View Modal
    var viewModal = MenuOptionsViewModal()
    
        //MARK: - Primary View
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                PrimaryHeader(
                    title: "Privacy Policy".localized,
                    isForLogo : false, leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(.white)
                VStack(alignment: .leading) {
                   
                    ScrollView(showsIndicators: false){
                        RichText(html: privacyPolicy)
                            .customCSS("""
            body {
                font-size: 16px;
            }
        """)
                            .font(.custom(nunitoLight, fixedSize: 16))
                            .multilineTextAlignment(.leading)
                            .padding([.top,.leading,.trailing])
                    }
                    Spacer()
                }
                .padding(.bottom, bottomPadding)
                .background(.text.opacity(0.05))
                .padding(.top, -topPadding)
                
                Spacer()
            })
            .refreshable {
                isLoading = true
                self.viewModal.getPrivacyDetails()
                observe()
            }
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .task {
            self.viewModal.getPrivacyDetails()
        }
        .onAppear(perform: {
            observe()
        })

    }
    
        //MARK: - View Modal Observer
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    isLoading = true
                case .stopLoading:
                    isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    print("Error >> \(error?.localizedDescription ?? "")")
            }
        }
    }
    
        //MARK: - View Modal Success Handler
    func handleSuccess() {
        if let response = viewModal.privacyResponse {
            if response.status == "success" {
                privacyPolicy = response.data.page_content ?? ""
            }
        }
    }
}

#Preview {
    PrivacyPolicyScreen()
}
