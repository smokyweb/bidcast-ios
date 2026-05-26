// RandomizerTemplatePickerSheet.swift
// BidCast — Show-create integration: pick a randomizer template to attach
// Build 313 / 2026-05-26

import SwiftUI
import AlertToast

struct RandomizerTemplatePickerSheet: View {

    @Environment(\.dismiss) var dismiss

    /// Currently selected template ID (nil = None)
    @Binding var selectedTemplateId: Int?

    @State private var templates: [RandomizerTemplate] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

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
            // "None" option — detach template
            Button {
                selectedTemplateId = nil
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
                Button {
                    selectedTemplateId = template.id
                } label: {
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
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
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
