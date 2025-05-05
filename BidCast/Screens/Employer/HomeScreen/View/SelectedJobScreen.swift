//
//  SelectedJobScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 03/02/24.
//

import SwiftUI
import AlertToast
import AVFoundation
import BottomSheet

struct SelectedJobScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var jobDetail: JobDetailResponse
    @State var userList: [UserDetailModal] = []
    @State var userListProfile : [UserDetailModal] = []
    @State var selectedScreen: String = ""
    @State var isLoading: Bool = false
    @State var job: JobDetailResponse = JobDetailResponse()
    @State var selectedEmployee: UserDetailModal = UserDetailModal()
    @State var navigateToSelectedEmployee: Bool = false
    @State var navigateToEditJobDetail: Bool = false
    @State var navigateToSearch: Bool = false
    @State var totalPage: Int = 1
    @State var currentPage: Int = 1
    @State var selectedJobDate: Date = Date()
    @State var selectedJobIndex: Int = 0
    @State var interviewId: String = ""
    @State var employerId: String = ""
    @State var showJobMatchSheet: Bool = false
    @State var navigateToScheduleInterView: Bool = false
    @State var navigateToInterView: Bool = false
    @State var isReshedule: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var navigateToMenu: Bool = false

    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    @State private var player: AVPlayer?

    @State var request: EmployeeJobIdRequest = EmployeeJobIdRequest(job_id: 0, status: 0,page: 0)
    
    
    var viewModal = EmployerViewModal()
    var viewModalJob = JobPostViewModal()
    
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                HeaderWithSegmentController(
                    title: "IMPERIUM",
                    option: ["Discover", "Saved", "Matched"],
                    leadingImgArr: [.sideArrow],
                    trailingImgArr: [.search,.sideMenu],
                    count: .constant(0),
                    onClickLeading: { _ in
                        withAnimation { self.presentationMode.wrappedValue.dismiss() }
                    }, onClickTrailing: { ind in
                        switch ind {
                            case 1:
                                navigateToMenu = true
                            default:
                                navigateToSearch = true
                        }
                    }, onSegmentOptionClick: { opt in
                        selectedScreen = opt
                        withAnimation {
                            userList.removeAll()
                            if opt == "Matched" {
                                self.viewModal.getJobMatchesForEmployee(currentPage: currentPage, job_id: jobDetail.id ?? 0)
                                request.status = 2
                            } else if opt == "Saved" {
                                request.status = 3
                            } else {
                                request.status = 0
                            }
                        }
                        Task(priority: .userInitiated) {
                            if request.status != 2{
                                self.viewModal.getSelectedJobEmployee(parameter: request)
                            }
                        }
                    },
                    selectedOption: selectedScreen,
                    showAppIcon: true)

                if request.status == 3{
                    VStack{
                        
                        if userListProfile.count > 0 {
                            ScrollView(showsIndicators: false, content: {
                                LazyVStack(spacing: 16) {
                                    ForEach(userListProfile.indices, id: \.self) {
                                        ind in
                                        UserListCard(
                                            employeeDetail: userListProfile[ind],
                                            onClick: { _ in
                                                selectedEmployee = userListProfile[ind]
                                                withAnimation { navigateToSelectedEmployee = true }
                                            })
                                        .onAppear(perform: {
                                            if userList.count > 0 {
                                                handlePagination(currentData: userListProfile[ind])
                                            }
                                        })
                                    }
                                }.padding(.all)
                                
                            }).refreshable {
                                isLoading = true
                                if request.status == 2{
                                    self.viewModal.getJobMatchesForEmployee(currentPage: currentPage, job_id: jobDetail.id ?? 0)
                                }else{
                                    request.job_id = jobDetail.id ?? 0
                                    self.viewModal.getSelectedJobEmployee(parameter: request)
                                }
                                self.observe()
                            }
                            
                            
                        } else if userListProfile.count == 0 && !isLoading {
                            Spacer()
                            Text("No candidate yet showed interest in your job posting")
                                .font(.custom(nunitoSemiBold, fixedSize: 18))
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }

                    }.padding(.top, -topPadding)
                    
                    
                }else if request.status == 2{
                    VStack {
                        ScrollView(showsIndicators: false, content: {
                            if userList.count > 0 {
                                LazyVStack(spacing: 16, content: {
                                    ForEach(userList.indices, id: \.self) {
                                        ind in
                                        EmployeesMatchCard(
                                             userList: $userList[ind],
                                             jobDetail: $jobDetail,
                                            onRescheduleClick: {
                                                selectedJobIndex = ind
                                                selectedJobDate = "\(userList[ind].job?[0].scheduledDate ?? "")".schedDateToDate()
                                                interviewId = "\(userList[ind].job?[0].id ?? 0)"
                                                employerId = "\(userList[ind].job?[0].employer_id ?? "")"
                                                isReshedule = true
                                                selectedEmployee = userList[ind]
                                                navigateToScheduleInterView = true
                                            },
                                            onScheduleClick: {
                                                showJobMatchSheet = true
                                                selectedJobIndex = ind
                                                selectedJobDate = "\(userList[ind].job?[0].scheduledDate ?? "")".schedDateToDate()
                                                interviewId = "\(userList[ind].job?[0].id ?? 0)"
                                                employerId = userList[ind].job?[0].employer_id ?? ""
                                                isReshedule = false
                                                selectedEmployee = userList[ind]
                                                navigateToScheduleInterView = true
                                            }, onClick: {
                                                interviewId = "\(userList[ind].id ?? 0)"
                                                selectedEmployee = userList[ind]
                                                navigateToInterView = true
                                            }, onStatusClick: { status, id in
                                                isLoading = true
//                                                viewModal?.updateInterviewStatus(status_id: status, match_id: id)
                                                observe()
                                            }).onAppear(perform: {
                                                handlePagination(currentData: userList[ind])
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
                        .padding(-40)
                        Spacer()
                    }

                    
                }else{
                    
                    ZStack {
                        if userListProfile.count == 0  {
                            
                            VStack {
                                Spacer()
                                Text("No candidate yet showed interest in your job posting")
                                    .font(.custom(nunitoSemiBold, fixedSize: 18))
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                Spacer()
                            }
                } else {
                            ForEach(userListProfile.indices, id: \.self) { ind in
                                EmployeeStackView(
                                    job: $jobDetail,
                                    userDetail: $userListProfile[ind],
                                    enableSwipe: .constant(true),
                                    onSwipe: { swipe, userId in
                                        if swipe {
                                                handleJobSwipe(userId: userId)
                                        } else {
                                            rejectJob(userId: userId)
                                        }
                                    },
                                    onSaveButtonClick: { userId in
                                        handleSaveJob(userId: userId)
                                    }
                                )
                            }
                        }
                    }

                }

                Spacer()
                
            })
            

            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlyeSuccess)}
            .onAppear(perform: {
                isLoading = true
                self.observe()
                observeJob()
                request.job_id = jobDetail.id ?? 0
                self.viewModal.getSelectedJobEmployee(parameter: request)

            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }

            CusNavLink(doNavigate: $navigateToSelectedEmployee, destination: EmployeeProfileScreen(job: $jobDetail, employeeId: $selectedEmployee.id))
            CusNavLink(doNavigate: $navigateToSearch, destination: EmployerSearchScreen(isFromSelectedJob: true, jobDetail: jobDetail))
            CusNavLink(doNavigate: $navigateToInterView, destination: InterviewDetailScreen(interviewId: $interviewId,userList: $selectedEmployee,isFromSelectedEmployee: true,jobTitle: jobDetail.title ?? ""))

            
        }.fullScreenCover(isPresented: $navigateToMenu) {
            NavigationContainer {
                MenuScreen(comeFromResume : true,jobDetail: jobDetail)
            }
        }
    }
    
    func handleJobSwipe(userId: Int) {
        let status = "1"
        let job_id = job.id ?? 0
        isLoading = true
        self.viewModal.performJobAction(parameter: PerformJobActionRequest(status: status, job_id: job_id, user_id: userId))
        observe()
    }
    
    func rejectJob(userId: Int) {
        let status = "2"
        let job_id = job.id ?? 0
        isLoading = true
        self.viewModal.performJobAction(parameter: PerformJobActionRequest(status: status, job_id: job_id, user_id: userId))
        observe()
    }
    
    func handleSaveJob(userId: Int) {
        let status = "3"
        let job_id = job.id ?? 0
        isLoading = true
        self.viewModal.performJobAction(parameter: PerformJobActionRequest(status: status, job_id: job_id, user_id: userId))
        observe()
    }
    
    func handlePagination(currentData item: UserDetailModal) {
        let thresholdData = userList.last?.id
        if thresholdData == item.id, (currentPage + 1) <= totalPage {
            currentPage += 1
            request.job_id = jobDetail.id ?? 0
            request.page = currentPage
            self.viewModal.getSelectedJobEmployee(parameter: request)
            self.viewModal.getJobMatchesForEmployee(currentPage: currentPage, job_id: jobDetail.id ?? 0)

        }
    }
    
    //MARK: - View Modal Observer
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
            case .loading:
                isLoading = true
            case .stopLoading:
                isLoading = false
            case .dataLoaded:
                handleSuccess()
            case .error(let error):
                print("Error >>> \(String(describing: error))")
            }
        }
    }
    
    func observeJob() {
        self.viewModalJob.eventHandler = {
            event in
            switch event {
            case .loading:
                isLoading = true
            case .stopLoading:
                isLoading = false
            case .dataLoaded:
                handleSuccessJob()
            case .error(let error):
                print("Error >>> \(String(describing: error))")
            }
        }
    }

    
    //MARK: - Success Handler
    func handleSuccess() {
        
        if viewModal.requestType == "GetSelected"{
            if let response = viewModal.userByJobResponse {
                self.viewModal.getJobMatchesForEmployee(currentPage: currentPage, job_id: jobDetail.id ?? 0)
                if response.status == "success" {
                    self.userListProfile = response.data.reversed()
                }
            }
            
        }else if viewModal.requestType == "GetMatchedJob"{
            
            if let response = viewModal.userByJobResponse {
                let jobId = "\(jobDetail.id ?? 0)"
                self.viewModalJob.getJobDetail(parameter: jobId)
                if response.status == "success" {
                    self.userList = response.data
                }
            }
            
        }else if viewModal.requestType == "Action"{
            if let response = viewModal.responseEmployee {
                if response.status == "success" {
                    self.viewModal.getSelectedJobEmployee(parameter: request)
                    hudMsg = response.message?.capitalized ?? ""
                    showHud = true
                } else {
                    hudMsg = response.message?.capitalized ?? ""
                    showHud = true
                }
            }
        }
    }
    
    
    func handleSuccessJob() {
        
        if viewModalJob.requestType == "GetJobDetail"{
            if let response = viewModalJob.response {
                if response.status == "success" {
                    self.job = response.data
                }
            }
        }
    }
}

//#Preview {
//    SelectedJobScreen(jobDetail: .constant(JobDetailResponse()))
//}
