//
//  HomeViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD

struct HomeViewScreen: View {
    @State private var selectedButton: HomeButton = .For_you
    @Environment(\.presentationMode) var presentationMode
    @State var navigateToLiveStream = false
    @State var index = 0
    let images = Array(1...10)
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    @Binding var showCategory : String
    @State var viewModel = HomeViewModel()
    @State var liveShowsData = [HomeModel]()
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var userId = ""
    @Binding var comeFromExploreScreen : Bool
    @State var navigateToNoti : Bool = false
    
    @State var navigateToProfile = false
    
    var body: some View {
        VStack(spacing:0){
            VStack{
                PrimaryHeader(
                    title: comeFromExploreScreen ? showCategory.capitalizingFirstLetter() : "",
                    isForLogo: comeFromExploreScreen ? false : true,
                    leadingImgArr: [comeFromExploreScreen ? .icBack : .appName],
                    trailingImgArr: [.search,.notification],
                    onClickLeading: { index in
                        if comeFromExploreScreen{
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    },
                    onClickTrailing: { index in
                        if index == 0{
                            print("For Search Navigation")
                        }else{
                            navigateToNoti = true
                        }
                    },
                    count: .constant(0)
                )
            }
            
            ScrollView(showsIndicators:false){
                VStack(alignment: .leading,spacing: 12){
                    SegmentedControlView(segments: HomeButton.allCases, selectedSegment:$selectedButton, isWithBorder: true)
                    ButtonTitleLabel(
                        titles: ["Live Now", "Popular", "Coming Soon"],
                        fontValue: 16,
                        textColor: .blue
                    ) { selected in
                        print("Tapped:", selected)
                        Task{
                            SVProgressHUD.show()
                            liveShowsData.removeAll()
                            var selection = ""
                            if selected == "Live Now"{
                                selection = "live"
                            }else if selected == "Popular"{
                                selection = "popular"
                            }else{
                                selection = "upcoming"
                            }
                            await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: selection,category: showCategory))
                            await SVProgressHUD.dismiss()
                            self.success()
                        }
                    }
                    if liveShowsData.isEmpty{
                        NoDataView(message: "No Shows found")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }else{
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(liveShowsData.indices, id: \.self) { index in
                                let item = liveShowsData[index]
                                
                                ImageCollectionView(profileImg: item.user?.profile_image ?? "",
                                                    profileName: item.user?.name ?? "".capitalizingFirstLetter(),
                                                    textSize: 14.0,
                                                    image: item.thumbnail?.first ?? "",
                                                    category: item.category?.name ?? "",
                                                    title2:item.title ?? "",
                                                    categorySize: 9,
                                                    title2Size: 13.0,
                                                    onTapProfile: {
                                    userId = "\(item.user?.id ?? 0)"
                                    navigateToProfile = true
                                    
                                },onTapMainImage: {
                                    
                                    print("babumoshai tapped the card!,inex \(index)")
                                    self.index = index
                                    userId = "\(item.user?.id ?? 0)"
                                    navigateToLiveStream = true
                                   
                                })
                                .background(.bg)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.vertical,3)
                    }
                }
            }
            .padding([.leading,.trailing],12)
            .padding(.top , 10)
            
            CusNavLink(doNavigate: $navigateToLiveStream, destination: LiveStream(currentStreamIndex :self.$index, userId : $userId ))
            CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(id:$userId))
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
        }
        .background(.white)
        .onAppear{
            NotificationCenter.default.addObserver(forName: Notification.Name("Notification"), object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo {
                    print("🔔 Babumoshai, Notification Payload: \(userInfo)")
                    let type = userInfo["type"] as? String ?? ""
//                           let senderName = userInfo["sender_name"] as? String ?? ""
//                           let senderImage = userInfo["sender_image"] as? String ?? ""
//                           let title = userInfo["title"] as? String ?? ""
//                           let body = userInfo["body"] as? String ?? ""

                    if type == "bid_show_start" {
//                        navigateToLiveStream = true
                    }
                }
            }
            Task{
                liveShowsData.removeAll()
                SVProgressHUD.show()
                await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: "live",category: showCategory))
                await SVProgressHUD.dismiss()
                self.success()
            }
            
            FirebaseManager.shared.observeNewLiveSessionNodes {
                   print("🔥 New session detected, refreshing the list babumoshai!")
                Task{
                    liveShowsData.removeAll()
                    SVProgressHUD.show()
                    await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: "live",category: showCategory))
                    await SVProgressHUD.dismiss()
                    self.success()
                }
               }
        }
     
    }
    
    
    func success() {
        let response = viewModel.liveShowsResponse
        if response.status == "success" {
            FirebaseManager.shared.fetchAllLiveSessions { firebaseRoomIds in
                let validShows = response.data?.filter { show in
                                   guard let roomId = show.room_id else { return false }
                                   return firebaseRoomIds.contains(roomId)
                               }
                
                DispatchQueue.main.async {
                    if validShows?.isEmpty == true {
//                        showError = true
                        alertType = .sheetType(
                            icon: .alert,
                            title: response.error_type?.capitalized ?? "",
                            message: response.message?.capitalized ?? "",
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                    }else{
                        liveShowsData = validShows ?? [HomeModel]()
//                        liveShowsData = response.data ?? [HomeModel]()
                    }
                }
            }
            
           
            
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
    }
}

//#Preview {
//    HomeViewScreen()
//}

enum HomeButton: String, CaseIterable, CustomStringConvertible {
    case For_you = "For You"
    case collectibles = "Collectibles"
    case trading = "Trading"
    case purchases = "Purchases"
    case savedItems = "Saved Items"
    
    var description: String {
        return rawValue
    }
}



struct ButtonTitleLabel: View {
    
    var titles: [String] = ["Live Now", "Popular", "Coming Soon"]
    var fontName = poppinsRegular
    var selectedFontName = poppinsSemiBold
    var fontValue: CGFloat = 18
    var textColor: Color = .gray
    var selectedColor: Color = .black
    var separatorColor: Color = .gray
    var spacing: CGFloat = 12
    var onTap: ((String) -> Void)? = nil
    
    @State var selectedTitle: String = "Live Now"
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(titles.indices, id: \.self) { index in
                HStack(spacing: spacing) {
                    let title = titles[index]
                    
                    Text(title)
                        .font(.custom(title == selectedTitle ? selectedFontName : fontName, fixedSize: fontValue))
                        .foregroundColor(title == selectedTitle ? selectedColor : separatorColor)
                        .onTapGesture {
                            selectedTitle = title
                            onTap?(title)
                        }
                    
                    if index < titles.count - 1 {
                        Text("|")
                            .foregroundColor(separatorColor)
                            .font(.custom(fontName, fixedSize: fontValue))
                    }
                }
            }
        }
        .padding(.horizontal, 6)
    }
}
