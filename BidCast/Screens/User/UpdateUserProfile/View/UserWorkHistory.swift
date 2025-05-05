//
//  UserWorkHistory.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 30/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct UserWorkHistory: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var workHistoryArray: [WorkHistory] = []
    @State var navigateToAddWorkHistory: Bool = false
    
    @State var navigateToEditWorkHistory: Bool = false
    
    var viewModal = UpdateUserProfileViewModal()
    
    @State var mostRecentJobTitle: String = ""
    @State var mostRecentCompany: String = ""
    @State var contactInfo: String = ""
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                PrimaryHeader(
                    title: "Work History",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
//                    VStack(alignment: .leading, spacing: 14, content: {
//                        Text("Current or Most Recent Job")
//                            .font(.custom(nunitoBold, fixedSize: 20))
//                            .foregroundStyle(.black)
//                        
//                        AuthTextField(floatingLabel: "Most Recent Job Title", placeholder: "Enter Job Title", icon: .bag, text: .constant(workHistoryArray.first?.job_title ?? ""), enteredText: { value in
//                            mostRecentJobTitle = value
//                        }).disabled(true)
//                        
//                        AuthTextField(floatingLabel: "Most Recent Company", placeholder: "Enter Company Name", icon: .menuContactUs, text: .constant(workHistoryArray.first?.company_name ?? ""), enteredText: { value in
//                            mostRecentCompany = value
//                        }).disabled(true)
//                        
////                        AuthTextField(floatingLabel: "Contact Info", placeholder: "Enter Contact Info", icon: .menuProfile, text: .constant(workHistoryArray.first?.contact_info ?? ""), enteredText: { value in
////                            contactInfo = value
////                        }).disabled(true)
//                    }).padding(.all)
                    
                    VStack(alignment: .leading, spacing: 14, content: {
                        Text("Work History")
                            .font(.custom(nunitoBold, fixedSize: 20))
                            .foregroundStyle(.black)
                        
                        ForEach(workHistoryArray.indices, id: \.self) {
                            ind in
                            WorkHistoryCard(
                                workHistory: $workHistoryArray[ind],
                                onEditWorkClick: {
                                    history in
                                    UserDefaultsManager.shared.setModel(history, forKey: .editWorkHistory)
                                    navigateToEditWorkHistory = true
                                }, onRemoveClick: {
                                    history in
                                    withAnimation {
                                        workHistoryArray.removeAll(where: { $0.id == history.id })
                                    }
                                })
                        }
                        
                        Button(action: {
                            withAnimation(.easeOut) { navigateToAddWorkHistory = true }
                        }, label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.text)
                                
                                Text("Add Work History")
                                    .font(.custom(nunitoBold, fixedSize: 14))
                                    .foregroundStyle(.black)
                                Spacer()
                            }
                        })
                        .padding(.all)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .gray, radius: 1, x: 0, y: 0)
                        )
                        .padding(.vertical, 10)
                        
                        PrimaryButton(title: "Save", isOutLine: false, onButtonClick: {
                            UIApplication.shared.endEditing()
                            
                            if workHistoryArray.count > 0 {
                                if let detail: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                                    for ind in 0..<workHistoryArray.count {
                                        workHistoryArray[ind].location_type = "\(detail.location_type.first(where: { $0.type ==  workHistoryArray[ind].location_type })?.id ?? 0)"
                                        
                                        workHistoryArray[ind].employment_type = "\(detail.employment_type.first(where: { $0.type == workHistoryArray[ind].employment_type })?.id ?? 0)"
                                    }
                                }
                            }
                            
                            var result: [CreateWorkHistory] = []
                            
                            workHistoryArray.forEach { data in
                                result.append(CreateWorkHistory(id: data.id ?? 0, job_title: data.job_title ?? "", company_name: data.company_name ?? "", location: data.location ?? "", employment_type: data.employment_type ?? "", location_type: data.location_type ?? "", start_date: data.start_date ?? "", end_date: data.end_date ?? "", profile_headline: data.profile_headline ?? "", description: data.description ?? "", industry: data.industry ?? "", contact_info: data.contact_info ?? ""))
                            }
                            
//                            if result.count > 0 {
                                self.viewModal.updateEmployeeWorkHistory(parameter: result, mrJt: mostRecentJobTitle, mrC: mostRecentCompany)
//                            } else {
//                                hudMsg = "Can not remove all Work History"
//                                showhud = true
////                                self.presentationMode.wrappedValue.dismiss()
//                            }
                        })
                        
                        PrimaryButton(title: "Cancel", onButtonClick: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    })
                    .padding(.all)
   //                 .background(.backGround)
                })
                .padding(.top, -topPadding)
                Spacer()
            }
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
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
//                        withAnimation(.interactiveSpring) { showAlert = false }
//                    }, rightButtonAction: {
//                        withAnimation(.interactiveSpring) { showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
            
            CusNavLink(doNavigate: $navigateToAddWorkHistory, destination: UserCreateWorkHistory())
            CusNavLink(doNavigate: $navigateToEditWorkHistory, destination: UserCreateWorkHistory(isEdit: true))
        }.onAppear(perform: {
            if let userDetail: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                mostRecentJobTitle = userDetail.most_recent_job_title ?? ""
                mostRecentCompany = userDetail.most_recent_company ?? ""
                withAnimation {
                    workHistoryArray.removeAll()
                    workHistoryArray = userDetail.work_histories ?? []
                    workHistoryArray.sort(by: { $0.created_at ?? "" > $1.created_at ?? "" })
                }
            }
            observe()
        })
        .onDisappear(perform: {
            withAnimation {
                workHistoryArray.removeAll()
            }
        })
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
    }
    
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
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.interpolatingSpring) { showAlert = true }
            }
        }
    }
    
    func handleSuccess() {
//        alertType = .error(title: "Error", message: error?.localizedDescription ?? "", leftBtnText: "Ok", rightBtnText: "")
//        withAnimation(.interpolatingSpring) { showAlert = true }
    }
}

#Preview {
    UserWorkHistory()
}
