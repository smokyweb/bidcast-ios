//
//  ProfileScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

struct ProfileScreen: View {
    
    @State var viewModel = ProfileViewModel()
    @Binding var id : String
    
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var profileData = ProfileModel()
    @State var showSellSheet = false
    @State var showNotify = false
   
    @State  var showhud = false
    @State  var hudMsg = ""
    @State  var productData = ProductListingDataModel()
    @State var isFollowing = false
    @State var productId : Int = 0
    @State var productArr = [ProductListingDataModel]()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    ProfileHeaderView(name: profileData.name ?? "", email: profileData.username ?? "", profileImage: profileData.profile_image ?? "", followers: "\(profileData.follower_count ?? 0)", following: "\(profileData.following_count ?? 0)" , bio: profileData.bio ?? "",onTapNotify: {
                        showNotify = true
                    })
                    
                    ProfileActionsView(isFollowing: $isFollowing ,
                                       onTapFollow: {
                        self.viewModel.followUnfollow(parameters: FollowRequest(following_id: id))
                    },
                                       onTapMessage: {
                        //MEssage chat
                        
                    })
                    ProfileTabsView()
                    SearchAndFiltersView()
                    ProductListView(prouduct: $productArr,onTapProduct: { index in
                        productData = productArr[index]
                        productId = productData.id ?? 0
                        showSellSheet = true
                        print("Selected product id: \(productData.id ?? 0)")
                        print("index fdor sheegt \(index)")
                    })
                }
//                .padding()
            }
            .edgesIgnoringSafeArea(.top)
            
            .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.95) {
                          ProductDetailSheet(
                            onDismiss : {
                                self.showSellSheet = false
                                productId = 0
                            },
                            productID: $productId

                          )
                      }
            .bottomSheet(isPresented: $showNotify,height: screenHeight * 0.45) {
                   NotifyMeBottomSheet(
                       profileImage: profileData.profile_image ?? "" ,
                       username: profileData.username ?? "",
                       onDismiss: {
                           self.showNotify = false
                       }
                   )
               }
           
        }
        .onAppear{
            observe()
            let param = ProfileParamRequest(id: id)
            print(param)
            self.viewModel.getProfile(param:param )
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                success()
            case .error(let error):
                let msg = error?.localizedDescription ?? AppString.error.localized
                alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: msg, primaryBtnText: "", secondaryBtnText: AppString.ok.localized)
                showError = true
            }
        }
    }

    func success() {
        if self.viewModel.requestType == "get"{
            let response = viewModel.getProfileDict
            if response.status == "success" {
                profileData = response.data ?? ProfileModel()
                isFollowing = profileData.is_following ?? false
                self.viewModel.productDetails(parameters: UserProductRequest(user_id: Int(id) ?? 0))
            } else {
                showError = true
                alertType = .sheetType(
                    icon: .alert,
                    title: response.error_type?.capitalized ?? "",
                    message: response.message?.capitalized ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
            }
            
        }else  if self.viewModel.requestType == "product"{
            let response = viewModel.productDetailsResponceDict
            if response?.status == "success" {
                      productArr = response?.data ?? []
                     
                  } else {
                      alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
                      withAnimation(.snappy) { showError = true }
                  }
        }
    }
}

struct ProfileHeaderView: View {
    @Environment(\.presentationMode) var presentationMode
    var name = "Sarah Williams"
    var email = "@sarahwilliams"
    var profileImage = "user1"
    var followers = "2.4K"
    var following = "856"
    var bio = "Professional photographer specializing in portrait and wedding photography. Available for bookings worldwide."
    var onTapNotify : () -> () = {}
    var body: some View {
        ZStack(alignment: .topLeading) {
                   // Background image
                   VStack(spacing: 0) {
                       Image("IMG_2678") // Replace with your image
                           .resizable()
                           .scaledToFill()
                           .frame(height: 200)
                           .clipped()
                       Spacer()
                   }

                   
                   Button(action: {
                       presentationMode.wrappedValue.dismiss()
                   }) {
                       Image(systemName: "chevron.left")
                           .font(.system(size: 20, weight: .bold))
                           .foregroundColor(.white)
                           .padding(10)
                           .background(Color.black.opacity(0.6))
                           .clipShape(Circle())
                           .shadow(radius: 4)
                   }
                   .padding(.top, 30)
                   .padding(.leading, 16)
                   .zIndex(1)

                   // Foreground content
                   VStack(alignment: .leading, spacing: 4) {
                       HStack {
//                           Image(profileImage)
//                               .resizable()
//                               .clipShape(Circle())
//                               .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                               .frame(width: 80, height: 80)
//                               .offset(x: 16, y: 160)
                           AsyncImage(url: URL(string: profileImage)) { phase in
                                              switch phase {
                                              case .empty:
                                                  ProgressView()
                                                      .frame(width: 80, height: 80)
                                              case .success(let image):
                                                  image
                                                      .resizable()
                                                      .clipShape(Circle())
                                                      .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                      .frame(width: 80, height: 80)
                                                      .offset(x: 16, y: 160)
                                              case .failure:
                                                  Image(systemName: "person.crop.circle.fill")
                                                      .resizable()
                                                      .clipShape(Circle())
                                                      .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                      .frame(width: 80, height: 80)
                                                      .offset(x: 16, y: 160)
                                              @unknown default:
                                                  EmptyView()
                                              }
                                          }
                           Spacer()

                          
                       }
                   }
               }
               .frame(height: 220) // Height of header section
        
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing:8){
                VStack{
                    Text(name)
                        .font(.custom(poppinsBold, size: 20.0))
//                        .fontWeight(.bold)
                    Text(email)
                        .font(.custom(poppinsRegular, size: 14.0))
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 12) {
                            Button(action: {
                                onTapNotify()
                            }) {
                                Image(systemName: "bell")
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }

                            Button(action: {
                                // Share action
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }

                            Button(action: {
                                // More options action
                            }) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.black)
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
            }
            
           
            
            HStack(spacing: 16) {
                Text("\(followers) Followers").bold()
                Text("\(following) Following").foregroundColor(.gray)
            }
            
            Text(bio)
                .font(.body)
                .foregroundColor(.gray)
        }.padding(.horizontal,8)
    }
}

struct ProfileActionsView: View {
    @Binding var isFollowing: Bool
    var onTapFollow :() -> () = { }
    var onTapMessage :() -> () = { }
    
    var body: some View {
        HStack(spacing: 16) {
            Button(isFollowing ? "Unfollow" : "Follow") {
                self.onTapFollow()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemGray5))
            .cornerRadius(12)

            Button("Message") {
                self.onTapMessage()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Button(action: {
                // Handle action
            }) {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.primary)
                    .font(.title2)
            }
        }
        .padding(.horizontal,13)
    }
}

struct ProfileTabsView: View {
    let tabs = ["Shop", "Shows", "Reviews", "Clips"]
    @State private var selectedTab = "Shop"

    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                VStack {
                    Text(tab)
                        .fontWeight(selectedTab == tab ? .bold : .regular)
                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                    if selectedTab == tab {
                        Capsule().fill(Color.blue).frame(height: 3)
                    } else {
                        Capsule().fill(Color.clear).frame(height: 3)
                    }
                }
                .onTapGesture {
                    selectedTab = tab
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal,13)
    }
}

struct SearchAndFiltersView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("What are you looking for?", text: .constant(""))
                    .padding(.leading, 12)
                Image(systemName: "slider.horizontal.3")
                    .padding(.trailing, 12)
            }
            .frame(height: 44)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            
            HStack {
                ForEach(["Filter", "Sort", "Buy Now", "Category"], id: \.self) { title in
                    Button(title) {
                        // Handle filter
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal,13)
    }
}

struct ProductListView: View {
    @Binding var prouduct : [ProductListingDataModel]
    @State var onTap = false
    var onTapProduct :(Int) -> () = {_ in }
    var body: some View {
        VStack(spacing: 12) {
            ForEach(prouduct.indices , id:\.self){ index in
                let item = prouduct[index]
                ProductCardView(imageName: item.images?.first ?? "", productName: item.title ?? "", description: item.description ?? "", pricing: "$\(item.pricing ?? 0)")
                    .onTapGesture {
                        self.onTap.toggle()
                        print("ontap \(index) / \(self.onTap)")
                        self.onTapProduct(index)
                    }
                
            }
        }
    }
}

struct ProductCardView: View {
    var imageName: String = "ic_bidder"
var productName = "Product Name"
    var description = "Category - Condition"
    var pricing = "$2"
    var body: some View {
        HStack {
           
//                Image(imageName)
//                    .resizable()
//                    .frame(width: 80, height: 80)
//                    .cornerRadius(10)
            AsyncImage(url: URL(string: imageName)) { phase in
                               switch phase {
                               case .empty:
                                   ProgressView()
                                       .frame(width: 80, height: 80)
                               case .success(let image):
                                   image
                                       .resizable()
                                       .frame(width: 80, height: 80)
                                       .cornerRadius(10)
                               case .failure:
                                   Image(systemName: "person.crop.circle.fill")
                                       .resizable()
                                       .clipShape(Circle())
                                       .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                       .frame(width: 80, height: 80)
                                       .offset(x: 16, y: 160)
                               @unknown default:
                                   EmptyView()
                               }
                           }

            VStack(alignment: .leading) {
                Text(productName).fontWeight(.semibold)
                Text(description).foregroundColor(.gray).font(.subheadline)
                Text(pricing).fontWeight(.bold)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}


struct TabIcon: View {
    var title: String
    var systemImage: String
    var selected: Bool = false

    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .foregroundColor(selected ? .purple : .gray)
            Text(title)
                .font(.caption)
                .foregroundColor(selected ? .purple : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    ProfileScreen()
//}
