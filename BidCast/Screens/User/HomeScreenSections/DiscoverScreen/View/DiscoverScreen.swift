//
//  DiscoverScreen.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI
import Combine
import AlertToast

struct DiscoverScreen: View {
    
    @Binding var isLoading: Bool
    
    @Binding var showAlert: Bool
    @Binding var alertType: BottomSheetType
    @State var navigateToSubscription: Bool = false

    @Binding var showHud: Bool
    @Binding var hudMsg: String
    @State var showSwipeSheet: Bool = false
    @State var rightSwipe: Int = 0
    @State var jobDetailArray: [JobDetailResponse] = []
    
    @State var viewModal: HomeScreenViewModal? // = HomeScreenViewModal()
    
    var body: some View {
        VStack {
            ZStack {
                if jobDetailArray.count > 0 {
                    ForEach(jobDetailArray.indices, id: \.self) {
                        ind in
                        JobPostDetailScreen(
                            job: $jobDetailArray[ind],
                            enableSwipe: .constant(true),
                            rightSwipe: $rightSwipe, isFromHome : true,
                            onSwipe: {
                                (swipe, jobId) in
                                if swipe {
                                    if rightSwipe != 0{
                                             handleJobSwipe(jobId: jobId)
                                    }else{
                                        alertType = .sheetType(icon: .alert, title: "Right Swipe Not Found", message: "No more right swipe left, Do you want to purchase 10 right swipes more?", primaryBtnText: "Yes", secondaryBtnText: "No", sheetThemeColor: .pinkBtn)
                                        withAnimation { showSwipeSheet = true }
                                    }
                                } else {
                                    rejectJob(jobId: jobId)
                                }
                            }, onSaveButtonClick: {
                                    jobId in
                                    handleSaveJob(jobId: jobId)
                                })
                    }
                } else {
                    ScrollView(showsIndicators: false, content: {
                        VStack {
                            Image(.noData)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: screenWidth/2, height: screenHeight/6)
                                .foregroundStyle(.text)
                            
                            Text("No New Job available")
                                .font(.custom(nunitoMedium, fixedSize: 18))
                                .foregroundStyle(.gray)
                        }.frame(height: screenHeight * 0.7)
                    })
                }
            }
            .task {
                viewModal?.getJob(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
            }
            .onAppear(perform: {
                viewModal = HomeScreenViewModal()
                observe()
            })
            .onDisappear(perform: {
                viewModal = nil
            })
            .refreshable {
                generateFeedback(type: .medium)
                isLoading = true
                withAnimation(.easeOut) { jobDetailArray.removeAll() }
                viewModal?.getJob(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
                observe()
            }
            .bottomSheet(isPresented: $showSwipeSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showSwipeSheet = true }, content: {
                CommonBottomSheet(sheetType: $alertType,
                                  onPrimaryClick: {
                    withAnimation { showSwipeSheet = false }
                    withAnimation (.easeInOut){ navigateToSubscription = true }
                }, onSecondaryClick: {
                    withAnimation { showSwipeSheet = false }
                })
            })
            
            CusNavLink(doNavigate: $navigateToSubscription, destination: SubscriptionScreen())

        }
    }
    
    func handleJobSwipe(jobId: Int) {
        isLoading = true
        viewModal?.applyJob(parameter: SaveJobRequest(job_id: jobId))
        observe()
    }
    
    func rejectJob(jobId: Int) {
        isLoading = true
        viewModal?.rejectJob(parameter: SaveJobRequest(job_id: jobId))
        observe()
    }
    
    func handleSaveJob(jobId: Int) {
        isLoading = true
        viewModal?.saveEmployeeJob(parameter: SaveJobRequest(job_id: jobId))
        observe()
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
                    print("Error >> \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func handleSuccess() {
        if viewModal?.requestType == "GetJob" {
            if let response = viewModal?.jobResponse {
                if response.status == "success" {
                    jobDetailArray = response.data
                    viewModal?.getProfile()
//                    jobDetailArray.sort(by: { $0.id ?? 0 < $1.id ?? 0 })
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }else if viewModal?.requestType == "GetProfile"{
            let response = viewModal?.response
            if response?.status == "success" {
                let swipe = Int(self.viewModal?.response.data?.right_swipes ?? "")
                rightSwipe = swipe ?? 0
            } else {
                showAlert = true
            }
        } else if viewModal?.requestType == "ApplyJob" || viewModal?.requestType == "RejectJob" || viewModal?.requestType == "SaveJob" || viewModal?.requestType == "RemoveSaveJob" {
            if let response = viewModal?.applyJobResponse {
                if response.status == "success" {
                    viewModal?.getJob(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
                    hudMsg = response.message?.capitalized ?? ""
                    showHud = true
                } else {
                    hudMsg = response.message?.capitalized ?? ""
                    showHud = true
                }
            }
            viewModal?.getJob(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
        }
    }
}

#Preview {
    UserHomeScreen()
}


//GeometryReader(content: { geometry in
//    ScrollView(.horizontal, showsIndicators: false) {
//        HStack {
//            ForEach(jobDetailArray, id: \.id) {
//                job in
//                JobPostDetailScreen(job: job)
//            }
//        }
//    }
//    .content.offset(x: self.offset)
//    .frame(width: geometry.size.width, alignment: .leading)
//    .gesture(
//        DragGesture()
//            .onChanged({ value in
//                if abs(value.translation.width) > 60 {
//                    withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
//                        self.offset = value.translation.width - geometry.size.width * CGFloat(self.index)
//                    }
//                }
//            })
//            .onEnded({ value in
//                if -value.predictedEndTranslation.width > geometry.size.width / 2, self.index < self.jobDetailArray.count - 1 {
//                    self.index += 1
//                    print("Job Added")
//                }
//                if value.predictedEndTranslation.width > geometry.size.width / 2 {
//                    self.index -= 1
//                    print("Job Removed")
//                }
//                withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
//                    self.offset = -(geometry.size.width + self.spacing) * CGFloat(self.index)
//                }
//                print("Offset >> \(offset)")
//            })
//    )
//})
//.onAppear(perform: {
//    isLoading = true
//    self.viewModal.getJob(parameter: GetJobParameter(currentPage: 1, type: "", search: ""))
//    self.observe()
//    })
