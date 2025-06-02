//
//  NotifyMeBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators

struct NotifyMeBottomSheet: View {
    
    // MARK: – Environment & VM
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = NotifyMeViewModel()
    
    // MARK: – UI State
    @State private var isLoading    = false
    @State private var showError    = false
    @State private var alertType: BottomSheetType =
        .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showHUD      = false
    @State private var hudMsg       = ""
    @State private var navToProfile = false
    
    // MARK: – Inputs from parent
    @Binding var isPresented: Bool
    let userId: Int = 5
    let profileImage: Image
    let username: String
    var onDismiss: () -> Void = {}
    
    // MARK: – View
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                // ---------- HEADER ----------
                HStack {
                    HStack(spacing: 12) {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                        
                        Text("@\(username)")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button { closeSheet() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                
                // ---------- MESSAGE ----------
                Text("Would you like to be notified when @\(username) goes live?")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // ---------- BUTTONS ----------
                VStack(spacing: 12) {
                    Button { notifyUser() } label: {
                        Text("Yes, notify me")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    
                    Button { closeSheet() } label: {
                        Text("No, thanks")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.black)
                            .cornerRadius(30)
                    }
                }
                
                Spacer()
//                CusNavLink(doNavigate: $navToProfile, destination: ProfileScreen())
            }
            .padding()
            
            // ---------- LOADING OVERLAY ----------
            if isLoading {
                Color.black.opacity(0.25).ignoresSafeArea()
                LoadingIndicator()
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .onAppear {
            observeEvents()
        }
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
        let param = NotifyLiveUserRequest(live_user_id: userId)
        viewModel.notifyLiveUser(parameter: param)
    }
    
    private func closeSheet() {
        onDismiss()
        isPresented = false
    }
    
    // MARK: – View-model events
    private func observeEvents() {
        viewModel.eventHandler = { event in
            switch event {
            case .loading:
                isLoading = true
            case .stopLoading:
                isLoading = false
            case .dataLoaded:
                handleSuccess()
            case .error(let err):
                isLoading = false
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: err?.localizedDescription ?? "Unknown error",
                    primaryBtnText: "",
                    secondaryBtnText: "Ok",
                    sheetThemeColor: .pinkBtn
                )
                showError = true
            }
        }
    }
    
    private func handleSuccess() {
        let response = viewModel.notifyLiveUserResponseDict
        if response?.status == "success" {
            onDismiss()
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
}
