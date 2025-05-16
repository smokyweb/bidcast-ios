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
    var body: some View {
        
        ZStack {
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

                MediaPickerView()
                
                
                
//                .refreshable {
//                    self.isLoading = true
//                    viewModel.getAboutContent()
//                    observe()
//                }

                Spacer()
            })
          
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

#Preview {
    ListProductScreen()
}

