////
////  SubscriptionScreen.swift
////  imperium
////
////  Created by Maneet-JAM-E-282 on 02/03/24.
////
//
//import SwiftUI
//import StoreKit
//import BottomSheet
//import AlertToast
//
//struct SubscriptionScreen: View {
//    
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject private var appRootManager: AppRootManager
//    
//    @State var selectedItem: String = ""
//    var is_expired: String = ""
//    @State var isUserSubscribed: Bool = false
//    @State var isSubscription :SubscriptionStatus = SubscriptionStatus()
//    
//    @State var productList: [SubsProductModel] = []
//    
//    @State var productListSwipe: [SubscriptionProduct] = []
//    
//    @State var manager: IAPManager = IAPManager.shared
//    
//    @State var isLoading: Bool = false
//    
//    @State var showAlert: Bool = false
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    
//    @State var isLoginFlow: Bool = false
//    
//    @State var receipt: String = ""
//    
//    @State var currentSubs: String = ""
//    
//    var SubscriptionDescription = ["Provides the user with 200 right swipes","Provides the user with 100 right swipes","Provides the user with 50 right swipes","Provides the user with 25 right swipes"]
//    
//    @State var viewModal: SubscriptionViewModal?
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//                
//                if !isLoginFlow{
//                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                        
//                        if role == "employer" {
//                            PrimaryHeader(
//                                title: "Subscription",
//                                leadingImgArr: [.sideArrow],
//                                onClickLeading: { _ in
//                                    if isLoginFlow {
//                                        DispatchQueue.main.async {
//                                            if UserDefaults.isFirstLogin == 1{
//                                                appRootManager.currentRoot = .welcome
//                                            }else{
//                                                appRootManager.currentRoot = .employer
//                                            }
//                                        }
//                                    } else {
//                                        DispatchQueue.main.async {
//                                            self.presentationMode.wrappedValue.dismiss()
//                                        }
//                                    }
//                                },
//                                count: .constant(0))
//                        }else{
//                            PrimaryHeader(
//                                title: "Purchase Right Swipe",
//                                leadingImgArr: [.sideArrow],
//                                onClickLeading: { _ in
//                                    if isLoginFlow {
//                                        DispatchQueue.main.async {
//                                            if UserDefaults.isFirstLogin == 1{
//                                                appRootManager.currentRoot = .welcome
//                                            }else{
//                                                appRootManager.currentRoot = .employer
//                                            }
//                                        }
//                                    } else {
//                                        DispatchQueue.main.async {
//                                            self.presentationMode.wrappedValue.dismiss()
//                                        }
//                                    }
//                                },
//                                count: .constant(0))
//                        }
//                    }
//                }else{
//                    
//                    PrimaryHeader(
//                        title: "Subscription",
//                        onClickLeading: { _ in
//                            if isLoginFlow {
//                                DispatchQueue.main.async {
//                                    if UserDefaults.isFirstLogin == 1{
//                                        appRootManager.currentRoot = .welcome
//                                    }else{
//                                        appRootManager.currentRoot = .employer
//                                    }
//                                }
//                            } else {
//                                DispatchQueue.main.async {
//                                    self.presentationMode.wrappedValue.dismiss()
//                                }
//                            }
//                        },
//                        count: .constant(0))
//                    
//                }
//                if productListSwipe.count > 0 {
//                    ScrollView(showsIndicators: false, content: {
//                        VStack(spacing: 15) {
//                            ForEach(productList.indices, id: \.self) {
//                                ind in
//                                SubsProductCardView(
//                                    product: productList[ind],
//                                    planDetail: productListSwipe[ind],
//                                    description: SubscriptionDescription[ind],
//                                    onClick: {
//                                        select in
//                                        selectedItem = selectedItem == select.identifier ? "" : select.identifier
//                                    })
//                                .overlay(alignment: .center) {
//                                    if isSubscription.is_expired != "yes" && isSubscription.is_expired != nil {
//                                        if isUserSubscribed && currentSubs == productList[ind].identifier {
//                                            HStack {
//                                                Spacer()
//                                                Text("Active")
//                                                    .padding(.horizontal, 20)
//                                                    .padding(.vertical, 5)
//                                                    .font(.custom(nunitoSemiBold, fixedSize: 18))
//                                                    .background(Color.black)
//                                                    .foregroundColor(.white)
//                                                    .cornerRadius(20)
//                                                    .overlay(
//                                                        RoundedRectangle(cornerRadius: 20)
//                                                            .stroke(Color.black, lineWidth: 2)
//                                                    )
//                                                    .padding(.trailing)
//                                            }
//                                        }
//                                    }
//                                }
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(selectedItem == productList[ind].identifier ? .text : .clear, lineWidth: 2)
//                                )
//                            }
//                        }
//                        .padding(.vertical, 10)
//                        .padding(.horizontal)
//                    })
//                    Spacer()
//                }else{
//                    Spacer()
//                    Text("No Product Found")
//                        .font(.custom(nunitoSemiBold, fixedSize: 18))
//                        .foregroundStyle(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                    Spacer()
//                }
//                
//                
//                
//                PrimaryButton(
//                    title: "Purchase",
//                    isOutLine: false,
//                    onButtonClick: {
//                        Log.v("Status >> \(manager.canMakePurchases())")
//                        if manager.canMakePurchases() == true {
//                            manager.purchaseProduct(selectedItem)
//                        } else {
//                            alertType = .sheetType(icon: .alert, title: "Error", message: "Failed to initialize Purchase.", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                            withAnimation{ showAlert = true }
//                        }
//                    })
//                .padding(.vertical)
//                if isLoginFlow {
//                    PrimaryButton(
//                        title: "Skip for now",
//                        isOutLine: true,
//                        onButtonClick: {
//                            DispatchQueue.main.async {
//                                if UserDefaults.isFirstLogin == 1{
//                                    appRootManager.currentRoot = .welcome
//                                }else{
//                                    appRootManager.currentRoot = .employer
//                                }
//                            }
//                        })
//                    
//                    .padding(.vertical)
//                }
//            }
//            .padding(.top, -topPadding)
//            .task {
//                viewModalObserver()
//                if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                    if role == "employer" {
//                        viewModal?.fetchSubscriptionEmployer()
//                    }else{
//                        viewModal?.fetchProductCandidate()
//                    }
//                }
//                DispatchQueue.main.async {
//                    isLoading = true
//                    manager.initialize()
//                }
//            }
//            .onAppear(perform: {
//                
//                viewModal = SubscriptionViewModal()
//                if let isValid: Bool = UserDefaultsManager.shared.value(forKey: .isSubscribed) {
//                    if isValid {
//                        isUserSubscribed = true
//                        if let detail: String = UserDefaultsManager.shared.value(forKey: .subscriptionType) {
//                            currentSubs = detail
//                        }
//                    }
//                }
//                observe()
//                
//            })
//            .onDisappear(perform: {
//                manager.stopObserving()
//            })
//            .toast(isPresenting: $showhud) {
//                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
//            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
//                showAlert = true
//            }, content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation { showAlert = false }
//                        if isLoginFlow {
//                            DispatchQueue.main.async {
//                                appRootManager.currentRoot = .welcome
//                            }
//                        }else{
//                            DispatchQueue.main.async {
//                                self.presentationMode.wrappedValue.dismiss()
//                            }
//                        }
//                    }, onSecondaryClick: {
//                        withAnimation { showAlert = false }
//                    })
//            })
//            
//            if isLoading {
//                Loader(isLoading: $isLoading)
//            }
//        }
//    }
//    
//    func observe() {
//        DispatchQueue.main.async {
//            manager.purchaseStatusBlock = {
//                alert, transaction in
//                switch alert {
//                case .isPurchasing:
//                    withAnimation{ isLoading = true }
//                case .disabled:
//                    withAnimation{ isLoading = false }
//                    alertType = .sheetType(icon: .alert, title: "Alert", message: alert.message(), primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation{ showAlert = true }
//                case .restored:
//                    withAnimation{ isLoading = false }
//                    validateSubscription()
//                case .purchased:
//                    withAnimation{ isLoading = false }
//                    validateSubscription()
//                    return
//                case .failed, .invalid:
//                    withAnimation{ isLoading = false }
//                    hudMsg = alert.message()
//                    withAnimation{ showhud = true }
//                case .initialized: break
//                    //                    withAnimation{ isLoading = false }
//                case .productLoaded(let result):
//                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
//                        let sortedPlans = result.sorted {
//                            guard let price1 = Double($0.price), let price2 = Double($1.price) else {
//                                return false
//                            }
//                            return price1 > price2
//                        }
//                        
//                        for plan in sortedPlans {
//                            print("\(plan.identifier): $\(plan.price)")
//                            self.productList.append(plan)
//                        }
//                        
//                        
//                    }
//                }
//            }
//        }
//    }
//    
//    func validateSubscription() {
//        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
//           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
//            hudMsg = "Please wait verifying Transaction Receipt"
//            showhud = true
//            do {
//                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
//                let receiptString = receiptData.base64EncodedString(options: [])
//                if var subscription = productList.first(where: { selectedItem == $0.identifier }) {
//                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                        if role == "employer" {
//                            self.viewModal?.saveSubscription(param: SubscriptionRequestModal(subscription: subscription.identifier, receipt: receiptString, platform: "ios", matches_count: Int(subscription.swipeCount) ?? 0))
//                        }else{
//                            self.viewModal?.purchaseRightSwipe(param: RightSwipeRequestModal(quantity: "10", price: "10", receipt: receiptString))
//                        }
//                        viewModalObserver()
//                        
//                    }
//                }
//            }catch {
//                hudMsg = "Unknown Error Occured"
//                showhud = true
//                print("Couldn't read receipt data with error: " + error.localizedDescription)
//            }
//        }
//    }
//    
//    func viewModalObserver() {
//        viewModal?.eventHandler = {
//            event in
//            switch event {
//            case .loading:
//                isLoading = true
//            case .stopLoading:
//                isLoading = false
//            case .dataLoaded:
//                handleSuccess()
//            case .error(let error):
//                alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                withAnimation(.easeIn) { showAlert = true }
//            }
//        }
//    }
//    
//    func handleSuccess() {
//        
//        if viewModal?.request == "EmployerSubscription"{
//            
//            if let response = viewModal?.responseProduct {
//                if response.status == "success" {
//                    self.productListSwipe = self.viewModal?.responseProduct?.data.reversed() ?? []
//                    print(productListSwipe)
//                } else {
//                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation(.easeIn) { showAlert = true }
//                }
//            }
//            
//        } else if viewModal?.request == "CandidateSubscription"{
//            
//            if let response = viewModal?.responseProduct {
//                if response.status == "success" {
//                    self.productListSwipe = self.viewModal?.responseProduct?.data ?? []
//                    print(productListSwipe)
//                    
//                } else {
//                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation(.easeIn) { showAlert = true }
//                }
//            }
//            
//        } else if viewModal?.request == "RightSwipe"{
//            if let response = viewModal?.responseRightSwipe {
//                if response.status == "success" {
//                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
//                    withAnimation(.easeIn) { showAlert = true }
//                    
//                } else {
//                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation(.easeIn) { showAlert = true }
//                }
//            }
//        }else{
//            
//            if let response = viewModal?.response {
//                if response.status == "success" {
//                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
//                    withAnimation(.easeIn) { showAlert = true }
//                    isUserSubscribed = true
//                    if response.data.is_expired == "no"{
//                        UserDefaults.EmployerRightSwipe = "Subscribe"
//                    }
//                    UserDefaultsManager.shared.setValue(true, forKey: .isSubscribed)
//                    UserDefaultsManager.shared.setValue(selectedItem, forKey: .subscriptionType)
//                    currentSubs = selectedItem
//                    selectedItem = ""
//                } else {
//                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation(.easeIn) { showAlert = true }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    SubscriptionScreen()
//}
//
//struct SubsProductModel: Codable {
//    var identifier: String
//    var price: String
//    
//    lazy var productName: String = {
//        return identifier.replacing(".", with: " ").capitalized
//    }()
//    
//    lazy var swipeCount: String = {
//        return String(identifier.split(separator: ".")[1])
//    }()
//}
//
//struct SubsProductCardView: View {
//    
//    @State var product: SubsProductModel = SubsProductModel(identifier: "", price: "")
//    var planDetail: SubscriptionProduct = SubscriptionProduct()
//    var description = ""
//    
//    var onClick: ((SubsProductModel) -> Void)?
//    
//    var body: some View {
//        VStack {
//            Button(action: { self.onClick?(product) }, label: {
//                VStack(alignment: .leading, spacing: 10) {
//                    HStack {
//                        Text(planDetail.benefits ?? "")
//                            .font(.custom(nunitoSemiBold, fixedSize: 18))
//                            .foregroundStyle(.black)
//                            .lineLimit(1)
//                        Spacer()
//                    }
//                    
//                    Text(product.price.toCurrency())
//                        .font(.custom(nunitoBold, fixedSize: 20))
//                        .foregroundStyle(.black)
//                        .lineLimit(1)
//                    
//                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                        if role == "employer" {
//                            
//                            Text(description)
//                                .font(.custom(nunitoMedium, fixedSize: 16))
//                                .foregroundStyle(.gray)
//                                .lineLimit(2)
//                                .multilineTextAlignment(.leading)
//                            
//                        }else{
//                            
//                            Text("Provides the user with daily 10 right swipes")
//                                .font(.custom(nunitoMedium, fixedSize: 16))
//                                .foregroundStyle(.gray)
//                                .lineLimit(2)
//                                .multilineTextAlignment(.leading)
//                            
//                        }
//                    }
//                    
//                }
//                .padding(.all)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.white)
//                        .shadow(color: .gray, radius: 2, x: 0, y: 0)
//                )
//            })
//        }
//    }
//}
//
struct SubscriptionRequestModal: Codable {
    var subscription: String
    var receipt: String
    var platform: String
    var matches_count: Int
}

struct RightSwipeRequestModal: Codable {
    var quantity: String
    var price: String
    var receipt : String
}
