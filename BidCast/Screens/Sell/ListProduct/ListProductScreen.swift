//
//  ListProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import SwiftUI

struct ListProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading : Bool = false
    @State var categorySelect : String = ""
    @State var categoyList = [String]()
    @State var productTitle = ""
    
    var body: some View {
        
        ZStack {
            VStack{
                VStack(spacing: 0, content: {
                    PrimaryHeader(
                        title: "List a Product".localized,
                        isForLogo : false, leadingImgArr: [.sideArrow],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                    .background(.white)
                })
                ScrollView(showsIndicators:false){
                    
                    MediaPickerView()
                        .padding([.leading,.trailing],12)
                    
                    VStack(alignment:.leading,spacing: 8){
                        Text("Product Details".localized)
                            .font(.headline)
                            .padding([.leading,.trailing],12)
                        
                        DropDownSelection(
                            options: $categoyList, floatingLabel:"Category",
                            hint: "Select Category",
                            anchor: .bottom
                        )
                        .onChange(of: categorySelect) { newValue in
                            
                        }
                        .padding([.leading,.trailing],16)
                        
                        AuthTextField(floatingLabel: "Title".localized, placeholder: "Enter Product title".localized, icon: .menuProfile, text:$productTitle ,isIconDisplay : false) { email in
                            self.productTitle = email
                        }
                        //                    .textContentType(.username)
                        .keyboardType(.alphabet)
                        .padding([.leading,.trailing],12)
                    }
                    
                    
                    //                .refreshable {
                    //                    self.isLoading = true
                    //                    viewModel.getAboutContent()
                    //                    observe()
                    //                }
                    
//                    Spacer()
                }
                .padding([.leading,.trailing],12)
                
                //            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
                //                CommonBottomSheet(
                //                    sheetType: $alertType,
                //                    onPrimaryClick: {
                //                        withAnimation { showError = false }
                //                    }, onSecondaryClick: {
                //                        withAnimation { showError = false }
                //                    })
                //            })
                
                //            if isLoading {
                //                Loader(isLoading: $isLoading)
                //            }
                
            }
//            .padding([.leading,.trailing],12)
        }
        .edgesIgnoringSafeArea(.top)
        .onFirstAppear(perform: {
            self.isLoading = true
            //            viewModel.getAboutContent()
        })
        .onAppear(perform: {
            //            observe()
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        
    }
}

//#Preview {
//    ListProductScreen()
//}

