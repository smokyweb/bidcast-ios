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
    let images = Array(1...10)
       
       let columns = [
           GridItem(.flexible()),
           GridItem(.flexible())
       ]
    
    @State var viewModel = HomeViewModel()
    @State var liveShowsData = [HomeModel]()
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var userId = ""
    
    var body: some View {
            VStack(spacing:0){
                VStack{
                    PrimaryHeader(
                        title: "",
                        isForLogo: true,
                        leadingImgArr: [.appName],
                        trailingImgArr: [.search,.notification],
                        onClickLeading: { index in
                            
                        },
                        onClickTrailing: nil,
                        count: .constant(0)
                    )
                   
                }
                
                ScrollView(showsIndicators:false){
                    VStack(alignment: .leading,spacing: 4){
                        SegmentedControlView(segments: HomeButton.allCases, selectedSegment:$selectedButton, isWithBorder: true)
                        SingleTitleLabel(title: "Live Now | Popular | coming Soon" ,textColor: .black,fontValue: 18.0)
                        LazyVGrid(columns: columns, spacing: 12) {
//                            let liveData = Array(0..<liveShowsData.count)
                            ForEach(liveShowsData, id: \.id) { item in
//                                let item = liveShowsData[index]
                                
                                ImageCollectionView(profileImg: item.user?.profile_image ?? "",
                                                    profileName: item.user?.name ?? "",
                                                    textSize: 13.0,
                                                    image: item.thumbnail?.first ?? "",
                                                    category: item.category?.name ?? "",
                                                    title2:item.title ?? "",
                                                    categorySize: 8,
                                                    title2Size: 12.0){
                                    
                                           print("babumoshai tapped the card!")
                                    userId = "\(item.user?.id ?? 0)"
                                           navigateToLiveStream = true
                                       }
                                           .background(.bg)
                                           .frame(maxWidth: .infinity)
                                           .frame(height: 280)
                                         
                                           .cornerRadius(10)
                                   }
                               }
                    }
                }
                .padding([.leading,.trailing],12)
                .padding(.top , 10)
                
                CusNavLink(doNavigate: $navigateToLiveStream, destination: LiveStream(userId : $userId))
            }
            .background(.white)
            .onAppear{
                Task{
                    SVProgressHUD.show()
                    await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: "live"))
                    await SVProgressHUD.dismiss()
                    await self.success()
                }
            }
            .onReceive(viewModel.$liveShowsResponse){ reponse in
               
            }
    }
   

    func success() {
        let response = viewModel.liveShowsResponse
            if response.status == "success" {
                liveShowsData = response.data ?? [HomeModel]()
                
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

#Preview {
    HomeViewScreen()
}

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


