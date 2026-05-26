// SlotEditorSheet.swift
// BidCast — Slot editor: 12-color swatch grid + 12-emoji grid + product picker
// Build 313 / 2026-05-26

import SwiftUI
import AlertToast

struct SlotEditorSheet: View {

    @Environment(\.dismiss) var dismiss
    @Binding var slot: RandomizerSlot

    /// Pass available seller products for the product picker
    let availableProducts: [SlotProduct]

    @State private var selectedColor: String
    @State private var selectedIcon: String?
    @State private var selectedProductId: Int?
    @State private var tab: SlotTab = .color

    init(slot: Binding<RandomizerSlot>, availableProducts: [SlotProduct]) {
        self._slot = slot
        self.availableProducts = availableProducts
        self._selectedColor = State(initialValue: slot.wrappedValue.color)
        self._selectedIcon  = State(initialValue: slot.wrappedValue.icon)
        self._selectedProductId = State(initialValue: slot.wrappedValue.product_id)
    }

    enum SlotTab: String, CaseIterable {
        case color   = "Color"
        case icon    = "Icon"
        case product = "Product"
    }

    private let columns3 = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Preview stripe
                slotPreview

                // Tab picker
                Picker("Tab", selection: $tab) {
                    ForEach(SlotTab.allCases, id: \.self) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()

                // Tab content
                ScrollView {
                    switch tab {
                    case .color:
                        colorGrid
                    case .icon:
                        iconGrid
                    case .product:
                        productList
                    }
                }
            }
            .navigationTitle("Edit Slot \(slot.position + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        slot.color = selectedColor
                        slot.icon  = selectedIcon
                        slot.product_id = selectedProductId
                        dismiss()
                    }
                    .font(.custom(poppinsBold, size: 15))
                    .foregroundColor(.defaultTheme)
                }
            }
        }
    }

    // MARK: - Preview
    private var slotPreview: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: selectedColor))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(selectedIcon ?? "")
                        .font(.system(size: 28))
                )
                .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 4) {
                if let pid = selectedProductId,
                   let prod = availableProducts.first(where: { $0.id == pid }) {
                    Text(prod.title ?? "Product #\(pid)")
                        .font(.custom(poppinsBold, size: 14))
                    Text(prod.pricing.map { "$\($0)" } ?? "")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                } else {
                    Text("Slot \(slot.position + 1)")
                        .font(.custom(poppinsBold, size: 14))
                    Text("No product assigned")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Color Grid
    private var colorGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Color")
                .font(.custom(poppinsBold, size: 15))
                .padding(.horizontal, 16)
                .padding(.top, 16)

            LazyVGrid(columns: columns3, spacing: 14) {
                ForEach(RandomizerSlotColor.allCases) { sc in
                    Circle()
                        .fill(sc.color)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Group {
                                if selectedColor == sc.rawValue {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                        )
                        .shadow(color: sc.color.opacity(0.5), radius: 4)
                        .onTapGesture { selectedColor = sc.rawValue }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Icon Grid
    private var iconGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Icon")
                .font(.custom(poppinsBold, size: 15))
                .padding(.horizontal, 16)
                .padding(.top, 16)

            // "None" option
            Button {
                selectedIcon = nil
            } label: {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(Text("∅").font(.system(size: 22)))
                    Text("No Icon")
                        .font(.custom(poppinsRegular, size: 14))
                    Spacer()
                    if selectedIcon == nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.defaultTheme)
                    }
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)

            LazyVGrid(columns: columns3, spacing: 14) {
                ForEach(RandomizerSlotIcon.allCases) { si in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedIcon == si.rawValue
                              ? Color.defaultTheme.opacity(0.15)
                              : Color.gray.opacity(0.08))
                        .frame(height: 52)
                        .overlay(Text(si.rawValue).font(.system(size: 28)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedIcon == si.rawValue ? Color.defaultTheme : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture { selectedIcon = si.rawValue }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Product List
    private var productList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assign Product (optional)")
                .font(.custom(poppinsBold, size: 15))
                .padding(.horizontal, 16)
                .padding(.top, 16)

            // None option
            Button {
                selectedProductId = nil
            } label: {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "minus.circle").foregroundColor(.gray))
                    Text("None")
                        .font(.custom(poppinsRegular, size: 14))
                    Spacer()
                    if selectedProductId == nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.defaultTheme)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            Divider().padding(.horizontal, 16)

            if availableProducts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No products available.\nCreate products first in your inventory.")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                ForEach(availableProducts) { product in
                    Button {
                        selectedProductId = product.id
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: product.thumbnailURL) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.15)
                            }
                            .frame(width: 44, height: 44)
                            .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.title ?? "Unnamed Product")
                                    .font(.custom(poppinsBold, size: 13))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                if let price = product.pricing {
                                    Text("$\(price)")
                                        .font(.custom(poppinsRegular, size: 12))
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()

                            if selectedProductId == product.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.defaultTheme)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)

                    Divider().padding(.horizontal, 16)
                }
            }
        }
        .padding(.bottom, 40)
    }
}
