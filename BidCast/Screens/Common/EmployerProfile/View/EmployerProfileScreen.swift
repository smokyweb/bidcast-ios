//
//  EmployerProfileScreen.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 07/02/24.
//

import SwiftUI

struct EmployerProfileScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var employerId: String
    
    @State var isLoading: Bool = false
    
    @State var detail: EmployerProfileJobsModal = EmployerProfileJobsModal()
    @State var selectedJob: String = ""
    @State var navigateToJobDetail: Bool = false
    
    var viewModal = EmployerProfileViewModal()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                HeaderWithImageTitle(
                    title: "Company Profile",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    userName: .constant(detail.company_data?.company_name ?? "" != "" ? detail.company_data?.company_name ?? "" : detail.name ?? ""),
                    userImg: .constant(detail.company_data?.company_logo ?? "" != "" ? detail.company_data?.company_logo ?? "" : detail.profile_image ?? ""))
                
                if detail.jobs?.data?.count ?? 0 > 0 {
                    ScrollView(showsIndicators: false, content: {
                        LazyVStack(spacing: 18) {
                            ForEach(detail.jobs!.data!.indices, id: \.self) {
                                ind in
                                JobListCardImg(
                                    jobData: detail.jobs!.data![ind],
                                onSelected: {
                                    index in
                                    selectedJob = "\(index)"
                                    withAnimation { navigateToJobDetail = true }
                                })
                            }
                        }.padding(.all)
                    })
                    .padding(.top, -topPadding)
                }
                
                Spacer()
            })
      //      .background(.backGround)
            .task {
                self.viewModal.getEmployerDetail(parameter: employerId)
            }
            .onAppear(perform: {
                observe()
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
            CusNavLink(doNavigate: $navigateToJobDetail, destination: JobPostingScreen(jobId: $selectedJob, enableSwipe: .constant(false)))
        }
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
                    Log.e(String(describing: error.debugDescription))
            }
        }
    }
    
    func handleSuccess() {
        if let response = viewModal.response {
            if response.status == "success" {
                detail = response.data
            }
        }
    }
}

#Preview {
    EmployerProfileScreen(employerId: .constant(""))
}
