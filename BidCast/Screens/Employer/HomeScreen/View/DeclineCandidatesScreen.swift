//
//  DeclineCandidatesScreen.swift
//  imperium
//
//  Created by JAM-E-221 on 29/07/24.
//

import SwiftUI
import AlertToast

struct DeclineCandidatesScreen: View {
        @Environment(\.presentationMode) var presentationMode
        
        @Binding var jobDetail: JobDetailResponse
        @State var userList: [UserDetailModal] = []
        @State var selectedScreen: String = ""
        @State var isLoading: Bool = false
        @State var job: JobDetailResponse = JobDetailResponse()
        @State var navigateToMenu: Bool = false
        @State var navigateToNotification: Bool = false
        @State var notiCount: Int = 0

        @State var selectedEmployee: UserDetailModal = UserDetailModal()
        @State var navigateToSelectedEmployee: Bool = false
        @State var navigateToEditJobDetail: Bool = false
        @State var navigateToSearch: Bool = false
        @State var totalPage: Int = 1
        @State var currentPage: Int = 1
        @State var showAlert: Bool = false
        @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")

        @State var showHud: Bool = false
        @State var hudMsg: String = ""

        @State var request: EmployeeJobIdRequest = EmployeeJobIdRequest(job_id: 0, status: 0,page: 0)
        
        
        var viewModal = EmployerViewModal()
        var viewModalJob = JobPostViewModal()
        
        
        
        var body: some View {
            ZStack {
                VStack(spacing: 0, content: {
                    PrimaryHeader(title: "Decline  Candidates", leadingImgArr: [.sideArrow], trailingImgArr: [.notification,.sideMenu], onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, onClickTrailing: { ind in
                        switch ind {
                            case 1:
                                navigateToMenu = true
                            default:
                                navigateToNotification = true
                        }
                    }, showAppIcon: true, count: $notiCount)
                    
                    VStack(alignment: .leading){
                            
                            TitleWithLine(title: "Decline Candidates", lineLength: 36)
                                .padding([.top, .horizontal])
                            
                            if userList.count > 0 {
                                ScrollView(showsIndicators: false, content: {
                                    LazyVStack(spacing: 16) {
                                        ForEach(userList.indices, id: \.self) {
                                            ind in
                                            UserListCard(
                                                employeeDetail: userList[ind],
                                                onClick: { _ in
                                                    selectedEmployee = userList[ind]
                                                    withAnimation { navigateToSelectedEmployee = true }
                                                })
                                            .onAppear(perform: {
                                                if userList.count > 0 {
                                                    handlePagination(currentData: userList[ind])
                                                }
                                            })
                                        }
                                    }.padding(.all)
                                }).refreshable {
                                    isLoading = true
                                    request.job_id = jobDetail.id ?? 0
                                    request.status = 2
                                    self.viewModal.getSelectedJobEmployee(parameter: request)
                                    self.observe()
                                }
                                
                                
                            } else if userList.count == 0 && !isLoading {
                                Spacer()
                                Text("No candidate yet showed interest in your job posting")
                                    .font(.custom(nunitoSemiBold, fixedSize: 18))
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(35)
                                Spacer()
                            }
                        }
                    .background(.text.opacity(0.05))
                    .padding(.top, -topPadding)
                    Spacer()
                })
                
                .toast(isPresenting: $showHud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
                
                .onAppear(perform: {
                    isLoading = true
                    self.observe()
                    request.job_id = jobDetail.id ?? 0
                    request.status = 2
                    self.viewModal.getSelectedJobEmployee(parameter: request)
                })
                
                if isLoading {
                    Loader(isLoading: $isLoading)
                }

                CusNavLink(doNavigate: $navigateToSelectedEmployee, destination: EmployeeProfileScreen(job: $jobDetail, employeeId: $selectedEmployee.id))
                CusNavLink(doNavigate: $navigateToSearch, destination: EmployerSearchScreen(isFromSelectedJob: true, jobDetail: jobDetail))
                
            }.fullScreenCover(isPresented: $navigateToMenu) {
                NavigationContainer {
                    MenuScreen(comeFromResume : true)
                }
            }
        }
    
        
        func handlePagination(currentData item: UserDetailModal) {
            let thresholdData = userList.last?.id
            if thresholdData == item.id, (currentPage + 1) <= totalPage {
                currentPage += 1
                request.job_id = jobDetail.id ?? 0
                request.page = currentPage
                self.viewModal.getSelectedJobEmployee(parameter: request)
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

        
        //MARK: - Success Handler
        func handleSuccess() {
            
            if viewModal.requestType == "GetSelected"{
                if let response = viewModal.userByJobResponse {
                    if response.status == "success" {
                        self.userList = response.data.reversed()
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
        
    
    }

//#Preview {
//    DeclineCandidatesScreen()
//}
