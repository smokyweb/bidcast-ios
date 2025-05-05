//
//  JobCategoriesView.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 29/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet

struct JobCategoriesView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedJob: [InterestedJob] = []
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var jobCategoryList: [JobCategoriesListModal] = []
    
    private var gridItem = [GridItem(.adaptive(minimum: screenWidth/2 - 40))]
    
    var viewModel = UpdateUserProfileViewModal()
    
    @ViewBuilder
    func jobCateButton(job: JobCategoriesListModal) -> some View {
        Button(action: {
            withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                if selectedJob.contains(where: { $0.job_id == "\(job.id!)" }) {
                    selectedJob.removeAll(where: { $0.job_id == "\(job.id!)" })
                } else {
                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                        selectedJob.append(InterestedJob(job_id: "\(job.id!)"))
                    }
                }
            }
        }, label: {
            if !selectedJob.contains(where: { $0.job_id == "\(job.id!)" }) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black.opacity(0.75), lineWidth: 1.5)
                    .frame(height: 55)
                    .overlay {
                        Text(job.name)
                            .font(.custom(nunitoMedium, fixedSize: 14))
                            .foregroundStyle(.black.opacity(0.75))
                            .lineLimit(2)
                    }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.pinkBtn)
                    .frame(height: 55)
                    .overlay {
                        Text(job.name)
                            .font(.custom(nunitoMedium, fixedSize: 14))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
            }
        })
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(title: "Job Categories", trailingImgArr: [.cancel], onClickTrailing: {_ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                
                VStack(spacing: 0) {
                    TitleWithLine(title: "Select the Job Categories you are interested in.", lineLength: 0)
                        .padding([.top, .leading])
                    ScrollView(showsIndicators: false, content: {
                        LazyVGrid(columns: gridItem, spacing: 16) {
                            ForEach(jobCategoryList.indices, id: \.self) {
                                ind in
                                jobCateButton(job: jobCategoryList[ind])
                                    .padding([.leading, .trailing], 5)
                            }
                        }.padding(.all, 10)
                    })
                    
                    VStack(spacing: 16) {
                        PrimaryButton(title: "Save", isOutLine: false, onButtonClick: {
                            UIApplication.shared.endEditing()
                            if selectedJob.count > 0 {
                                self.viewModel.updateEmployeeInterestedJob(parameter: selectedJob)
                            } else {
                                hudMsg = "Please select Job Categories of your interest"
                                showhud = true
                            }
                        })
                        
                        PrimaryButton(title: "Cancel", onButtonClick: {
                            UIApplication.shared.endEditing()
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    }.padding(.top)
                }
                .padding(.top, -topPadding)
                .toast(isPresenting: $showhud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
                .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                    CommonBottomSheet(
                        sheetType: $alertType,
                        onPrimaryClick: {
                            withAnimation { showAlert = false }
                            self.presentationMode.wrappedValue.dismiss()
                        }, onSecondaryClick: {
                            withAnimation { showAlert = false }
                        })
                })
                
                Spacer()
            }
            
            //MARK: - Loading
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
            //MARK: - Alert Pop Up
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false } },
//                    rightButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
            
        }.onAppear(perform: {
            observe()
            
            if let detail: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                detail.category.forEach { category in
                    jobCategoryList.append(JobCategoriesListModal(id: category.id, name: category.name, category_id: ""))
                }
            }
            
            if let userDetail: UserDetailModal
                = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                userDetail.interested_jobs?.forEach({ data in
                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                        selectedJob.append(InterestedJob(job_id: data.job_id ?? ""))
                    }
                })
            }
        })
    }
    
    func observe() {
        self.viewModel.eventHandler = {
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
                    withAnimation { showAlert = true }
            }
        }
    }
    
    func handleSuccess() {
        if viewModel.requestType == "GetJobProfile" {
            if let response = viewModel.jobCategoryResponse {
                if response.status == "success" {
                    jobCategoryList = response.data
                }
            }
        }else if viewModel.requestType == "UpdateEmployeeInterestedJob" {
            if let response = viewModel.skillResponse {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    withAnimation { showAlert = true }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation { showAlert = true }
                }
            }
        }
    }
}

#Preview {
    JobCategoriesView()
}
