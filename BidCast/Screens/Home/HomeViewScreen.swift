//
//  HomeViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

struct HomeViewScreen: View {
    @State private var selectedButton: HomeButton = .For_you
    @Environment(\.presentationMode) var presentationMode
    
    let images = Array(1...10)
       
       let columns = [
           GridItem(.flexible()),
           GridItem(.flexible())
       ]
    
    var body: some View {
            VStack(spacing:0){
                PrimaryHeader(
                    title: "",
                    isForLogo : true, leadingImgArr: [.appName],
                    trailingImgArr: [.search,.notification],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(.white)
                
                ScrollView{
                    VStack(alignment: .leading,spacing: 8){
                        SegmentedControlView(segments: HomeButton.allCases, selectedSegment:$selectedButton, isWithBorder: true)
                        SingleTitleLabel(title: "Live Now | Popular | coming Soon" ,textColor: .black,fontValue: 20.0)
                        LazyVGrid(columns: columns, spacing: 20) {
                                   ForEach(images, id: \.self) { index in
                                       ImageCollectionView(textSize: 16.0, image: .IMG_2678)
                                           .background(.bg)
                                           .frame(height: 240)
                                         
                                           .cornerRadius(10)
                                   }
                               }
                    }
                }
                .padding([.leading,.trailing],12)
                .padding(.top , 10)
            }
            .background(.bg.opacity(0.4))
            .edgesIgnoringSafeArea(.top)
            
       
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


