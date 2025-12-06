//
//  PillSelectorView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

enum PillBackgroundStyle {
    case none
    case pill
    case roundedRect
}

struct PillsSelectorView: View {
    
    let titles: [String]          // e.g. ["Sort", "Auction", "Buy Now", "Giveaway"]
    @Binding var selectedIndex: Int
    
    var backgroundStyle: PillBackgroundStyle = .roundedRect
    var underlineEnabled: Bool = false
    var showFilterButton: Bool = false
    var showSortDropdown: Bool = false
    
    var onSelectionChanged: ((Int, String) -> Void)?
    var onFilterTapped: (() -> Void)? = nil
    var onSortTapped: (() -> Void)? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                
                // MARK: - Filter Button
                if showFilterButton {
                    filterButton
                }
                
                // MARK: - Pills
                ForEach(titles.indices, id: \.self) { index in
                    
                    if showSortDropdown && titles[index].lowercased() == "sort" {
                        sortButton(index: index)
                    } else {
                        pillItem(for: index)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

// MARK: - FILTER BUTTON
extension PillsSelectorView {
    private var filterButton: some View {
        Button(action: { onFilterTapped?() }) {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.custom(poppinsMedium, size: 14))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(12)
        }
    }
}

// MARK: - SORT BUTTON (WITH DROPDOWN ICON)
extension PillsSelectorView {
    private func sortButton(index: Int) -> some View {
        
        let isSelected = (selectedIndex == index)
        
        return Button(action: {
            onSortTapped?()
            withAnimation {
                selectedIndex = index
                onSelectionChanged?(index, titles[index])
            }
        }) {
            HStack(spacing: 6) {
                Text(titles[index])
                    .font(.custom(poppinsMedium, size: 14))
                    .foregroundColor(foreground(for: isSelected))
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(foreground(for: isSelected))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 16)
            .background(background(for: isSelected))
            .cornerRadius(12)
        }
    }
}

// MARK: - NORMAL PILL ITEMS
extension PillsSelectorView {
    
    private func pillItem(for index: Int) -> some View {
        let title = titles[index]
        let isSelected = (selectedIndex == index)
        
        return VStack(spacing: 4) {
            Text(title)
                .font(.custom(isSelected ? poppinsBold : poppinsMedium, size: 14))
                .foregroundColor(foreground(for: isSelected))
                .padding(.horizontal, stylePadding())
                .padding(.vertical, 7)
                .background(background(for: isSelected))
                .cornerRadius(backgroundCornerRadius())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = index
                        onSelectionChanged?(index, titles[index])
                    }
                }
            
            if underlineEnabled && isSelected {
                Capsule()
                    .fill(Color.black)
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func stylePadding() -> CGFloat {
        switch backgroundStyle {
        case .none: return 1
        case .pill, .roundedRect: return 16
        }
    }
    
    private func backgroundCornerRadius() -> CGFloat {
        switch backgroundStyle {
        case .pill: return 50
        case .roundedRect: return 12
        case .none: return 0
        }
    }
    
    private func background(for isSelected: Bool) -> some View {
        switch backgroundStyle {
        case .none:
            Color.clear
        case .pill:
            (isSelected ? Color.defaultTheme.opacity(0.85) : Color.gray.opacity(0.15))
            
        case .roundedRect:
            (isSelected ? Color.defaultTheme.opacity(0.85) : Color.gray.opacity(0.15))
        }
    }
    
    private func foreground(for isSelected: Bool) -> Color {
        switch backgroundStyle {
        case .none:
            return isSelected ? .black : .gray
        case .pill:
            return isSelected ? .white : .gray
        case .roundedRect:
            return isSelected ? .white : .gray
        }
    }

}

struct PillItemView: View {
    var title: String
    @Binding var isSelected: Bool

    var onSelectionChanged: ((Bool) -> Void)?   // returns the new state
    
    var body: some View {
        VStack(spacing: 4) {
            
            Text(title)
                .font(.custom(isSelected ? poppinsBold : poppinsMedium, size: 14))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.defaultTheme.opacity(0.85)
                                         : Color.gray.opacity(0.15))
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isSelected.toggle()
                        onSelectionChanged?(isSelected)
                    }
                }
        }
    }
}

