// RandomizerTemplatesView.swift
// BidCast — Seller template list with edit/delete/duplicate swipe actions + "+ New" button
// Build 313 / 2026-05-26

import SwiftUI
import AlertToast

struct RandomizerTemplatesView: View {

    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = RandomizerTemplatesViewModel()

    @State private var showingBuilder = false
    @State private var editingTemplate: RandomizerTemplate? = nil
    @State private var hudMsg = ""
    @State private var showHud = false
    @State private var showDeleteConfirm = false
    @State private var deletingTemplate: RandomizerTemplate? = nil

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                PrimaryHeader(
                    title: "Randomizer Templates",
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                    count: .constant(0)
                )
                HStack {
                    Spacer()
                    Button {
                        editingTemplate = nil
                        showingBuilder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.defaultTheme)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 8)
                }
            }

            if vm.isLoading && vm.templates.isEmpty {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .defaultTheme))
                Spacer()
            } else if vm.templates.isEmpty {
                emptyState
            } else {
                templateList
            }
        }
        .background(Color.backGround)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
        .onAppear { Task { await vm.loadTemplates() } }
        .toast(isPresenting: $showHud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .sheet(isPresented: $showingBuilder, onDismiss: {
            Task { await vm.loadTemplates() }
        }) {
            RandomizerTemplateBuilderView(editingTemplate: editingTemplate, allowsProductMapping: false)
        }
        .alert("Delete Template?", isPresented: $showDeleteConfirm, presenting: deletingTemplate) { tpl in
            Button("Delete", role: .destructive) {
                Task { await vm.deleteTemplate(tpl); hudMsg = "Template deleted"; showHud = true }
            }
            Button("Cancel", role: .cancel) {}
        } message: { tpl in
            Text("'\(tpl.name)' will be permanently deleted and all product reservations released.")
        }
    }

    // MARK: - Template List
    private var templateList: some View {
        List {
            ForEach(vm.templates) { template in
                TemplateRowView(template: template)
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deletingTemplate = template
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            editingTemplate = template
                            showingBuilder = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            Task {
                                guard let id = template.id else { return }
                                do {
                                    _ = try await RandomizerService.shared.duplicateTemplate(id: id)
                                    await vm.loadTemplates()
                                    hudMsg = "Template duplicated"
                                    showHud = true
                                } catch {
                                    hudMsg = "Duplicate failed: \(error.localizedDescription)"
                                    showHud = true
                                }
                            }
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        .tint(.orange)
                    }
            }
        }
        .listStyle(.plain)
        .refreshable { await vm.loadTemplates() }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "dice")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundColor(.defaultTheme.opacity(0.4))

            Text("No Templates Yet")
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)

            Text("Create a randomizer template to use\non your shows. Tap + to get started.")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Create First Template", isOutLine: false) {
                editingTemplate = nil
                showingBuilder = true
            }
            .padding(.horizontal, 40)
            Spacer()
        }
    }
}

// MARK: - Template Row
struct TemplateRowView: View {
    let template: RandomizerTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Color swatch strip from first 3 slots
                HStack(spacing: 3) {
                    ForEach((template.slots ?? []).prefix(6), id: \.localId) { slot in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: slot.color))
                            .frame(width: 12, height: 28)
                    }
                }
                .padding(.trailing, 4)

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.name)
                        .font(.custom(poppinsBold, size: 15))
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        Text(template.randomizerType.displayName)
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.defaultTheme)
                            .cornerRadius(8)

                        Text("\(template.slot_count) slots")
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)

                        if let cost = template.entry_cost, cost > 0 {
                            Text(String(format: "$%.2f entry", cost))
                                .font(.custom(poppinsRegular, size: 12))
                                .foregroundColor(.green)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.5))
                    .font(.system(size: 12))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - ViewModel
@MainActor
final class RandomizerTemplatesViewModel: ObservableObject {
    @Published var templates: [RandomizerTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func loadTemplates() async {
        isLoading = true
        do {
            templates = try await RandomizerService.shared.listTemplates()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteTemplate(_ template: RandomizerTemplate) async {
        guard let id = template.id else { return }
        do {
            try await RandomizerService.shared.deleteTemplate(id: id)
            templates.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
