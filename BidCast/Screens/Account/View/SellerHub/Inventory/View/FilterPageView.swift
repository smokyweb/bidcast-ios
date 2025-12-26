//
//  FilterPageView.swift
//  BidCast
//
//  Created by JamTech on 04/12/25.
//

import SwiftUI
import SwiftUI

struct FilterPageView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Filter States
//    @State private var selectedCategories: Set<Int> = []
//    @State private var selectedConditions: Set<String> = []
//    @State private var selectedFormat: String = ""
    @State private var visibleFormat: String = ""
//    @State private var minPrice: Double = 100
//    @State private var maxPrice: Double = 10000
    @State private var isPriceExpanded: Bool = false
    @State private var isCategoryExpanded: Bool = false
    @State private var isConditionExpanded: Bool = false
    @State private var isFormatExpanded: Bool = false
    
    @Binding var selectedCategoryArr: [Int]
    @Binding var selectedConditionArr: [String]
    @Binding var minPriceVal: Double
    @Binding var maxPriceVal: Double
    @Binding var selectedFormat: String
    
    var apiCallClosure: (() -> Void)? = nil
    
    @Binding var categories: [CategoryDataModel]
    
    let conditions = ["New",
                      "Like New",
                      "Gently Loved",
                      "Well Loved",
                      "Other",
                      "Trending"]
    let formats = ["Price: Low to High", "Price: High to Low"]
    
    var hasActiveFilters: Bool {
        !selectedCategoryArr.isEmpty || !selectedConditionArr.isEmpty || selectedFormat != "" || minPriceVal != 100 || (maxPriceVal != 10000 )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.custom(poppinsBold, size: 16))
                        
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Filters")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    clearAllFilters()
                }) {
                    Text("Clear Filters")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(hasActiveFilters ? .blue : .gray)
                }
                .disabled(!hasActiveFilters)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            Divider()
            
            // MARK: - Filter Options
            ScrollView {
                VStack(spacing: 0) {
                    
                    // MARK: - Price Range
                    FilterSection(
                        title: "Price Range",
                        icon: "dollarsign.circle.fill",
                        isExpanded: $isPriceExpanded
                    ) {
                        VStack(spacing: 20) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Min Price")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text("$")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        TextField("0", value: $minPriceVal, format: .number)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .onChange(of: minPriceVal) { newValue in
                                                if newValue > maxPriceVal {
                                                    minPriceVal = maxPriceVal
                                                }
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                )
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Max Price")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text("$")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        TextField("1000", value: $maxPriceVal, format: .number)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .onChange(of: maxPriceVal) { newValue in
                                                if newValue < minPriceVal {
                                                    maxPriceVal = minPriceVal
                                                }
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray6))
                                )
                            }
//                            
//                            VStack(spacing: 8) {
//                                Text("Min: $\(Int(minPrice))")
//                                    .font(.system(size: 12, weight: .medium))
//                                    .foregroundColor(.secondary)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                Slider(value: $minPrice, in: 0...maxPrice, step: 10)
//                                    .tint(.blue)
//                                    .onChange(of: minPrice) { newValue in
//                                        if newValue > maxPrice {
//                                            minPrice = maxPrice
//                                        }
//                                    }
//                            }
//                            
//                            VStack(spacing: 8) {
//                                Text("Max: $\(Int(maxPrice))")
//                                    .font(.system(size: 12, weight: .medium))
//                                    .foregroundColor(.secondary)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                Slider(value: $maxPrice, in: 0...maxPrice, step: 10)
//                                    .tint(.blue)
//                                    .onChange(of: maxPrice) { newValue in
//                                        if newValue < minPrice {
//                                            maxPrice = minPrice
//                                        }
//                                    }
//                            }
                        }
                        .padding(16)
                    }
                    
                    // MARK: - Category
                    FilterSection(
                        title: "Category",
                        icon: "square.grid.2x2.fill",
                        isExpanded: $isCategoryExpanded
                    ) {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(categories, id: \.id) { category in
                                    CheckboxRow(
                                        title: category.name ?? "",
                                        isSelected: selectedCategoryArr.contains(category.id ?? -1)
                                    ) {
                                        if selectedCategoryArr.contains(category.id ?? -1) {
                                            selectedCategoryArr = selectedCategoryArr.filter({$0 != (category.id ?? -1)})
                                        } else {
                                            selectedCategoryArr.append(category.id ?? -1)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        }
                        .frame(maxHeight: 300)
                    }
                    
                    // MARK: - Condition
                    FilterSection(
                        title: "Condition",
                        icon: "star.fill",
                        isExpanded: $isConditionExpanded
                    ) {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(conditions, id: \.self) { condition in
                                    CheckboxRow(
                                        title: condition,
                                        isSelected: selectedConditionArr.contains(condition)
                                    ) {
                                        if selectedConditionArr.contains(condition) {
                                            selectedConditionArr = selectedConditionArr.filter({$0 != condition})
                                        } else {
                                            selectedConditionArr.append(condition)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        }
                        .frame(maxHeight: 300)
                    }
                    
                    // MARK: - Format
                    FilterSection(
                        title: "Sort By",
                        icon: "arrow.up.arrow.down",
                        isExpanded: $isFormatExpanded
                    ) {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(formats, id: \.self) { format in
                                    RadioRow(
                                        title: format,
                                        isSelected: visibleFormat == format
                                    ) {
                                        visibleFormat = format
                                        selectedFormat = format == "Price: Low to High" ? "asc" : "desc"
                                    }
                                }
                            }
                            .padding(16)
                        }
                        .frame(maxHeight: 300)
                    }
                }
            }
            
            // MARK: - Apply Button
            VStack(spacing: 0) {
                Divider()
                
                Button(action: {
                    // Apply filters
                    presentationMode.wrappedValue.dismiss()
                    if hasActiveFilters {
//                        if isPriceExpanded{
//                            minPriceVal = minPrice
//                            maxPriceVal = maxPrice
//                        }
//                        categoryArr = Array(selectedCategoryArr)
//                        conditionArr =  Array(selectedConditions)
//                        format = selectedFormat
                        apiCallClosure?()
                    }
                }) {
                    Text("Apply Filters")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.defaultTheme.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            print(selectedCategoryArr)
            visibleFormat = selectedFormat == "asc" ? "Price: Low to High" : "Price: High to Low"
//            selectedCategories = Set(categoryArr)
//            selectedConditions = Set(conditionArr)
//            minPrice = minPriceVal
//            maxPrice = maxPriceVal
//            selectedFormat = format
        }
    }
    
    func clearAllFilters() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedCategoryArr.removeAll()
            selectedConditionArr.removeAll()
            selectedFormat = ""
            visibleFormat = ""
            minPriceVal = 0
            maxPriceVal = 0
            
//            categoryArr = []
//            conditionArr = []
//            minPriceVal = 0.0
//            maxPriceVal = 0.0
//            selectedFormat = ""
        }
    }
}

// MARK: - Filter Section Component
struct FilterSection<Content: View>: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let content: Content
    
    init(title: String, icon: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.defaultThemeLight)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
            }
            
            if isExpanded {
                content
                    .background(Color(.systemBackground))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            Divider()
        }
    }
}

// MARK: - Checkbox Row Component
struct CheckboxRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.defaultTheme)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
}

// MARK: - Radio Row Component
struct RadioRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.defaultTheme)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
}
