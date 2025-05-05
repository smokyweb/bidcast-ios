//
//  ReviewVideoView.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 25/01/24.
//

import SwiftUI
import AVFoundation
import BottomSheet

struct ReviewVideoView: View {
    
    @Environment(\.presentationMode) var presentationMode
	@EnvironmentObject private var appRootManager: AppRootManager
    
        //MARK: - Variable's Used
    @State private var player: AVPlayer?
    var comeFromProfile = false
    @State var videoURL: String = ""
    @State var isLoading: Bool = false
    @State var showBottomSheet: Bool = false
    @State var isSuccess: Bool = false
    
    var onSuccess: (() -> Void)?
    
        //MARK: - Upload Video View Modal
    var viewModal = UploadVideoViewModal()
    
        //MARK: - Primary View
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: "Review Video Resume",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(alignment: .leading) {
                        CustomVideoPlayer(player: player)
                            .frame(height: screenHeight/1.5)
                            .onAppear(perform: {
                                player?.play()
                            })
                            .onDisappear(perform: {
                                player?.pause()
                            })
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 18, content: {
                            
                            Text("View your recording to ensure it's perfect!")
                                .font(.custom(nunitoRegular, fixedSize: 12))
                            
                            PrimaryButton(title: "Submit Video Resume", isOutLine: false, onButtonClick: {
                                DispatchQueue.main.async {
                                    player?.isMuted = true
                                    player?.pause()
                                }
                                isLoading = true
                                self.viewModal.uploadVideo(videoURL: videoURL)
                            })
                            
                            PrimaryButton(title: "Try Again", isOutLine: true, onButtonClick: {
                                DispatchQueue.main.async {
                                    player?.isMuted = true
                                    player?.pause()
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            })
                            
                        }).padding(.vertical)
                        
                    }.padding(.all)
                }).padding(.top, -topPadding)
                
                Spacer()
            }
            .onAppear(perform: {
                DispatchQueue.main.async {
                    if let url: String = UserDefaultsManager.shared.value(forKey: .userVideoResumeURL) {
                        videoURL = url
                        player?.pause()
                        player = AVPlayer(url: URL(string: url)!)
                        player?.play()
                    }
                }
                self.observe()
            })
            .bottomSheet(isPresented: $showBottomSheet, height: screenHeight/2.6, topBarHeight: 10, topBarCornerRadius: 25, showTopIndicator: false, content: {
                SubmitVideoResumeSheet(
                    isSuccess: $isSuccess,
                    onContinueClick: {
                        withAnimation(.easeOut) { showBottomSheet = false }
						if !comeFromProfile{
							self.presentationMode.wrappedValue.dismiss()
							onSuccess?()
						}else{
							DispatchQueue.main.async {
								appRootManager.currentRoot = .welcome
							}
						}
                    },
                    onCancelClick: {
                        withAnimation(.easeOut) { showBottomSheet = false }
                    })
            })
            
                //MARK: - Loading Indicator
            if isLoading {
                Loader(isLoading: $isLoading)
            }
        }
    }
    
        //MARK: - View Modal Observer
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
                    print("Error >> \(error?.localizedDescription ?? "")")
            }
        }
    }
    
        //MARK: - Handle Success
    func handleSuccess() {
        if let response = viewModal.response {
            if response.status == "success" {
                withAnimation(.spring) { isSuccess = true }
                withAnimation(.easeOut) { showBottomSheet = true }
            } else {
                withAnimation(.easeOut) { showBottomSheet = true }
                
            }
        }
    }
}

#Preview {
    ReviewVideoView()
}
