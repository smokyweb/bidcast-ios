//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import SVProgressHUD

struct PromoteToolsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showError: Bool = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var navigateToLesson = false
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var viewModel = PromoteToolsViewModel()
    @State private var promoteToolData = PromoteToolModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PrimaryHeader(
                title: AppString.Promote,
                isForBoth: true,
                leadingImgArr: [.icBack,.appName],
                trailingImgArr: [.icSetting],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Top Banner
                    HStack {
                        AsyncImage(url: URL(string: promoteToolData.showIcon ?? "")) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(promoteToolData.showTitle ?? "")
                                .font(.custom(poppinsSemiBold, size: 20.0))
                                .fontWeight(.semibold)
                            Text(promoteToolData.showDetails ?? "")
                                .font(.custom(poppinsRegular, size: 16.0))
                                .foregroundColor(.darkGray)
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    if let options = promoteToolData.showOptions {
                        HStack {
                            if let shows = options.shows {
                                StatView(stat: StatItem(label: "Shows", value: "\(shows)"))
                            }
                            if let views = options.views {
                                StatView(stat: StatItem(label: "Views", value: "\(views)"))
                            }
                            if let followers = options.followers {
                                StatView(stat: StatItem(label: "Followers", value: "\(followers)"))
                            }
                        }
                        .padding(.horizontal)
                    }


                    // Tools Grid
                    if promoteToolData.features?.count != 0{
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(0 ..< (promoteToolData.features?.count ?? 0), id: \.self) { index in
                                let feature = promoteToolData.features?[index] ?? Feature()
                                ToolGridItemView(feature: feature)
                            }
                        }
                        .padding(.horizontal)
                    }

//                    .padding(.horizontal)
                    
                    // Learn Section
                    VStack(spacing: 12) {
                        Text(promoteToolData.promoteTitle ?? "")
                            .font(.custom(poppinsSemiBold, size: 16.0))
                            .foregroundColor(.white)
                        Text(promoteToolData.promoteDetails ?? "")
                            .font(.custom(poppinsSemiBold, size: 16.0))
                            .foregroundColor(.white.opacity(0.9))
                        Button(action: { navigateToLesson = true }) {
                            Text(AppString.startLearning)
                                .font(.custom(poppinsSemiBold, size: 13.0))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.defaultTheme)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(.defaultTheme)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
            }
            .padding(.top , 15)
        }
        .onFirstAppear {
            Task { await loadData() }
        }
        CusNavLink(doNavigate: $navigateToLesson, destination: LessonScreen())
    }
    
    // MARK: Load API
    func loadData() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await viewModel.getPromoteToolContent()
        await SVProgressHUD.dismiss()
        
        if viewModel.promoteToolResponse.status != "success" {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.promoteToolResponse.message ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .pinkBtn
            )
            withAnimation(.snappy) { showError = true }
        } else {
            promoteToolData = viewModel.promoteToolResponse.data ?? PromoteToolModel()
        }
    }
}
