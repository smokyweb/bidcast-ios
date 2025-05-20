//
//  TitleWithPencil.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 25/01/24.
//

import SwiftUI

struct TitleWithPencil: View {
    
    var title: String = ""
    var showPencil: Bool = true
    var onPencilClick: (() -> Void)?
    var comeFrom : Bool = false
    var body: some View {
        HStack {
            Text(title)
                .font(.custom(nunitoBlack, fixedSize: 18))
                .foregroundStyle(.black)
            
            Spacer()
            
            if comeFrom{
                if showPencil {
                    Button(action: { withAnimation(.easeIn) { self.onPencilClick?() } }, label: {
                        Image(.arrowForward)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    })
                }
            }else{
                if showPencil {
                    Button(action: { withAnimation(.easeIn) { self.onPencilClick?() } }, label: {
                        Image(.editPencil)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    })
                }
            }
        }
    }
}

#Preview {
    TitleWithPencil()
}
