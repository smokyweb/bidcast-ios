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
    
    @State private var blockedUsers: [BlockedByUserList] = []
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
            
            // Scrollable list of blocked users
            ScrollView {
                LazyVStack(spacing: 12, pinnedViews: []) {
                    if blockedUsers.isEmpty {
                        NoDataView(message: "No blocked users found")
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        ForEach(blockedUsers, id: \.id) { user in
                            SwipeToUnblockCard(user: user) {
                                Task { await UnBlockedUser(sellerId: user.id ?? 0) }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            .refreshable {
                await loadData()
            }
            
            Spacer()
            
            CusNavLink(
                doNavigate: $navigateToHome,
                destination: HomeViewScreen(showCategory: .constant(""), comeFromExploreScreen: .constant(false))
            )
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .background(Color(.systemGray6))
        .onFirstAppear {
            Task { await loadData() }
        }
    }
    
    // MARK: - Networking
    func loadData() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await viewModel.getBlockUser(param: BlockUserList(blocked_by: nil))
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
            blockedUsers = viewModel.blockedUserListResponse.data?.data ?? []
        }
    }
    
    func UnBlockedUser(sellerId: Int) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        let param = BlockUserRequest(blocked_id: sellerId)
        await self.profileViewModel.blockUser(param: param)
        await SVProgressHUD.dismiss()
        blockSuccess()
    }
    
    func blockSuccess() {
        SVProgressHUD.dismiss()
        let response = profileViewModel.blockUserResponseDict
        if response?.status == "success" {
            hudMsg = response?.message ?? ""
            showhud = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                navigateToHome = true
            }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response?.status?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized,
                sheetThemeColor: .defaultTheme
            )
            withAnimation(.snappy) { showError = true }
        }
    }
}

struct SwipeToUnblockCard: View {
    var user: BlockedByUserList  
    var onUnblock: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: onUnblock) {
                    Label("Unblock", systemImage: "person.crop.circle.badge.minus")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            BlockedUserCard(user: user)
        }
    }
}

struct BlockedUserCard: View {
    var user: BlockedByUserList    // 👈 FIX
    
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
