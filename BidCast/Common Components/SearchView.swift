//  SearchView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//
import SwiftUI

struct SearchView: View {

    @StateObject private var viewModel: SearchTextViewModel
    @State private var placeholder: String = AppString.whatAreYouLookingFor.localized
    @FocusState private var isFocused: Bool
    
    init(onDebouncedSearch: @escaping (String) -> Void) {
        _viewModel = StateObject(wrappedValue: SearchTextViewModel(onDebouncedSearch: onDebouncedSearch))
    }

    
    var body: some View {
        HStack(spacing: 10) {
            // Search Icon
            Image(.search)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(10)
                .accessibilityHidden(true)
            
            TextField(placeholder, text: $viewModel.searchText)
                       .font(.custom(poppinsMedium, fixedSize: 14))
                       .keyboardType(.default)
                       .autocorrectionDisabled(true)
                       .autocapitalization(.none)
                       .foregroundStyle(.text)
                       .accentColor(.text)
                       .submitLabel(.search)
                       .accessibilityLabel("Search field")
                       .accessibilityHint("Enter keywords to search")
                       .focused($isFocused)
            
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
        .frame(height: 42)
//        .clipShape(RoundedRectangle(cornerRadius: 8))
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color.black.opacity(0.6), lineWidth: 1.0)
//        )
//        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 1)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.black.opacity(0.8) : Color.black.opacity(0.5), lineWidth: isFocused ? 2 : 1)
        )
        .shadow(color: isFocused ? Color.black.opacity(0.1) : .clear,
                radius: 8, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .padding(1)
    }
}
