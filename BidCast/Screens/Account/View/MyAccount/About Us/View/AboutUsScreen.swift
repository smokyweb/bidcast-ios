//
//  AboutUsScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import SwiftUI
import SVProgressHUD

struct AboutUsScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var showError: Bool = false
    

    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var viewModel = AboutUsViewModel()
    @State var aboutUsData = AboutUsModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            VStack{
                PrimaryHeader(
                    title: "Select Your Favorite Category".localized,
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            
            // Dynamic Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        let data = aboutUsData
                        // Company Logo and Name
                        VStack(spacing: 8) {
                            AsyncImage(url: URL(string: data.logo ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 40)
//                            .clipShape(Circle())
                            
                            Text(data.company_name ?? "")
                                .font(.custom(poppinsSemiBold, size: 20))
                            
                            Text(data.platform_name ?? "")
                                .font(.custom(poppinsRegular, size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                        
                        Divider()
                        
                        // Mission Section
                        Text("Our Mission")
                            .font(.custom(poppinsSemiBold, size: 16))
                        
                        Text(data.mission ?? "")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.gray)
                        
                        Divider()
                        
                        // Key Features Section
                        Text("Key Features")
                            .font(.custom(poppinsSemiBold, size: 16))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(data.features ?? [Feature](), id: \.title) { feature in
                                FeatureCardView(feature: feature)
                            }
                        }
                        
                        Divider()
                        
                        // Impact Section
                        Text("Our Impact")
                            .font(.custom(poppinsSemiBold, size: 16))
                        
                        HStack {
                            ForEach(data.impact ?? [Impact](), id: \.label) { impact in
                                VStack {
                                    Text(impact.value ?? "")
                                        .font(.custom(poppinsSemiBold, size: 18))
                                        .foregroundColor(.red)
                                    
                                    Text(impact.label ?? "")
                                        .font(.custom(poppinsRegular, size: 14))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        
                        Divider()
                        
                        // Team Section
                        Text("Our Team")
                            .font(.custom(poppinsSemiBold, size: 16))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                          
                                HStack(spacing: 40) {
                                       ForEach(data.team ?? [TeamMember](), id: \.name) { member in
                                           TeamMemberView(member: member)
                                       }
                                   }
                            
                        }
                        
                        Divider()
                        
                        // Contact Info
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.red)
                                    Text(data.contact_email ?? "")
                                        .font(.custom(poppinsRegular, size: 14))
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.red)
                                    Text(data.contact_phone ?? "")
                                        .font(.custom(poppinsRegular, size: 14))
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                            }
                           
                        }

                        
                        // Social Media Links
                        HStack(spacing: 20) {
                            ForEach(data.social_media ?? [SocialMedia](), id: \.platform) { social in
                                if let urlString = social.url?.url, let url = URL(string: urlString) {
                                    Link(destination: url) {
                                        Image(systemName: socialIcon(platform: social.url?.platform ?? ""))
                                            .font(.title2)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding()
                }
                .refreshable {
                    await loadData()
                }
            
            
            Spacer()
        }
        .background(Color(.systemGray6))
        .onFirstAppear {
            Task { await loadData() }
        }
    }
    
    func loadData() async {
       guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await viewModel.getAboutContent()
        await SVProgressHUD.dismiss()
        
        if viewModel.aboutResponse.status != "success" {
            alertType = .sheetType(icon: .alert, title: "Error", message: viewModel.aboutResponse.message ?? "Something went wrong.", primaryBtnText: "", secondaryBtnText: "OK", sheetThemeColor: .pinkBtn)
            withAnimation(.snappy) { showError = true }
        }else{
            aboutUsData =  self.viewModel.aboutResponse.data ?? AboutUsModel()
        }
    }
    
    func socialIcon(platform: String) -> String {
        switch platform.lowercased() {
        case "linkdin": return "link"
        case "facebook": return "f.circle.fill"
        case "instagram": return "camera.circle.fill"
        case "skype": return "phone.circle.fill"
        default: return "globe"
        }
    }
}

struct FeatureCardView: View {
    var feature: Feature

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: feature.icon ?? "")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40, height: 40)
            
            Text(feature.title ?? "")
                .font(.custom(poppinsSemiBold, size: 14))
            
            Text(feature.description ?? "")
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        
        .shadow(radius: 2)
    }
}


struct TeamMemberView: View {
    var member: TeamMember

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: member.image ?? "")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            Text(member.name ?? "" )
                .font(.custom(poppinsSemiBold, size: 14))

            Text(member.role ?? "")
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.gray)
        }
        
    }
}
