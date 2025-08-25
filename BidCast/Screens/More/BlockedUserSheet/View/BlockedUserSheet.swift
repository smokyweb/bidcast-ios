
//
//  BlockedUserSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD

struct BlockedUserSheet: View {
    
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
    
    // MARK: – Inputs from parent
    let profileImage: String
    let username: String
    let winnerProfileID : Int
    
    @Binding var showParentToast: Bool
    @Binding var parentToastMessage: String
    var onDismiss: () -> Void = {}

    
    // MARK: – View
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                // ---------- HEADER ----------
                HStack {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: profileImage)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        Text("\(username)")
                            .font(.custom(poppinsSemiBold, size: 14.0))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                    }
                }
                
                // ---------- MESSAGE ----------
                Text("\(username) Blocked You")
                    .font(.custom(poppinsBold, size: 16.0))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)

                
                // ---------- SINGLE BUTTON ----------
                Button {
                    onDismiss()
                } label: {
                    Text("OK")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                
                Spacer()
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
}
