//
//  MenuListCard.swift
// BidSwipe
//
//  Created by JAM-E-282 on 22/01/24.
//

import SwiftUI
import SafariServices

struct MenuListCard: View {
    
    var check: Bool = false
    var menu: MenuModal = MenuModal(title: "", img: .menuHome)
    var onMenuClick: ((String) -> Void)?

    
    @StateObject var viewModel = GoogleAuthViewModel()
    var body: some View {
        Button(action: {
            onMenuClick?(menu.title)
        }, label: {
            HStack {
                Image(menu.img)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    .padding(.all, 8)
                    .background(.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Text(menu.title)
                    .font(.custom(nunitoSemiBold, fixedSize: 16))
                    .foregroundStyle(.black)
                
                Spacer()
                if self.check == true{
                    PrimaryButton(title: "Sync", isOutLine: false, onButtonClick: {
                        viewModel.googleAuthorization()
                    }, width: 80, height: 30, btnColor: .text)
                }else{
                    Image(.arrowForward)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.text)
                }
            }
            .padding(.all, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 1, x: 0, y: 0)
            )
        })
        
    }
}


#Preview {
    MenuListCard()
}
