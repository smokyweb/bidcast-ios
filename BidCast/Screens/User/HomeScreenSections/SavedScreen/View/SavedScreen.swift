//
//  SavedScreen.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI
import SwipeActions
import BottomSheet

struct SavedScreen: View {
    
    @Binding var isLoading: Bool
    @Binding var showAlert: Bool
    @Binding var alertType: BottomSheetType
    
    @State var savedJobList: [JobDetailResponse] = []
    @State var navigateToJobPost: Bool = false
    @State var selectedJobId: String = ""
    
    @State var state: SwipeState = .untouched
    
    @State var viewModal: HomeScreenViewModal?
    
    var body: some View {
        ScrollView(showsIndicators: false, content: {
            if savedJobList.count > 0 {
                VStack(spacing: 14, content: {
                    ForEach(savedJobList.indices, id: \.self) {
                        ind in
                        JobListCardImg(
                            jobData: savedJobList[ind],
                            onSelected: { value in
                                navigateToJobPost = true
                                selectedJobId = "\(value)"
                            })
                    }
                })
                .padding(.vertical, 10)
                .padding(.horizontal)
            } else {
                VStack {
                    Image(.noData)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth/2, height: screenHeight/6)
                        .foregroundStyle(.text)
                    
                    Text("No Saved Job available")
                        .font(.custom(nunitoMedium, fixedSize: 18))
                        .foregroundStyle(.gray)
                }.frame(height: screenHeight * 0.7)
            }
            
            CusNavLink(doNavigate: $navigateToJobPost, destination: JobPostingScreen(jobId: $selectedJobId, enableSwipe: .constant(false)))
        })
        .task {
            viewModal?.getSavedJob()
        }
        .onAppear(perform: {
            viewModal = HomeScreenViewModal()
            observe()
        })
        .refreshable {
            generateFeedback(type: .medium)
            isLoading = true
            savedJobList.removeAll()
            viewModal?.getSavedJob()
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
        if let response = viewModal?.getSavedJobResponse {
            if response.status == "success" {
                response.data.forEach({
                    data in
                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                        if !savedJobList.contains(where: { $0.id == data.job.id }) {
                            savedJobList.append(data.job) }
                        else {
                            let ind = savedJobList.firstIndex(where: { $0.id == data.job.id }) ?? 0
                            savedJobList[ind] = data.job
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

#Preview {
    UserHomeScreen()
}
