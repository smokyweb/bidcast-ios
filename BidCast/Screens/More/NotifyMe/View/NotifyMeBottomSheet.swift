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
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    // ---------- HEADER ----------
                    HStack(spacing: 0) {
                        HStack(spacing: 14) {
                            AsyncImage(url: URL(string: profileImage)) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        
                                        ProgressView()
                                            .frame(width: 44, height: 44)
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.2)]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2
                                                )
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                case .failure:
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .foregroundColor(.gray)
                                            .clipShape(Circle())
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
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
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onDismiss()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // ---------- MESSAGE CARD ----------
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.defaultTheme.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Stay Updated")
                                    .font(.custom(poppinsSemiBold, size: 15))
                                    .foregroundColor(.primary)
                                
                                Text("Would you like to be notified when @\(username) goes live?")
                                    .font(.custom(poppinsRegular, size: 14))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            Spacer(minLength: 0)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.defaultTheme.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // ---------- BUTTONS ----------
                    VStack(spacing: 12) {
                        // Yes Button
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                yesButtonScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    yesButtonScale = 1.0
                                }
                                notifyUser()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Yes, notify me")
                                    .font(.custom(poppinsSemiBold, size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.defaultTheme.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .scaleEffect(yesButtonScale)
                        
                        // No Button
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                noButtonScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    noButtonScale = 1.0
                                }
                                onDismiss()
                            }
                        } label: {
                            Text("No, thanks")
                                .font(.custom(poppinsRegular, size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.primary)
                        }
                        .scaleEffect(noButtonScale)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            // ---------- LOADING OVERLAY ----------
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .blur(radius: 2)
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        
                        Text("Processing...")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGroupedBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
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
