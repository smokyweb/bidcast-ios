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

    @State private var attachedTemplates: [RandomizerTemplate] = []
    @State private var sellerTemplates: [RandomizerTemplate] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showBuilder = false
    @State private var builderTemplate: RandomizerTemplate? = nil
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
                NavigationLink(isActive: $showBuilder, destination: {
                    RandomizerTemplateBuilderView(
                        editingTemplate: builderTemplate,
                        allowsProductMapping: true,
                        showId: showId,
                        onSaved: { saved in
                            attachSavedShowTemplate(saved)
                        }
                    )
                        .onDisappear { loadData() }
                }, label: { EmptyView() })
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.defaultTheme)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        builderTemplate = nil
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
                _ = try await RandomizerService.shared.attachTemplate(showId: showId, templateId: templateId, copyForShow: true)
                loadData()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func openShowScopedProductMapper(_ template: RandomizerTemplate) {
        guard let templateId = template.id else { return }
        if template.show_scoped_show_id == showId {
            builderTemplate = template
            showBuilder = true
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
        let scopedId = try await RandomizerService.shared.attachTemplate(showId: showId, templateId: templateId, copyForShow: true) ?? templateId
        builderTemplate = try await RandomizerService.shared.getTemplate(id: scopedId)
        showBuilder = true
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
