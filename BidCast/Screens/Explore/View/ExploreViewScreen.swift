//
//  ExploreViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

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
    
    @State var categoryList = [CategoryDataModel]()
    @State var isLoading = false
    
    var body: some View {
        VStack(spacing:0){
            VStack{
            PrimaryHeader(
                title: "",
                isForLogo : true, leadingImgArr: [.appName],
                trailingImgArr: [.search,.notification],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .padding(.horizontal,12)
            .frame(height: 40)
            .background(.white)
        }
            .padding(.horizontal,12)
            .background(.white)
                
                ScrollView{
                    VStack(alignment: .leading,spacing: 8){
                        SearchView()
                        
                        SingleTitleLabel(title: "Recommended | Popular | All" ,textColor: .black,fontValue: 20.0)
//                            .padding([.leading,.trailing],12)
//                        let data = self.viewModel.categoryDict?.data ?? [CategoryDataModel]()
                        ForEach(0 ..< categoryList.count, id: \.self) { ind in
//                            print("\(ind)")
//                            print(self.title[ind])
                            ListCell(image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : "BidSwipe",tintColot: categoryList[ind].color ?? "")
                                .padding(.horizontal,12)
                           
                        }
                       
                    }
                   
                } .padding(.horizontal,12)
              
            }
            
            .background(.bg.opacity(0.4))
//            .edgesIgnoringSafeArea(.top)
            .onAppear {
                observe()
                self.viewModel.getCategoryList()
            }
            
       
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                categorySuccess()
            case .error(let error):
                let msg = error?.localizedDescription ?? AppString.error.localized
                print(msg)
            }
        }
    }

    func categorySuccess() {
        if viewModel.request == "Category" {
            if let response = viewModel.categoryDict {
                if response.status == "success" {
                 
                    self.categoryList = response.data
                } else {
                   
//                    showError = true
                }
            }
        }
    }
}

#Preview {
    ExploreViewScreen()
}

