//
//  BlockedUserScreen.swift
//  BidCast
//
//  Created by JAM-E-329 on 13/08/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct BlockedUserScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showError: Bool = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var viewModel = BlockedUserListViewModel()
    @State var profileViewModel = ProfileViewModel()
    
    @State private var blockedUsers: [BlockedUserList] = []
    @State private var navigateToHome = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            PrimaryHeader(
                title: "Blocked Users",
                isForLogo: false,
                leadingImgArr: [.sideArrow],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            
            // Blocked User Cards
            List {
                if blockedUsers.isEmpty {
                    Text("No blocked users found")
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(blockedUsers, id: \.id) { user in
                        BlockedUserCard(user: user)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await UnBlockedUser(sellerId: user.id ?? 0)
                                    }
                                } label: {
                                    Label("Unblock", systemImage: "person.crop.circle.badge.minus")
                                }
                                .tint(.red)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await loadData()
            }

            
            Spacer()
            CusNavLink(doNavigate: $navigateToHome, destination: HomeViewScreen(showCategory: .constant(""), comeFromExploreScreen: .constant(false)))
            
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        
        
        .background(Color(.systemGray6))
        .onFirstAppear {
            Task { await loadData() }
        }
    }
    
    func loadData() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await viewModel.getBlockUser()
        await SVProgressHUD.dismiss()
        
        if viewModel.blockedUserListResponse.status != "success" {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.blockedUserListResponse.message ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .pinkBtn
            )
            withAnimation(.snappy) { showError = true }
        } else {
            blockedUsers = viewModel.blockedUserListResponse.data ?? []
        }
    }
    
    func UnBlockedUser(sellerId : Int) async{
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        let param = BlockUserRequest(blocked_id: sellerId )
        await self.profileViewModel.blockUser(param: param)
        await SVProgressHUD.dismiss()
        blockSuccess()
    }
    
    //MARK: blockSuccess.
    func blockSuccess(){
        SVProgressHUD.dismiss()
        let response = profileViewModel.blockUserResponseDict
        if response?.status == "success" {
            hudMsg = response?.message ?? ""
            showhud = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                navigateToHome = true
            }
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
}

struct BlockedUserCard: View {
    var user: BlockedUserList
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            
            Text(user.name ?? "Unknown User")
                .font(.custom(poppinsSemiBold, size: 16))
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
