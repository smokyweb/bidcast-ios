//
//  SearchView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct SearchView: View {
    @State var searchText: String = ""
    var onSubmitClick: ((String) -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            Image(.search)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(.black.opacity(0.5))
                .padding(.all, 10)
                .background(.gray.opacity(0.15))
                .clipShape(Circle())
            
            Spacer()
            
            TextField("Search for...", text: $searchText)
                .font(.custom(nunitoMedium, fixedSize: 14))
                .keyboardType(.default)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                .foregroundStyle(.text)
                .accentColor(.text)
                .submitLabel(.search)
                .onSubmit {
                    self.onSubmitClick?(searchText)
                }
            
            Spacer()
            
            
        }
        .frame(width: screenWidth - 30)
        .padding(.all, 4)
        .background(.bg)
        .cornerRadius(8)
        .shadow(color: .black, radius: 1)
        .padding(.all)
    }
}
