//
//  PreferncesScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD

struct PreferncesScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = PreferenceViewModel()
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    
    @State private var selectedCountry = "United States"
    @State private var directMessages = false
    @State private var receiveGifts = false
    @State private var enablePrivateEntry = false
    @State private var showRewardStatus = false
    @State private var showSellerTools = false
    @State private var enableClips = false
    @State private var savePastShows = false
    @State private var activityStatus = false
    @State private var syncPhoneContacts = false
    @State private var suggestMyAccount = false
    @State private var hapticFeedback = false
    @State private var showCountryPicker = false
    
    var body: some View {
        ZStack {
            VStack {
                PrimaryHeader(
                    title: "Preferences".localized,
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(.white)
                .frame(height: 50)
                
                List {
                    Section(header: Text("Account")) {
                        SelectableCell(
                            title: "Country of Residence",
                            value: selectedCountry,
                            onTap: {
                                showCountryPicker = true
                            }
                        )
                    }.listRowSeparator(.hidden)
                        .sheet(isPresented: $showCountryPicker) {
                            CountryPickerView(selectedCountry: $selectedCountry)
                        }
                    Section(header: Text("Privacy")) {
                        ToggleCell(title: "Direct Messages", isTappedSwitch: $directMessages)
                        ToggleCell(title: "Receive Gifts", isTappedSwitch: $receiveGifts)
                        ToggleCell(title: "Enable Private Entry", isTappedSwitch: $enablePrivateEntry)
                    }.listRowSeparator(.hidden)
                    
                    Section(header: Text("Display")) {
                        ToggleCell(title: "Show Reward Status", isTappedSwitch: $showRewardStatus)
                        ToggleCell(title: "Show Seller Tools", isTappedSwitch: $showSellerTools)
                    }.listRowSeparator(.hidden)
                    
                    Section(header: Text("Content")) {
                        ToggleCell(title: "Enable Clips", isTappedSwitch: $enableClips)
                        ToggleCell(title: "Save Past Shows", isTappedSwitch: $savePastShows)
                    }.listRowSeparator(.hidden)
                    
                    Section(header: Text("Other Settings")) {
                        ToggleCell(title: "Activity Status", isTappedSwitch: $activityStatus)
                        ToggleCell(title: "Sync Phone Contacts", isTappedSwitch: $syncPhoneContacts)
                        ToggleCell(title: "Suggest My Account", isTappedSwitch: $suggestMyAccount)
                        ToggleCell(title: "Haptic Feedback", isTappedSwitch: $hapticFeedback)
                    }.listRowSeparator(.hidden)
                }
                
                PrimaryButton(
                    title: AppString.submit.localized,
                    isOutLine: false,
                    onButtonClick: {
                        UIApplication.shared.endEditing()
                        let request = UpdatePreferenceRequest(
                            country_of_residence: selectedCountry,
                            direct_message: directMessages ? 1 : 0,
                            receive_gifts: receiveGifts ? 1 : 0,
                            enable_private_entry: enablePrivateEntry ? 1 : 0,
                            show_reward_status: showRewardStatus ? 1 : 0,
                            show_seller_tools: showSellerTools ? 1 : 0,
                            enable_clips: enableClips ? 1 : 0,
                            save_past_shows: savePastShows ? 1 : 0,
                            activity_status: activityStatus ? 1 : 0,
                            sync_phone_contacts: syncPhoneContacts ? 1 : 0,
                            suggest_my_account: suggestMyAccount ? 1 : 0,
                            haptic_feedback: hapticFeedback ? 1 : 0
                        )
                        Task{
                            SVProgressHUD.show()
                            await viewModel.updatePreference(parameters: request)
                            await SVProgressHUD.dismiss()
                            await getPreferenceSuccess()
                        }
                    },
                    btnTextColor: .white
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 0)
                .background(Color.white.ignoresSafeArea(edges: .bottom))
            }
            .disabled(isLoading)
            
            
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
            
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
           
            Task{
                SVProgressHUD.show()
                await viewModel.getPreferenceContent()
                await SVProgressHUD.dismiss()
                await getPreferenceSuccess()
               
            }
        }
        
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
    
    private func getPreferenceSuccess() {
        guard let data = viewModel.preferenceResponse.data else { return }
        selectedCountry = data.countryOfResidence ?? "United States"
        directMessages = data.directMessage ?? false
        receiveGifts = data.receiveGifts ?? false
        enablePrivateEntry = data.enablePrivateEntry ?? false
        showRewardStatus = data.showRewardStatus ?? false
        showSellerTools = data.showSellerTools ?? false
        enableClips = data.enableClips ?? false
        savePastShows = data.savePastShows ?? false
        activityStatus = data.activityStatus ?? false
        syncPhoneContacts = data.syncPhoneContacts ?? false
        suggestMyAccount = data.suggestMyAccount ?? false
        hapticFeedback = data.hapticFeedback ?? false
    }
}

