// RandomizerTemplatePickerSheet.swift
// BidCast — Show-create integration: pick a randomizer template to attach
// Build 313 / 2026-05-26

import SwiftUI
import AlertToast

struct RandomizerTemplatePickerSheet: View {

    @Environment(\.dismiss) var dismiss

    /// Currently selected template ID (nil = None)
    @Binding var selectedTemplateId: Int?
    var allowsProductMapping: Bool = false
    var onTemplateSelected: ((RandomizerTemplate?) -> Void)? = nil

    @State private var templates: [RandomizerTemplate] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    // Basecamp #9929871140 / #9931107836 (2026-05-27 round 2): in-flow
    // template builder. Pushing onto navigation stack instead of opening
    // a separate screen keeps the show-create / live-show flow intact.
    @State private var showBuilder: Bool = false
    @State private var builderTemplate: RandomizerTemplate? = nil

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let err = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 36))
                            .foregroundColor(.orange)
                        Text(err)
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Retry") { loadTemplates() }
                            .foregroundColor(.defaultTheme)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    templateListView
                }
            }
            .navigationTitle("Randomizer Template")
            .navigationBarTitleDisplayMode(.inline)
            // Basecamp #9929871140 / #9931107836 (2026-05-27 round 2): inline
            // builder so the seller can create a template without leaving
            // the show-create / live flow.
            .background(
                NavigationLink(isActive: $showBuilder, destination: {
                    RandomizerTemplateBuilderView(editingTemplate: builderTemplate, allowsProductMapping: allowsProductMapping)
                        .onDisappear { loadTemplates() }
                }, label: { EmptyView() })
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.custom(poppinsBold, size: 15))
                        .foregroundColor(.defaultTheme)
                }
            }
        }
        .onAppear { loadTemplates() }
    }

    // MARK: - Template List
    private var templateListView: some View {
        List {
            // Basecamp #9929871140 / #9931107836 (2026-05-27 round 2):
            // always-visible create-new entry point.
            createNewRow

            // "None" option — detach template
            Button {
                selectedTemplateId = nil
                onTemplateSelected?(nil)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("None")
                            .font(.custom(poppinsBold, size: 14))
                            .foregroundColor(.primary)
                        Text("No randomizer for this show")
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if selectedTemplateId == nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.defaultTheme)
                    }
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)

            ForEach(templates) { template in
                HStack(spacing: 10) {
                    HStack(spacing: 10) {
                        // Color swatch strip
                        HStack(spacing: 2) {
                            ForEach((template.slots ?? []).prefix(4), id: \.localId) { slot in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hex: slot.color))
                                    .frame(width: 10, height: 32)
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.name)
                                .font(.custom(poppinsBold, size: 14))
                                .foregroundColor(.primary)

                            HStack(spacing: 6) {
                                Text(template.randomizerType.displayName)
                                    .font(.custom(poppinsRegular, size: 11))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.defaultTheme)
                                    .cornerRadius(6)

                                Text("\(template.slot_count) slots · \(template.formattedEntryCost)")
                                    .font(.custom(poppinsRegular, size: 11))
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()

                        if selectedTemplateId == template.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.defaultTheme)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTemplateId = template.id
                        onTemplateSelected?(template)
                    }

                    if allowsProductMapping {
                        Button {
                            builderTemplate = template
                            showBuilder = true
                        } label: {
                            Text(templateHasProducts(template) ? "Edit products" : "Add products")
                                .font(.custom(poppinsBold, size: 11))
                                .foregroundColor(.defaultTheme)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func templateHasProducts(_ template: RandomizerTemplate) -> Bool {
        if template.prize_product_id != nil { return true }
        return (template.slots ?? []).contains { $0.product_id != nil }
    }


    // Basecamp #9929871140 / #9931107836 (2026-05-27 round 2):
    // "+ Create new template" row at the top of the picker.
    @ViewBuilder
    private var createNewRow: some View {
        Button {
            builderTemplate = nil
            showBuilder = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.defaultTheme)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Build a new randomizer")
                        .font(.custom(poppinsBold, size: 14))
                        .foregroundColor(.primary)
                    Text(allowsProductMapping ? "Pick slot colors, icons, and products" : "Pick slot colors and icons")
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Load
    private func loadTemplates() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                templates = try await RandomizerService.shared.listTemplates()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct ShowRandomizersManagementSheet: View {

    @Environment(\.dismiss) var dismiss

    let showId: Int
    var autoOpenTemplateId: Int? = nil
    var onTemplateReady: ((RandomizerTemplate) -> Void)? = nil

    @State private var attachedTemplates: [RandomizerTemplate] = []
    @State private var sellerTemplates: [RandomizerTemplate] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showBuilder = false
    @State private var builderTemplate: RandomizerTemplate? = nil
    @State private var productMappingOnly = false
    @State private var showProductMapper = false
    @State private var mapperTemplate: RandomizerTemplate? = nil
    @State private var didAutoOpenTemplate = false

    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    attachedSection
                    availableSection
                }
            }
            .listStyle(.plain)
            .navigationTitle("Randomizers")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Group {
                    NavigationLink(isActive: $showBuilder, destination: {
                        RandomizerTemplateBuilderView(
                            editingTemplate: builderTemplate,
                            allowsProductMapping: true,
                            showId: showId,
                            productMappingOnly: productMappingOnly,
                            onSaved: { saved in
                                attachSavedShowTemplate(saved)
                            }
                        )
                            .onDisappear { loadData() }
                    }, label: { EmptyView() })

                    NavigationLink(isActive: $showProductMapper, destination: {
                        if let template = mapperTemplate {
                            RandomizerProductMappingView(
                                template: template,
                                showId: showId,
                                onSaved: { saved in
                                    attachSavedShowTemplate(saved)
                                }
                            )
                            .onDisappear { loadData() }
                        } else {
                            EmptyView()
                        }
                    }, label: { EmptyView() })
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.defaultTheme)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        builderTemplate = nil
                        productMappingOnly = false
                        showBuilder = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.defaultTheme)
                    }
                }
            }
        }
        .onAppear { loadData() }
    }

    @ViewBuilder
    private var attachedSection: some View {
        Section {
            if attachedTemplates.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("No randomizers added")
                        .font(.custom(poppinsBold, size: 14))
                    Text("Attach an existing randomizer or create a new one.")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(attachedTemplates) { template in
                    ShowRandomizerRow(
                        template: template,
                        isAttached: true,
                        onMapProducts: {
                            openShowScopedProductMapper(template)
                        },
                        action: { detach(template) }
                    )
                }
            }
        } header: {
            Text("Added To This Show")
        }
    }

    @ViewBuilder
    private var availableSection: some View {
        Section {
            Button {
                builderTemplate = nil
                productMappingOnly = false
                showBuilder = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.defaultTheme)
                    Text("Create new randomizer")
                        .font(.custom(poppinsBold, size: 14))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            if let errorMessage {
                Text(errorMessage)
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.red)
            }

            ForEach(sellerTemplates.filter { template in
                !attachedTemplates.contains(where: { $0.id == template.id })
            }) { template in
                ShowRandomizerRow(
                    template: template,
                    isAttached: false,
                    onMapProducts: {
                        openShowScopedProductMapper(template)
                    },
                    action: { attach(template) }
                )
            }
        } header: {
            Text("Available Templates")
        }
    }

    private func loadData() {
        guard showId > 0 else {
            errorMessage = "Show not found."
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        Task {
            do {
                async let attached = RandomizerService.shared.listShowTemplates(showId: showId)
                async let templates = RandomizerService.shared.listTemplates()
                attachedTemplates = try await attached
                sellerTemplates = try await templates
                if let autoOpenTemplateId, !didAutoOpenTemplate {
                    didAutoOpenTemplate = true
                    openShowScopedProductMapper(templateId: autoOpenTemplateId)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func attach(_ template: RandomizerTemplate) {
        guard let templateId = template.id else { return }
        openShowScopedProductMapper(templateId: templateId)
    }

    private func attachSavedShowTemplate(_ template: RandomizerTemplate) {
        guard let templateId = template.id else { return }
        Task {
            do {
                let refreshed = try await RandomizerService.shared.getTemplate(id: templateId)
                loadData()
                onTemplateReady?(refreshed)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func openShowScopedProductMapper(_ template: RandomizerTemplate) {
        guard let templateId = template.id else { return }
        if template.show_scoped_show_id == showId {
            mapperTemplate = template
            showProductMapper = true
            return
        }

        Task {
            do {
                try await prepareAndOpenShowScopedTemplate(templateId: templateId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func openShowScopedProductMapper(templateId: Int) {
        guard templateId > 0 else { return }
        Task {
            do {
                try await prepareAndOpenShowScopedTemplate(templateId: templateId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func prepareAndOpenShowScopedTemplate(templateId: Int) async throws {
        guard let scopedId = try await RandomizerService.shared.attachTemplate(showId: showId, templateId: templateId, copyForShow: true) else {
            throw NSError(
                domain: "Randomizer",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Could not create a show-only copy of this randomizer."]
            )
        }
        let scopedTemplate = try await RandomizerService.shared.getTemplate(id: scopedId)
        if scopedTemplate.id == templateId && scopedTemplate.show_scoped_show_id != showId {
            throw NSError(
                domain: "Randomizer",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Could not create a show-only copy of this randomizer."]
            )
        }
        mapperTemplate = scopedTemplate
        showProductMapper = true
        loadData()
    }

    private func detach(_ template: RandomizerTemplate) {
        guard let templateId = template.id else { return }
        Task {
            do {
                try await RandomizerService.shared.detachOneTemplate(showId: showId, templateId: templateId)
                loadData()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

private struct RandomizerProductMappingView: View {
    @Environment(\.dismiss) private var dismiss

    let template: RandomizerTemplate
    let showId: Int
    let onSaved: ((RandomizerTemplate) -> Void)?

    @State private var availableProducts: [SlotProduct] = []
    @State private var slots: [RandomizerSlot] = []
    @State private var prizeProductId: Int? = nil
    @State private var pickerSlotIndex: Int? = nil
    @State private var showPrizePicker = false
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    private var selectedType: RandomizerType {
        template.randomizerType
    }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(template.name)
                                .font(.custom(poppinsBold, size: 15))
                            Text("Choose products for this show only. These products will not be saved back to the master template.")
                                .font(.custom(poppinsRegular, size: 12))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 6)
                    }

                    if selectedType == .buyerRaffle {
                        Section("Prize Product") {
                            productPickerRow(
                                title: productTitle(for: prizeProductId) ?? "Select prize product",
                                subtitle: prizeProductId == nil ? "Required before starting this randomizer" : nil
                            ) {
                                showPrizePicker = true
                            }
                        }
                    } else {
                        Section("Slot Products") {
                            ForEach(slots.indices, id: \.self) { idx in
                                productPickerRow(
                                    title: "Slot \(idx + 1)",
                                    subtitle: productTitle(for: slots[idx].product_id) ?? "No product selected"
                                ) {
                                    pickerSlotIndex = idx
                                }
                            }
                        }
                    }

                    if availableProducts.isEmpty {
                        Section {
                            Text("No inventory products with quantity greater than 0 are available.")
                                .font(.custom(poppinsRegular, size: 13))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        }
                    }

                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .font(.custom(poppinsRegular, size: 12))
                                .foregroundColor(.red)
                        }
                    }
                }
                .listStyle(.plain)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .font(.custom(poppinsBold, size: 15))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.25), lineWidth: 1))

                Button(isSaving ? "Saving..." : "Save Products") {
                    saveProducts()
                }
                .font(.custom(poppinsBold, size: 15))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(isSaving || isLoading ? Color.gray.opacity(0.5) : Color.defaultTheme)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(isSaving || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.backGround)
        }
        .background(Color.backGround)
        .navigationTitle("Add Products")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadProducts() }
        .sheet(isPresented: Binding(
            get: { pickerSlotIndex != nil },
            set: { if !$0 { pickerSlotIndex = nil } }
        )) {
            if let idx = pickerSlotIndex {
                RandomizerInventoryProductPickerSheet(
                    title: "Select Product",
                    selectedProductId: Binding(
                        get: { idx < slots.count ? slots[idx].product_id : nil },
                        set: { newValue in
                            guard idx < slots.count else { return }
                            slots[idx].product_id = newValue
                        }
                    ),
                    availableProducts: availableProducts
                )
            }
        }
        .sheet(isPresented: $showPrizePicker) {
            RandomizerInventoryProductPickerSheet(
                title: "Select Prize Product",
                selectedProductId: $prizeProductId,
                availableProducts: availableProducts
            )
        }
    }

    private func productPickerRow(title: String, subtitle: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.defaultTheme.opacity(0.08))
                    .frame(width: 44, height: 44)
                    .overlay(Image(systemName: "shippingbox").foregroundColor(.defaultTheme))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom(poppinsBold, size: 13))
                        .foregroundColor(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func loadProducts() {
        guard isLoading else { return }
        slots = normalizedSlots(from: template)
        prizeProductId = template.prize_product_id ?? template.slots?.first?.product_id
        Task {
            do {
                availableProducts = try await RandomizerService.shared.listSellerProducts()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func normalizedSlots(from template: RandomizerTemplate) -> [RandomizerSlot] {
        if let existing = template.slots, !existing.isEmpty {
            return existing.enumerated().map { idx, slot in
                var updated = slot
                updated.position = idx
                return updated
            }
        }
        let colors = RandomizerSlotColor.allCases
        return (0..<max(2, template.slot_count)).map { idx in
            RandomizerSlot(
                position: idx,
                color: colors[idx % colors.count].rawValue,
                icon: RandomizerSlotIcon.allCases[idx % RandomizerSlotIcon.allCases.count].rawValue
            )
        }
    }

    private func productTitle(for productId: Int?) -> String? {
        guard let productId else { return nil }
        return availableProducts.first(where: { $0.id == productId })?.title
    }

    private func saveProducts() {
        guard let templateId = template.id else { return }
        if selectedType == .buyerRaffle && prizeProductId == nil {
            errorMessage = "Select a prize product for buyer raffle."
            return
        }

        isSaving = true
        errorMessage = nil

        var requestSlots = slots.enumerated().map { idx, slot in
            RandomizerSlotRequest(
                position: idx,
                color: slot.color,
                icon: slot.icon,
                image: slot.image,
                product_id: selectedType == .buyerRaffle ? prizeProductId : slot.product_id
            )
        }

        if requestSlots.isEmpty {
            requestSlots = normalizedSlots(from: template).enumerated().map { idx, slot in
                RandomizerSlotRequest(
                    position: idx,
                    color: slot.color,
                    icon: slot.icon,
                    image: slot.image,
                    product_id: selectedType == .buyerRaffle ? prizeProductId : slot.product_id
                )
            }
        }

        let body = RandomizerTemplateRequest(
            name: template.name,
            type: template.type,
            entry_cost: template.entry_cost,
            prize_product_id: selectedType == .buyerRaffle ? prizeProductId : nil,
            slot_count: max(2, template.slot_count),
            slots: requestSlots,
            show_id: showId,
            is_show_copy: true
        )

        Task {
            do {
                let saved = try await RandomizerService.shared.updateTemplate(id: templateId, body: body)
                onSaved?(saved)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }
}

private struct RandomizerInventoryProductPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    @Binding var selectedProductId: Int?
    let availableProducts: [SlotProduct]

    var body: some View {
        NavigationView {
            List {
                Button {
                    selectedProductId = nil
                    dismiss()
                } label: {
                    productRow(title: "No product", subtitle: "Leave empty", isSelected: selectedProductId == nil, imageURL: nil)
                }
                .buttonStyle(.plain)

                ForEach(availableProducts) { product in
                    Button {
                        selectedProductId = product.id
                        dismiss()
                    } label: {
                        productRow(
                            title: product.title ?? "Unnamed Product",
                            subtitle: "Available: \(product.availableQuantityValue)",
                            isSelected: selectedProductId == product.id,
                            imageURL: product.thumbnailURL
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.defaultTheme)
                }
            }
        }
    }

    private func productRow(title: String, subtitle: String, isSelected: Bool, imageURL: URL?) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: imageURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.15)
            }
            .frame(width: 44, height: 44)
            .cornerRadius(8)
            .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom(poppinsBold, size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.defaultTheme)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct ShowRandomizerRow: View {
    let template: RandomizerTemplate
    let isAttached: Bool
    let onMapProducts: () -> Void
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 2) {
                ForEach((template.slots ?? []).prefix(4), id: \.localId) { slot in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: slot.color))
                        .frame(width: 10, height: 32)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(template.name)
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("\(template.randomizerType.displayName) · \(template.slot_count) slots · \(template.formattedEntryCost)")
                    .font(.custom(poppinsRegular, size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Button(templateHasProducts ? "Edit products" : "Add products") {
                onMapProducts()
            }
            .font(.custom(poppinsBold, size: 11))
            .foregroundColor(.defaultTheme)

            Button(isAttached ? "Remove" : "Add") {
                action()
            }
            .font(.custom(poppinsBold, size: 12))
            .foregroundColor(isAttached ? .red : .defaultTheme)
        }
        .padding(.vertical, 5)
    }

    private var templateHasProducts: Bool {
        if template.prize_product_id != nil { return true }
        return (template.slots ?? []).contains { $0.product_id != nil }
    }
}
