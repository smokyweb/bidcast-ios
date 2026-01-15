//
//  NotifyMeBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD

//struct NotifyMeBottomSheet: View {
//    
//    // MARK: – Environment & VM
//    @Environment(\.presentationMode) private var presentationMode
//    @StateObject private var viewModel = NotifyMeViewModel()
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    
//    // MARK: – UI State
//    @State private var isLoading    = false
//    @State private var showError    = false
//    @State private var alertType: BottomSheetType =
//        .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State private var showHUD      = false
//    @State private var hudMsg       = ""
//    @State private var navToProfile = false
//    
//    // MARK: – Inputs from parent
//    @Binding var userId : Int
//    let profileImage: String
//    let username: String
//    
//    @Binding var showParentToast: Bool
//    @Binding var parentToastMessage: String
//    var onDismiss: () -> Void = {}
//    
//    // MARK: – View
//    var body: some View {
//        ZStack {
//            VStack(spacing: 20) {
//                
//                // ---------- HEADER ----------
//                HStack {
//                    HStack(spacing: 12) {
//                        AsyncImage(url: URL(string: profileImage)) { phase in
//                                           switch phase {
//                                           case .empty:
//                                               ProgressView()
//                                                   .frame(width: 80, height: 80)
//                                           case .success(let image):
//                                               image
//                                                   .resizable()
//                                                   .scaledToFill()
//                                                   .frame(width: 36, height: 36)
//                                                   .clipShape(Circle())
//                                           case .failure:
//                                               Image(systemName: "person.crop.circle.fill")
//                                                   .resizable()
//                                                   .scaledToFill()
//                                                   .frame(width: 36, height: 36)
//                                                   .clipShape(Circle())
//                                           @unknown default:
//                                               EmptyView()
//                                           }
//                                       }
//                        
//                        Text("@\(username)")
//                            .font(.custom(poppinsSemiBold, size: 14.0))
//                            .foregroundColor(.black)
//                    }
//                    
//                    Spacer()
//                    
//                    
//                    Button { onDismiss() } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(.red)
//                            .frame(width: 30, height: 30)
//                    }
//                }
//                
//                // ---------- MESSAGE ----------
//                Text("Would you like to be notified when @\(username) goes live?")
//                    .font(.subheadline)
//                    .multilineTextAlignment(.leading)
//                    .foregroundColor(.black)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                // ---------- BUTTONS ----------
//                VStack(spacing: 12) {
//                    Button { notifyUser() } label: {
//                        Text("Yes, notify me")
//                            .fontWeight(.bold)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.defaultTheme)
//                            .foregroundColor(.white)
//                            .cornerRadius(30)
//                    }
//                    
//                    Button { onDismiss() } label: {
//                        Text("No, thanks")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color(.systemGray6))
//                            .foregroundColor(.black)
//                            .cornerRadius(30)
//                    }
//                }
//                
//                Spacer()
//            }
//            .padding()
//            
//            // ---------- LOADING OVERLAY ----------
//            if isLoading {
//                Color.black.opacity(0.25).ignoresSafeArea()
//                LoadingIndicator()
//            }
//        }
//        .background(Color.white)
//        .cornerRadius(20)
//     
//        .toast(isPresenting: $showHUD) {
//            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
//            
//        }
//        .bottomSheet(
//            isPresented: $showError,
//            height: screenHeight / 2.3,
//            topBarCornerRadius: 25,
//            showTopIndicator: false
//        ) {
//            CommonBottomSheet(
//                sheetType: $alertType,
//                onPrimaryClick: { withAnimation { showError = false } },
//                onSecondaryClick: { withAnimation { showError = false } }
//            )
//        }
//    }
//    
//    // MARK: – Actions
//    private func notifyUser() {
//        Task{
//           guard Reachability.isConnectedToNetwork() else {
//                hudMsg = "No Internet Connection"
//                showHUD = true
//                return
//            }
//            let param = NotifyLiveUserRequest(live_user_id: userId)
//            SVProgressHUD.show()
//            await viewModel.notifyLiveUser(parameter: param)
//            await SVProgressHUD.dismiss()
//            handleSuccess()
//        }
//    }
//
//    private func handleSuccess() {
//        SVProgressHUD.dismiss()
//        let response = viewModel.notifyLiveUserResponseDict
//        if response?.status == "success" {
//            parentToastMessage = response?.message ?? "Notification set!"
//                   showParentToast = true
//                   
//                   onDismiss()
//          
//        } else {
//            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
//            withAnimation(.snappy) { showError = true }
//        }
//    }
//}

struct NotifyMeBottomSheet: View {
    
    // MARK: – Environment & VM
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = NotifyMeViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    // MARK: – UI State
    @State private var isLoading    = false
    @State private var showError    = false
    @State private var alertType: BottomSheetType =
        .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showHUD      = false
    @State private var hudMsg       = ""
    @State private var navToProfile = false
    @State private var yesButtonScale: CGFloat = 1.0
    @State private var noButtonScale: CGFloat = 1.0
    
    // MARK: – Inputs from parent
    @Binding var userId : Int
    let profileImage: String
    let username: String
    
    @Binding var showParentToast: Bool
    @Binding var parentToastMessage: String
    var onDismiss: () -> Void = {}
    
    // MARK: – View
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.top, 8)
            }
            VStack(spacing: 12) {
                // ---------- HEADER ----------
                HStack(spacing: 0) {
                    HStack(spacing: 12) {
                        
                        CustomProfileImage(url: profileImage,isCircular: true,size: 44)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("@\(username)")
                                .font(.custom(poppinsSemiBold, size: 16))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 6, height: 6)
                                
                                Text("Live Notification")
                                    .font(.custom(poppinsRegular, size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.custom(poppinsSemiBold, size: 24.0))
                            .foregroundStyle(.black)
                    }
                }
                //                    .padding(.horizontal, 16)
                
                // ---------- MESSAGE CARD ----------
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.defaultThemeLight)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Stay Updated")
                                .font(.custom(poppinsSemiBold, size: 13))
                                .foregroundColor(.primary)
                            
                            Text("Would you like to be notified when @\(username) goes live?")
                                .font(.custom(poppinsRegular, size: 11))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer(minLength: 0)
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.defaultThemeLight, lineWidth: 1)
                )
                //                    .padding(.horizontal, 20)
                Spacer()
                // ---------- BUTTONS ----------
                VStack(spacing: 12) {
                    PrimaryButton(title: "Yes, notify me",isOutLine:false,onButtonClick:{
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            yesButtonScale = 0.95
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                yesButtonScale = 1.0
                            }
                            notifyUser()
                        }
                    }, btnTextColor:.white, btnColor: .defaultTheme)
                    
                    PrimaryButton(title: "No, Thanks",isOutLine:false,onButtonClick:{
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            noButtonScale = 0.95
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                noButtonScale = 1.0
                            }
                            onDismiss()
                        }
                    }, btnTextColor:.defaultTheme, btnColor: .defaultThemeLight)
                }
                
                
            }
            
            
        }
        .edgesIgnoringSafeArea(.top)
        .padding(.horizontal, 16)
        .background(.backGround)
        .toast(isPresenting: $showHUD) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: { withAnimation { showError = false } },
                onSecondaryClick: { withAnimation { showError = false } }
            )
        }
    }
    
    // MARK: – Actions
    private func notifyUser() {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showHUD = true
                return
            }
            let param = NotifyLiveUserRequest(live_user_id: userId)
            SVProgressHUD.show()
            await viewModel.notifyLiveUser(parameter: param)
            await SVProgressHUD.dismiss()
            handleSuccess()
        }
    }

    private func handleSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.notifyLiveUserResponseDict
        if response?.status == "success" {
            parentToastMessage = response?.message ?? "Notification set!"
            showParentToast = true
            
            onDismiss()
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
}
