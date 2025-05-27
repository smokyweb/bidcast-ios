//
//  PreferncesScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SettingsViewModel()
    @State var isTappedSwitch : Bool = false
    var body: some View {
        VStack{
            PrimaryHeader(
                title: "Preferences".localized,
                isForLogo : false, leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(.white)
            .frame(height: 50)
            
            List {
                Section(header: Text("Account")) {
                    SelectableCell(
                        title: "Country of Residence",
                        value: viewModel.selectedCountry,
                        onTap: {
                            viewModel.showCountryPicker = true
                        }
                    )
                }
                .listRowSeparator(.hidden)
                .sheet(isPresented: $viewModel.showCountryPicker) {
                    CountryPickerView(selectedCountry: $viewModel.selectedCountry)
                }
                Section(header: Text("Privacy")) {
                    ToggleCell(title:"Direct Messages",isTappedSwitch: $viewModel.directMessages,onToggle: { newValue in
                        viewModel.directMessages = newValue
                    })
                    ToggleCell(title:"Receive Gifts",isTappedSwitch: $viewModel.receiveGifts,onToggle: { newValue in
                        viewModel.receiveGifts = newValue
                    })
                    ToggleCell(title:"Enable Private Entry",isTappedSwitch: $viewModel.enablePrivateEntry,onToggle: { newValue in
                        viewModel.enablePrivateEntry = newValue
                    })
                    
                }.listRowSeparator(.hidden)
                
                Section(header: Text("Display")) {
                       ToggleCell(title: "Show Reward Status", isTappedSwitch: $viewModel.showRewardStatus) { newValue in
                           viewModel.showRewardStatus = newValue
                       }
                       ToggleCell(title: "Show Seller Tools", isTappedSwitch: $viewModel.showSellerTools) { newValue in
                           viewModel.showSellerTools = newValue
                       }
                   }
                   .listRowSeparator(.hidden)

                   Section(header: Text("Content")) {
                       ToggleCell(title: "Enable Clips", isTappedSwitch: $viewModel.enableClips) { newValue in
                           viewModel.enableClips = newValue
                       }
                       ToggleCell(title: "Save Past Shows", isTappedSwitch: $viewModel.savePastShows) { newValue in
                           viewModel.savePastShows = newValue
                       }
                   }
                   .listRowSeparator(.hidden)

                   Section(header: Text("Other Settings")) {
                       ToggleCell(title: "Activity Status", isTappedSwitch: $viewModel.activityStatus) { newValue in
                           viewModel.activityStatus = newValue
                       }
                       ToggleCell(title: "Sync Phone Contacts", isTappedSwitch: $viewModel.syncPhoneContacts) { newValue in
                           viewModel.syncPhoneContacts = newValue
                       }
                       ToggleCell(title: "Suggest My Account", isTappedSwitch: $viewModel.suggestMyAccount) { newValue in
                           viewModel.suggestMyAccount = newValue
                       }
                       ToggleCell(title: "Haptic Feedback", isTappedSwitch: $viewModel.hapticFeedback) { newValue in
                           viewModel.hapticFeedback = newValue
                       }
                   }
                   .listRowSeparator(.hidden)
               
            }
            
        }
        
        
    }
}

#Preview {
    SettingsView()
}


struct SettingSection: Identifiable {
    let id = UUID()
    let title: String
    var items: [SettingItem]
}

struct SettingItem: Identifiable {
    enum SettingType {
        case toggle(Binding<Bool>)
        case navigation
    }
    
    let id = UUID()
    let title: String
    let type: SettingType
}
class SettingsViewModel: ObservableObject {
    @Published var directMessages = true
    @Published var receiveGifts = true
    @Published var enablePrivateEntry = false
    @Published var showRewardStatus = true
    @Published var showSellerTools = true
    @Published var enableClips = true
    @Published var savePastShows = false
    @Published var activityStatus = true
    @Published var syncPhoneContacts = false
    @Published var suggestMyAccount = true
    @Published var hapticFeedback = true
    
    @Published var selectedCountry: String = "United States"
        @Published var showCountryPicker: Bool = false
}


