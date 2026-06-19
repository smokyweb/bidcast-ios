// RandomizerTemplateBuilderView.swift
// BidCast — Create/edit a randomizer template: name, type, entry_cost, slot count, slot grid
// Build 313 / 2026-05-26

import SwiftUI
import AlertToast
import SVProgressHUD

struct RandomizerTemplateBuilderView: View {

    @Environment(\.dismiss) var dismiss

    // nil = create mode; non-nil = edit mode
    let editingTemplate: RandomizerTemplate?
    var allowsProductMapping: Bool = false

    // Form state
    @State private var name: String = ""
    @State private var selectedType: RandomizerType = .productRaffle
    @State private var isPaidEntry: Bool = false
    @State private var entryCost: String = ""
    @State private var slotCount: Int = 6
    @State private var slots: [RandomizerSlot] = []

    // UI state
    @State private var editingSlotIndex: Int? = nil
    @State private var showingSlotEditor = false
    @State private var availableProducts: [SlotProduct] = []
    @State private var isLoading = false
    @State private var hudMsg = ""
    @State private var showHud = false
    @State private var isSaving = false
    @State private var showNameError = false

    // Buyer Raffle: single prize product (mirrored to all slots)
    // Basecamp #9955991396 — hide per-slot picker, show one prize picker
    @State private var buyerRaffleProductId: Int? = nil
    @State private var showingPrizeProductPicker = false

    private let minSlots = 2
    private let maxSlots = 12

    var isEditMode: Bool { editingTemplate != nil }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        nameSectionView
                        typeSectionView

                        if allowsProductMapping && selectedType == .buyerRaffle {
                            buyerRafflePrizeSection
                        }

                        if selectedType == .buyerRaffle || selectedType == .productRaffle || selectedType == .blindProductRaffle {
                            pricingSectionView
                        }

                        slotCountSectionView
                        slotGridSection
                    }
                    .padding(16)
                }

                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.custom(poppinsBold, size: 15))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                    }

                    Button {
                        saveTemplate()
                    } label: {
                        Text("Save Template")
                            .font(.custom(poppinsBold, size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(isSaving ? Color.gray.opacity(0.5) : Color.defaultTheme)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .disabled(isSaving)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.backGround)
            }
            .background(Color.backGround)
            .navigationTitle(isEditMode ? "Edit Randomizer Template" : "New Randomizer Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.gray)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .font(.custom(poppinsBold, size: 15))
                    .foregroundColor(isSaving ? .gray : .white)
                    .disabled(isSaving)
                }
            }
            .sheet(isPresented: $showingSlotEditor) {
                if let idx = editingSlotIndex, idx < slots.count {
                    SlotEditorSheet(
                        slot: $slots[idx],
                        availableProducts: availableProducts,
                        hideProductPicker: selectedType == .buyerRaffle || !allowsProductMapping
                    )
                }
            }
            // Prize product picker for Buyer Raffle (Basecamp #9955991396)
            .sheet(isPresented: $showingPrizeProductPicker) {
                ProductPickerSheet(
                    selectedProductId: $buyerRaffleProductId,
                    availableProducts: availableProducts
                )
            }
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
            }
        }
        .onAppear { setup() }
        // Mirror prize product whenever it changes (picker selection)
        .onChange(of: buyerRaffleProductId) { _ in
            mirrorBuyerRaffleProduct()
        }
        // Re-mirror when switching type TO buyer_raffle
        .onChange(of: selectedType) { _ in
            if selectedType == .buyerRaffle {
                mirrorBuyerRaffleProduct()
            }
        }
    }

    // MARK: - Name Section
    private var nameSectionView: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Template name")
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)

                TextField("e.g. Saturday Night Raffle", text: $name)
                    .font(.custom(poppinsRegular, size: 15))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                    .onChange(of: name) { _ in
                        if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                            showNameError = false
                        }
                    }

                if showNameError {
                    Text("Template name is required.")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - Type Picker
    private var typeSectionView: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Type")
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)

                ForEach(RandomizerType.allCases) { type in
                    typeOptionRow(for: type)
                }
            }
        }
    }

    private func typeOptionRow(for type: RandomizerType) -> some View {
        Button {
            selectedType = type
        } label: {
            HStack(alignment: .center, spacing: 12) {
                typeOptionText(for: type)
                Spacer()
                typeSelectionIndicator(isSelected: selectedType == type)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedType == type ? Color.defaultTheme : Color.primary, lineWidth: selectedType == type ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func typeSelectionIndicator(isSelected: Bool) -> some View {
        Circle()
            .fill(isSelected ? Color.defaultTheme : Color.white)
            .frame(width: 18, height: 18)
            .overlay(Circle().stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.55), lineWidth: 1.5))
            .overlay {
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 7, height: 7)
                }
            }
    }

    private func typeOptionText(for type: RandomizerType) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(typeOptionTitle(type))
                .font(.custom(poppinsBold, size: 13))
                .foregroundColor(.primary)
            Text(typeOptionDescription(type))
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func typeOptionTitle(_ type: RandomizerType) -> String {
        switch type {
        case .productRaffle: return "🎁 Product Raffle"
        case .blindProductRaffle: return "🙈 Blind Product Raffle"
        case .buyerRaffle: return "👥 Buyer Raffle"
        case .wheelBinAuction: return "🔨 Wheel BIN / Auction"
        }
    }

    private func typeOptionDescription(_ type: RandomizerType) -> String {
        switch type {
        case .productRaffle:
            return "Each slot shows a product. Winner gets that product."
        case .blindProductRaffle:
            return "Products hidden from buyers — icons only until the winner is revealed."
        case .buyerRaffle:
            return "Slots are buyers. One center product goes to the winner."
        case .wheelBinAuction:
            return "Wheel spins alongside the existing auction / Buy-It-Now flow for visual flair."
        }
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Pricing
    private var pricingSectionView: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Pricing")
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    pricingOption(title: "Free", isSelected: !isPaidEntry) {
                        isPaidEntry = false
                        entryCost = ""
                    }
                    pricingOption(title: "Paid", isSelected: isPaidEntry) {
                        isPaidEntry = true
                    }
                }

                if isPaidEntry {
                    HStack {
                        Text("$")
                            .font(.custom(poppinsBold, size: 16))
                            .foregroundColor(.gray)
                            .padding(.leading, 12)

                        TextField("0.00", text: $entryCost)
                            .font(.custom(poppinsRegular, size: 15))
                            .keyboardType(.decimalPad)
                            .padding(.vertical, 12)
                            .padding(.trailing, 12)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                }
            }
        }
    }

    private func pricingOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                typeSelectionIndicator(isSelected: isSelected)
                Text(title)
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.primary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.defaultTheme : Color.primary, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Slot Count
    private var slotCountSectionView: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of slots")
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)

                Menu {
                    ForEach(minSlots...maxSlots, id: \.self) { value in
                        Button("\(value) slots") {
                            slotCount = value
                            syncSlots()
                        }
                    }
                } label: {
                    HStack {
                        Text("\(slotCount) slots")
                            .font(.custom(poppinsRegular, size: 15))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Slot Grid
    private var slotGridSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Slots")
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)

                ForEach(slots.indices, id: \.self) { idx in
                    SlotCardView(
                        slot: slots[idx],
                        position: idx,
                        product: selectedType == .buyerRaffle || !allowsProductMapping ? nil : productForSlot(slots[idx]),
                        isBuyerSlot: selectedType == .buyerRaffle
                    )
                    .onTapGesture {
                        editingSlotIndex = idx
                        showingSlotEditor = true
                    }
                }
            }
        }
    }

    // MARK: - Buyer Raffle helpers (Basecamp #9955991396)

    /// Mirror the single prize product onto every slot. Only acts when type == .buyerRaffle.
    private func mirrorBuyerRaffleProduct() {
        guard allowsProductMapping, selectedType == .buyerRaffle else { return }
        for i in slots.indices {
            slots[i].product_id = buyerRaffleProductId
        }
    }

    /// Template-level prize product row shown only for buyer_raffle.
    private var buyerRafflePrizeSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Prize Product")
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)

                Text("One product for the whole raffle — goes to whichever buyer-slot wins.")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)

                Button {
                    showingPrizeProductPicker = true
                } label: {
                    HStack(spacing: 12) {
                        if let pid = buyerRaffleProductId,
                           let prod = availableProducts.first(where: { $0.id == pid }) {
                            AsyncImage(url: prod.thumbnailURL) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.15)
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                            .clipped()

                            VStack(alignment: .leading, spacing: 2) {
                                Text(prod.title ?? "Product #\(pid)")
                                    .font(.custom(poppinsBold, size: 13))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                if let price = prod.pricing {
                                    Text("$\(price)")
                                        .font(.custom(poppinsRegular, size: 11))
                                        .foregroundColor(.gray)
                                }
                            }
                        } else {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 20))
                                .foregroundColor(.defaultTheme)
                                .frame(width: 40, height: 40)

                            Text("Select prize product")
                                .font(.custom(poppinsRegular, size: 14))
                                .foregroundColor(.defaultTheme)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private func productForSlot(_ slot: RandomizerSlot) -> SlotProduct? {
        guard let pid = slot.product_id else { return nil }
        return availableProducts.first(where: { $0.id == pid })
    }

    private func setup() {
        // Prefill from editing template
        if let t = editingTemplate {
            name = t.name
            selectedType = t.randomizerType
            slotCount = t.slot_count
            isPaidEntry = (t.entry_cost ?? 0) > 0
            entryCost = t.entry_cost.map { $0 > 0 ? String(format: "%.2f", $0) : "" } ?? ""
            if let existingSlots = t.slots, !existingSlots.isEmpty {
                slots = existingSlots
            } else {
                generateDefaultSlots()
            }
            // For buyer_raffle edit: prefer the template-level prize_product_id
            // (#9960173707 Phase 4), fall back to slot[0].product_id for older templates.
            if t.randomizerType == .buyerRaffle {
                buyerRaffleProductId = t.prize_product_id ?? t.slots?.first?.product_id
            }
        } else {
            generateDefaultSlots()
        }

        guard allowsProductMapping else { return }

        Task {
            do {
                availableProducts = try await RandomizerService.shared.listSellerProducts()
            } catch {
                print("Could not load randomizer products: \(error)")
            }
        }
    }

    private func generateDefaultSlots() {
        let colors = RandomizerSlotColor.allCases
        slots = (0..<slotCount).map { idx in
            RandomizerSlot(
                position: idx,
                color: colors[idx % colors.count].rawValue,
                icon: RandomizerSlotIcon.allCases[idx % RandomizerSlotIcon.allCases.count].rawValue
            )
        }
    }

    private func syncSlots() {
        let colors = RandomizerSlotColor.allCases
        let current = slots.count

        if slotCount > current {
            // Add new slots
            for i in current..<slotCount {
                slots.append(RandomizerSlot(
                    position: i,
                    color: colors[i % colors.count].rawValue,
                    icon: RandomizerSlotIcon.allCases[i % RandomizerSlotIcon.allCases.count].rawValue
                ))
            }
        } else if slotCount < current {
            slots = Array(slots.prefix(slotCount))
        }

        // Re-index positions
        for i in slots.indices { slots[i].position = i }

        // Mirror prize product when slot count changes in buyer_raffle mode
        if allowsProductMapping && selectedType == .buyerRaffle {
            mirrorBuyerRaffleProduct()
        }
    }

    private func saveTemplate() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            showNameError = true
            hudMsg = "Please enter a template name"
            showHud = true
            return
        }
        showNameError = false
        let cost = isPaidEntry ? Double(entryCost.trimmingCharacters(in: .whitespaces)) : 0
        if isPaidEntry && (cost ?? 0) <= 0 {
            hudMsg = "Please enter an entry cost for paid randomizers"
            showHud = true
            return
        }

        // Mirror prize product to all slots before building the save payload
        if allowsProductMapping && selectedType == .buyerRaffle {
            mirrorBuyerRaffleProduct()
        }

        isSaving = true
        let shouldPreserveExistingProductMapping = !allowsProductMapping && editingTemplate != nil
        let requestSlots = slots.map { s in
            RandomizerSlotRequest(
                position: s.position,
                color: s.color,
                icon: s.icon,
                image: s.image,
                product_id: (allowsProductMapping || shouldPreserveExistingProductMapping) ? s.product_id : nil
            )
        }
        // #9960173707 Phase 4: send the buyer_raffle prize as the template-level field.
        let prizeId: Int?
        if allowsProductMapping && selectedType == .buyerRaffle {
            prizeId = buyerRaffleProductId
        } else if shouldPreserveExistingProductMapping {
            prizeId = editingTemplate?.prize_product_id
        } else {
            prizeId = nil
        }
        let body = RandomizerTemplateRequest(
            name: trimmedName,
            type: selectedType.rawValue,
            entry_cost: cost,
            prize_product_id: prizeId,
            slot_count: slotCount,
            slots: requestSlots
        )

        Task {
            do {
                if let id = editingTemplate?.id {
                    _ = try await RandomizerService.shared.updateTemplate(id: id, body: body)
                } else {
                    _ = try await RandomizerService.shared.createTemplate(body)
                }
                dismiss()
            } catch {
                hudMsg = "Save failed: \(error.localizedDescription)"
                showHud = true
            }
            isSaving = false
        }
    }
}

// MARK: - Slot Card
struct SlotCardView: View {
    let slot: RandomizerSlot
    let position: Int
    let product: SlotProduct?
    /// When true, label shows "Buyer N" and product overlay is hidden (buyer_raffle mode)
    var isBuyerSlot: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Text("\(position + 1)")
                .font(.custom(poppinsBold, size: 13))
                .foregroundColor(.gray)
                .frame(width: 22)

            Circle()
                .fill(Color(hex: slot.color))
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(Color.white, lineWidth: 3))

            Text((slot.icon?.isEmpty == false) ? slot.icon! : "+")
                .font(.system(size: 16))
                .frame(width: 32, height: 32)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))

            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.gray.opacity(0.2), lineWidth: 1))

                if let img = slot.image, !img.isEmpty, let url = URL(string: img) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 32, height: 32)

            Text(productTitle)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                .padding(.horizontal, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 58)
        .background(Color.backGround.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.08), lineWidth: 1))
    }

    private var productTitle: String {
        if isBuyerSlot {
            return "Buyer slot"
        }
        if let title = product?.title, !title.isEmpty {
            return title
        }
        return "No product"
    }
}

// MARK: - ProductPickerSheet
// Basecamp #9955991396 — standalone product picker for buyer_raffle prize product

struct ProductPickerSheet: View {

    @Environment(\.dismiss) var dismiss
    @Binding var selectedProductId: Int?
    let availableProducts: [SlotProduct]

    var body: some View {
        NavigationView {
            List {
                // None option
                Button {
                    selectedProductId = nil
                    dismiss()
                } label: {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "minus.circle").foregroundColor(.gray))
                        Text("None")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedProductId == nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.defaultTheme)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)

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
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(availableProducts) { product in
                        Button {
                            selectedProductId = product.id
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                AsyncImage(url: product.thumbnailURL) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.15)
                                }
                                .frame(width: 44, height: 44)
                                .cornerRadius(8)
                                .clipped()

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
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Select Prize Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.defaultTheme)
                }
            }
        }
    }
}
