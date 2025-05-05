//
//  WelcomeScreen.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//

import SwiftUI
import AVFoundation
import AVKit
import Combine



struct WelcomeScreen: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @Environment(\.presentationMode) var presentationMode
    @State private var player : AVPlayer?
//    @State var navigateToSignUp: Bool = false
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var alertType: AlertType = .success(title: "", message: "", leftBtnText: "", rightBtnText: "")
    @State var videoURL = String ()
    
    
    var viewModel = WelcomeViewModel()

    var body: some View {
        VStack {
            
            PrimaryHeader(title: "Welcome", leadingImgArr: [.sideArrow],onClickLeading: { index in
                self.presentationMode.wrappedValue.dismiss()
            }, count: .constant(0))
            
            VStack(alignment: .leading, spacing: 15) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome to Imperium")
                        .font(.custom(nunitoBold, fixedSize: 24))
                        .bold()
                    Divider()
                        .frame(width: 32, height: 5)
                        .background(.red)
                }.padding(.bottom, 16)
                
                CustomVideoPlayer(player: player)
                    .frame(height: screenHeight/1.5)
                    .onAppear(perform: {
                        player?.isMuted = true
                        player?.play()
                    })
                    .onDisappear(perform: {
                        player?.isMuted = true
                        player?.pause()
                    })
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                
                PrimaryButton(title:"Skip",isOutLine : true) {
                    if UserDefaultsManager.shared.value(forKey: .userRoleId) == "2" {
                        UserDefaultsManager.shared.setValue("employee", forKey: .userRole)
                        DispatchQueue.main.async {
                            player?.isMuted = true
                            player?.pause()
                            appRootManager.currentRoot = .user
                        }
                    } else if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
                        UserDefaultsManager.shared.setValue("employer", forKey: .userRole)
                        DispatchQueue.main.async {
                            player?.isMuted = true
                            player?.pause()
                            appRootManager.currentRoot = .employer
                        }
                    }
//                    navigateToSignUp = true
                }
                Spacer()
                
            }.padding([.leading, .trailing]).padding(.top,-topPadding + 10)
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            self.isLoading = true
            observe()
            viewModel.getWelcomeVideo()
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
//        CusNavLink(doNavigate: $navigateToSignUp, destination: SignUpScreen())
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = false
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    success()
                case .error(let error):
                    self.showError = true
                    print(error as Any)
            }
        }
    }
    
    func success() {
        if let dict = viewModel.welcomeDict {
            
            if dict.status == "success" {

                UserDefaultsManager.shared.setModel(dict.data, forKey: .videoURLs)
                
                videoURL = dict.data.welcome ?? "" //first(where: { $0.name == "welcome" })?.url ?? ""
                
                guard let url = URL(string: "https://backend.imperiumjob.com/\(videoURL)") else {
                    return
                }
                let player = AVPlayer(url: url)
                self.player = player
                self.player?.playImmediately(atRate: 1.0)
            }else{
                alertType = .error(title: dict.status!.capitalized, message: dict.message!, leftBtnText: "", rightBtnText: "Ok")
                withAnimation(.snappy) { showError = true }
            }
        }
        
    }
    
    
}

#Preview {
    WelcomeScreen()
}
