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
                    SlotEditorSheet(slot: $slots[idx], availableProducts: availableProducts)
                }
            }
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
            }
        }
        .onAppear { setup() }
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
                    Button {
                        selectedType = type
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(selectedType == type ? Color.defaultTheme : Color.clear)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle().stroke(Color.defaultTheme, lineWidth: 2)
                                )
                                .overlay(
                                    Group {
                                        if selectedType == type {
                                            Circle().fill(Color.white).frame(width: 7, height: 7)
                                        }
                                    }
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.displayName)
                                    .font(.custom(poppinsBold, size: 13))
                                    .foregroundColor(.primary)
                                Text(type.description)
                                    .font(.custom(poppinsRegular, size: 11))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)

                    if type != RandomizerType.allCases.last {
                        Divider().padding(.horizontal, 14)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
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
                    SlotCardView(slot: slots[idx], position: idx, product: productForSlot(slots[idx]))
                        .onTapGesture {
                            editingSlotIndex = idx
                            showingSlotEditor = true
                        }
                }
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
            entryCost = t.entry_cost.map { $0 > 0 ? String(format: "%.2f", $0) : "" } ?? ""
            if let existingSlots = t.slots, !existingSlots.isEmpty {
                slots = existingSlots
            } else {
                generateDefaultSlots()
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
    }

    private func saveTemplate() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            hudMsg = "Please enter a template name"
            showHud = true
            return
        }

        isSaving = true
        let cost = Double(entryCost.trimmingCharacters(in: .whitespaces))
        let requestSlots = slots.map { s in
            RandomizerSlotRequest(position: s.position, color: s.color, icon: s.icon, product_id: s.product_id)
        }
        let body = RandomizerTemplateRequest(
            name: trimmedName,
            type: selectedType.rawValue,
            entry_cost: cost,
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

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: slot.color))
                    .frame(height: 64)

                VStack(spacing: 2) {
                    if let icon = slot.icon {
                        Text(icon).font(.system(size: 24))
                    }
                    if let prod = product, let title = prod.title {
                        Text(title)
                            .font(.custom(poppinsRegular, size: 9))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                    }
                }
            }

            Text("Slot \(position + 1)")
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.gray)
        }
    }
}
