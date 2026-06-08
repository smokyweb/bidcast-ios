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

    // Form state
    @State private var name: String = ""
    @State private var selectedType: RandomizerType = .productRaffle
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

    // Buyer Raffle: single prize product (mirrored to all slots)
    // Basecamp #9955991396 — hide per-slot picker, show one prize picker
    @State private var buyerRaffleProductId: Int? = nil
    @State private var showingPrizeProductPicker = false

    private let minSlots = 2
    private let maxSlots = 12

    var isEditMode: Bool { editingTemplate != nil }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name
                    nameSectionView

                    // Type picker
                    typeSectionView

                    // Buyer Raffle: single prize product picker
                    // Basecamp #9955991396
                    if selectedType == .buyerRaffle {
                        buyerRafflePrizeSection
                    }

                    // Entry cost (shown for buyer_raffle and product_raffle)
                    if selectedType == .buyerRaffle || selectedType == .productRaffle {
                        entryCostSectionView
                    }

                    // Slot count stepper
                    slotCountSectionView

                    // Slot grid
                    slotGridSection
                }
                .padding(16)
            }
            .background(Color.backGround)
            .navigationTitle(isEditMode ? "Edit Template" : "New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Save" : "Create") {
                        saveTemplate()
                    }
                    .font(.custom(poppinsBold, size: 15))
                    .foregroundColor(isSaving ? .gray : .defaultTheme)
                    .disabled(isSaving || name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingSlotEditor) {
                if let idx = editingSlotIndex, idx < slots.count {
                    SlotEditorSheet(
                        slot: $slots[idx],
                        availableProducts: availableProducts,
                        hideProductPicker: selectedType == .buyerRaffle
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Template Name")
                .font(.custom(poppinsBold, size: 14))
                .foregroundColor(.primary)

            TextField("e.g. Summer Giveaway", text: $name)
                .font(.custom(poppinsRegular, size: 15))
                .padding(12)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - Type Picker
    private var typeSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Randomizer Type")
                .font(.custom(poppinsBold, size: 14))
                .foregroundColor(.primary)

            VStack(spacing: 0) {
                ForEach(RandomizerType.allCases) { type in
                    typeOptionRow(
                        for: type,
                        showsDivider: type != RandomizerType.allCases.last
                    )
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
        }
    }

    @ViewBuilder
    private func typeOptionRow(for type: RandomizerType, showsDivider: Bool) -> some View {
        Button {
            selectedType = type
        } label: {
            HStack(spacing: 12) {
                typeSelectionIndicator(isSelected: selectedType == type)
                typeOptionText(for: type)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)

        if showsDivider {
            Divider().padding(.horizontal, 14)
        }
    }

    private func typeSelectionIndicator(isSelected: Bool) -> some View {
        Circle()
            .fill(isSelected ? Color.defaultTheme : Color.clear)
            .frame(width: 18, height: 18)
            .overlay(Circle().stroke(Color.defaultTheme, lineWidth: 2))
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
            Text(type.displayName)
                .font(.custom(poppinsBold, size: 13))
                .foregroundColor(.primary)
            Text(type.description)
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.gray)
        }
    }

    // MARK: - Entry Cost
    private var entryCostSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Entry Cost (leave blank for free)")
                .font(.custom(poppinsBold, size: 14))
                .foregroundColor(.primary)

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
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
        }
    }

    // MARK: - Slot Count
    private var slotCountSectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Number of Slots")
                .font(.custom(poppinsBold, size: 14))
                .foregroundColor(.primary)

            HStack {
                Text("\(slotCount) slots")
                    .font(.custom(poppinsBold, size: 15))
                    .frame(minWidth: 80, alignment: .leading)

                Spacer()

                HStack(spacing: 0) {
                    Button {
                        guard slotCount > minSlots else { return }
                        slotCount -= 1
                        syncSlots()
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 44, height: 44)
                            .foregroundColor(slotCount > minSlots ? .defaultTheme : .gray)
                    }

                    Text("\(slotCount)")
                        .font(.custom(poppinsBold, size: 16))
                        .frame(width: 44)

                    Button {
                        guard slotCount < maxSlots else { return }
                        slotCount += 1
                        syncSlots()
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 44, height: 44)
                            .foregroundColor(slotCount < maxSlots ? .defaultTheme : .gray)
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
        }
    }

    // MARK: - Slot Grid
    private var slotGridSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Slots  — tap to customize")
                .font(.custom(poppinsBold, size: 14))
                .foregroundColor(.primary)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(slots.indices, id: \.self) { idx in
                    SlotCardView(
                        slot: slots[idx],
                        position: idx,
                        product: selectedType == .buyerRaffle ? nil : productForSlot(slots[idx]),
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
        guard selectedType == .buyerRaffle else { return }
        for i in slots.indices {
            slots[i].product_id = buyerRaffleProductId
        }
    }

    /// Template-level prize product row shown only for buyer_raffle.
    private var buyerRafflePrizeSection: some View {
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

        // Fetch products
        Task {
            do {
                availableProducts = try await RandomizerService.shared.listSellerProducts()
            } catch {
                print("⚠️ Could not load products: \(error)")
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
        if selectedType == .buyerRaffle {
            mirrorBuyerRaffleProduct()
        }
    }

    private func saveTemplate() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            hudMsg = "Please enter a template name"
            showHud = true
            return
        }

        // Mirror prize product to all slots before building the save payload
        if selectedType == .buyerRaffle {
            mirrorBuyerRaffleProduct()
        }

        isSaving = true
        let cost = Double(entryCost.trimmingCharacters(in: .whitespaces))
        let requestSlots = slots.map { s in
            RandomizerSlotRequest(position: s.position, color: s.color, icon: s.icon, image: s.image, product_id: s.product_id)
        }
        // #9960173707 Phase 4: send the buyer_raffle prize as the template-level field.
        let prizeId: Int? = (selectedType == .buyerRaffle) ? buyerRaffleProductId : nil
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
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: slot.color))
                    .frame(height: 64)

                // #9960173707 Phase 4: custom slot image fills the card when set.
                if let img = slot.image, !img.isEmpty, let url = URL(string: img) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                    .frame(height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(spacing: 2) {
                    if slot.image == nil || slot.image?.isEmpty == true, let icon = slot.icon {
                        Text(icon).font(.system(size: 24))
                    }
                    // Hide product name overlay for buyer_raffle (prize is shown at template level)
                    if !isBuyerSlot, let prod = product, let title = prod.title {
                        Text(title)
                            .font(.custom(poppinsRegular, size: 9))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                    }
                }
            }

            Text(isBuyerSlot ? "Buyer \(position + 1)" : "Slot \(position + 1)")
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.gray)
        }
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
