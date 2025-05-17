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
    @State var message = ""
    @State var isTappedFlash : Bool = false
    @State var isTappedAccept : Bool = false
    @State var isTappedReserve: Bool = false
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
//                    .background(.bg.opacity(0.5))
                })
                
//                .background(.bg.opacity(0.5))
                
                ScrollView(showsIndicators:false){
                    
                    MediaPickerView()
                    
                    VStack(alignment:.leading,spacing: 8){
                        Text("Product Details".localized)
                            .font(.headline)
                            .padding(.top,8)
                            .padding([.leading,.trailing],8)
                        
                        DropDownSelection(
                            options: $categoyList, floatingLabel:"Category",
                            hint: "Select Category",
                            anchor: .bottom
                        )
                        .onChange(of: categorySelect) { newValue in
                            
                        }
                        .padding([.leading,.trailing],8)
                        
                        AuthTextField(floatingLabel: "Title".localized, placeholder: "Enter Product title".localized, icon: .menuProfile, text:$productTitle ,isIconDisplay : false) { email in
                            self.productTitle = email
                        }
                        //                    .textContentType(.username)
                        .keyboardType(.alphabet)
                        .padding([.leading,.trailing],4)
                        
                        DescriptionFieldView(){ message in
                            self.message = message
                        }
                        
                        PrimaryButton(title: "Add Variants", isOutLine: false, onButtonClick: {
                            print("hell")
                        },width: screenWidth - 45, imageName: "plus_btn", btnColor: .white)
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.all,12)
                    
                    VStack(alignment:.leading,spacing: 12){
                        Text("Pricing".localized)
                            .font(.headline)
                            .padding(.top,8)
                            .padding([.leading,.trailing],8)
                        
                        AuthTextField(floatingLabel: "Buy it Now Price".localized, placeholder: "0.00".localized, icon: .menuProfile, text:$productTitle ,isIconDisplay : true) { email in
                            self.productTitle = email
                        }
                        //                    .textContentType(.username)
                        .keyboardType(.alphabet)
                        .padding([.leading,.trailing],4)
                        
                        MenuCell( title: "Flash Sale",fontValue: 18.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedFlash,onToggle: { value in
                            print(value)
                        })
                        MenuCell( title: "Accept offers",fontValue: 18.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedAccept,onToggle: { value in
                            print(value)
                        })
                        MenuCell( title: "Reserve for Live",fontValue: 18.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedReserve,onToggle: { value in
                            print(value)
                        })
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.all,12)
                    
                    VStack(alignment:.leading,spacing: 12){
                        Text("Shipping".localized)
                            .font(.headline)
                            .padding(.top,8)
                            .padding([.leading,.trailing],8)
                        
                        DropDownSelection(
                            options: $categoyList, floatingLabel:"Shipping Profile",
                            hint: "Select Profile",
                            anchor: .top
                        )
                        .onChange(of: categorySelect) { newValue in
                            
                        }
                        .padding(.bottom,8)
                        .padding([.leading,.trailing],8)
                        
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.all,12)
                    
                    TwoButton(titleOne: "Save Draft", titleTwo: "Publish", onFirstButtonClick: {
                        
                    }, onSecButtonClick: {
                        
                    }, height: 45, firstBtnTitleColor: .darkGray, secBtnTitleColor: .white, firstBtnBgColor: .white, secBtnBgColor:.darkBlue)
//                    TwoPrimaryButtonsRow()
                    
                    
                    //                .refreshable {
                    //                    self.isLoading = true
                    //                    viewModel.getAboutContent()
                    //                    observe()
                    //                }
                    
//                    Spacer()
                }
                .edgesIgnoringSafeArea(.top)
                .padding(.all,12)
                .background(.bg.opacity(0.5))
                
                
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
        .background(.bg.opacity(0.5))
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

#Preview {
    ListProductScreen()
}





struct TwoPrimaryButtonsRow: View {
    var btn1Title : String = "Save Draft"
    var btn2Title : String = "Publish"
    var btn1Color  : Color = .gray
    var body: some View {
        HStack(spacing: 12) {
            
            Button(action: {
                print("Add Variants tapped")
            }) {
                Text(btn1Title)
                    .fontWeight(.bold)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(btn1Color, lineWidth: 2)
            )
            
            .foregroundColor(btn1Color)
            
            // Filled “Save”
            Button(action: {
                print("Save tapped")
            }) {
                Text(btn2Title)
                    .fontWeight(.bold)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                    )
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .shadow(color: .gray.opacity(0.25), radius: 2, x: 0, y: 0)
    }
}

#Preview {
    TwoPrimaryButtonsRow()
}
