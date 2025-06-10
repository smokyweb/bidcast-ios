//
//  FAQScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct FAQScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedButton: FAQButton = .AllFAQ
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var expandedItemID: Int? = nil
    @State private var faqList: [FAQDataModel] = [] // ✅ Local FAQ list

    var viewModel = FAQViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Primary Header
            PrimaryHeader(
                title: "FAQ",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [.search],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)
            .shadow(radius: 2)

            // Segmented Control
            SegmentedControlView(segments: FAQButton.allCases, selectedSegment: $selectedButton, isWithBorder: true)
                .padding(.top, 20)

            // FAQ List
            ScrollView {
                VStack(spacing: 20) {
                    if faqList.isEmpty {
                        Text("No FAQ data available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(faqList, id: \.id) { item in
                            FAQCell(
                                title: item.question ?? "",
                                content: item.answer ?? "",
                                isExpanded: expandedItemID == item.id,
                                onTap: {
                                    expandedItemID = (expandedItemID == item.id) ? nil : item.id
                                }
                            )
                        }
                    }
                }
                .padding(.all, 20)
            }
        }
        .background(Color.pearl)
        .onAppear {
            Task{
                SVProgressHUD.show()
                await self.viewModel.getFAQ()
            }
        }
        .onReceive(viewModel.$faqModel){response in
            
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    let response = viewModel.faqModel
                    if response.status == "success" {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }

   

    func success() {
        SVProgressHUD.dismiss()
        let response = viewModel.faqModel
        if response.status == "success" {
            self.faqList = response.data ?? [] // ✅ Update UI-bound list
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
}


// Enum for FAQ segments
enum FAQButton: String, CaseIterable, CustomStringConvertible {
    case AllFAQ = "ALL FAQs"
    case biding = "Bidding"
    case payment = "Payment"
    
    var description: String {
        return rawValue
    }
}

//// Preview for the FAQ Screen
//#Preview {
//    FAQScreen()
//}

