//
//  SearchBarView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

struct SearchBarView: View {
    var placeholder: String = "What are you looking for?"
    var cornerRadius: CGFloat = 19
    var borderColor: Color = Color.gray.opacity(0.5)
    var borderWidth: CGFloat = 1
    var onCommit: (() -> Void)? = nil
    
    @StateObject private var viewModel: SearchTextViewModel
    
    init(
        placeholder: String = "What are you looking for?",
        onDebouncedSearch: @escaping (String) -> Void
    ) {
        self.placeholder = placeholder
        _viewModel = StateObject(wrappedValue: SearchTextViewModel(onDebouncedSearch: onDebouncedSearch))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.custom(poppinsSemiBold, size: 20.0))
            
            TextField(placeholder, text: $viewModel.searchText)
                .font(.custom(poppinsRegular, size: 14.0))
                .keyboardType(.default)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                .foregroundStyle(.text)
                .accentColor(.text)
                .submitLabel(.search)
                .accessibilityLabel("Search field")
                .accessibilityHint("Enter keywords to search")
            
            // Clear Button
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .frame(width: 20, height: 20)
                }
                .padding(4)
                .accessibilityLabel("Clear search text")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .cornerRadius(cornerRadius)
    }
}
