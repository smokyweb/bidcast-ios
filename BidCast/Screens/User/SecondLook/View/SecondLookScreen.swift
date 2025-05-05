//
//  SecondLookScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 30/01/24.
//

import SwiftUI

struct SecondLookScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isLoading: Bool = false
    @State var savedJobList: [JobDetailResponse] = []
    @State var notiCount: Int = 0

    @State var navigateToJobPost: Bool = false
    @State var selectedJobId: String = ""
    @State var navigateToMenu: Bool = false
    @State var navigateToNotification: Bool = false
    
    @State var viewModal: HomeScreenViewModal? // = HomeScreenViewModal()
    
    var body: some View {
        ZStack {
            VStack {
                PrimaryHeader(title: "Second Look", leadingImgArr: [.sideArrow], trailingImgArr: [.notification,.sideMenu], onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, onClickTrailing: { ind in
                    switch ind {
                        case 1:
                            navigateToMenu = true
                        default:
                            navigateToNotification = true
                    }
                }, showAppIcon: true, count: $notiCount)
                
                ScrollView(showsIndicators: false, content: {
                    
                    if savedJobList.count > 0 {
                        VStack(spacing: 14, content: {
                            ForEach(savedJobList.indices, id: \.self) {
                                ind in
                                JobListCardImg(
                                    jobData: savedJobList[ind],
                                    onSelected: {
                                        selectedId in
                                        selectedJobId = "\(selectedId)"
                                        navigateToJobPost = true
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
                            
                            Text("No Second Look Job available")
                                .font(.custom(nunitoMedium, fixedSize: 18))
                                .foregroundStyle(.gray)
                        }.frame(height: screenHeight * 0.7)
                    }
                })
                .padding(.top, -topPadding)
                .onAppear(perform: {
                    viewModal = HomeScreenViewModal()
                    isLoading = true
                    self.viewModal?.getJob(parameter: GetJobParameter(currentPage: 1, type: "rejected", search: ""))
                    self.observe()
                })
                .onDisappear(perform: {
                    viewModal = nil
                })
                .refreshable {
                    isLoading = true
                    self.viewModal?.getJob(parameter: GetJobParameter(currentPage: 1, type: "rejected", search: ""))
                    self.observe()
                }
                
                Spacer()
            }
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
            CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())

            .fullScreenCover(isPresented: $navigateToMenu, content: {
                NavigationContainer {
                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
                        if role != "employer" {
                            UserHomeScreen()
                        }else{
                            EmployerHomeScreen()
                        }
                    }
                   
                }
            })
            
            CusNavLink(doNavigate: $navigateToJobPost, destination: JobPostingScreen(jobId: $selectedJobId, enableSwipe: .constant(false)))
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
                    print("Error >> \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func handleSuccess() {
        if let response = viewModal?.jobResponse {
            if response.status == "success" {
                withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                    savedJobList = response.data
                }
            }
        }
    }
}

#Preview {
    SecondLookScreen()
}
