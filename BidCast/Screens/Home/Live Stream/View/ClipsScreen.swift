// ProfileScreen.swift
// BidCast

// Created by Tabish-JAM-E-381 on 19/01/25.

import SwiftUI
import SVProgressHUD

struct ClipsScreen: View {

    // MARK: - State
    @State private var viewModel = ProfileViewModel()

    @State private var clipArr: [GetClipModel] = []
    @State private var clipPage: Int = 1
    @State private var totalClipsCount: Int = 0
    @State private var canLoadMoreClips: Bool = true
    @State private var isFetchingMoreClips: Bool = false
    @State var navigateToVideoReceipt = false
    @State var videoURL = ""

    // MARK: - BottomSheet / HUD
    @State private var showError: Bool = false
    @State private var alertType: BottomSheetType =
        .sheetType(icon: .alert,
                   title: "",
                   message: "",
                   primaryBtnText: "",
                   secondaryBtnText: "")

    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""

    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    // MARK: - BODY
    var body: some View {
        VStack{
            VStack(spacing: 12) {
                
                // MARK: Header
                PrimaryHeader(
                    title: "Clips",
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
//                    trailingImgArr: [.icInfo],
                    onClickLeading: { _ in
                        dismiss()
                    },
                    count: .constant(0)
                )
                .frame(height: 50)
                .background(Color.white)
            }
            
            ScrollView(showsIndicators: false) {
                
                // MARK: Clips Grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(clipArr.indices, id: \.self) { index in
                        ClipImage(
                            url: clipArr[index].thumbnailURL ?? "",
                            onSelection: {
                                navigateToVideoReceipt = true
                                videoURL = clipArr[index].clipURL ?? ""
                            }
                        )
                        .onAppear {
                            Task {
                                await handlePagination(index: index)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                // MARK: Loader
                if isFetchingMoreClips {
                    ProgressView()
                        .padding(.vertical, 16)
                }
                
            }
            CusNavLink(doNavigate: $navigateToVideoReceipt, destination: VideoPlayerScreen(videoURL: $videoURL))
        }
        .task {
            await fetchClips(reset: true)
        }
        
        // MARK: Error Bottom Sheet
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight * 0.35,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    showError = false
                },
                onSecondaryClick: {
                    showError = false
                }
            )
        }
    }

    // MARK: - API CALL
    func fetchClips(reset: Bool = false) async {
        if reset {
            resetClipsData()
        }

        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }

        guard canLoadMoreClips else { return }

        isFetchingMoreClips = true
        SVProgressHUD.show()

        let request = clipRequest(page: clipPage)
        await viewModel.getClips(parameters: request)

        await SVProgressHUD.dismiss()
        clipSuccess()
    }

    // MARK: - API SUCCESS
    func clipSuccess() {
        let response = viewModel.getClipsResponseDict

        if response?.status == "success" {
            let newClips = response?.data ?? []
            totalClipsCount = response?.total ?? 0

            if newClips.isEmpty {
                canLoadMoreClips = false
            } else {
                clipArr.append(contentsOf: newClips)
            }
        } else {
            canLoadMoreClips = false
            alertType = .sheetType(
                icon: .alert,
                title: response?.status?.capitalized ?? "Error",
                message: response?.message?.capitalized ?? "Something went wrong",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }

        isFetchingMoreClips = false
    }

    // MARK: - PAGINATION
    func handlePagination(index: Int) async {
        guard canLoadMoreClips, !isFetchingMoreClips else { return }

        let thresholdIndex = clipArr.count - 1
        if index == thresholdIndex && clipArr.count < totalClipsCount {
            clipPage += 1
            await fetchClips()
        }
    }

    // MARK: - RESET
    func resetClipsData() {
        clipArr.removeAll()
        clipPage = 1
        totalClipsCount = 0
        canLoadMoreClips = true
        isFetchingMoreClips = false
    }
}
