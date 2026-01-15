//
//  SortByBottomSheet.swift
//  BidCast
//
//  Created by JamTech on 25/11/25.
//

import SwiftUI

// MARK: - Sort Option Enum
enum SortOption: String, CaseIterable, Identifiable {
    case titleAZ = "Title (A-Z)"
    case titleZA = "Title (Z-A)"
    case priceLowHigh = "Price (Low to High)"
    case priceHighLow = "Price (High to Low)"
    case newest = "Newest"
    case oldest = "Oldest"
    var id: String { self.rawValue }
    func getSortOrder() -> String{
        switch self {
        case .titleAZ:
            return "title_asc"
        case .titleZA:
            return "title_desc"
        case .priceLowHigh:
            return "price_low_high"
        case .priceHighLow:
            return "price_high_low"
        case .newest:
            return "newest"
        case .oldest:
            return "oldest"
        }
    }
    
}

// MARK: - Sort By Bottom Sheet
struct SortByBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedSort: String
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            PrimarySheetHeader(title: "Sort By", onClose: {
                isPresented = false
            })
            
            // MARK: - Sort Options
            VStack(spacing: 0) {
                ForEach(SortOption.allCases) { option in
                    SortOptionRow(
                        option: option,
                        isSelected: selectedSort == option.getSortOrder(),
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedSort = option.getSortOrder()
                            }
                            
                            // Auto dismiss after selection (optional)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isPresented = false
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.backGround)
    }
}

// MARK: - Sort Option Row
struct SortOptionRow: View {
    var option: SortOption
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.defaultTheme)
                            .frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                // Option Text
                Text(option.rawValue)
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
