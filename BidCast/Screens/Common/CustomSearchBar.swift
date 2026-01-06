//
//  CustomSearchBar.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 15/10/25.
//

import SwiftUI
import SwiftUI

struct CustomSearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Search..."

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding([.leading] , 8)

            TextField(placeholder, text: $searchText)
                .foregroundColor(.primary)
                .frame(height: 45)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.custom(poppinsSemiBold, size: 28.0))
                        .foregroundStyle(.black)
                }
                .padding([.trailing] , 8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}


//#Preview {
//    CustomSearchBar()
//}
