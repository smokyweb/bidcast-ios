//
//  UserHomeScreen.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct UserHomeScreen: View {
    
    //MARK: - Variable Required
    @State var selectedScreen: String = ""
    @State var isLoading: Bool = false
    @State var navigateToMenu: Bool = false
    @State var navigateToSearch: Bool = false
    @State var navigateToNoti: Bool = false
    @State var showJobMatchSheet: Bool = false
    @State var navigateToScheduleInterView: Bool = false
    @State var notiCount = 0
    @State var navigateToCreateVidRes: Bool = false
    @State var navigateToVidResTuto: Bool = false
    @State var navigateToUserHome: Bool = false
    @State var navigateToVideoResume: Bool = false
    @State var showVideoTutorialSheet: Bool = false
    @State var matchedJob: InterviewScheduleModal = InterviewScheduleModal()
    @State var selectedId: String = ""
    @State var employerId: String = ""
    @State var isWelcomePage: Bool = false

    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var hudMsg: String = ""
    @State var showHud: Bool = false
    @State var selectedDate: Date = Date()
    
    @State var viewModal: HomeScreenViewModal?
    
    //MARK: - Primary View Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderWithSegmentController(title: "IMPERIUM", option: ["Discover", "Saved", "Matches"], leadingImgArr: [.search], trailingImgArr: [.notification, .sideMenu], count: $notiCount, onClickLeading: { _ in
                    withAnimation {
                        navigateToSearch = true
                    }
                }, onClickTrailing: { ind in
                    withAnimation {
                        if (ind != 0) {
                            navigateToMenu = true
                        } else {
                            navigateToNoti = true
                        }
                    }
                }, onSegmentOptionClick: { opt in
                    selectedScreen = opt
                }, selectedOption: selectedScreen, showAppIcon: true)
                
                switch selectedScreen {
                case "Saved":
                    SavedScreen(isLoading: $isLoading, showAlert: $showAlert, alertType: $alertType)

                case "Matches":
                    MatchesScreen(isLoading: $isLoading, showAlert: $showAlert, alertType: $alertType)

                default:
                    DiscoverScreen(isLoading: $isLoading, showAlert: $showAlert, alertType: $alertType, showHud: $showHud, hudMsg: $hudMsg)
                }
                
                Spacer()
            }
            .padding(.top, -topPadding)
            .task({
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    viewModal?.getJobMatchesForEmployee(currentPage: 0)
                })
            })
            .onAppear(perform: {
                viewModal = HomeScreenViewModal()
                observe()
            })
            
            .onDisappear(perform:{
                self.isWelcomePage = false
            })

            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlyeSuccess)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            .bottomSheet(isPresented: $showVideoTutorialSheet, height: screenHeight/1.75, topBarHeight: 10, topBarCornerRadius: 25, showTopIndicator: false) {
                VideoResumeSheet(onStartResumeClick: {
                    withAnimation(.easeOut) { showVideoTutorialSheet = false }
                    withAnimation(.easeInOut) { navigateToVideoResume = true }
                }, onWatchTutorialClick: {
                    withAnimation(.easeOut) { showVideoTutorialSheet = false }
                    withAnimation(.easeInOut) { navigateToVidResTuto = true }
                }, onSkipClick: {
                    withAnimation(.easeOut) { showVideoTutorialSheet = false }
                    DispatchQueue.main.async {
                        withAnimation { showAlert = false }
                    }
                })
            }
            

            
            //MARK: - Loader
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
            //MARK: - Navigation Links
            CusNavLink(doNavigate: $navigateToVidResTuto, destination: YourVideoResume())
            CusNavLink(doNavigate: $navigateToVideoResume, destination: RecordVideoView())
            CusNavLink(doNavigate: $navigateToSearch, destination: UserSearchScreen())
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
            CusNavLink(doNavigate: $navigateToScheduleInterView, destination: ScheduleInterviewScreen(interviewId: $selectedId, employerId: $employerId, date: $selectedDate, isReschedule: .constant(false)))
        }.fullScreenCover(isPresented: $navigateToMenu) {
            NavigationContainer {
                MenuScreen()
            }
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
                    isLoading = false
            }
        }
    }
    
    func handleSuccess() {
        if viewModal?.requestType == "GetMatchedJob"{
            if let response = viewModal?.getJobMatchesResponse {
                if response.status == "success" {
                    viewModal?.getWelcomeVideo()
                    if !response.data.isEmpty {
                        matchedJob = response.data.first(where: { $0.status == "0" }) ?? InterviewScheduleModal()
                        selectedId = "\(matchedJob.id ?? 0)"
                        employerId = matchedJob.employer_id ?? ""
                        if matchedJob.status == "0" {
                            if let res: Bool = UserDefaultsManager.shared.value(forKey: .showMatchingSheet) {
                                if res {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                                        generateFeedback(type: .medium)
                                        withAnimation(.easeOut) { showJobMatchSheet = true }
                                        UserDefaultsManager.shared.setValue(false, forKey: .showMatchingSheet)
                                    })
                                }
                            }
                        }
                    }
                }
            }
            
        }else if viewModal?.requestType == "Video"{
            viewModal?.getProfile()
            if let dict = viewModal?.welcomeDict {
                
                if dict.status == "success" {
                    
                    UserDefaultsManager.shared.setModel(dict.data, forKey: .videoURLs)
                }
            }
        }else if viewModal?.requestType == "GetProfile" {
            let response = viewModal?.response
            if response?.status == "success" {
                
                if isWelcomePage == true{
                    if response?.data?.video_resume == "media/employee/default_video.mp4"{
                        withAnimation(.easeIn) { showVideoTutorialSheet = true }
                    }
                }
                viewModal?.getNotificationCount()
            } else {
//                alertType = .sheetType(icon: .alert, title: response?.status.capitalized!, message: response?.message.capitalized!, primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
            
        }else if viewModal?.requestType == "GetNotiCount" {
            if let response = viewModal?.notiCountDict {
                if response.status == "success" {
                    self.notiCount = response.data

                }
            }
        }
    }
}

#Preview {
    UserHomeScreen()
}

