//
//  EmployerHomeScreen.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI
import SwipeActions
import BottomSheet
import AlertToast

struct EmployerHomeScreen: View {
    
        //MARK: Navigation Variable
    @State var navigateToCreateJob: Bool = false
    @State var navigateToSearch: Bool = false
    @State var navigateToNotification: Bool = false
    @State var navigateToMenu: Bool = false
    @State var navigateToSelectedJob: Bool = false
    @State var navigateToCreateCompany: Bool = false
    @State var navigateToCreateJobAccess: Bool = false
    @State var navigateToDeleteJobAccess: Bool = false

    @State var jobList: [JobDetailResponse] = []
    @State var isLoading: Bool = false
    
    @State var request: GetJobParameter = GetJobParameter(currentPage: 1, type: "", search: "")
    @State var totalPage: Int = 1
    @State var notiCount: Int = 0
    @State var showDeleteSheet: Bool = false
    @State var showDeleteAAccessSheet: Bool = false
    @State var showJobAccessSheet: Bool = false


    @State var selectedJobId: String = ""
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var alertTypeAccess: BottomSheetType = .sheetType(icon: .alert, title: "Delete Job", message: "You don't have access to delete job", primaryBtnText: "Ok", secondaryBtnText: "")

    @State var showAlert: Bool = false
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    @State var isCompanyCreated: Bool = false
    @State var isFromHome: Bool = true

    
    @State var state: SwipeState = .untouched
    
    @State var selectedJob: JobDetailResponse = JobDetailResponse()
    
    @State var viewModal: EmployerViewModal? = EmployerViewModal()
    
        //MARK: Main View
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                PrimaryHeader(title: "IMPERIUM", leadingImgArr: [.search], trailingImgArr: [.notification, .sideMenu], onClickLeading: { _ in
                    print("Search Button Clicked")
                    withAnimation {
                        navigateToSearch = true
                    }
                }, onClickTrailing: { ind in
                    switch ind {
                        case 1:
                            navigateToMenu = true
                        default:
                            navigateToNotification = true
                    }
                }, showAppIcon: true, count: $notiCount)
                
                VStack {
                    if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                        if data.is_verified == "1"{
                            if jobList.count > 0 {
                                TitleWithLine(title: "My Listing", lineLength: 36)
                                    .padding([.top, .horizontal])
                            }
                        }
                    }
                    
                    ScrollView(showsIndicators: false) {
                        if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                            if data.is_verified == nil{
                                Spacer(minLength: 170)
                                NoInternetScreen(Homescreen: true,btnString: "Upload Docs",contentString:"Upload your documents to start your verification!")
                            }else if data.is_verified == "0"{
                                Spacer(minLength: 170)
                                NoInternetScreen(Homescreen: true,btnString: "Review Docs",contentString:"Your documents haven't been verified yet.\n Please wait until verified to start creating jobs!")
                            }else if data.is_verified == "2"{
                                Spacer(minLength: 170)
                                NoInternetScreen(Homescreen: true,btnString: "Reupload Docs",contentString:"Documents have been rejected.\n Please upload the correct required document again.!")
                            }else{
                                if jobList.count > 0 {
                                                           LazyVStack(spacing: 12) {
                                                               ForEach(jobList.indices, id: \.self) {
                                                                   ind in
                                                                   JobListingCard(
                                                                       jobDetail: $jobList[ind],
                                                                       onClick: {
                                                                           id in
                                                                           selectedJob = jobList.first(where: { $0.id == id }) ?? JobDetailResponse()
                                                                           navigateToSelectedJob = true
                                                                       })
                                                                   .addSwipeAction(menu: .swiped, edge: .trailing, state: $state, {
                                                                       Button(action: {
                                                                           if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
                                                                               withAnimation { showDeleteSheet = true }
                                                                               selectedJobId = "\(jobList[ind].id!)"
                                                                           }else{
                                                                               
                                                                               if navigateToDeleteJobAccess{
                                                                                   withAnimation { showDeleteSheet = true }
                                                                                   selectedJobId = "\(jobList[ind].id!)"
                                                                               }else{
                                                                                   withAnimation { showDeleteAAccessSheet = true }

                                                                               }
                                                                           }
                                                                       }, label: {
                                                                           HStack(alignment: .center, spacing: 5) {
                                                                               Image(systemName: "xmark.bin.fill")
                                                                                   .renderingMode(.template)
                                                                                   .aspectRatio(contentMode: .fill)
                                                                                   .foregroundStyle(.white)
                               
                                                                               Text("Delete")
                                                                                   .font(.custom(nunitoBold, fixedSize: 18))
                                                                                   .bold()
                                                                                   .foregroundStyle(.white)
                                                                                   .lineLimit(1)
                                                                           }
                                                                           .padding(.all)
                                                                           .padding([.top, .bottom], 10)
                                                                       })
                                                                       .background(.pinkBtn)
                                                                       .custCornerRadius(10, corners: [.bottomRight, .topRight])
                                                                   })
                                                                   .onAppear(perform: {
                                                                       if ind < jobList.count {
                                                                           handlePagination(currentData: jobList[ind])
                                                                       }
                                                                   })
                                                               }
                                                           }
                                                           .padding([.horizontal, .vertical])
                                                       } else {
                                                           VStack {
                                                               Spacer()
                                                               Image(.noData)
                                                                   .renderingMode(.template)
                                                                   .resizable()
                                                                   .aspectRatio(contentMode: .fit)
                                                                   .frame(width: screenWidth/2, height: screenHeight/6)
                                                                   .foregroundStyle(.text)
                                                               if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
                                                                   Text("No Job created yet, Go to Create Job")
                                                                       .font(.custom(nunitoSemiBold, fixedSize: 18))
                                                                       .foregroundStyle(.gray)
                                                                       .multilineTextAlignment(.center)
                                                                   
                                                               }else{
                                                                   Text( showJobAccessSheet ? "No Job created yet, Go to Create Job" : "You don't have access to read the jobs till now")
                                                                       .font(.custom(nunitoSemiBold, fixedSize: 18))
                                                                       .foregroundStyle(.gray)
                                                                       .multilineTextAlignment(.center)
                                                               }



                                                               Spacer()
                                                           }.frame(height: screenHeight*0.7)
                                                       }
                                                   }
                            }
                        }
              .refreshable {
                        generateFeedback(type: .medium)
                        isLoading = true
                        
                  viewModal?.getCombineDetail()
                  observe()

                    }

                                PrimaryButton(title: "Create Job", isOutLine: false, onButtonClick: {
                                    if let detail: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                                        if detail.emp_company_created ?? false {
                                            navigateToCreateJob = true
                                        } else {
                                            hudMsg = "Please create Company Profile first to create new Jobs.\nGo to My Company to create Company Profile"
                                            showHud = true
                                        }
                                    }
                                })


                    }
                .padding(.bottom, bottomPadding)
                .background(.white)
                .padding(.top, -topPadding)
                
                Spacer()
            })
            .onAppear(perform: {
                viewModal = EmployerViewModal()
                observe()
            })
            .task {
                if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
                    observe()
                    viewModal?.getCombineDetail()
                    }else{
                        viewModal?.getSubCompanyDetails()
                    }
            }
            .onDisappear(perform: {
                viewModal = nil
            })
            .bottomSheet(isPresented: $showDeleteSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showDeleteSheet = true }, content: {
                DeleteJobSheet(
                    onDeleteClick: {
                        isLoading = true
                        viewModal?.deleteJob(parameter: selectedJobId)
                        withAnimation(.snappy) {
                            showDeleteSheet = false
                        }
                    }, onCancelClick: {
                        withAnimation(.snappy) { showDeleteSheet = false }
                    })
            })
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showAlert = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        isLoading = true
                        withAnimation(.easeOut(duration: 1.0)) {
                            jobList.removeAll()
                        }
                        self.viewModal?.getJobRequest(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
                        withAnimation { showAlert = false }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            
            .bottomSheet(isPresented: $showDeleteAAccessSheet, height: screenHeight/2.5, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showDeleteAAccessSheet = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertTypeAccess,
                    onPrimaryClick: {
                        withAnimation { showDeleteAAccessSheet = false }
                    }, onSecondaryClick: {
                        withAnimation { showDeleteAAccessSheet = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    rightButtonAction: {
//                        isLoading = true
//                        withAnimation(.easeOut(duration: 1.0)) {
//                            jobList.removeAll()
//                        }
//                        self.viewModal?.getJobRequest(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
//                        withAnimation(.snappy) { showAlert = false }
//                    })
//            }
            
            CusNavLink(doNavigate: $navigateToCreateJob, destination: CreateEditJob())
            CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())
            CusNavLink(doNavigate: $navigateToSearch, destination: UserSearchScreen())
            CusNavLink(doNavigate: $navigateToSelectedJob, destination: SelectedJobScreen(jobDetail: $selectedJob))
            CusNavLink(doNavigate: $navigateToCreateCompany, destination: EmployerCreateCompany(isProfileFlow: true))
        }
        .fullScreenCover(isPresented: $navigateToMenu, content: {
            NavigationContainer {
                MenuScreen()
            }
        })
        .edgesIgnoringSafeArea(.bottom)
    }
    
        //MARK: Handle Notification Screen Pagination
    func handlePagination(currentData item: JobDetailResponse) {
        let thresholdData = jobList.last?.id
        if thresholdData == item.id, (request.currentPage + 1) <= totalPage {
            request.currentPage += 1
            Task {
                viewModal?.getJobRequest(parameter: request)
            }
        }
    }
    
        //MARK: - View Modal Observer
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
    
        //MARK: - Success Handler
    func handleSuccess() {
        
        if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
            if viewModal?.requestType == "CombineDetail" {
                if let response = viewModal?.CombineDict {
                    if response.status == "success" {
                        viewModal?.getJobRequest(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
                        UserDefaults.EmployerRightSwipe = response.data.employer_matches_count
                    }
                }
            }  else  if viewModal?.requestType == "Get" {
                if let response = viewModal?.response {
                    if response.status == "success" {
                        
                        viewModal?.getWelcomeVideo()
                        totalPage = response.totalPage ?? 1
                        if request.currentPage == 1 {
                            jobList.removeAll()
                        }
                        response.data.forEach { data in
                            if !jobList.contains(where: { $0.id == data.id }) {
                                jobList.append(data)
                            } else if let index = jobList.firstIndex(where: { $0.id == data.id }) {
                                jobList[index] = data
                            }
                        }
                        jobList.sort(by: { $0.created_at ?? "" > $1.created_at ?? "" })
                    }
                }
                
            } else if viewModal?.requestType == "Video"{
                Task {
                    viewModal?.getNotificationCount()
                }
                if let dict = viewModal?.welcomeDict {
                    
                    if dict.status == "success" {
                        
                        UserDefaultsManager.shared.setModel(dict.data, forKey: .videoURLs)
                    }
                }
            } else if viewModal?.requestType == "GetNotiCount"{
                if let response = viewModal?.notiCountDict {
                    if response.status == "success" {
                        self.notiCount = response.data
                    }
                }
            }
            
            if viewModal?.requestType == "DeleteJob" {
                if let response = viewModal?.deleteJobResponse {
                    if response.status == "success" {
                        alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "OK", secondaryBtnText: "", sheetThemeColor: .green)
                        showAlert = true
                    } else {
                        alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                        showAlert = true
                    }
                }
            }
        }else{
            
            if viewModal?.requestType == "GetCompany" {
                if let response = viewModal?.companyResponse {
                    if response.status == "success" {
                        
                        if let details = self.viewModal?.companyResponse?.data,
                           let permission = details.permission?.first(where: { $0.permission == "Jobs" }) {
                            print("Permission Details: \(permission)")
                            
                            let readAccess = permission.read_access == "true"
                            let writeAccess = permission.write_access == "true"
                            let deleteAccess = permission.delete_access == "true"
                            
                            
                            if readAccess == true{
                                showJobAccessSheet = true
                                viewModal?.getJobRequest(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
                            }
                            
                            if writeAccess == true{
                                navigateToCreateJobAccess = true
                            }
                            
                            if deleteAccess == true{
                                navigateToDeleteJobAccess = true
                            }
                            
                            print("Read Access: \(readAccess), Write Access: \(writeAccess), Delete Access: \(deleteAccess)")
                        } else {
                            print("Jobs permission not found.")
                        }
                        
                        if let details = self.viewModal?.companyResponse?.data,
                           let permission = details.permission?.first(where: { $0.permission == "Company" }) {
                            
                            print("Permission Details: \(permission)")
                            
                            let readAccess = permission.read_access == "true"
                            let writeAccess = permission.write_access == "true"
                            let deleteAccess = permission.delete_access == "true"
                            
                            
                            if readAccess == true{
                                UserDefaults.companyReadAccess = true
                            }
                            
                            if writeAccess == true{
                                UserDefaults.companyWriteAccess = true
                            }
                            
                            if deleteAccess == true{
                                UserDefaults.companyDeleteAccess = true
                            }
                            
                            print("Read Access: \(readAccess), Write Access: \(writeAccess), Delete Access: \(deleteAccess)")
                            
                            
                            
                            
                        }
                        
                        if let details = self.viewModal?.companyResponse?.data,
                           let permission = details.permission?.first(where: { $0.permission == "Interview List" }) {
                            
                            
                            print("Permission Details: \(permission)")
                            
                            let readAccess = permission.read_access == "true"
                            let writeAccess = permission.write_access == "true"
                            let deleteAccess = permission.delete_access == "true"
                            
                            
                            if readAccess == true{
                                UserDefaults.InterViewRead = true
                            }
                            
                            if writeAccess == true{
                                UserDefaults.InterViewWrite = true
                            }
                            
                            if deleteAccess == true{
                                UserDefaults.InterViewDelete = true
                            }
                            
                            print("Read Access: \(readAccess), Write Access: \(writeAccess), Delete Access: \(deleteAccess)")
                            
                            
                            
                        }
                        
                        if let details = self.viewModal?.companyResponse?.data,
                           let permission = details.permission?.first(where: { $0.permission == "Perform Action of employee profile" }) {
                            
                            
                            
                            print("Permission Details: \(permission)")
                            
                            let readAccess = permission.read_access == "true"
                            let writeAccess = permission.write_access == "true"
                            let deleteAccess = permission.delete_access == "true"
                            
                            
                            if readAccess == true{
                                UserDefaults.ActionRead = true

                            }
                            
                            if writeAccess == true{
                                UserDefaults.ActionWrite = true
                            }
                            
                            if deleteAccess == true{
                                UserDefaults.ActionDelete = true
                            }
                            
                            print("Read Access: \(readAccess), Write Access: \(writeAccess), Delete Access: \(deleteAccess)")
                            
                            
                        }
                        
                        if let details = self.viewModal?.companyResponse?.data,
                           let permission = details.permission?.first(where: { $0.permission == "Document Verification" }) {
                            
                            
                            
                            print("Permission Details: \(permission)")
                            
                            let readAccess = permission.read_access == "true"
                            let writeAccess = permission.write_access == "true"
                            let deleteAccess = permission.delete_access == "true"
                            
                            
                            if readAccess == true{
                                UserDefaults.DocRead = true

                            }
                            
                            if writeAccess == true{
                                UserDefaults.DocWrite = true
                            }
                            
                            if deleteAccess == true{
                                UserDefaults.DocDelete = true
                            }
                            
                            print("Read Access: \(readAccess), Write Access: \(writeAccess), Delete Access: \(deleteAccess)")
                            
                            
                        }
                        
                        if let details = self.viewModal?.companyResponse?.data,
                           let permission = details.permission?.first(where: { $0.permission == "Calendar Management" }) {
                            print("Permission Details: \(permission)")
                            
                            let readAccess = permission.read_access == "true"
                            let writeAccess = permission.write_access == "true"
                            let deleteAccess = permission.delete_access == "true"
                            
                            
                            if readAccess == true{
                                UserDefaults.CalendarRead = true

                            }
                            
                            if writeAccess == true{
                                UserDefaults.CalendarWrite = true
                            }
                            
                            if deleteAccess == true{
                                UserDefaults.CalendarDelete = true
                            }
                            
                            print("Read Access: \(readAccess), Write Access: \(writeAccess), Delete Access: \(deleteAccess)")
                            
                            
                            
                        }
                        
                        if let details = self.viewModal?.companyResponse?.data,
                           let permission = details.permission?.first(where: { $0.permission == "Purchase Swipe" }) {
                            
                            
                            print("Permission Details: \(permission)")
                            
                            let readAccess = permission.read_access == "true"
                            let writeAccess = permission.write_access == "true"
                            let deleteAccess = permission.delete_access == "true"
                            
                            
                            if readAccess == true{
//                                UserDefaults. = true

                            }
                            
                            if writeAccess == true{
//                                UserDefaults.InterViewWrite = true
                            }
                            
                            if deleteAccess == true{
//                                UserDefaults.InterViewWrite = true
                            }
                            
                            print("Read Access: \(readAccess), Write Access: \(writeAccess), Delete Access: \(deleteAccess)")
                            
                            
                            
                        }
                        
                    }
                }
                
            } else if viewModal?.requestType == "Get"{
                
                if let response = viewModal?.response {
                    if response.status == "success" {
                        
                        totalPage = response.totalPage ?? 1
                        if request.currentPage == 1 {
                            jobList.removeAll()
                        }
                        response.data.forEach { data in
                            if !jobList.contains(where: { $0.id == data.id }) {
                                jobList.append(data)
                            } else if let index = jobList.firstIndex(where: { $0.id == data.id }) {
                                jobList[index] = data
                            }
                        }
                        jobList.sort(by: { $0.created_at ?? "" > $1.created_at ?? "" })
                    }
                }
                
            }else if viewModal?.requestType == "GetNotiCount"{
                if let response = viewModal?.notiCountDict {
                    if response.status == "success" {
                        self.notiCount = response.data
                        viewModal?.getCombineDetail()
                        observe()
                    }
                }
            }
            
            if viewModal?.requestType == "DeleteJob" {
                if let response = viewModal?.deleteJobResponse {
                    if response.status == "success" {
                        alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "OK", secondaryBtnText: "", sheetThemeColor: .green)
                        showAlert = true
                    } else {
                        alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                        showAlert = true
                    }
                }
            }
            
        }
    }
}

#Preview {
    EmployerHomeScreen()
}
