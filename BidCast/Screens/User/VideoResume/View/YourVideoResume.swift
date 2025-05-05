//
//  YourVideoResume.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 25/01/24.
//

import SwiftUI
import AVFoundation
import AVKit

struct YourVideoResume: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @State private var player : AVPlayer?
    
    @State var title: String = "Virtual Resume Tutorial"
    @State var isNextClicked: Bool = false
    @State var onStartRecord: Bool = false
    @State var onUploadVideo: Bool = false
    @State var showVideoPreviewScreen: Bool = false
    @State var showVideoExampleScreen: Bool = false

    @State var videoURL : String = ""
    
    @State var howToMakeRes: String = ""
    @State var exampleRes: String = ""
    
    @State var isMainFlow: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(title: "Virtual Resume Tutorial", leadingImgArr: [.sideArrow], onClickLeading: { _ in
                if isMainFlow {
                    DispatchQueue.main.async {
                        appRootManager.currentRoot = .welcome
                    }
                } else {

                        self.presentationMode.wrappedValue.dismiss()
                }
            }, onClickTrailing: { _ in
            }, count: .constant(0))
            
            ScrollView(showsIndicators: false, content: {
                VStack {
                    CustomVideoPlayer(player: player)
                        .frame(height: screenHeight/1.5)
                        .onAppear(perform: {
                            player?.play()
                        })
                        .onDisappear(perform: {
                            player?.pause()
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(spacing: 18, content: {
//                        if !isNextClicked {
                            TitleWithLine(title: "Virtual Resume Tutorial")
                            if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                                Text(data.your_video_text.htmlToString)
                                    .font(.custom(nunitoRegular, fixedSize: 12))
                            }
//                            
//                            
//                            
//                            PrimaryButton(title: "Next", isOutLine: false, onButtonClick: {
//                                withAnimation(.default) {
//                                    self.showVideoExampleScreen = true
//                                }
//                            })
//                        } else {
//                            if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
//                                Text(data.example_video_test.htmlToString)
//                                    .font(.custom(nunitoRegular, fixedSize: 12))
//                            }
                            
                            PrimaryButton(title: "Start Recording", isOutLine: false, onButtonClick: {
                                DispatchQueue.main.async {
                                    player?.pause()
                                    withAnimation(.easeOut) {
                                        onStartRecord = true
                                    }
                                }
                            })
                            
                            PrimaryButton(title: "Upload Video", isOutLine: true, onButtonClick: {
                                DispatchQueue.main.async {
                                    player?.pause()
                                    withAnimation(.easeOut) {
                                        onUploadVideo = true
                                    }
                                }
                            })
//                        }
                    }).padding(.vertical)
                    
                    CusNavLink(doNavigate: $onStartRecord, destination: RecordVideoView(goBackAction: {
						
                        self.presentationMode.wrappedValue.dismiss()
                    }))
                    CusNavLink(doNavigate: $showVideoPreviewScreen, destination: ReviewVideoView(comeFromProfile: true))
                    
                    CusNavLink(doNavigate: $showVideoExampleScreen, destination: ExampleVideoResume())
                    
                }.padding(.all)
            })
            .padding(.top, -topPadding)
            .onAppear {
                    if let data: WelcomeModel = UserDefaultsManager.shared.getModel(forKey: .videoURLs) {
                        howToMakeRes = data.howToMakeYourResume ?? "" //first(where: { $0.id == 2 })?.url ?? ""
                        exampleRes = data.exampleResume ?? ""
                        
                        videoURL = howToMakeRes
                        if let url = URL(string: "https://backend.imperiumjob.com/\(videoURL)"){
                            let player = AVPlayer(url: url)
                            self.player = player
                            self.player?.playImmediately(atRate: 1.0)
                        }
                        }
                    
            }
            .onDisappear {
                player?.pause()
            }
            
            Spacer()
        }
        .sheet(isPresented: $onUploadVideo, content: {
            VideoRecorderHelper(
                sourceType: .savedPhotosAlbum,
                onRecordingCancel: {
                    withAnimation(.easeOut) { onUploadVideo = false }
                }, onRecordingSuccess: {
                    vidURL in
                    UserDefaultsManager.shared.setValue(vidURL.absoluteString, forKey: .userVideoResumeURL)
                    withAnimation(.easeOut) { onUploadVideo = false }
                    withAnimation(.snappy) { showVideoPreviewScreen = true }
                })
        })
    }
}

#Preview {
    YourVideoResume()
}
