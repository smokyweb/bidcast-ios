//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SVProgressHUD

struct LetsPrepare: View {
    @EnvironmentObject var coordinator: LetsPrepareCoordinator
    @Environment(\.presentationMode) var presentationMode
//    @State private var currentIndex = 0
//    @State var prepare =  [LessonModel]()
    @State var isLoading  = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var showsData = HomeModel()
    var viewModel = ScheduleViewModel()
//    @State var request : StoreScheduleShowRequest = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: [], is_explicit: false, show_discoverability: "", repeat_value: "", is_repeat: false, language: "english")
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var navigateToTips  = false
    @State var navigateToCreateScreen = false
    @State var navigateToCreateShow = false
//    @State var thumbNAil = ""
    @State var navigateToSelectShow = false
    @State var didLoadPrepare = false
    @State var navigateToshowTitle = false
    @State var navigateToRehearsal = false
    @State var rehearsalNavigation = false
    @State var referScreenNavigation = false
    @State var navigateToReferScreen = false
    @State var navigateForLive = false
    @State var productIds: [String] = []
    @State var showId : String = ""
    
    private var currentProgress: Double {
        guard !coordinator.prepare.isEmpty else { return 0 }
        return Double(coordinator.currentIndex) / Double(coordinator.prepare.count - 1)
    }
    
    

    
    @Binding var backToTabBar : Bool
    var body: some View {
        VStack(spacing:18){
            VStack{
                PrimaryHeader(
                    title: "Lets Prepare Your show".localized,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                
            }
            .background(.white)
            
            ProgressView(value: currentProgress, total: 1)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.defaultTheme)
                .padding(.horizontal,16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment:.leading,spacing: 16) {
                    ForEach(coordinator.prepare.indices, id: \.self) { idx in
                        StepCard(
                            prepare: coordinator.prepare[idx],
                            index: idx + 1,
                            isCurrent: idx == coordinator.currentIndex
                        ) {
                            if idx == 0 {
                                navigateToSelectShow = true
//                                navigateToCreateShow = true
                            }else if idx == 1 {
                                
                                navigateToshowTitle = true
//                                navigateToCreateScreen = true
                            }else if idx == 2{
                                navigateToRehearsal = true
                                rehearsalNavigation = true
                            }else if idx == 3{
                                storeScheduleSHow()
                            }else if idx == 4{
                                navigateForLive = true
                            }
                            //                            goToNextStep()
                        }
                        .onTapGesture {
                          if !coordinator.prepare[idx].isLocked {
                            coordinator.currentIndex = idx
                          }
                        }
                    }
                    
                    
                }
                .padding(.top,4)
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
            .background(.backGround)
            .cornerRadius(12)
//            .padding(.horizontal,16)
            
            
            
            CusNavLink(doNavigate: $navigateToSelectShow, destination: SelectShowScreen(request: $coordinator.request, thumbNail: $coordinator.thumbNAil, comeFromPrepareScreen: .constant(true)))
            
            CusNavLink(doNavigate: $navigateToRehearsal,
                       destination: RehearsalScreen(showUd: .constant(""),
                                                    productListData: .constant([ProductDataModel1]()),
                                                    comeFromPrepare: true,
                                                    backToTabBar: .constant(true),
                                                    showsData: .constant(HomeModel())
                                                   )
            )
            
            CusNavLink(doNavigate: $navigateForLive,
                       destination: RehearsalScreen(showUd: $showId,
                                                    productListData: .constant([ProductDataModel1]()),
                                                    comeFromPrepare: true,
                                                    comeForLive: true,
                                                    backToTabBar: $backToTabBar,
                                                    showsData: $showsData ))
            
            CusNavLink(doNavigate: $navigateToshowTitle, destination: ShowTitleTips(request : $coordinator.request,fromPrepare:.constant(true), showId: .constant(0)))
            CusNavLink(doNavigate: $navigateToReferScreen, destination: ReferEarnScreen())
            
            
            
            
            CusNavLink(doNavigate: $navigateToTips, destination: ShowTips())
//            CusNavLink(doNavigate: $navigateToCreateShow, destination: ShowTitleTips(fromPrepare:.constant(true),backToPrepare: .constant(false), delegate: self))
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding(.bottom,-200)
        .background(.backGround)
        .toolbar(.hidden,for: .tabBar)
        .bottomSheet(isPresented: $showError, height: screenHeight/2.8, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            if let error = viewModel.errorMessage, !error.isEmpty {
                showError = false
            } else {
                showError = true
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if viewModel.errorMessage == nil || viewModel.errorMessage == "" {
                        navigateToReferScreen = true
                        referScreenNavigation = true
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
                if rehearsalNavigation{
                    if coordinator.prepare.indices.contains(coordinator.currentIndex) {
                        coordinator.prepare[coordinator.currentIndex].isDone = true
                    }
                    
                    // ✅ Unlock next step:
                    let nextIndex = coordinator.currentIndex + 1
                    if coordinator.prepare.indices.contains(nextIndex) {
                        coordinator.prepare[nextIndex].status = "unlocked"
                    }
                    
                    coordinator.currentIndex = nextIndex
                    print("🔓 Next unlocked: ", coordinator.prepare)
                    rehearsalNavigation = false
                    
                }else if referScreenNavigation{
                    if coordinator.prepare.indices.contains(coordinator.currentIndex) {
                        coordinator.prepare[coordinator.currentIndex].isDone = true
                    }
                    
                    // ✅ Unlock next step:
                    let nextIndex = coordinator.currentIndex + 1
                    if coordinator.prepare.indices.contains(nextIndex) {
                        coordinator.prepare[nextIndex].status = "unlocked"
                    }
                    
                    coordinator.currentIndex = nextIndex
                    print("🔓 Next unlocked: ", coordinator.prepare)
                    referScreenNavigation = false
                }
            }
        }
        .onChange(of: coordinator.shouldNavigateBackToPrepare) { shouldNavigate in
                   if shouldNavigate {
                       // ✅ Dismiss all presented sheets and navigate back
                       navigateToSelectShow = false
                       navigateToRehearsal = false
                       navigateForLive = false
                       navigateToshowTitle = false
                       navigateToReferScreen = false
                       
                       // Reset the flag
                       coordinator.resetNavigation()
                   }
               }
        .refreshable {
            didLoadPrepare = false
        }
       
    }
    
//    func didUpdateRequest(_ request: StoreScheduleShowRequest,thumbNail:String) {
//        didLoadPrepare = true
//            self.request = request
//        self.thumbNAil = thumbNail
//            print("✅ Parent got updated request:\(request) thumbail \(thumbNail)")
//        if prepare.indices.contains(currentIndex) {
//              prepare[currentIndex].isDone = true
//          }
//
//          // ✅ Unlock next step:
//          let nextIndex = currentIndex + 1
//          if prepare.indices.contains(nextIndex) {
//              prepare[nextIndex].status = "unlocked"
//          }
//
//          currentIndex = nextIndex
//          print("🔓 Next unlocked: ", prepare)
//        }
//    func didUpdateRequest(_ request: StoreScheduleShowRequest, thumbNail: String) {
//        print("📍 didUpdateRequest called")
//        print("   request.product_ids: \(request.product_ids)")
//        print("   thumbNail: \(thumbNail)")
//        print("   self exists: \(type(of: self))")
//        print("   prepare count: \(prepare.count)")
//        print("   currentIndex: \(currentIndex)")
//        
//        // ✅ Use Task with @MainActor
//        Task { @MainActor in
//            print("📍 Inside MainActor - START")
//            
//            didLoadPrepare = true
//            self.request = request
//            self.thumbNAil = thumbNail
//            
//            print("📍 Properties updated")
//            print("✅ Parent got updated request:\(request) thumbail \(thumbNail)")
//            
//            if prepare.indices.contains(currentIndex) {
//                prepare[currentIndex].isDone = true
//                print("📍 Marked step \(currentIndex) as done")
//            }
//
//            let nextIndex = currentIndex + 1
//            if prepare.indices.contains(nextIndex) {
//                prepare[nextIndex].status = "unlocked"
//                print("📍 Unlocked step \(nextIndex)")
//            }
//
//            currentIndex = nextIndex
//            print("📍 Updated currentIndex to \(nextIndex)")
//            print("🔓 Next unlocked: ", prepare)
//            print("📍 Inside MainActor - END")
//        }
//        
//        print("📍 didUpdateRequest - END")
//    }
    
    func storeScheduleSHow(){
        let request = coordinator.request
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
        guard !coordinator.thumbNAil.isEmpty else {
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
                thumbImage.append(coordinator.thumbNAil)
                self.viewModel.errorMessage = ""
                var param: [String: Any] = [
                    "title": request.title,
                    "date": request.date,
                    "time": request.time,
                    "category_id": request.category_id,
                    "auction_type_id": request.auction_type_id,
                ]
//                let products = request.product_ids.toIntArray()
//                for (index, id) in productIds.enumerated() {
//                    param["product_ids[\(index)]"] = id
//                }
                
//                let prodIds = request.product_ids
//                for (index, product) in prodIds.enumerated() {
//                    param["product_ids[\(index)]"] = product
//                }
                
                let prodIds = request.product_ids.joined(separator: ",")
                param["product_ids"] = prodIds
                viewModel.errorMessage?.removeAll()
                try await viewModel.storeScheduleShow(param: param,images: [coordinator.thumbNAil],key: "thumbnail[]")
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

                    coordinator.prepare = steps
        } else {
            print("API error: \(dict?.status ?? "")")
        }
        
    }
    
    func storeSuccess(){
        SVProgressHUD.dismiss()
        let response = viewModel.storeShowResponse
        if response?.status == "success"{
            productIds = response?.data.product_ids ?? []
            showId = "\(response?.data.id ?? 0)"
            print("showID \(self.showId)")
            showsData = response?.data ?? HomeModel()
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
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
    
    private func goToNextStep() {
        if coordinator.currentIndex < coordinator.prepare.count - 1 {
            coordinator.currentIndex += 1
        }else{
            navigateToTips = true
        }
    }
    
    private func unlockNextStep() {
        let nextIndex = coordinator.currentIndex + 1
        if coordinator.prepare.indices.contains(nextIndex) {
            coordinator.prepare[coordinator.currentIndex].isDone = true
            coordinator.prepare[nextIndex].status = "unlocked"
            coordinator.currentIndex = nextIndex
        }
    }
}

//#Preview {
//    LetsPrepare()
//}




protocol ShowStepDelegate {  // ✅ Add AnyObject for weak references
    func didUpdateRequest(_ request: StoreScheduleShowRequest, thumbNail: String)
}


extension String {
    func toIntArray() -> [Int] {
        return self
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }
}


final class LetsPrepareCoordinator: ObservableObject {
    
    @Published var request = StoreScheduleShowRequest(
        title: "", date: "", time: "", category_id: "",
        auction_type_id: "", product_ids: [],
        is_explicit: false, show_discoverability: "",
        repeat_value: "", is_repeat: false, language: "english"
    )

    @Published var thumbNAil = ""
    @Published var currentIndex = 0
    @Published var prepare: [LessonModel] = []
    @Published var shouldNavigateBackToPrepare = false

//    func didUpdateRequest(_ request: StoreScheduleShowRequest, thumbNail: String) {
//        print("📍 didUpdateRequest called")
//        print("   request.product_ids: \(request.product_ids)")
//        print("   thumbNail: \(thumbNail)")
//        print("   self exists: \(type(of: self))")
//        print("   prepare count: \(prepare.count)")
//        print("   currentIndex: \(currentIndex)")
//        
//        // ✅ Use Task with @MainActor
//        Task { @MainActor in
//            print("📍 Inside MainActor - START")
//            
//            self.request = request
//            self.thumbNAil = thumbNail
//            
//            print("📍 Properties updated")
//            print("✅ Parent got updated request:\(request) thumbail \(thumbNail)")
//            
//            if prepare.indices.contains(currentIndex) {
//                prepare[currentIndex].isDone = true
//                print("📍 Marked step \(currentIndex) as done")
//            }
//
//            let nextIndex = currentIndex + 1
//            if prepare.indices.contains(nextIndex) {
//                prepare[nextIndex].status = "unlocked"
//                print("📍 Unlocked step \(nextIndex)")
//            }
//
//            currentIndex = nextIndex
//            print("📍 Updated currentIndex to \(nextIndex)")
//            print("🔓 Next unlocked: ", prepare)
//            print("📍 Inside MainActor - END")
//        }
//        
//        print("📍 didUpdateRequest - END")
//    }
    
    @MainActor
    func markCurrentStepCompleted() {
        if prepare.indices.contains(currentIndex) {
            prepare[currentIndex].isDone = true
        }

        let nextIndex = currentIndex + 1
        if prepare.indices.contains(nextIndex) {
            prepare[nextIndex].status = "unlocked"
        }

        currentIndex = nextIndex
        print("📍 Updated currentIndex to \(nextIndex)")
        print("🔓 Next unlocked: ", prepare)
        print("📍 Inside MainActor - END")
    }
    
    func resetNavigation() {
           shouldNavigateBackToPrepare = false
       }

}
