//
//  EmployerSearchScreen.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 24/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet
import SwiftfulLoadingIndicators

struct EmployerSearchScreen: View {
    
        //MARK:  Static Properties
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var employeeList: [UserDetailModal] = []
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var filterRequest: FilterRequestModal = FilterRequestModal(location: "", job_title: "", company_name: "", job_description: "", category: 0, job_id: 0, salary: "", benefit: "")
    @State var searchRequest: SearchRequest = SearchRequest(search: "", type: "search", page: 1)
    @State var totalPage: Int = 1
    
    @State var navigateToEmployeeDetailScreen: Bool = false
    @State var selectedEmployeeId: Int?
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var showFilterOption: Bool = false
    @State var isFilterApplied: Bool = false
    
    @State var isFromSelectedJob: Bool = false
    @State var jobDetail: JobDetailResponse = JobDetailResponse()
    @State var navigateToSelectedEmployee: Bool = false
    
        //MARK: Properties
    var searchViewModel = SearchViewModel()
    
        //MARK: - Primary View Body
    var body: some View {
        ZStack {
            VStack {
                HeaderWithSearch(
                    title: "Candidate Search",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss() },
                    onSubmitClick: {
                        value in
                        if value.isEmpty {
                            hudMsg = "Please enter candidate name to begin search"
                            showhud = true
                        } else {
                            withAnimation(.easeOut) { employeeList.removeAll() }
                            searchRequest.search = value
                            searchRequest.page = 1
                            searchRequest.type = "search"
                            self.searchViewModel.employeeSearch(parameter: searchRequest)
                        }
                    }, onFilterClick: {
                        showFilterOption.toggle()
                    })
                
                ScrollView(showsIndicators: false, content: {
                    LazyVStack {
                        if employeeList.count > 0 {
                            ForEach(employeeList, id: \.id) {
                                employee in
                                UserListCard(employeeDetail: employee, onClick: {
                                    userId in
                                    print("User id >> \(userId)")
                                    selectedEmployeeId = userId
                                    if isFromSelectedJob {
                                        navigateToSelectedEmployee = true
                                    } else {
                                        navigateToEmployeeDetailScreen = true
                                    }
                                })
                                .onAppear(perform: {
                                    if !isFromSelectedJob {
                                        handlePagination(currentEmployee: employee)
                                    }
                                })
                            }
                        } else if !isLoading {
                            VStack {
                                Image(.noData)
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: screenWidth/2, height: screenHeight/6)
                                    .foregroundStyle(.text)
                                
                                Text("No Candidate available")
                                    .font(.custom(nunitoMedium, fixedSize: 18))
                                    .foregroundStyle(.gray)
                            }.frame(height: screenHeight * 0.7)
                        }
                    }.padding([.horizontal, .vertical])
                })
                Spacer()
            }
            .padding(.top, -topPadding)
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                    }, onSecondaryClick: {
                        withAnimation { showError = false }
                    })
            })
            .sheet(isPresented: $showFilterOption, content: {
//                FilterOptionView(filterRequest:self.filterRequest,jobDetail: jobDetail) { result in
//                    showFilterOption.toggle()
//                    searchRequest.page = 1
//                    searchRequest.search = ""
//                    filterRequest = result
//                    self.searchViewModel.getEmployeeFilterSearch(parameter: result)
//                }
            })
            
            if isLoading {
                LoadingIndicator()
            }
            
//            if showError {
//                AlertPopUp(
//                    presentAlert: $showError,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.easeOut) { showError = false }
//                    },
//                    rightButtonAction: {
//                        withAnimation(.easeOut) { showError = false }
//                    })
//            }
            
//            CusNavLink(doNavigate: $navigateToEmployeeDetailScreen, destination: EmployeeDetailScreen(employeeId: $selectedEmployeeId))
//            
//            CusNavLink(doNavigate: $navigateToSelectedEmployee, destination: EmployeeProfileScreen(job: $jobDetail, employeeId: $selectedEmployeeId))
        }
        .onAppear(){
            isLoading = true
            if isFromSelectedJob {
                self.searchViewModel.getSelectedJobEmployee(parameter: EmployeeJobIdRequest(job_id: jobDetail.id ?? 0, status: 0,page: 1))
            } else {
                self.searchViewModel.employeeSearch(parameter: searchRequest)
            }
            observe()
        }
    }
    
        //MARK: - View Modal Observer
    func observe() {
        self.searchViewModel.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showError = true
            }
        }
    }
    
        //MARK: - Handle View Modal Success
    func handleSuccess() {
        if searchViewModel.requestType == "EmployeeSearch" || searchViewModel.requestType == "GetEmpByJobId" {
            if let response = searchViewModel.employeeSearchResponse {
                if response.status == "success" {
                    searchRequest.page = response.currentPage ?? 1
                    totalPage = response.totalPage ?? 1
                    isFilterApplied = false
                    if response.currentPage ?? 0 == 1 {
                        withAnimation { employeeList.removeAll() }
                    }
                    response.data.forEach { data in
                        if !employeeList.contains(where: { $0.id == data.id }) {
                            withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                                employeeList.append(data)
                            }
                        }
                    }
                }else{
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.snappy) { showError = true }
                }
            }
        } else if searchViewModel.requestType == "EmployeeFilterSearch" {
            if let response = searchViewModel.employeeSearchResponse {
                if response.status == "success" {
                    withAnimation { employeeList.removeAll() }
                    isFilterApplied = true
                    response.data.forEach { data in
                        if !employeeList.contains(where: { $0.id == data.id }) {
                            withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                                employeeList.append(data)
                            }
                        }
                    }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.snappy) { showError = true }
                }
            }
        }
    }
    
        //MARK: Handle Search Screen Pagination
    func handlePagination(currentEmployee item: UserDetailModal) {
        if !isFilterApplied {
            let thresholdIndex = self.employeeList[self.employeeList.index(self.employeeList.endIndex, offsetBy: -1)]
            if thresholdIndex.id == item.id, (searchRequest.page + 1) <= totalPage {
                searchRequest.page += 1
                self.searchViewModel.employeeSearch(parameter: searchRequest)
            }
        }
    }
}

#Preview {
    EmployerSearchScreen()
}
