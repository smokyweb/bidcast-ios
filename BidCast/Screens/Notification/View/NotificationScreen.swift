//
//  NotificationScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct NotificationScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var notiListArr = [NotificationListingModel]()
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var navigateToCreate = false
    @State var isDefault = false
    var viewModel = NotificationViewModel()

    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Notification",
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )

            // MARK: Notification List (Swipe-enabled)
            List {
                ForEach(notiListArr, id: \.id) { notification in
                    if let title = notification.title,
                       let message = notification.message,
                       let createdAt = notification.createdAt {

                        NotificationCardView(
                            title: title,
                            message: message,
                            timeAgo: createdAt.convertToTimeAgo()
                        )
                        .listRowSeparator(.hidden)
                        .swipeActions {
                            Button(role: .destructive) {
                                if let id = notification.id {
                                    notiListArr.removeAll { $0.id == id }
                                    let param = DeleteNotificationRequest(id: id)
                                    Task {
                                        await viewModel.DeleteNotification(param: param)
                                        DeleteNotificationSuccess()
                                    }
                                }
                            }label: {
                                Image("ic_delete")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .clipped()

                            }
                            .tint(.clear)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .listRowBackground(Color.clear)

            // MARK: Clear All Button
            Button(action: {
//                notiListArr.removeAll()
//                let param = DeleteNotificationRequest(id: 0)
//                Task {
//                    await viewModel.DeleteNotification(param: param)
//                    DeleteNotificationSuccess()
//                }
            }) {
                Text("CLEAR ALL")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
        }
        .onAppear {
            Task {
                SVProgressHUD.show()
                await viewModel.GetNotification()
                await SVProgressHUD.dismiss()
                NotificationSuccess()
            }
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }

    //MARK: NotificationSuccess.
    func NotificationSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.notiListingDict
        if response?.status == "success" {
            notiListArr = response?.data ?? []
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }

    //MARK: DeleteNotificationSuccess.
    func DeleteNotificationSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.deleteNotiDict
        if response?.status == "success" {
            Task {
                SVProgressHUD.show()
                await viewModel.GetNotification()
                await SVProgressHUD.dismiss()
                NotificationSuccess()
            }
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
}
