// SlotEditorSheet.swift
// BidCast — Slot editor: 12-color swatch grid + 12-emoji grid + product picker
// Build 313 / 2026-05-26

import SwiftUI
import AlertToast
import PhotosUI

struct SlotEditorSheet: View {

    @Environment(\.dismiss) var dismiss
    @Binding var slot: RandomizerSlot

    /// Pass available seller products for the product picker
    let availableProducts: [SlotProduct]

    /// When true, the Product tab is hidden (buyer_raffle mode — Basecamp #9955991396)
    let hideProductPicker: Bool

    @State private var selectedColor: String
    @State private var selectedIcon: String?
    @State private var selectedProductId: Int?
    @State private var tab: SlotTab = .color

    // #9960173707 Phase 4: custom slot image
    @State private var selectedImageURL: String?
    @State private var photoItem: PhotosPickerItem?
    @State private var isUploadingImage = false
    @State private var uploadError: String?

    init(slot: Binding<RandomizerSlot>, availableProducts: [SlotProduct], hideProductPicker: Bool = false) {
        self._slot = slot
        self.availableProducts = availableProducts
        self.hideProductPicker = hideProductPicker
        self._selectedColor = State(initialValue: slot.wrappedValue.color)
        self._selectedIcon  = State(initialValue: slot.wrappedValue.icon)
        self._selectedProductId = State(initialValue: slot.wrappedValue.product_id)
        self._selectedImageURL = State(initialValue: slot.wrappedValue.image)
    }

    /// Tabs shown in the segmented control (Product tab hidden for buyer_raffle)
    private var visibleTabs: [SlotTab] {
        hideProductPicker ? [.color, .icon, .image] : SlotTab.allCases
    }

    enum SlotTab: String, CaseIterable {
        case color   = "Color"
        case icon    = "Icon"
        case image   = "Image"
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
                    ForEach(visibleTabs, id: \.self) { t in
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
                    case .image:
                        imagePickerSection
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
                        slot.image = selectedImageURL
                        slot.product_id = selectedProductId
                        dismiss()
                    }
                    .disabled(isUploadingImage)
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
                    Group {
                        // #9960173707 Phase 4: show custom image if set, else emoji icon
                        if let img = selectedImageURL, !img.isEmpty, let url = URL(string: img) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Text(selectedIcon ?? "").font(.system(size: 28))
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Text(selectedIcon ?? "").font(.system(size: 28))
                        }
                    }
                )
                .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 4) {
                if hideProductPicker {
                    Text("Slot \(slot.position + 1)")
                        .font(.custom(poppinsBold, size: 14))
                    Text("Appearance only")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                } else if let pid = selectedProductId,
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

    // MARK: - Image Picker (#9960173707 Phase 4)
    private var imagePickerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Custom Slot Image (optional)")
                .font(.custom(poppinsBold, size: 15))
                .padding(.horizontal, 16)
                .padding(.top, 16)

            Text("Add a custom image for this slot. Overrides the emoji icon on the wheel.")
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)

            if let img = selectedImageURL, !img.isEmpty, let url = URL(string: img) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(Color.gray.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            }

            HStack(spacing: 12) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    HStack {
                        if isUploadingImage {
                            ProgressView().padding(.trailing, 4)
                            Text("Uploading…")
                        } else {
                            Image(systemName: "photo.on.rectangle")
                            Text(selectedImageURL == nil ? "Choose Image" : "Replace Image")
                        }
                    }
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.defaultTheme)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isUploadingImage)

                if selectedImageURL != nil {
                    Button {
                        selectedImageURL = nil
                        photoItem = nil
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 48, height: 48)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isUploadingImage)
                }
            }
            .padding(.horizontal, 16)

            if let err = uploadError {
                Text(err)
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
            }

            Spacer().frame(height: 24)
        }
        .onChange(of: photoItem) { newItem in
            guard let newItem = newItem else { return }
            uploadError = nil
            isUploadingImage = true
            Task {
                do {
                    guard let data = try await newItem.loadTransferable(type: Data.self) else {
                        await MainActor.run { isUploadingImage = false; uploadError = "Could not read image." }
                        return
                    }
                    let url = try await RandomizerService.shared.uploadSlotImage(imageData: data)
                    await MainActor.run {
                        selectedImageURL = url
                        isUploadingImage = false
                    }
                } catch {
                    await MainActor.run {
                        isUploadingImage = false
                        uploadError = "Upload failed. Please try again."
                    }
                }
            }
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
