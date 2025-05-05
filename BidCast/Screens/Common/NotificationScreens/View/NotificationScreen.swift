////
////  NotificationScreen.swift
////  imperium
////
////  Created by Abdul-JAM-E-157 on 20/02/24.
////
//
//import SwiftUI
////import SwipeActions
//import BottomSheet
//import AlertToast
//
//struct NotificationScreen: View {
//    
//    @Environment(\.presentationMode) var presentationMode
//    
//        //MARK: - Loading, Toast Initializer
//    @State var isLoading: Bool = false
//    @State var showError: Bool = false
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @State var showHud: Bool = false
//    @State var hudMsg: String = ""
//    @State var selectedEmployee: UserDetailModal = UserDetailModal()
//
//    @State var notificationListArr: [NotificationListModel] = []
//    
//    @State var selectedNotification: NotificationListModel = NotificationListModel()
//    
//    @State var selectedEmpId: Int?
//    @State var selectedJobId: Int?
//    @State var selectedType: String = ""
//    @State var jobDetail: JobDetailResponse = JobDetailResponse()
//    
//        //MARK: - Notification Navigation Variables
//    @State var navigateToInterviewList: Bool = false
//    @State var navigateToEmployeeProfile: Bool = false
//    @State var navigateToInterviewDetail: Bool = false
//    @State var isJobCreated: Bool = false
//    @State var createdJobId: String = ""
//    @State var employerId: String = ""
//    @State var navigateToScheduleInterView: Bool = false
//    @State var selectedDate: Date = Date()
//    
//    @State var showDeleteSheet: Bool = false
//    @State var selectedNotiId: String = ""
//    @State var selectedInterviewId: String = ""
//    
//    @State var totalPage: Int = 1
//    @State var currentPage: Int = 1
//    
//    @State var state: SwipeState = .untouched
//    
//    @State var viewModel: NotificationViewModel? = NotificationViewModel()
//    
//        //MARK: - Primary Body
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0, content: {
//                PrimaryHeader(title: "Notification", leadingImgArr: [.sideArrow], onClickLeading: { _ in
//                 
//                    self.presentationMode.wrappedValue.dismiss()
//                }, count: .constant(0))
//                
//                HStack {
//                    TitleWithLine(title: "Notification", lineLength: 36)
//                        .padding([.top, .horizontal])
//                    Spacer()
//                    if notificationListArr.count > 0 {
//                        Button {
//                            alertType = .sheetType(icon: .alert, title: "Delete Notification", message: "Are you sure you want to delete all notification?", primaryBtnText: "Delete All", secondaryBtnText: "Cancel", sheetThemeColor: .pinkBtn)
//                            withAnimation(.snappy) { showDeleteSheet = true }
//                        } label: {
//                            Text("clear all")
//                                .tint(.red)
//                                .font(.custom(nunitoBold, fixedSize: 18))
//                        }.padding(.trailing)
//                    }
//                }.padding(.trailing)
//                
//                ScrollView(showsIndicators: false, content: {
//                    if notificationListArr.count > 0 {
//                        LazyVStack(spacing: 12) {
//                            ForEach(notificationListArr.indices, id: \.self) {
//                                ind in
//                                NotificationListingCard(
//                                    notificationData: $notificationListArr[ind],
//                                    onSelected: {
//                                        data in
//                                        selectedEmpId = data.sender?.id
//                                        selectedJobId = Int(data.job_id ?? "0")
//                                        selectedType = data.type ?? ""
//                                        selectedInterviewId = data.match_id ?? ""
//                                        if data.isSeen == "0" {
//                                            viewModel?.updateNotificationContent(notiId: "\(data.id ?? 0)")
//                                        }
//                                        switch selectedType {
//                                            case "job_applied":
//                                            viewModel?.getJobDetail(jobId: "\(selectedJobId!)")
//                                            case "interview_cancelled":
//                                            navigateToInterviewDetail = true
//                                                return
//                                            case "interview_rescheduled", "interview_schedule", "interview_accepted":
//                                                navigateToInterviewDetail = true
//                                                return
//                                            case "job_matched":
//                                                createdJobId = data.match_id ?? ""
//                                                navigateToScheduleInterView = true
//                                                return
//                                            case "created_job", "job_rejected":
//                                                createdJobId = data.job_id ?? ""
//                                                isJobCreated = true
//                                                return
//                                            default:
//                                                return
//                                        }
//                                    })
//                                .addSwipeAction(menu: .swiped, edge: .trailing, state: $state, {
//                                    Button(action: {
//                                        selectedNotiId = "\(notificationListArr[ind].id ?? 0)"
//                                        alertType = .sheetType(icon: .trash, title: "Delete Notification", message: "Do you want to delete selected notification?", primaryBtnText: "Delete", secondaryBtnText: "Cancel", sheetThemeColor: .pinkBtn)
//                                        withAnimation { showDeleteSheet = true }
//                                    }, label: {
//                                        HStack(alignment: .center, spacing: 5) {
//                                            Image(systemName: "xmark.bin.fill")
//                                                .renderingMode(.template)
//                                                .aspectRatio(contentMode: .fill)
//                                                .foregroundStyle(.white)
//                                            
//                                            Text("Delete")
//                                                .font(.custom(nunitoBold, fixedSize: 18))
//                                                .bold()
//                                                .foregroundStyle(.white)
//                                                .lineLimit(1)
//                                        }
//                                        .padding(.all)
//                                        .padding([.top, .bottom])
//                                    })
//                                    .background(.pinkBtn)
//                                    .custCornerRadius(10, corners: [.bottomRight, .topRight])
//                                })
//                                .onAppear(perform: {
//                                    if ind < notificationListArr.count {
//                                        handlePagination(currentData: notificationListArr[ind])
//                                    }
//                                })
//                            }
//                        }
//                        .unredacted(when: $isLoading)
//                        .padding([.horizontal, .vertical])
//                    } else {
//                        VStack {
//                            Image(.noData)
//                                .renderingMode(.template)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: screenWidth/2, height: screenHeight/6)
//                                .foregroundStyle(.text)
//                            
//                            Text("No Notification available")
//                                .font(.custom(nunitoMedium, fixedSize: 18))
//                                .foregroundStyle(.gray)
//                        }.frame(height: screenHeight * 0.7)
//                    }
//                }).refreshable(action: {
//                    generateFeedback(type: .medium)
//                    isLoading = true
//                    state = .untouched
//                    viewModel?.getNotificationContent(page: "1")
//                    currentPage = 1
//                })
//            })
//            .disabled(isLoading)
//            .padding(.top, -topPadding)
//            .padding(.bottom, bottomPadding)
//            .background(.text.opacity(0.05))
//            .bottomSheet(isPresented: $showDeleteSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showDeleteSheet = true }, content: {
//                CommonBottomSheet(sheetType: $alertType,
//                                  onPrimaryClick: {
//                    withAnimation { showDeleteSheet = false }
//                    viewModel?.deleteNotification(id: selectedNotiId)
//                }, onSecondaryClick: {
//                    withAnimation { showDeleteSheet = false }
//                })
//            })
//            .toast(isPresenting: $showHud) {
//                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlyeSuccess)}
//            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation { showError = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    }, onSecondaryClick: {
//                        withAnimation { showError = false }
//                    })
//            })
//            
//            if isLoading, notificationListArr.count == 0 {
//                Loader(isLoading: $isLoading)
//            }
//            
////            if showError {
////                AlertPopUp(
////                    presentAlert: $showError,
////                    alertType: alertType,
////                    leftButtonAction: {
////                        withAnimation(.snappy) { showError = false }
////                    }, rightButtonAction: {
////                        withAnimation(.snappy) { showError = false }
////                        if alertType.rightActionText == "Yes" {
////                            viewModel?.deleteNotification(id: "")
////                            observe()
////                        }
////                    })
////            }
//            
//            //MARK: - Navigation Links
//            CusNavLink(doNavigate: $navigateToEmployeeProfile, destination: EmployeeProfileScreen(job: $jobDetail, employeeId: $selectedEmpId))
//            CusNavLink(doNavigate: $navigateToInterviewList, destination: InterviewlistScreen())
//            CusNavLink(doNavigate: $navigateToInterviewDetail, destination: InterviewDetailScreen(interviewId: $selectedInterviewId, userList: $selectedEmployee))
//            CusNavLink(doNavigate: $isJobCreated, destination: JobPostingScreen(jobId: $createdJobId, enableSwipe: .constant(false)))
//            CusNavLink(doNavigate: $navigateToScheduleInterView, destination: ScheduleInterviewScreen(interviewId: $createdJobId, employerId: .constant(""), date: $selectedDate, isReschedule: .constant(false)))
//        }
//        .edgesIgnoringSafeArea(.bottom)
//        .task {
//            viewModel?.getNotificationContent(page: "\(currentPage)")
//        }
//        .onAppear(perform: {
//            viewModel = NotificationViewModel()
//            observe()
//        })
//        .onDisappear(perform: {
//            viewModel = nil
//        })
//        .onTapGesture {
//            UIApplication.shared.endEditing()
//        }
//    }
//    
//        //MARK: - Handle Notification Screen Pagination
//    func handlePagination(currentData item: NotificationListModel) {
//        let thresholdData = notificationListArr.last?.id
//        if thresholdData == item.id, (currentPage + 1) <= totalPage {
//            currentPage += 1
//            viewModel?.getNotificationContent(page: "\(currentPage)")
//        }
//    }
//    
//        //MARK: - HandleNotification Navigation
//    func handleNavi(type: String) {
//        
//    }
//    
//        //MARK: - ViewModel Observer
//    func observe() {
//        viewModel?.eventHandler = { event in
//            switch event {
//                case .loading:
//                    self.isLoading = true
//                case .stopLoading:
//                    self.isLoading = false
//                case .dataLoaded:
//                    success()
//                case .error(let error):
//                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    self.showError = true
//            }
//        }
//    }
//    
//        //MARK: - ViewModel Success Handle
//    func success() {
//        if viewModel?.requestType == "GetNotification"{
//            if let dict = viewModel?.notificationResponceDict {
//                if dict.status == "success" {
//                    totalPage = dict.totalPage ?? 0
//                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
//                        if currentPage == 1 {
//                            notificationListArr.removeAll()
//                        }
//                        dict.data.forEach({
//                            data in
//                            if !notificationListArr.contains(where: { $0.id == data.id }) {
//                                notificationListArr.append(data)
//                            } else {
//                                let index = notificationListArr.firstIndex(where: { $0.id == data.id }) ?? 0
//                                notificationListArr[index] = data
//                            }
//                        })
//                    }
//                }else{
//                    alertType = .sheetType(icon: .alert, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation(.snappy) { showError = true }
//                }
//            }
//        }else if viewModel?.requestType == "GetJobDetails" {
//            if let response = viewModel?.jobDetailResponse {
//                jobDetail = response.data
//                navigateToEmployeeProfile = true
//            }
//        } else if viewModel?.requestType == "ReadNoti" {
//                //            switch selectedType {
//                //                case "job_applied":
//                //                    self.viewModel.getJobDetail(jobId: "\(selectedJobId!)")
//                //                case "interview_rescheduled", "interview_schedule":
//                //                    navigateToInterviewList = true
//                //                default:
//                //                    return
//                //            }
//        } else if viewModel?.requestType == "DeleteNotification" {
//            if let response = viewModel?.deleteNotiResponse {
////                alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .text)
////                withAnimation(.snappy) { showError = true }
//                
//                hudMsg = response.message?.capitalized ?? ""
//                showHud = true
//                
//                if response.status == "success" {
//                    currentPage = 1
//                    viewModel?.getNotificationContent(page: "\(currentPage)")
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    NotificationScreen()
//}
