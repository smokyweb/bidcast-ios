//
//  ExploreViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD

struct ExploreViewScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    let count = Array(0...5)
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var imageName : [ImageResource] = [.gaming,.sports,.jewelery,.fashion,.vinyl]
    var tabName = ["Gaming","Sports","Jewellery ","Fashion","Vinyl Records"]
    var subLabel = ["864 Live","1.2K Live","640 Live","640 Live","640 Live"]
    var viewModel = SelectCategoryViewModel()
    @State var selectedTab = "recommended"
    @State var category : String = ""
    @State var navigateToCategoryDetailScreen = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false

    
    @State var categoryList = [CategoryDataModel]()
    @State var navigateToNoti : Bool = false
    
    var body: some View {
        VStack(alignment:.leading,spacing:0){
            VStack{
                PrimaryHeader(
                    title: "",
                    isForLogo: true,
                    leadingImgArr: [.appName], // logo on left
                    trailingImgArr: [.search,.notification],
                    onClickLeading: { index in
                        
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
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading,spacing: 12){
                    SearchView()
//                    SingleTitleLabel(title: "Recommended | Popular | All" ,textColor: .black,fontValue: 18.0)
                    ButtonTitleLabel(
                        titles: ["Recommended", "Popular", "All"],
                        fontValue: 16,
                        textColor: .blue
                    ) { selected in
                        print("Tapped:", selected)
                        Task{
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }

                            SVProgressHUD.show()
                            categoryList.removeAll()
                            var selection = ""
                            if selected == "Recommended"{
                                selection = "recommended"
                            }else if selected == "Popular"{
                                selection = "popular"
                            }else{
                                selection = "all"
                            }
                            self.selectedTab = selection
                            await self.viewModel.getCategoryList(param: CategoryRequest(category_id: "",type: selectedTab))
                            await SVProgressHUD.dismiss()
                            self.success()
                        }
                    }
                    ForEach(0 ..< categoryList.count, id: \.self) { ind in
                        ListCell(image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : "\(categoryList[ind].usage_count ?? "") Live",tintColot: categoryList[ind].color ?? "",onTapMenuCell: {
                        category = categoryList[ind].name ?? ""
                        navigateToCategoryDetailScreen = true
                        
                    })
                    .padding(.horizontal,0)
                    }
                }
            }
            .padding(.top,20)
            .padding(.horizontal,13)
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen, destination: HomeViewScreen(showCategory:$category,comeFromExploreScreen : $navigateToCategoryDetailScreen))
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
        }
        
        .background(.bg.opacity(0.4))
        .onAppear {
            Task {
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await self.viewModel.getCategoryList(param: CategoryRequest(category_id: "",type: selectedTab))
                await SVProgressHUD.dismiss()
                success()
//                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
//                  
//                }
            }
        }
    }
    
    func success() {
        let response = viewModel.categoryResponse
        if response.status == "success" {
            self.categoryList = viewModel.categoryResponse.data ?? [CategoryDataModel]()
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

