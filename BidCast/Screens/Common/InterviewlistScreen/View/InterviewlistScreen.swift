////
////  InterviewlistScreen.swift
//// BidSwipe
////
////  Created by Abdul-JAM-E-157 on 27/02/24.
////
//
//import SwiftUI
//import BottomSheet
//import AlertToast
//
//struct InterviewlistScreen: View {
//    
//    @Environment(\.presentationMode) var presentationMode
//    @State var isLoading: Bool = false
//    @State var showError: Bool = false
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @State var interviewListContent: [InterviewScheduleModal] = []
//    @State var selectedEmployee: UserDetailModal = UserDetailModal()
//
//    @State var totalPage: Int = 1
//    @State var currentPage: Int = 1
//    @State var selectedJobDate: Date = Date()
//    @State var navigateToDetail: Bool = false
//    @State var navigateToGoogleCalender: Bool = false
//    @State var interviewId: String = ""
//    @State var isReschedule: Bool = false
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    
//    
//    var viewModel = InterviewlistViewModel()
//    
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0, content: {
//                PrimaryHeader(title: "Interview List", leadingImgArr: [.sideArrow], trailingImgArr: [], onClickLeading: { _ in
//                    self.presentationMode.wrappedValue.dismiss()
//                }, onClickTrailing: { _ in
//                    print("Bell Button Clicked")
//                }, count: .constant(0))
//                
//                VStack(alignment: .leading) {
//                    ScrollView(showsIndicators: false){
//                        
//                        if interviewListContent.count > 0 {
//                            LazyVStack(spacing: 12) {
//                                ForEach(interviewListContent.indices, id: \.self) {
//                                    ind in
//                                    JobMatchesCard(
//                                        matchedJobDetail: $interviewListContent[ind],
//                                        onClick: {
//                                            interviewId = "\(interviewListContent[ind].id ?? 0)"
//                                            selectedJobDate = interviewListContent[ind].scheduledDate?.schedDateToDate() ?? Date()
//                                            navigateToDetail = true
//                                        })
//                                    .unredacted(when: $isLoading)
//                                    .onAppear(perform: {
//                                        handlePagination(currentData: interviewListContent[ind])
//                                    })
//                                }
//                            }
//                            .padding([.horizontal, .vertical])
//                        } else {
//                            VStack {
//                                Image(.noData)
//                                    .renderingMode(.template)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: screenWidth/2, height: screenHeight/6)
//                                    .foregroundStyle(.text)
//                                
//                                Text("No Interview Scheduled")
//                                    .font(.custom(nunitoMedium, fixedSize: 18))
//                                    .foregroundStyle(.gray)
////                                PrimaryButton(title: "Schedule Interview", isOutLine: false, onButtonClick: {
////                                    self.navigateToGoogleCalender = true
////                                }, width: screenWidth/1.5, height: 45, btnColor: .text)
//                            }.frame(width: screenWidth, height: screenHeight * 0.7)
//                        }
//                    }
//                    Spacer()
//                }
//                .padding(.bottom, bottomPadding)
//                .background(.text.opacity(0.05))
//                .padding(.top, -topPadding)
//                .refreshable {
//                    generateFeedback(type: .medium)
//                    self.isLoading = true
////                    interviewListContent.removeAll()
//                    viewModel.getInterviewContent(currentPage: 1)
//                    observe()
//                }
//                
//                Spacer()
//            })
//            .toast(isPresenting: $showhud) {
//                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
//            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation { showError = false }
//                    }, onSecondaryClick: {
//                        withAnimation { showError = false }
//                    })
//            })
//            
//            if isLoading && interviewListContent.count == 0 {
//                LoadingIndicator()
//            }
//            
////            if showError {
////                AlertPopUp(
////                    presentAlert: $showError,
////                    alertType: alertType,
////                    rightButtonAction: {
////                        withAnimation(.snappy) { showError = false }
////                    })
////            }
//            
//            CusNavLink(doNavigate: $navigateToDetail, destination: InterviewDetailScreen(interviewId: $interviewId, userList: $selectedEmployee))
//         //   CusNavLink(doNavigate: $navigateToGoogleCalender, destination: ScheduleInterviewScreen(interviewId: $interviewId, date: $selectedJobDate, isReschedule: $isReschedule))//GoogleCalenderScreen())
//            CusNavLink(doNavigate: $navigateToGoogleCalender, destination: GoogleCalenderScreen())
//            
//        }
//        .edgesIgnoringSafeArea(.bottom)
//        .task {
//            viewModel.getInterviewContent(currentPage: currentPage)
//        }
//        .onAppear(perform: {
//            observe()
//        })
//        .onTapGesture {
//            UIApplication.shared.endEditing()
//        }
//    }
//    
//        //MARK: Handle Interview List Screen Pagination
//    func handlePagination(currentData item: InterviewScheduleModal) {
//        let thresholdData = interviewListContent.last?.id
//        if thresholdData == item.id, (currentPage + 1) <= totalPage {
//            currentPage += 1
//            self.viewModel.getInterviewContent(currentPage: currentPage)
//        }
//    }
//    
//    func observe() {
//        self.viewModel.eventHandler = { event in
//            switch event {
//                case .loading:
//                    self.isLoading = true
//                case .stopLoading:
//                    self.isLoading = false
//                case .dataLoaded:
//                    success()
//                case .error(let error):
//                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    showError = true
//            }
//        }
//    }
//    
//    func success() {
//        if let dict = viewModel.interviewDict {
//            
//            if dict.status == "success" {
//                totalPage = dict.totalPage ?? 0
//                withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
//                    dict.data.forEach { data in
//                        if !interviewListContent.contains(where: { $0.id == data.id }) {
//                            interviewListContent.append(data)
//                        } else {
//                            let index = interviewListContent.firstIndex(where: { $0.id == data.id }) ?? 0
//                            interviewListContent[index] = data
//                        }
//                    }
//                }
//            }else{
//                alertType = .sheetType(icon: .alert, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                withAnimation(.snappy) { showError = true }
//            }
//        }
//        
//    }
//}
//
//#Preview {
//    InterviewlistScreen()
//}
