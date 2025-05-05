//
//  NewsScreen.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//

import SwiftUI
//import BottomSheet

struct NewsScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var navigateToMenu: Bool = false
    @State var navigateToNotification: Bool = false
    @State var notiCount: Int = 0
    @State var newsContent = [NewsResponseModel]()
    
    
    var viewModel = NewsViewModel()
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                PrimaryHeader(title: "News",
                              leadingImgArr: [.sideArrow], trailingImgArr: [.notification,.sideMenu], onClickLeading: { _ in
                                  self.presentationMode.wrappedValue.dismiss()
                              }, onClickTrailing: { ind in
                                  switch ind {
                                      case 1:
                                          navigateToMenu = true
                                      default:
                                          navigateToNotification = true
                                  }
                              }, showAppIcon: true, count: $notiCount)
                
                VStack(alignment: .leading) {
                    ScrollView(showsIndicators: false){
                        LazyVStack(spacing: 12) {
                            ForEach(newsContent.indices, id: \.self) {
                                ind in
//                                NewsCard(newsDetail: newsContent[ind])
                            }
                        }
                        .padding([.horizontal, .vertical])
                    }
                    Spacer()
                }
                .padding(.bottom, bottomPadding)
                .background(.text.opacity(0.05))
                .padding(.top, -topPadding)
                .refreshable {
                    generateFeedback(type: .medium)
                    self.isLoading = true
                    newsContent.removeAll()
                    viewModel.getNewsContent()
                    observe()
                }
                
                Spacer()
            })
            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                    }, onSecondaryClick: {
                        withAnimation { showError = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
//            if showError {
//                AlertPopUp(presentAlert: $showError, alertType: alertType, rightButtonAction: {
//                    withAnimation(.snappy) { showError = false }
//                })
//            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onFirstAppear(perform: {
            self.isLoading = true
            viewModel.getNewsContent()
        })
        .onAppear(perform: {
            observe()
        })
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
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    success()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showError = true
            }
        }
    }
    
    func success() {
        if let dict = viewModel.newsResponceDict {
            
            if dict.status == "success" {
                withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                    self.newsContent.append(contentsOf: dict.data)
                }
            }else{
                alertType = .sheetType(icon: .alert, title: dict.status?.capitalized ?? "", message: dict.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                withAnimation(.snappy) { showError = true }
            }
        }
        
    }
}

#Preview {
    NewsScreen()
}
