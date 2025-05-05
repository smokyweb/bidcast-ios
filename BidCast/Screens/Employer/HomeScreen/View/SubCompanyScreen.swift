//
//  SubCompanyScreen.swift
//  imperium
//
//  Created by JAM-E-221 on 27/01/25.
//

import SwiftUI
import AlertToast
import BottomSheet
import SwipeActions

struct SubCompanyScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    @State var interviewListContent: [SubCompanyModal] = []
    @State var selectedEmployee: UserDetailModal = UserDetailModal()

    @State var totalPage: Int = 1
    @State var currentPage: Int = 1
    @State var selectedCompId: Int = 0
    @State var selectedJobDate: Date = Date()
    @State var navigateToCreateSubCompany: Bool = false
    @State var navigateFromUserList: Bool = false
    @State var navigateToGoogleCalender: Bool = false
    @State var interviewId: String = ""
    @State var isReschedule: Bool = false
    @State var showhud: Bool = false
    @State var state: SwipeState = .untouched
    @State var showDeleteSheet: Bool = false
    @State var showActiveSheet: Bool = false


    
    var viewModel = InterviewlistViewModel()
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                PrimaryHeader(title: "User List", leadingImgArr: [.sideArrow], trailingImgArr: [], onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, onClickTrailing: { _ in
                    print("Bell Button Clicked")
                }, count: .constant(0))
                
                VStack(alignment: .leading) {
                    ScrollView(showsIndicators: false){
                        
                        if interviewListContent.count > 0 {
                            LazyVStack(spacing: 12) {
                                ForEach(interviewListContent.indices, id: \.self) {
                                    ind in
                                    SubCompanyCard(
                                         subCompanyDetail: $interviewListContent[ind],
                                         onSelected: { value in
                                             if interviewListContent[ind].status == "active"{
                                                 navigateFromUserList = true
                                                 selectedCompId = value
                                             }else{
                                                 selectedCompId = interviewListContent[ind].id ?? 0
                                                 alertType = .sheetType(icon: .trash, title: "Deactivate User", message: "Do you want to activate selected User?", primaryBtnText: "Activate", secondaryBtnText: "Cancel", sheetThemeColor: .pinkBtn)
                                                 withAnimation { showActiveSheet = true }
                                             }
                                         })
                                    
                                    .addSwipeAction(menu: .swiped, edge: .trailing, state: $state, {
                                        Button(action: {
                                            selectedCompId = interviewListContent[ind].id ?? 0
                                            alertType = .sheetType(icon: .trash, title: "Deactivate User", message: "Do you want to deactivate selected User?", primaryBtnText: "Deactivate", secondaryBtnText: "Cancel", sheetThemeColor: .pinkBtn)
                                            withAnimation { showDeleteSheet = true }
                                        }, label: {
                                            HStack(alignment: .center, spacing: 5) {
                                                Image(systemName: "xmark.bin.fill")
                                                    .renderingMode(.template)
                                                    .aspectRatio(contentMode: .fill)
                                                    .foregroundStyle(.white)
                                                
                                                Text("Deactivate")
                                                    .font(.custom(nunitoBold, fixedSize: 18))
                                                    .bold()
                                                    .foregroundStyle(.white)
                                                    .lineLimit(1)
                                            }
                                            .padding(.all)
                                            .padding([.top, .bottom])
                                        })
                                        .background(.pinkBtn)
                                        .custCornerRadius(10, corners: [.bottomRight, .topRight])
                                    })
//                                         onRescheduleClick: .unredacted(when: $isLoading)
                                    .onAppear(perform: {
//                                        handlePagination(currentData: interviewListContent[ind])
                                    })
                                }
                            }
                            .unredacted(when: $isLoading)
                            .padding([.horizontal, .vertical])
                        } else {
                            VStack {
                                Image(.noData)
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: screenWidth/2, height: screenHeight/6)
                                    .foregroundStyle(.text)
                                
                                Text("No Company User")
                                    .font(.custom(nunitoMedium, fixedSize: 18))
                                    .foregroundStyle(.gray)
//                                PrimaryButton(title: "Schedule Interview", isOutLine: false, onButtonClick: {
//                                    self.navigateToGoogleCalender = true
//                                }, width: screenWidth/1.5, height: 45, btnColor: .text)
                            }.frame(width: screenWidth, height: screenHeight * 0.7)
                        }
                    }
                    Spacer()
                }
                .disabled(isLoading)
                .padding(.bottom, bottomPadding)
                .background(.text.opacity(0.05))
                .padding(.top, -topPadding)

                .refreshable {
                    generateFeedback(type: .medium)
                    self.isLoading = true
//                    interviewListContent.removeAll()
                    viewModel.getCompanyUser(currentPage: 1)
                    observe()
                }
                PrimaryButton(title: "Create User", isOutLine: false, onButtonClick: {
                    navigateToCreateSubCompany = true
                })
                
                Spacer(minLength: 30)
            })
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
            .bottomSheet(isPresented: $showDeleteSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showDeleteSheet = true }, content: {
                CommonBottomSheet(sheetType: $alertType,
                                  onPrimaryClick: {
                    withAnimation { showDeleteSheet = false }
                    let id = String(selectedCompId)
                    viewModel.deactivateeCompanyUser(parameter: DeleteCompanyUserParam(user_id: id,status:"inactive"))
                }, onSecondaryClick: {
                    withAnimation { showDeleteSheet = false }
                })
            })
            
            .bottomSheet(isPresented: $showActiveSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showActiveSheet = true }, content: {
                CommonBottomSheet(sheetType: $alertType,
                                  onPrimaryClick: {
                    withAnimation { showActiveSheet = false }
                    let id = String(selectedCompId)
                    viewModel.deactivateeCompanyUser(parameter: DeleteCompanyUserParam(user_id: id,status:"active"))
                }, onSecondaryClick: {
                    withAnimation { showActiveSheet = false }
                })
            })
            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                        self.presentationMode.wrappedValue.dismiss()
                    }, onSecondaryClick: {
                        withAnimation { showError = false }
                    })
            })
            
            if isLoading && interviewListContent.count == 0 {
                Loader(isLoading: $isLoading)
            }
            
//            if showError {
//                AlertPopUp(
//                    presentAlert: $showError,
//                    alertType: alertType,
//                    rightButtonAction: {
//                        withAnimation(.snappy) { showError = false }
//                    })
//            }
            
//            CusNavLink(doNavigate: $navigateToDetail, destination: InterviewDetailScreen(interviewId: $interviewId, userList: $selectedEmployee))
         //   CusNavLink(doNavigate: $navigateToGoogleCalender, destination: ScheduleInterviewScreen(interviewId: $interviewId, date: $selectedJobDate, isReschedule: $isReschedule))//GoogleCalenderScreen())
            CusNavLink(doNavigate: $navigateToCreateSubCompany, destination: CreateSubCompanyScreen(comeFromuserList: false, comeFromuserProfile: false, userId: $selectedCompId))
            CusNavLink(doNavigate: $navigateFromUserList, destination: CreateSubCompanyScreen(comeFromuserList:true, comeFromuserProfile: false, userId: $selectedCompId))
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .task {
            viewModel.getCompanyUser(currentPage: currentPage)
        }
        .onAppear(perform: {
            observe()
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
        //MARK: Handle Interview List Screen Pagination
    func handlePagination(currentData item: InterviewScheduleModal) {
        let thresholdData = interviewListContent.last?.id
        if thresholdData == item.id, (currentPage + 1) <= totalPage {
            currentPage += 1
            self.viewModel.getCompanyUser(currentPage: currentPage)
        }
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    success()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showError = true
            }
        }
    }
    
    func success() {
        
        if viewModel.request != "Deactivate"{
            if let dict = viewModel.subCompanyDict {
                if dict.status == "success" {
                    totalPage = dict.totalPage ?? 0
                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                        dict.data.forEach { data in
                            if !interviewListContent.contains(where: { $0.id == data.id }) {
                                interviewListContent.append(data)
                            } else {
                                let index = interviewListContent.firstIndex(where: { $0.id == data.id }) ?? 0
                                interviewListContent[index] = data
                            }
                        }
                    }
                }else{
                    alertType = .sheetType(icon: .alert, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.snappy) { showError = true }
                }
            }
        }else{
            if let response = viewModel.deleteCompanyDict {
                if response.status == "success" {
                    hudMsg = response.message?.capitalized ?? ""
                    showHud = true
                    viewModel.getCompanyUser(currentPage: 1)
                }else{
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.snappy) { showError = true }
                }
            }
        }
        
    }
}

#Preview {
    SubCompanyScreen()
}
