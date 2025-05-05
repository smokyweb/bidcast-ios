//
//  UserVideoResumeDemoScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 24/01/24.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
import BottomSheet

struct UserVideoResumeDemoScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
        
    @State private var player : AVPlayer?
    @State var navigateToCreateVidRes: Bool = false
    @State var navigateToVidResTuto: Bool = false
    @State var navigateToUserHome: Bool = false
    @State var navigateToVideoResume: Bool = false
    @State var showVideoTutorialSheet: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                PrimaryHeader(title: "How to Make Your Resume", trailingImgArr: [.cancel], onClickTrailing:  { _ in
                    DispatchQueue.main.async {
                        appRootManager.currentRoot = .welcome
                    }
                }, count: .constant(0))
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("How to Make Your Resume")
                            .font(.custom(nunitoBold, fixedSize: 24))
                            .bold()
                        Divider()
                            .frame(width: 32, height: 5)
                            .background(.red)
                    }.padding(.bottom, 16)
                    
                    
                    VideoPlayer(player: player)
                        .onDisappear {
                            player?.isMuted = true
                            player?.pause()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: screenHeight/4-10)
                        .padding(.bottom, 8)
                    
                    PrimaryButton(title: "Done", isOutLine: false) {
                        withAnimation(.easeIn) { showVideoTutorialSheet = true }
                    }
                    Spacer()
                    
                }.padding([.leading, .trailing]).padding(.top,-topPadding + 10)
                Spacer()
            }
            .bottomSheet(isPresented: $showVideoTutorialSheet, height: screenHeight/1.75, topBarHeight: 10, topBarCornerRadius: 25, showTopIndicator: false) {
                VideoResumeSheet(onStartResumeClick: {
                    withAnimation(.easeOut) { showVideoTutorialSheet = false }
                    withAnimation(.easeInOut) { navigateToVideoResume = true }
                }, onWatchTutorialClick: {
                    withAnimation(.easeOut) { showVideoTutorialSheet = false }
                    withAnimation(.easeInOut) { navigateToVidResTuto = true }
                }, onSkipClick: {
                    withAnimation(.easeOut) { showVideoTutorialSheet = false }
                    DispatchQueue.main.async {
                        appRootManager.currentRoot = .welcome
                    }
                })
            }
            
            CusNavLink(doNavigate: $navigateToVidResTuto, destination: YourVideoResume(isMainFlow: true))
            CusNavLink(doNavigate: $navigateToVideoResume, destination: RecordVideoView(comeFromSignUp: true,isMainFlow: true))
        }.onAppear {
            if let data: WelcomeModel = UserDefaultsManager.shared.getModel(forKey: .videoURLs) {
                let howToMakeRes = data.howToMakeYourResume ?? "" //first(where: { $0.id == 2 })?.url ?? ""
                DispatchQueue.main.async {
                    player = AVPlayer(url: getMediaURL(url: howToMakeRes))
                    player?.play()
                }
            }
        }
        .onDisappear {
            player?.isMuted = true
            player?.pause()
        }
    }
}

#Preview {
    UserVideoResumeDemoScreen()
}
