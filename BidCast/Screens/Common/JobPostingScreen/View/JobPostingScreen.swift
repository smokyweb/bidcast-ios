//
//  JobPostingScreen.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 07/02/24.
//

import SwiftUI

struct JobPostingScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var jobId: String
    @Binding var enableSwipe: Bool
    
    @State var job: JobDetailResponse = JobDetailResponse()
    @State var rightSwipe : Int = 1
    @State var isLoading: Bool = false
    
    var viewModal = JobPostViewModal()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: "Job Posting",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: {
                        _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                if isLoading {
                    EmptyView()
                } else {
//                    JobPostDetailScreen(
//                        job: $job,
//                        enableSwipe: $enableSwipe, rightSwipe: $rightSwipe,
//                        showTryThis: true,
//                        onSwipe: {
//                            result, id in
//                            if result {
//                                viewModal.applyJob(parameter: SaveJobRequest(job_id: id))
//                            } else {
//                                viewModal.rejectJob(parameter: SaveJobRequest(job_id: id))
//                            }
//                            observe()
//                        }, onSaveButtonClick: {
//                            id in
//                            viewModal.saveEmployeeJob(parameter: SaveJobRequest(job_id: id))
//                            observe()
//                        })
                }
                
                Spacer()
            }
            .padding(.top, -topPadding)
            .onAppear(perform: {
                isLoading = true
                self.viewModal.getJobDetail(parameter: jobId)
                observe()
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
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
        if viewModal.requestType == "GetJobDetail" {
            if let response = viewModal.response {
                if response.status == "success" {
                    job = response.data
                }
            }
        } else if viewModal.requestType == "JobAction" {
            if let response = viewModal.jobResponse {
                if response.status == "success" {
                    viewModal.getJobDetail(parameter: jobId)
                }
            }
        } else if viewModal.requestType == "SaveJob" || viewModal.requestType == "RemoveSaveJob" {
            viewModal.getJobDetail(parameter: jobId)
        }
    }
}

#Preview {
    JobPostingScreen(jobId: .constant(""), enableSwipe: .constant(false))
}
