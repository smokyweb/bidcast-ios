//
//  InterviewDetailScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 07/03/24.
//

import SwiftUI
import Kingfisher
import AlertToast
import BottomSheet

struct InterviewDetailScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var interviewId: String
    @State var employerId: String? = ""
    @Binding var userList: UserDetailModal

    @State var interviewDetail: InterviewScheduleModal = InterviewScheduleModal()
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showActionButton: Bool = false
    @State var showAcceptAction: Bool = false
    @State var showScheduleBtn: Bool = false
    @State var showReschedule: Bool = false
    @State var isReschedule: Bool = false
    
    @State var navigateToScheduleInterView: Bool = false
    @State var selectedJobDate: Date = Date()
    @State var isFromSelectedEmployee: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var jobTitle: String = ""

    var viewModel = InterviewDetailViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                PrimaryHeader(
                    title: "Interview Detail",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack {
                        
                        if isFromSelectedEmployee{
                            KFImage.url(getMediaURL(url: userList.profile_image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))
                                .placeholder({
                                    Image(.imgPlaceholder)
                                        .resizable()
                                        .blur(radius: 1.5)
                                })
                            
                                .retry(maxCount: 3, interval: .seconds(5))
                                .cacheOriginalImage()
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: screenWidth/2.75, height: screenWidth/2.75)
                                .clipShape(Circle())
                            
                            Text(userList.name ?? "")
                                .font(.custom(nunitoBold, fixedSize: 22))
                                .foregroundStyle(.black)
                                .padding(.bottom)
                        }else{
                            KFImage.url(getMediaURL(url: interviewDetail.job?.user?.company_data?.company_logo ?? "" == "" ? interviewDetail.user?.profile_image ?? "" : interviewDetail.job?.user?.company_data?.company_logo ?? ""))
                                .placeholder({
                                    Image(.imgPlaceholder)
                                        .resizable()
                                        .blur(radius: 1.5)
                                })
                            
                                .retry(maxCount: 3, interval: .seconds(5))
                                .cacheOriginalImage()
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: screenWidth/2.75, height: screenWidth/2.75)
                                .clipShape(Circle())
                            
                            Text(interviewDetail.job?.user?.company_data?.company_name ?? "" != "" ? interviewDetail.job?.user?.company_data?.company_name ?? "" : interviewDetail.user?.name ?? "" == "" ? interviewDetail.job?.user?.name ?? "" : interviewDetail.user?.name ?? "")
                                .font(.custom(nunitoBold, fixedSize: 22))
                                .foregroundStyle(.black)
                                .padding(.bottom)
                        }
                        
                        VStack(spacing: 6) {
                            HStack {
                                if isFromSelectedEmployee{
                                    Text("Job Title")
                                        .font(.custom(nunitoRegular, fixedSize: 14))
                                    Spacer()
                                    Text(jobTitle ?? " - ")
                                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                                }else{
                                    Text("Job Title")
                                        .font(.custom(nunitoRegular, fixedSize: 14))
                                    Spacer()
                                    Text(interviewDetail.job?.title ?? " - ")
                                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                                }
                            }
                            
                            HStack {
                                
                                if isFromSelectedEmployee{
                                    
                                    Text("Salary")
                                        .font(.custom(nunitoRegular, fixedSize: 14))
                                    Spacer()
                                    Text("$\(userList.jobMatched?.salary ?? "")/\(userList.jobMatched?.salary_type ?? " - ")")
                                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                                    
                                }else{
                                    Text("Salary")
                                        .font(.custom(nunitoRegular, fixedSize: 14))
                                    Spacer()
                                    Text("$\(interviewDetail.job?.salary ?? " - ")/\(interviewDetail.job?.salary_type ?? " - ")")
                                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                                }
                            }
                            HStack {
                                Text("Interview Status")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                Spacer()
                                Text(interviewDetail.status?.getInterviewStatus() ?? " - ")
                                    .font(.custom(nunitoBold, fixedSize: 14))
                                    .foregroundStyle(interviewDetail.status?.getInterviewStatusColor() ?? .gray)
                            }
                            HStack {
                                Text("Interview Date")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                Spacer()
                                Text("\(interviewDetail.scheduledDate ?? " - ")")
                                    .font(.custom(nunitoSemiBold, fixedSize: 14))
                            }
                            HStack {
                                Text("Interview Time")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                Spacer()
                                Text("\(interviewDetail.scheduledTime ?? " - ")")
                                    .font(.custom(nunitoSemiBold, fixedSize: 14))
                            }
                            
                            if (interviewDetail.rescheduled_date ?? "") != "" {
                                Divider()
                                
                                HStack {
                                    Text("Interview Re-Scheduled")
                                        .font(.custom(nunitoSemiBold, fixedSize: 16))
                                    Spacer()
                                }
                                HStack {
                                    Text("Interview Date")
                                        .font(.custom(nunitoRegular, fixedSize: 14))
                                    Spacer()
                                    Text("\(interviewDetail.rescheduled_date ?? " - ")")
                                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                                }
                                HStack {
                                    Text("Interview Time")
                                        .font(.custom(nunitoRegular, fixedSize: 14))
                                    Spacer()
                                    Text("\(interviewDetail.rescheduled_time ?? " - ")")
                                        .font(.custom(nunitoSemiBold, fixedSize: 14))
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .gray, radius: 2, x: 0, y: 0)
                        )
                        .unredacted(when: $isLoading)
                    }
                    .padding()
                }).refreshable {
                    if !isFromSelectedEmployee{
                        viewModel.getInterviewDetail(id: interviewId)
                    }
                }
                
                Spacer()
                if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
                    if role == "employer" {
                        if interviewDetail.status != "5" {
                            VStack {
                                if showAcceptAction && showActionButton {
                                    HStack {
                                        PrimaryButton(
                                            title: interviewDetail.status == "3" ? "Reject" : "Cancel",
                                            isOutLine: true,
                                            onButtonClick: {
                                                if interviewDetail.status == "3" {
                                                    viewModel.updateInterviewStatus(status_id: "4", match_id: "\(interviewDetail.id ?? 0)")
                                                    observe()
                                                } else {
                                                    alertType = .sheetType(icon: .alert, title: "Alert", message: "Are you sure you want to cancel this interview?", primaryBtnText: "Confirm", secondaryBtnText: "Cancel", sheetThemeColor: .text)
                                                    showAlert = true
                                                }
                                            }, width: screenWidth/2 - 30, height: 45)
                                        
                                        Spacer()
                                        
                                        PrimaryButton(
                                            title: "Accept",
                                            isOutLine: false,
                                            onButtonClick: {
                                                viewModel.updateInterviewStatus(status_id: "2", match_id: "\(interviewDetail.id ?? 0)")
                                                observe()
                                            }, width: screenWidth/2 - 30, height: 45)
                                    }.padding(.horizontal, 8)
                                } else if showActionButton {
                                    PrimaryButton(
                                        title: "Cancel",
                                        isOutLine: true,
                                        onButtonClick: {
                                            alertType = .sheetType(icon: .alert, title: "Alert", message: "Are you sure you want to cancel this interview?", primaryBtnText: "Confirm", secondaryBtnText: "Cancel", sheetThemeColor: .text)
                                            showAlert = true
                                        }, height: 45)
                                }
                                
                                if showReschedule {
                                    PrimaryButton(
                                        title: isReschedule ? "Reschedule Interview" : "Schedule Interview",
                                        isOutLine: false,
                                        onButtonClick: {
                                            interviewId = "\(interviewDetail.id ?? 0)"
                                            employerId = interviewDetail.employer_id
                                            selectedJobDate = interviewDetail.scheduledDate?.schedDateToDate() ?? Date()
                                            navigateToScheduleInterView = true
                                        })
                                }
                            }
                            .padding()
                            .background(.white)
                        }
                    }
                }
            }
            .padding(.top, -topPadding)
      //      .background(.backGround)
            .task {
                if !isFromSelectedEmployee{
                    viewModel.getInterviewDetail(id: interviewId)
                }
            }
            .onAppear {
                observe()}
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        if alertType.primaryBtnText == "Confirm" {
                            viewModel.updateInterviewStatus(status_id: "5", match_id: "\(interviewDetail.id ?? 0)")
                            observe()
                        }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation{ showAlert = false }
//                    }, rightButtonAction: {
//                        if alertType.rightActionText == "Confirm" {
//                            withAnimation{ showAlert = false }
//                            viewModel.updateInterviewStatus(status_id: "5", match_id: "\(interviewDetail.id ?? 0)")
//                            observe()
//                        } else {
//                            withAnimation{ showAlert = false }
//                        }
//                    })
//            }
            
            CusNavLink(doNavigate: $navigateToScheduleInterView, destination: ScheduleInterviewScreen(interviewId: $interviewId, employerId: .constant(""), date: $selectedJobDate, isReschedule: $isReschedule))
        }
    }
    
    //MARK: View Model Observer
    func observe() {
        viewModel.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
            }
        }
    }
    
    //MARK: View Model Handle Success
    func handleSuccess() {
        if viewModel.requestType == "GetInterviewDetail" {
            if let response = viewModel.response {
                if response.status == "success" {
                    interviewDetail = response.data
                    if interviewDetail.status != "5" {
                        if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
                            if role == "employee" {
                                if interviewDetail.status == "0" {
                                    withAnimation {
                                        showReschedule = true
                                        showActionButton = false
                                        showAcceptAction = false
                                    }
                                    isReschedule = false
                                } else {
                                    if interviewDetail.status == "3" && interviewDetail.employee_agree ?? "0" == "0" {
                                        withAnimation {
                                            showActionButton = true
                                            showAcceptAction = true
                                            showReschedule = false
                                        }
                                    } else if interviewDetail.employee_agree ?? "0" == "0" {
                                        withAnimation(.easeOut(duration: 0.25)) {
                                            showActionButton = true
                                        }
                                    } else {
                                        withAnimation {
                                            showActionButton = true
                                            showReschedule = false
                                        }
                                    }
                                }
                            } else if role == "employer" {
                                if interviewDetail.status != "0" && interviewDetail.employee_agree == "1" {
                                    withAnimation(.easeOut(duration: 0.25)) { showReschedule = true }
                                    isReschedule = true
                                }else {
                                    withAnimation(.easeOut(duration: 0.25)) { showReschedule = false }
                                    isReschedule = true
                                }
                                
                                if interviewDetail.employer_agree ?? "0" == "0" {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showAcceptAction = true
                                        showActionButton = true
                                    }
                                } else {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        showAcceptAction = false
                                        showActionButton = true
                                        showReschedule = false
                                    }
                                }
                            }

                        }
                    } else {
                        showAcceptAction = false
                        showActionButton = false
                        withAnimation(.easeOut(duration: 0.25)) { showReschedule = false }
                        
                    }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        } else if viewModel.requestType == "UpdateInterviewStatus" {
            if let response = viewModel.scheduleJobResponse {
                if response.status == "success" {
                    showAcceptAction = false
                    showActionButton = false
                    isReschedule = false
                    showReschedule = false
                    viewModel.getInterviewDetail(id: interviewId)
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        } else if viewModel.requestType == "ScheduleInterview" {
            
        }
    }
}

//#Preview {
//    InterviewDetailScreen(interviewId: .constant(""), userList: .constant(UserDetailModal()))
//}
