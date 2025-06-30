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
    
    let count = Array(0...5)
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var imageName : [ImageResource] = [.gaming,.sports,.jewelery,.fashion,.vinyl]
    var tabName = ["Gaming","Sports","Jewellery ","Fashion","Vinyl Records"]
    var subLabel = ["864 Live","1.2K Live","640 Live","640 Live","640 Live"]
    var viewModel = SelectCategoryViewModel()
    @State var category : String = ""
    @State var navigateToCategoryDetailScreen = false
    
    @State var categoryList = [CategoryDataModel]()
    @State var isLoading = false
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
                        navigateToNoti = true
                    },
                    count: .constant(0)
                )
                
            }
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading,spacing: 12){
                    SearchView()
                    SingleTitleLabel(title: "Recommended | Popular | All" ,textColor: .black,fontValue: 18.0)
                    ForEach(0 ..< categoryList.count, id: \.self) { ind in                            ListCell(image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : "BidSwipe",tintColot: categoryList[ind].color ?? "",onTapMenuCell: {
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
                SVProgressHUD.show()
                await self.viewModel.getCategoryList()
                await SVProgressHUD.dismiss()
                self.categoryList = viewModel.categoryResponse.data ?? [CategoryDataModel]()
            }
        }
    }
}

