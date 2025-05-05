//
//  MatchesScreen.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI

struct MatchesScreen: View {
    
    @Binding var isLoading: Bool
    @Binding var showAlert: Bool
    @Binding var alertType: BottomSheetType
    @State var matchedJob: InterviewScheduleModal = InterviewScheduleModal()
//    @Binding var jobDetail: InterviewScheduleModal
    @State var selectedEmployee: UserDetailModal = UserDetailModal()

    @State var matchedJobList: [InterviewScheduleModal] = []
    @State var selectedJobDate: Date = Date()
    @State var selectedJobIndex: Int = 0
    @State var interviewId: String = ""
    @State var employerId: String = ""
    @State var showJobMatchSheet: Bool = false

    @State var navigateToScheduleInterView: Bool = false
    @State var navigateToInterView: Bool = false
    @State var isReshedule: Bool = false
    
    @State var totalPage: Int = 1
    @State var currentPage: Int = 1
    
    @State var viewModal: HomeScreenViewModal? // = HomeScreenViewModal()
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(showsIndicators: false, content: {
                    if matchedJobList.count > 0 {
                        LazyVStack(spacing: 16, content: {
                            ForEach(matchedJobList.indices, id: \.self) {
                                ind in
                                JobMatchesCard(
                                    matchedJobDetail: $matchedJobList[ind],
                                    onRescheduleClick: {
                                        selectedJobIndex = ind
                                        selectedJobDate = "\(matchedJobList[ind].scheduledDate ?? "")".schedDateToDate()
                                        interviewId = "\(matchedJobList[ind].id ?? 0)"
                                        employerId = "\(matchedJobList[ind].employer_id ?? "")"
                                        isReshedule = true
                                        navigateToScheduleInterView = true
                                    },
                                    onScheduleClick: {
//                                        showJobMatchSheet = true
                                        selectedJobIndex = ind
                                        selectedJobDate = "\(matchedJobList[ind].scheduledDate ?? "")".schedDateToDate()
                                        interviewId = "\(matchedJobList[ind].id ?? 0)"
                                        employerId = matchedJobList[ind].employer_id ?? ""
                                        isReshedule = false
                                        navigateToScheduleInterView = true
                                    }, onClick: {
                                        interviewId = "\(matchedJobList[ind].id ?? 0)"
                                        navigateToInterView = true
                                    }, onStatusClick: { status, id in
                                        isLoading = true
                                        viewModal?.updateInterviewStatus(status_id: status, match_id: id)
                                        observe()
                                    }).onAppear(perform: {
                                        handlePagination(currentData: matchedJobList[ind])
                                    })
                            }
                        })
                        
                        .padding([.horizontal, .vertical])
                    } else {
                        VStack {
                            Image(.noData)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: screenWidth/2, height: screenHeight/6)
                                .foregroundStyle(.text)
                            
                            Text("No Job has been matched.")
                                .font(.custom(nunitoMedium, fixedSize: 18))
                                .foregroundStyle(.gray)
                        }.frame(height: screenHeight * 0.7)
                    }
                })
                
                Spacer()
            }
            .task {
                viewModal?.getJobMatchesForEmployee(currentPage: currentPage)
            }
            .onAppear(perform: {
                viewModal = HomeScreenViewModal()
                observe()
            })
//            .bottomSheet(isPresented: $showJobMatchSheet, height: screenHeight / 1.75, topBarHeight: 0, topBarCornerRadius: 20, showTopIndicator: false) {
//                ForEach(matchedJobList.indices, id: \.self) {
//                    ind in
//                    JobMatchSheet(
//                        jobDetail: $matchedJobList[0],
////                        jobDetail: $matchedJob, // Pass the matchedJob data here
//                        onScheduleClick: {
//                            withAnimation(.spring) {
//                                showJobMatchSheet = false
//                            }
//                            withAnimation(.spring) {
//                                navigateToScheduleInterView = true
//                            }
//                        },
//                        onContinueClick: {
//                            withAnimation(.spring) {
//                                showJobMatchSheet = false
//                            }
//                        }
//                    )
//                }
//            }

            .refreshable {
                isLoading = true
                selectedJobIndex = 0
                generateFeedback(type: .medium)
                currentPage = 1
                viewModal?.getJobMatchesForEmployee(currentPage: 1)
                observe()
            }

            CusNavLink(doNavigate: $navigateToScheduleInterView, destination: ScheduleInterviewScreen(interviewId: $interviewId,employerId:$employerId, date: $selectedJobDate, isReschedule: $isReshedule))
            CusNavLink(doNavigate: $navigateToInterView, destination: InterviewDetailScreen(interviewId: $interviewId, userList: $selectedEmployee))
        }
    }
    
        //MARK: Handle Interview List Screen Pagination
    func handlePagination(currentData item: InterviewScheduleModal) {
        let thresholdData = matchedJobList.last?.id
        if thresholdData == item.id, (currentPage + 1) <= totalPage {
            currentPage += 1
            isLoading = true
            viewModal?.getJobMatchesForEmployee(currentPage: currentPage)
            observe()
        }
    }
    
    func observe() {
        viewModal?.eventHandler = {
            event in
            switch event {
                case .loading:
                    isLoading = true
                case .stopLoading:
                    isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
            }
        }
    }
    
    func handleSuccess() {
        if viewModal?.requestType == "UpdateInterviewStatus" {
            currentPage = 1
            viewModal?.getJobMatchesForEmployee(currentPage: currentPage)
        } else {
            if let response = viewModal?.getJobMatchesResponse {
                if response.status == "success" {
                    totalPage = response.totalPage ?? 1
                    response.data.forEach({
                        data in
                        withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                            if !matchedJobList.contains(where: { $0.id == data.id }) {
                                matchedJobList.append(data)
                            } else {
                                let index = matchedJobList.firstIndex(where: { $0.id == data.id }) ?? 0
                                matchedJobList[index] = data
                            }
                        }
                    })
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    UserHomeScreen()
}

extension String {
    func schedDateToDate() -> Date {
        print(self)
        let format = DateFormatter()
        format.dateFormat = "EEEE, MMMM dd, yyyy"
        return format.date(from: self) ?? Date()
    }
}
