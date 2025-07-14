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
    
    @State var currentPage = 1

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
            if notiListArr.count == 0{
                NoDataView(message: "No Notitification Found")
            }else{
                List {
                    ForEach(notiListArr.indices, id: \.self) { index in
                        let notification = notiListArr[index]
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
                            .onAppear {
                                handlePagination(index: index)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .listRowBackground(Color.clear)
                
                //             MARK: Clear All Button
                Button(action: {
                   
                    let param = DeleteNotificationRequest()
                    Task {
                        SVProgressHUD.show()
                        notiListArr.removeAll()
                        await viewModel.DeleteNotification(param: param)
                        await SVProgressHUD.dismiss()
                        DeleteNotificationSuccess()
                    }
                }) {
                    Text("Clear All")
                        .font(.custom(poppinsSemiBold, size: buttonTitle))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.defaultTheme)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
            }
        }
        .onAppear {
            fetchNotification(page: currentPage)
           
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
    
    //MARK: handlePagination.
    func handlePagination(index: Int) {
        let isLastItem = index == notiListArr.count - 1
        let canFetchMore = (viewModel.notiListingDict?.total ?? 0) > notiListArr.count

        if isLastItem && canFetchMore {
            fetchMoreNotificartion()
        }
    }
    
    // MARK: - Fetch Inventory List
    func fetchNotification(page: Int) {
        Task{
            SVProgressHUD.show()
            let param = PageRequest(page: page)
            await viewModel.GetNotification(param: param)
            await SVProgressHUD.dismiss()
            NotificationSuccess()
        }
    }
    
    //MARK: fetchMoreNotificartion.
    func fetchMoreNotificartion() {
        Task {
            currentPage += 1
            let request = PageRequest(page: currentPage)
            await viewModel.GetNotification(param: request)
            NotificationSuccess()
        }
    }

    //MARK: NotificationSuccess.
    func NotificationSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.notiListingDict
        if response?.status == "success" {
            notiListArr.append(contentsOf: response?.data ?? [])
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
                notiListArr.removeAll()
                let param = PageRequest(page: 1)
                await viewModel.GetNotification(param: param)
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
