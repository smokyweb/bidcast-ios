//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SVProgressHUD

struct LetsPrepare: View,ShowStepDelegate {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State var prepare =  [LessonModel]()
    @State var isLoading  = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    
    var viewModel = ScheduleViewModel()
    @State var request : StoreScheduleShowRequest = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "")
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var navigateToTips  = false
    @State var navigateToCreateScreen = false
    @State var navigateToCreateShow = false
    @State var thumbNAil = ""
    @State var navigateToSelectShow = false
    @State var didLoadPrepare = false
    @State var navigateToshowTitle = false
    @State var navigateToRehearsal = false
    @State var navigateToReferScreen = false
    @State var navigateForLive = false
    @State var product = [ProductDataModel]()
    
    private var currentProgress: Double {
        guard !prepare.isEmpty else { return 0 }
        return Double(currentIndex) / Double(prepare.count - 1)
    }
    
    var body: some View {
        VStack(spacing:18){
            VStack{
                PrimaryHeader(
                    title: "Lets Prepare Your show".localized,
                    isForLogo : false, leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                
            }
            
            ProgressView(value: currentProgress, total: 1)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.blue)
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment:.leading,spacing: 16) {
                    ForEach(prepare.indices, id: \.self) { idx in
                        StepCard(
                            prepare: prepare[idx],
                            index: idx + 1,
                            isCurrent: idx == currentIndex
                        ) {
                            if idx == 0 {
                                navigateToSelectShow = true
//                                navigateToCreateShow = true
                            }else if idx == 1 {
                                
                                navigateToshowTitle = true
//                                navigateToCreateScreen = true
                            }else if idx == 2{
                                navigateToRehearsal = true
                            }else if idx == 3{
                                storeScheduleSHow()
                            }else if idx == 4{
                                navigateForLive = true
                            }
                            //                            goToNextStep()
                        }
                        .onTapGesture {
                          if !prepare[idx].isLocked {
                            currentIndex = idx
                          }
                        }
                    }
                    
                    
                }
                .padding(.all,18)
                //                .background(.yellow)
            }
            .edgesIgnoringSafeArea(.bottom)
           
            .padding(.horizontal,16)
            
            HStack(alignment: .center,spacing:6) {
                Spacer()
                Image(systemName: "questionmark.circle")
                Text("Need help? Contact our support team")
                    .font(.custom(poppinsRegular, size: 11.0))
                Spacer()
            }
            
            .frame(height: 40)
            .foregroundColor(.gray)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal,16)
            
            
            
            CusNavLink(doNavigate: $navigateToSelectShow, destination: SelectShowScreen(request: $request, thumbNail: $thumbNAil, comeFromPrepareScreen: .constant(true),backToPrepare: .constant(false), delegate: self))
            
            CusNavLink(doNavigate: $navigateToRehearsal, destination: RehearsalScreen(showUd: .constant(""),productListData: .constant([ProductDataModel]()), comeFromPrepare: true))
            CusNavLink(doNavigate: $navigateForLive, destination: RehearsalScreen(showUd: .constant("\(viewModel.storeShowResponse?.data.id ?? 0)"),productListData:$product,comeFromPrepare: false,comeForLive: true ))
            
            CusNavLink(doNavigate: $navigateToshowTitle, destination: ShowTitleTips(request : $request,fromPrepare:.constant(true),backToPrepare: $navigateToshowTitle, delegate: self))
            CusNavLink(doNavigate: $navigateToReferScreen, destination: ReferEarnScreen())
            
            
            
            
            CusNavLink(doNavigate: $navigateToTips, destination: ShowTips())
//            CusNavLink(doNavigate: $navigateToCreateShow, destination: ShowTitleTips(fromPrepare:.constant(true),backToPrepare: .constant(false), delegate: self))
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding(.bottom,-200)
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .bottomSheet(isPresented: $showError, height: screenHeight/2.8, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            if viewModel.errorMessage != nil || viewModel.errorMessage != "" {
                showError = true
            }else{
               
                showError = false
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if viewModel.errorMessage == nil || viewModel.errorMessage == "" {
                        navigateToReferScreen = true
                        withAnimation { showError = false }
                        
                    }else{
                        withAnimation { showError = false }
                       
                    }
                   
                }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
        .onAppear {
            if !didLoadPrepare {
                didLoadPrepare = true
                Task{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    SVProgressHUD.show()
                    await viewModel.getLetsPrepare()
                    await SVProgressHUD.dismiss()
                    success()
                }
            }else{
                if navigateToRehearsal{
                    if prepare.indices.contains(currentIndex) {
                        prepare[currentIndex].isDone = true
                    }
                    
                    // ✅ Unlock next step:
                    let nextIndex = currentIndex + 1
                    if prepare.indices.contains(nextIndex) {
                        prepare[nextIndex].status = "unlocked"
                    }
                    
                    currentIndex = nextIndex
                    print("🔓 Next unlocked: ", prepare)
                    navigateToRehearsal = false
                    
                }else if navigateToReferScreen{
                    if prepare.indices.contains(currentIndex) {
                        prepare[currentIndex].isDone = true
                    }
                    
                    // ✅ Unlock next step:
                    let nextIndex = currentIndex + 1
                    if prepare.indices.contains(nextIndex) {
                        prepare[nextIndex].status = "unlocked"
                    }
                    
                    currentIndex = nextIndex
                    print("🔓 Next unlocked: ", prepare)
                    navigateToReferScreen = false
                }
            }
        }
        .refreshable {
            didLoadPrepare = false
        }
       
    }
    func didUpdateRequest(_ request: StoreScheduleShowRequest,thumbNail:String) {
        didLoadPrepare = true
            self.request = request
        self.thumbNAil = thumbNail
            print("✅ Parent got updated request:\(request) thumbail \(thumbNail)")
        if prepare.indices.contains(currentIndex) {
              prepare[currentIndex].isDone = true
          }

          // ✅ Unlock next step:
          let nextIndex = currentIndex + 1
          if prepare.indices.contains(nextIndex) {
              prepare[nextIndex].status = "unlocked"
          }

          currentIndex = nextIndex
          print("🔓 Next unlocked: ", prepare)
        }
    
    func storeScheduleSHow(){
        guard !request.title.isEmpty else {
            hudMsg = "Please enter title"
                showhud = true
                return
        }
        guard !request.category_id.isEmpty else {
            hudMsg = "Please enter category type"
                showhud = true
                return
        }
        guard !request.auction_type_id.isEmpty else {
            hudMsg = "Please enter auction type"
                showhud = true
                return
        }
        guard !thumbNAil.isEmpty else {
            hudMsg = "Please select thumbnail image"
                showhud = true
                return
        }
        guard !request.date.isEmpty else {
            hudMsg = "Please enter date"
                showhud = true
                return
        }
        guard !request.time.isEmpty else {
            hudMsg = "Please select time"
                showhud = true
                return
        }
        guard !request.product_ids.isEmpty else {
            hudMsg = "Please select product"
                showhud = true
                return
        }
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                var thumbImage = [String]()
                thumbImage.append(thumbNAil)
                self.viewModel.errorMessage = ""
                await viewModel.storeScheduleShow(param: request,images: [thumbNAil],key: "thumbnail[]")
                await SVProgressHUD.dismiss()
                
                if viewModel.errorMessage == nil || viewModel.errorMessage == "" {
                    storeSuccess()
                }else{
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText:""
                    )
                    showError = true
                }
                
            }
        
    }
    
    func success() {
        let dict = viewModel.lessonsResponse
        if dict?.status == "success" {
            var steps = dict?.data ?? []
                 
                    if steps.indices.contains(0) {
                        steps[0].status = "unlocked"
                    }

                    for idx in 1..<steps.count {
                        steps[idx].status = "locked"
                    }

                    prepare = steps
        } else {
            print("API error: \(dict?.status ?? "")")
        }
        
    }
    
    func storeSuccess(){
        SVProgressHUD.dismiss()
        let response = viewModel.storeShowResponse
        if response?.status == "success"{
            self.product = response?.data.products ?? [ProductDataModel]()
            alertType = .sheetType(
                icon: .success,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }else{
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText:AppString.ok.localized
            )
            showError = true
        }
    }
    
    private func goToNextStep() {
        if currentIndex < prepare.count - 1 {
            currentIndex += 1
        }else{
            navigateToTips = true
        }
    }
    
    private func unlockNextStep() {
        let nextIndex = currentIndex + 1
        if prepare.indices.contains(nextIndex) {
            prepare[currentIndex].isDone = true
            prepare[nextIndex].status = "unlocked"
            currentIndex = nextIndex
        }
    }
}

#Preview {
    LetsPrepare()
}




protocol ShowStepDelegate {
    func didUpdateRequest(_ request: StoreScheduleShowRequest,thumbNail: String)
}
