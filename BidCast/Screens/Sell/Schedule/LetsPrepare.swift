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
    // Basecamp #9929871140: randomizer template picker during show creation.
    @State private var showRandomizerPickerInCreate: Bool = false
    // Basecamp #9986427172 (QA round 4): promote sheet for existing-show mode (idx==3).
    // NOTE: not `private` — a private stored property would make the struct's
    // memberwise initializer private and break LetsPrepare(...) callers in
    // ShowDetailsScreen/SellingTips (CI failure 2026-06-12).
    @State var showPromoteSheetFromPrepare: Bool = false
    @State var prepareBoosts: [BoostModel] = []
    @State var isPreparePromoting: Bool = false
    @State var showPreparePromoteSuccess: Bool = false
    @State var didCompletePreparePromotion: Bool = false
    var prepareShowsViewModel = ShowsViewModel()
    
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
                                // Basecamp #9986427172 (QA round 4): existing-show mode
                                // must NOT call storeScheduleShow — open PromoteShowSheet
                                // for this show instead.  Creation mode keeps original behaviour.
                                if let existingId = coordinator.existingShowId, !existingId.isEmpty {
                                    loadAndShowPreparePromote(showIdStr: existingId)
                                } else {
                                    storeScheduleSHow()
                                }
                            }else if idx == 4{
                                // Basecamp #9986427172 (QA round 4): existing-show mode —
                                // LetsPrepare was PUSHED from ShowDetailsScreen, so dismiss
                                // back to it.  Start Show lives on ShowDetailsScreen.
                                // Creation mode keeps the original RehearsalScreen navigation.
                                if coordinator.existingShowId != nil {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    navigateForLive = true
                                }
                            }
                            //                            goToNextStep()
                        }
                        .onTapGesture {
                          if !coordinator.prepare[idx].isLocked {
                            coordinator.currentIndex = idx
                          }
                        }
                    }
                    
                    // Basecamp #9929871140: optional randomizer template picker row.
                    Button {
                        showRandomizerPickerInCreate = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: coordinator.randomizerTemplateId != nil
                                  ? "dice.fill" : "dice")
                                .font(.system(size: 22))
                                .foregroundColor(coordinator.randomizerTemplateId != nil
                                                 ? .defaultTheme : .gray)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Randomizer Template (optional)")
                                    .font(.custom(poppinsBold, size: 13))
                                    .foregroundColor(.primary)
                                Text(coordinator.randomizerTemplateId != nil
                                     ? "Template #\(coordinator.randomizerTemplateId!)  – tap to change"
                                     : "None – attach a randomizer to this show")
                                    .font(.custom(poppinsRegular, size: 11))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.6))
                                .font(.system(size: 13))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    
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
        // Basecamp #9929871140: randomizer template picker sheet for show creation.
        .sheet(isPresented: $showRandomizerPickerInCreate) {
            RandomizerTemplatePickerSheet(selectedTemplateId: $coordinator.randomizerTemplateId)
        }
        // Basecamp #9986427172 (QA round 4): promote sheet for existing-show mode (idx==3).
        .sheet(isPresented: $showPromoteSheetFromPrepare, onDismiss: {
            // Mark step 3 complete only after a real promotion purchase succeeds.
            if didCompletePreparePromotion && coordinator.currentIndex == 3 {
                coordinator.markCurrentStepCompleted()
            }
            didCompletePreparePromotion = false
        }) {
            PromoteShowSheet(
                boosts: $prepareBoosts,
                onPromotionSelected: { selectedBoost in
                    storePreparePromoteShow(boost: selectedBoost)
                    showPromoteSheetFromPrepare = false
                },
                onClose: { showPromoteSheetFromPrepare = false },
                onSkipPromotion: {
                    markBringInBuyersComplete()
                    if coordinator.currentIndex == 3 {
                        coordinator.markCurrentStepCompleted()
                    }
                    showPromoteSheetFromPrepare = false
                }
            )
            .presentationDetents([.fraction(0.70)])
            .presentationCornerRadius(25)
            .presentationDragIndicator(.hidden)
        }
        .alert("Show Promoted", isPresented: $showPreparePromoteSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your show has been promoted successfully.")
        }
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
                    markRehearsedComplete()
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
        .onChange(of: coordinator.shouldNavigateBackToPrepare) { oldValue,shouldNavigate in
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
    
    // Basecamp #9986427172 (QA round 4): fetch promote tiers then open PromoteShowSheet.
    // Called from idx==3 action when coordinator.existingShowId != nil.
    private func loadAndShowPreparePromote(showIdStr: String) {
        Task {
            isPreparePromoting = true
            prepareShowsViewModel.errorMessage = nil
            await prepareShowsViewModel.getPromoteShows()
            isPreparePromoting = false
            if let msg = prepareShowsViewModel.errorMessage, !msg.isEmpty {
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: msg,
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            } else if let tiers = prepareShowsViewModel.promoteShow?.data {
                prepareBoosts = tiers
                showPromoteSheetFromPrepare = true
            }
        }
    }

    // Basecamp #9986427172 (QA round 4): call the promote endpoint for the selected tier.
    // Called from the PromoteShowSheet onPromotionSelected closure when in existing-show mode.
    private func storePreparePromoteShow(boost: BoostModel) {
        guard let promoteId = boost.id,
              let existingId = coordinator.existingShowId,
              let showIdInt = Int(existingId), showIdInt > 0 else { return }
        guard UserDefaults.hasCardAdded,
              let cardId = UserDefaults.default_card.card_id,
              !cardId.isEmpty else {
            alertType = .sheetType(
                icon: .alert,
                title: "Payment Method Required",
                message: "Add a payment card before purchasing a show promotion.",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
            return
        }
        let req = StorePromoteShowRequest(
            scheduleShowId: "\(showIdInt)",
            promoteShowId: "\(promoteId)",
            customerPaymentProfileId: cardId
        )
        Task {
            isPreparePromoting = true
            prepareShowsViewModel.errorMessage = nil
            await prepareShowsViewModel.storePromoteShow(parameters: req)
            isPreparePromoting = false
            if let msg = prepareShowsViewModel.errorMessage, !msg.isEmpty {
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: msg,
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            } else if prepareShowsViewModel.storePromoteShowModel?.status == "success" {
                markBringInBuyersComplete()
                didCompletePreparePromotion = true
                if coordinator.currentIndex == 3 {
                    coordinator.markCurrentStepCompleted()
                }
                showPreparePromoteSuccess = true
            }
        }
    }

    private func markRehearsedComplete() {
        guard let showId = coordinator.existingShowId, !showId.isEmpty else { return }
        UserDefaults.standard.set(true, forKey: "bidcast_prepare_rehearsed_\(showId)")
    }

    private func markBringInBuyersComplete() {
        guard let showId = coordinator.existingShowId, !showId.isEmpty else { return }
        UserDefaults.standard.set(true, forKey: "bidcast_prepare_bring_in_buyers_\(showId)")
    }

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
                // Browse-filter bundle (Basecamp #9928367737): attach tags as `tags[i]` keys.
                if let tags = request.tags, !tags.isEmpty {
                    for (i, tag) in tags.enumerated() {
                        param["tags[\(i)]"] = tag
                    }
                }
//                let products = request.product_ids.toIntArray()
//                for (index, id) in productIds.enumerated() {
//                    param["product_ids[\(index)]"] = id
//                }
                
//                let prodIds = request.product_ids
//                for (index, product) in prodIds.enumerated() {
//                    param["product_ids[\(index)]"] = product
//                }
                
                // Basecamp #9991372302: send product_ids[] and product_stream_quantities[]
                // as positionally aligned indexed multipart fields (mirrors PWA wire format).
                // Stream quantities are stored on the coordinator by AddProductsScreen
                // (fromPrepare path). If the picker was never visited the map is empty:
                // OMIT the field entirely so the server defaults to full stock —
                // sending a hard-coded 1 would wrongly cap every product at one unit.
                let prodIds = request.product_ids
                let qtys = coordinator.streamQuantities
                for (i, pid) in prodIds.enumerated() {
                    param["product_ids[\(i)]"] = pid
                    if !qtys.isEmpty {
                        param["product_stream_quantities[\(i)]"] = qtys[pid] ?? 1
                    }
                }
                // Basecamp #9929871140: attach randomizer template if the seller
                // picked one via the optional picker row above the step cards.
                if let tmplId = coordinator.randomizerTemplateId {
                    param["randomizer_template_id"] = tmplId
                }
                viewModel.errorMessage?.removeAll()
                // Basecamp #9986427172 (Bug C): wrap in do-catch so SVProgressHUD
                // is always dismissed — a thrown error previously escaped the Task
                // scope before reaching the dismiss call, leaving the spinner running.
                do {
                    try await viewModel.storeScheduleShow(param: param, images: [coordinator.thumbNAil], key: "thumbnail[]")
                } catch {
                    // errorMessage was already set by the ViewModel; dismiss HUD here
                    // so the spinner stops even on network/server errors.
                    await SVProgressHUD.dismiss()
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? error.localizedDescription,
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    showError = true
                    return
                }
                await SVProgressHUD.dismiss()

                if viewModel.errorMessage == nil || viewModel.errorMessage == "" {
                    storeSuccess()
                } else {
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    showError = true
                }
                
            }
        
    }
    
    func success() {
        let dict = viewModel.lessonsResponse
        if dict?.status == "success" {
            var steps = dict?.data ?? []

            // Basecamp #9986427172 (round 3, 2026-06-12): respect the
            // coordinator.currentIndex that ShowDetailsScreen pre-seeded from
            // the show's existing data (derivedComplete steps).  Steps before
            // currentIndex are marked done+unlocked; the current step is
            // unlocked (active); steps after are locked.
            let seededIndex = coordinator.currentIndex

            for idx in 0..<steps.count {
                if idx < seededIndex {
                    // Already completed
                    steps[idx].isDone = true
                    steps[idx].status = "unlocked"
                } else if idx == seededIndex {
                    // Current active step
                    steps[idx].status = "unlocked"
                } else {
                    // Future steps remain locked
                    steps[idx].status = "locked"
                }
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
            print("showID \(self.showId)/n \(response?.data ?? HomeModel())")
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
    /// Basecamp #9929871140: randomizer template to attach to the show on store.
    @Published var randomizerTemplateId: Int? = nil
    @Published var shouldNavigateBackToPrepare = false
    // Basecamp #9991372302: per-product stream quantities set by AddProductsScreen
    // when coming from the LetsPrepare wizard (fromPrepare == true). Keyed by
    // product-id string, values >= 1.
    @Published var streamQuantities: [String: Int] = [:]

    // Basecamp #9986427172 (QA round 4): when LetsPrepare is entered from
    // ShowDetailsScreen for an existing show, set this to the show's string ID.
    // nil means creation/training mode (the original flow). When non-nil:
    //   - idx==3 ("Bring in buyers"): present PromoteShowSheet instead of storeScheduleShow
    //   - idx==4 ("Preview show and go live"): dismiss back to ShowDetailsScreen
    //   - storeScheduleShow() is gated on existingShowId == nil
    @Published var existingShowId: String? = nil

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
