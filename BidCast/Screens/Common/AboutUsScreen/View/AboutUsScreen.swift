////
////  AboutUsScreen.swift
////  imperium
////
////  Created by Abdul-JAM-E-157 on 20/01/24.
////
//
//import SwiftUI
//import BottomSheet
//import RichText
//import AVFoundation
//import AVKit
//import Combine
//
//struct AboutUsScreen: View {
//    
//    @Environment(\.presentationMode) var presentationMode
//    @State var isLoading: Bool = false
//    @State var navigateToMenu: Bool = false
//    @State var navigateToNotification: Bool = false
//    @State var notiCount: Int = 0
//    @State private var player : AVPlayer?
//
//    @State var showError: Bool = false
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @State var aboutUsContent = String()
//    
//    
//    var viewModel = AboutUsViewModel()
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0, content: {
//                PrimaryHeader(title: "About Us", leadingImgArr: [.sideArrow], trailingImgArr: [.notification,.sideMenu], onClickLeading: { _ in
//                    self.presentationMode.wrappedValue.dismiss()
//                }, onClickTrailing: { ind in
//                    switch ind {
//                        case 1:
//                            navigateToMenu = true
//                        default:
//                            navigateToNotification = true
//                    }
//                }, showAppIcon: true, count: $notiCount)
//                ScrollView(showsIndicators: false){
//                VStack(alignment: .leading, spacing: 16) {
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Welcome to Imperium")
//                            .font(.custom(nunitoBold, fixedSize: 24))
//                            .bold()
//                        Divider()
//                            .frame(width: 32, height: 5)
//                            .background(.red)
//                    }.padding(.bottom, 16)
//                    
//                    CustomVideoPlayer(player: player)
//                        .frame(height: screenHeight/2.5)
//                        .onAppear(perform: {
//                            player?.isMuted = true
//                            player?.play()
//                        })
//                        .onDisappear(perform: {
//                            player?.isMuted = true
//                            player?.pause()
//                        })
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                    
//                    TitleWithLine(title: "About Us", lineLength: 36)
//                        .padding(.top)
//                    
//                    
//                        RichText(html: aboutUsContent)
//                            .customCSS("""
//                body {
//                        font-size: 16px;
//                        line-height: 1.5; /* Improve readability */
//                    }
//                    ul {
//                        margin: 0; /* Remove default margin */
//                        padding-left: 20px; /* Indent for bullets */
//                    }
//                    li {
//                        margin-bottom: 8px; /* Space between list items */
//                        list-style-type: disc; /* Ensure bullet points are displayed */
//                    }
//                """)
//
//
//                            .font(.custom(nunitoLight, fixedSize: 16))
//                            .multilineTextAlignment(.leading)
//                    }
//                    
////                    Spacer()
//                }
//                .padding([.horizontal, .vertical])
//                .background(.text.opacity(0.05))
//                .padding(.top, -topPadding)
//                .refreshable {
//                    self.isLoading = true
//                    viewModel.getAboutContent()
//                    observe()
//                }
//                
//                Spacer()
//            })
//            .onAppear {
//                    if let data: WelcomeModel = UserDefaultsManager.shared.getModel(forKey: .videoURLs) {
//                        let welcomeVideo = data.welcome ?? "" //first(where: { $0.id == 2 })?.url ?? ""
// 
//                        if let url = URL(string: "https://backend.imperiumjob.com/\(welcomeVideo)"){
//                            let player = AVPlayer(url: url)
//                            self.player = player
//                            self.player?.playImmediately(atRate: 1.0)
//                        }
//                        }
//                    
//            }
//            .onDisappear {
//                player?.pause()
//            }
//            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation { showError = false }
//                    }, onSecondaryClick: {
//                        withAnimation { showError = false }
//                    })
//            })
//            
//            if isLoading {
//                Loader(isLoading: $isLoading)
//            }
//
//        }
//        .edgesIgnoringSafeArea(.bottom)
//        .onFirstAppear(perform: {
//            self.isLoading = true
//            viewModel.getAboutContent()
//        })
//        .onAppear(perform: {
//            observe()
//        })
//        CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())
//
//        .fullScreenCover(isPresented: $navigateToMenu, content: {
//         
//                NavigationContainer {
//                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                        if role != "employer" {
//                            UserHomeScreen()
//                        }else{
//                            EmployerHomeScreen()
//                        }
//                    }
//                   
//                
//            }
//        })
//        .onTapGesture {
//            UIApplication.shared.endEditing()
//        }
//        
//    }
//    
//    func observe() {
//        self.viewModel.eventHandler = { event in
//            switch event {
//                case .loading:
//                    self.isLoading = true
//                case .stopLoading:
//                    self.isLoading = false
//                case .dataLoaded:
//                    success()
//                case .error(let error):
//                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    showError = true
//            }
//        }
//    }
//    
//    func success() {
//        if let dict = viewModel.aboutResponceDict {
//            
//            if dict.status == "success" {
//                aboutUsContent = dict.data.page_content ?? ""
//            }else{
//                alertType = .sheetType(icon: .alert, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                withAnimation(.snappy) { showError = true }
//            }
//        }
//        
//    }
//    
//}
//
//#Preview {
//    AboutUsScreen()
//}
//
//
