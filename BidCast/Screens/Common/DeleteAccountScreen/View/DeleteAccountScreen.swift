////
////  DeleteAccountScreen.swift
//// BidSwipe
////
////  Created by Abdul-JAM-E-157 on 01/03/24.
////
//
//import SwiftUI
//import AlertToast
//import BottomSheet
//
//struct DeleteAccountScreen: View {
//    
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject private var appRootManager: AppRootManager
//
//    @State var isLoading: Bool = false
//    @State var userSubmited: Bool = false
//    @State var showError: Bool = false
//    @State var reason = ""
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    
//    var viewModel = DeleteAccountViweModel()
//    
//    var body: some View {
//        ZStack{
//            VStack(spacing: 0, content: {
//                PrimaryHeader(title: "Delete Account", leadingImgArr: [.sideArrow],onClickLeading: { index in
//                    self.presentationMode.wrappedValue.dismiss()
//                }, count: .constant(0))
//                
//                
//                TitleWithLine(title: "Delete Account", lineLength: 36)
//                    .padding([.top, .horizontal])
//                
//                MultilineTextField(floatingLabel: "Reason for deletion", placeholder: "Enter your message here...", text: $reason) { message in
//                    reason = message
//                }
//                .padding()
//                PrimaryButton(title: "Submit",isOutLine: false) {
//                    if self.reason == ""{
//                        hudMsg = "Please provide reason for deleting your account."
//                        showhud = true
//                    }else{
//                        self.userSubmited = true
//                    }
//                }
//                Spacer()
//            })
//            
//            .padding(.bottom, bottomPadding)
//            .background(.text.opacity(0.05))
//            .padding(.top, -topPadding)
//            .bottomSheet(isPresented: $userSubmited, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { userSubmited = true }, content: {
//                DeleteAccountSheet(onDeleteClick: {
//                    self.viewModel.postDeleteRequest(param: DeleteParam(reason: reason))
//                }, onCancelClick: {
//                    withAnimation(.snappy) { userSubmited = false }
//                })
//            })
//            .toast(isPresenting: $showhud) {
//                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
//            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation { showError = false }
//                        UserDefaultsManager.shared.clearAllValues()
//                        DispatchQueue.main.async {
//                            appRootManager.currentRoot = .authentication
//                        }
//                    }, onSecondaryClick: {
//                        withAnimation { showError = false }
//                    })
//            })
//            
//            if isLoading {
//                Loader(isLoading: $isLoading)
//            }
//            
////            if showError {
////                AlertPopUp(presentAlert: $showError, alertType: alertType, rightButtonAction: {
////                    withAnimation(.snappy) { showError = false }
////                })
////            }
//            
//        }
//        .edgesIgnoringSafeArea(.bottom)
//        .onAppear(perform: {
//            observe()
//        })
//        .onTapGesture {
//            UIApplication.shared.endEditing()
//        }
//        
//    }
//    
//    func observe() {
//        self.viewModel.eventHandler = { event in
//            switch event {
//                case .loading:
//                    self.isLoading = true
//                case .stopLoading:
//                    self.isLoading = false
//                case .dataLoaded:
//                    success()
//                case .error(let error):
//                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    showError = true
//            }
//        }
//    }
//    
//    func success() {
//        if let dict = viewModel.1 {
//            if dict.status == "success" {
//                alertType = .sheetType(icon: .success, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
//                showError = true
//            }else{
//                alertType = .sheetType(icon: .alert, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                withAnimation(.snappy) { showError = true }
//            }
//        }
//        
//    }
//}
//
//#Preview {
//    DeleteAccountScreen()
//}
