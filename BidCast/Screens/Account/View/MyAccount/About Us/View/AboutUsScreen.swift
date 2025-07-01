//
//  AboutUsScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import SwiftUI
import RichText
import SwiftfulLoadingIndicators
import SVProgressHUD

struct AboutUsScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var navigateToMenu: Bool = false
    @State var navigateToNotification: Bool = false
    @State var notiCount: Int = 0
    //    @State private var player : AVPlayer?
    
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var aboutUsContent = String()
    
    
    var viewModel = AboutUsViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                VStack{
                    PrimaryHeader(
                        title: "About Us".localized,
                        isForLogo : false, leadingImgArr: [.sideArrow],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                    .background(.white)
                }
                ScrollView(showsIndicators: false){
                    VStack(alignment: .leading, spacing: 16) {
                        
                        //                    TitleWithLine(title: "About Us", lineLength: 36)
                        //                        .padding()
                        
                        
                        RichText(html: aboutUsContent)
                            .customCSS("""
                body {
                        font-size: 16px;
                        line-height: 1.5; /* Improve readability */
                    }
                    ul {
                        margin: 0; /* Remove default margin */
                        padding-left: 20px; /* Indent for bullets */
                    }
                    li {
                        margin-bottom: 8px; /* Space between list items */
                        list-style-type: disc; /* Ensure bullet points are displayed */
                    }
                """)
                        
                        
                            .font(.custom(nunitoLight, fixedSize: 16))
                            .multilineTextAlignment(.leading)
                    }
                    
                }
                .padding([.horizontal, .vertical])
                .background(.text.opacity(0.05))
                .padding(.top, 2)
                .refreshable {
                    Task{
                        SVProgressHUD.show()
                        await viewModel.getAboutContent()
                        await SVProgressHUD.dismiss()
                        success()
                    }
                    
                }
                
                Spacer()
            })
            
        }
        .onFirstAppear(perform: {
            Task{
                SVProgressHUD.show()
                await viewModel.getAboutContent()
                await SVProgressHUD.dismiss()
                success()
            }
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        
        
    }
    
    
    
    func success() {
        let dict = viewModel.aboutResponse
        
        if dict.status == "success" {
            aboutUsContent = dict.data?.page_content ?? ""
        }else{
            alertType = .sheetType(icon: .alert, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
            withAnimation(.snappy) { showError = true }
        }
        
        
    }
    
}

#Preview {
    AboutUsScreen()
}



