//
//  SearchView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//
//
//  SearchView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//
import SwiftUI
import SwiftUICore

struct SearchView: View {
    @State private var searchText: String = ""
    var onSubmitClick: ((String) -> Void)?
    
    var body: some View {
        HStack(spacing: 10) {
            // Search Icon
            Image(.search)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(.black.opacity(0.5))
                .padding(10)
                .background(Color.gray.opacity(0.15))
                .clipShape(Circle())
                .accessibilityHidden(true)
            
            // Text Field
            TextField("Search for...", text: $searchText)
                .font(.custom(poppinsMedium, fixedSize: 14))
                .keyboardType(.default)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                .foregroundStyle(.text)
                .accentColor(.text)
                .submitLabel(.search)
                .onSubmit {
                    onSubmitClick?(searchText)
                }
                .accessibilityLabel("Search field")
                .accessibilityHint("Enter keywords to search")
            
            // Clear Button
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                }
                .accessibilityLabel("Clear search text")
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 50)
        .background(Color.bg.opacity(0.4))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 1)
//        .padding(.horizontal)
    }
}
