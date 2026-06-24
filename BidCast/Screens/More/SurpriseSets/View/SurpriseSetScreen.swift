//
//  SurpriseSetScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//

import SwiftUI

struct SurpriseSetScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var navigateToCreate = false
    
    @State private var surprises: [ProductSurpriseData] = []
    @StateObject var viewModel = SurpriseViewModel()
    
    @State private var navigateToProductDetail = false
    @State private var selectedSurprise: ProductSurpriseData?

    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var body: some View {
        VStack{
            VStack{
                
                PrimaryHeader(
                    title: "Surprise Sets".localized,
                    isForLogo : false, leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                
            }
            .frame(height:  50)
            .background(Color.white)
            
            ScrollView(showsIndicators:false){
                VStack(spacing: 16) {
                    if surprises.isEmpty {
                        NoDataView(message: "No Surprise setfound")
                    }
                    else  {
                        ForEach(surprises, id: \.id) { surprise in
                            SurpriseCardView(surprise: surprise)
                                .onTapGesture {
                                    selectedSurprise = surprise
                                    navigateToProductDetail.toggle()
                                }
                        }
                    }
                }
            }
            
            .padding(.horizontal,12)
            .background(.backGround)
            .zIndex(1000)
            VStack{
                PrimaryButton(title:"Create New Surprise",onButtonClick: {
                    navigateToCreate = true
                })
            }
            .padding(.bottom,12)
            
            CusNavLink(doNavigate: $navigateToCreate, destination: CreateSurpriseScreen())
            CusNavLink(doNavigate: $navigateToProductDetail, destination: ProductDetail(surprise: selectedSurprise))
        }
        .bottomSheet(isPresented: $showError, height: screenHeight * 0.35, topBarCornerRadius: 25, showTopIndicator: false,
                     onDismiss: {
            if let errorMessage = viewModel.errorMessage {
                showError = false
                viewModel.errorMessage = nil
            }else{
                showError = true
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if let errorMessage = viewModel.errorMessage {
                        showError = false
                        viewModel.errorMessage = nil
                    }else{
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation {
                            showError = false
                            viewModel.errorMessage = nil
                        }
                    }
                }, onSecondaryClick: {
                    withAnimation {
                        showError = false
                        viewModel.errorMessage = nil
                    }
                })
            .ignoresSafeArea(.keyboard)
        })
        .edgesIgnoringSafeArea(.bottom)
        .background(.backGround)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear{
            Task{
                
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        var errorMessage = viewModel.errorMessage ?? viewModel.errorMessage
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        
                        successSurpries()
                        
                    }
                    
                ) {
                    // 👇 These run in parallel
                    
                    async let shippingTask: () = viewModel.getSurpiseSet()
                    
                    // Wait for all
                    _ = try await (shippingTask)
                }
            }
        }
    }
    func successSurpries(){
        let response = viewModel.getSurpriseResponse
        if response?.status == "success"{
            self.surprises = response?.data ?? []
        }
    }
}

//#Preview {
//    SurpriseSetScreen()
//}
struct SurpriseCardView: View {

    let surprise: ProductSurpriseData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header
            HStack {
                Text(surprise.name?.capitalizingFirstLetter() ?? "")
                    .font(.custom(robotoMedium, size: 16))

                Spacer()

                Text(surprise.price?.description.toDouble?.compactCurrency() ?? "")
                    .font(.custom(robotoMedium, size: 15))
            }

            Text(surprise.description ?? "")
                .font(.custom(robotoRegular, size: 13))
                .foregroundColor(.gray)

            // Tags
            HStack(spacing: 8) {
                TagView(text: surprise.type?.replacingOccurrences(of: "_", with: " ").capitalized ?? "")

                if surprise.quickSpin == 1 {
                    TagView(text: "Quick Spin")
                }

                if surprise.autoRandomizer == 1 {
                    TagView(text: "Auto Random")
                }
            }

            Divider()

            // Items
            VStack(spacing: 8) {
                let items = surprise.items ?? []
                ForEach(items, id: \.id) { item in
                    ItemRowView(item: item)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    private func formatCurrencyCompact(_ value: Double) -> String {
           let absValue = abs(value)
           let sign = value < 0 ? "-" : ""
           
           switch absValue {
           case 1_000_000_000...:
               // Billions
               return String(format: "%@$%.2fB", sign, absValue / 1_000_000_000)
           case 1_000_000...:
               // Millions
               return String(format: "%@$%.2fM", sign, absValue / 1_000_000)
           case 1_000...:
               // Thousands
               return String(format: "%@$%.1fK", sign, absValue / 1_000)
           default:
               // Less than 1000 - show full amount
               return String(format: "%@$%.2f", sign, absValue)
           }
       }
}
struct ItemRowView: View {

    let item: ProductItemResponse

    var body: some View {
        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name?.capitalizingFirstLetter() ?? "")
                    .font(.custom(robotoMedium, size: 14))

                Text(item.description ?? "")
                    .font(.custom(robotoRegular, size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("Quantity : \(item.quantity ?? 0)")
                .font(.custom(robotoMedium, size: 14))
        }
        .padding(.vertical, 4)
    }
}
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.custom(robotoMedium, size: 11))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.defaultThemeLight)
            .foregroundColor(.defaultTheme)
            .cornerRadius(6)
    }
}
