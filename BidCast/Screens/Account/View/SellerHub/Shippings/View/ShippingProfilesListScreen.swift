//
//  ShippingProfilesListScreen.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//
//
import SwiftUI

struct ShippingProfile: Hashable {
    var name: String
    var weight: Int
    var scale: String
    var maxItems: Bool
    var additionalWeight: Bool
}


// MARK: - Shipping Profiles List Screen
struct ShippingProfilesListScreen: View {
//    @State private var profiles: [StoreShippingModel] = [
//        StoreShippingModel(userID: 12, name: "My new shipping", size: "Pound", weight: "25", id: 1),
//        StoreShippingModel(userID: 13, name: "My new shipping ", size: "Ounch", weight: "22", id: 2)
//    ]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showCreateProfile = false
    @State private var showEditProfile = false
    
    @State private var profiles: [StoreShippingModel] = []
    @State private var selectedProfile:StoreShippingModel?
    
    @StateObject private var shippingViewModel = ShippingViewModel()

    @State var isLoading: Bool = true

    @State private var showDeleteProduct: Bool = false
    
    @State private var shippingId: Int = -1
    
    
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State private var showError = false
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.custom(poppinsBold, size: 16))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Shipping Profiles")
                        .font(.custom(poppinsSemiBold, size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible placeholder for alignment
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.white))
                
                Divider()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if isLoading {
                            // Show 5 skeleton items
                            ForEach(0..<5) { _ in
                                SkeletonShippingProfileCardView()
                            }
                        }
                        else if profiles.isEmpty {
                            NoDataView(message: AppString.NoShippingProfileFound.localized)
                        }
                        else {
                            ForEach(profiles, id: \.id) { profile in
                                ShippingProfileCard(profile: profile) {
                                    //on tap edit
                                    selectedProfile = profile
                                    shippingId = profile.id ?? -1
                                    editShippingProfile()
                                } onTapDelete: {
                                    //on tap delete
                                    selectedProfile = profile
                                    shippingId = profile.id ?? -1
                                    config = BottomSheetConfig(
                                        icon: "trash.circle.fill",
                                        title: "Delete Shipping Profile?",
                                        message:  "Are you sure you want to remove this Profile?",
                                        primaryButtonTitle: "Delete",
                                        secondaryButtonTitle: "Cancel",
                                        bottomPadding: -70
                                    )
                                    showDeleteProduct = true
                                }

                            }
                        }
                    }
                    .padding(12)
                }
                .background(Color(.systemGroupedBackground))
                
                // Bottom Button
                VStack(spacing: 0) {
                    Divider()
                    PrimaryButton(title: "Create Shipping Profile",
                                  isOutLine: false,
                                  onButtonClick: { showCreateProfile = true }
                    )
                    .padding(.vertical, 12)
                }
                .onAppear {
                    getShippingProfiles()
                }
                .background(.backGround)
                NavigationLink(destination: CreateShippingProfileScreen().navigationBarBackButtonHidden(true), isActive: $showCreateProfile) {
                    EmptyView()
                }
                .hidden()
                NavigationLink(
                    destination: CreateShippingProfileScreen(nameVal: selectedProfile?.name,
                                                             sizeVal: selectedProfile?.size,
                                                             weightVal: selectedProfile?.weight,
                                                             shippingId: shippingId,
                                                             additionalWeight: selectedProfile?.additionalWeight,
                                                             maxItems: selectedProfile?.maxItems,
                                                            )
                                    .navigationBarBackButtonHidden(true),
                    isActive: $showEditProfile) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
            .toolbar(.hidden,for: .tabBar)
            .overlay(
                CustomBottomSheetView(
                    isPresented: $showDeleteProduct,
                    config: config,
                    primaryAction: {
                        withAnimation {
                            showDeleteProduct = false
                            deleteShippingProfile(with: shippingId)
                        }
                    },
                    secondaryAction: {
                        withAnimation {
                            showDeleteProduct = false
                        }
                    }
                )
            )
            
            .overlay(
                CustomBottomSheetView(
                    isPresented: $showError,
                    config: config,
                    primaryAction: {
                        withAnimation {
                            showError = false
                        }
                    },
                    secondaryAction: {
                        withAnimation {
                            showError = false
                        }
                    }
                )
            )
        }
    }
    
    private func editShippingProfile(){
        showEditProfile = true
    }
    
    private func deleteShippingProfile(with shippingId: Int?){
        guard let id = shippingId else {
             return
        }
        Task {
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: errorDesc(error: error, message: shippingViewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    getShippingProfiles()
                }
            ) {
                let request =  DeleteShippingProfileRequest(shipping_profile_id: id)
                try await shippingViewModel.deleteShippingProfile(request: request)
            }
        }
    }
}

// MARK: - API Calls
extension ShippingProfilesListScreen {
    private func getShippingProfiles()  {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: false,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: errorDesc(error: error, message: shippingViewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    isLoading = false
                    self.profiles = shippingViewModel.getShippingProfilesResponse?.data ?? []
                }
            ) {
                isLoading = true
                try await shippingViewModel.getShippingProfiles()
            }
        }
    }
}


// MARK: - Shipping Profile Card
struct ShippingProfileCard: View {
    let profile: StoreShippingModel
    @State private var isPressed = false
    
    var onTapEdit: () -> Void
    var onTapDelete: () -> Void
    
    private var menuOptions: [MenuOption] {
        var options: [MenuOption] = []
        options.append(MenuOption(
            icon: "pencil",
            title: "Edit",
            iconColor: .blue,
            action: onTapEdit))
        
        options.append(
            MenuOption(
                icon: "trash",
                title: "Delete",
                iconColor: .red,
                role: .destructive,
                action: onTapDelete))
        
        return options
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(profile.name?.capitalizingFirstLetter() ?? "Name")
                        .font(.custom(poppinsSemiBold, size: 18))
                        .foregroundColor(.primary)
                    Spacer()
                    ReusableMenu(
                        options: menuOptions,
                        style: .dotsVertical
                    )
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight:")
                            .font(.custom(poppinsMedium, size: 14))
                            .foregroundColor(.secondary)
                        Text("\(profile.weight ?? "")")
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Scale:")
                            .font(.custom(poppinsMedium, size: 14))
                            .foregroundColor(.secondary)
                        Text(profile.size ?? "Scale")
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.primary)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Set max items per package")
                        .font(.custom(poppinsRegular, size: 15))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
//                    Text("No")
                    Text((profile.maxItems ?? false) ? "Yes" : "No")
                        .font(.custom(poppinsSemiBold, size: 15))
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Additional weight per item")
                        .font(.custom(poppinsRegular, size: 15))
                        .foregroundColor(.primary)
                    
                    Spacer()
//                    Text("No")
                    Text((profile.additionalWeight ?? false) ? "Yes" : "No")
                        .font(.custom(poppinsSemiBold, size: 15))
                        .foregroundColor(.blue)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SkeletonShippingProfileCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Name Placeholder
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 160, height: 18)
                .shimmer()
            
            // Weight + Scale Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 14)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 16)
                        .shimmer()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 14)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 16)
                        .shimmer()
                }
            }
            
            Divider()
            
            // Max items per package Row
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 16)
                    .shimmer()
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 16)
                    .shimmer()
            }
            
            // Additional weight Row
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 16)
                    .shimmer()
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 16)
                    .shimmer()
            }
            
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}
