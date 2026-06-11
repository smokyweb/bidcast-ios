// USPSPackagePresets.swift
// BidCast
//
// Basecamp #9988324984 — USPS flat-rate package size presets.
// Defined once; consumed by CreateProductScreen, EditProductScreen /
// ListProductScreen (via DimensionsSection) and CreateShippingProfileScreen.

import Foundation
import SwiftUI

// MARK: - USPS Package Preset

/// A single USPS flat-rate size preset.
/// All dimension values are in inches.
struct USPSPackagePreset: Identifiable, Equatable {
    let id: String          // unique stable identifier (the label)
    let label: String       // display name shown in the picker
    let length: Double
    let width: Double
    let height: Double

    // Convenience: the unit string expected by the shipping-profile screen.
    static let unitLabel = "Inch"
}

// MARK: - Preset Catalogue

extension USPSPackagePreset {

    /// "Custom" sentinel — selecting this leaves fields untouched.
    static let custom = USPSPackagePreset(
        id: "custom",
        label: "Custom",
        length: 0, width: 0, height: 0
    )

    static let all: [USPSPackagePreset] = [
        custom,
        USPSPackagePreset(id: "flat_rate_envelope",
                          label: "USPS Flat Rate Envelope",
                          length: 12.5, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "window_flat_rate_envelope",
                          label: "USPS Window Flat Rate Envelope",
                          length: 12.5, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "small_flat_rate_envelope",
                          label: "USPS Small Flat Rate Envelope",
                          length: 10, width: 6, height: 0.5),
        USPSPackagePreset(id: "padded_flat_rate_envelope",
                          label: "USPS Padded Flat Rate Envelope",
                          length: 12.5, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "legal_flat_rate_envelope",
                          label: "USPS Legal Flat Rate Envelope",
                          length: 15, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "small_flat_rate_box",
                          label: "USPS Small Flat Rate Box",
                          length: 8.69, width: 5.44, height: 1.75),
        USPSPackagePreset(id: "medium_flat_rate_box_1",
                          label: "USPS Medium Flat Rate Box 1 (Top Loading)",
                          length: 11.25, width: 8.75, height: 6),
        USPSPackagePreset(id: "medium_flat_rate_box_2",
                          label: "USPS Medium Flat Rate Box 2 (Side Loading)",
                          length: 14, width: 12, height: 3.5),
        USPSPackagePreset(id: "large_flat_rate_box",
                          label: "USPS Large Flat Rate Box",
                          length: 12.25, width: 12.25, height: 6),
    ]
}

// MARK: - Formatted dimension string (for display in menu label)

extension USPSPackagePreset {
    /// "12.5 × 9.5 × 0.5 in" — appended to non-custom menu items.
    var dimensionSummary: String {
        func fmt(_ v: Double) -> String {
            v.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", v)
                : String(format: "%g", v)
        }
        return "\(fmt(length)) × \(fmt(width)) × \(fmt(height)) in"
    }

    /// Full menu label: "USPS Flat Rate Envelope  12.5 × 9.5 × 0.5 in"
    var menuLabel: String {
        self == .custom ? label : "\(label)  \(dimensionSummary)"
    }
}

// MARK: - Picker View (reusable)

/// A compact Menu-style picker that sits above dimension fields.
/// Selecting a non-Custom preset calls `onSelect` with the chosen preset.
/// Selecting Custom calls `onSelect(.custom)` — callers must ignore it to
/// leave existing values untouched.
struct USPSPackagePresetPicker: View {
    @Binding var selectedPreset: USPSPackagePreset

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "shippingbox")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.defaultTheme)

            Text("USPS Package Preset")
                .font(.custom(poppinsMedium, size: 13))
                .foregroundColor(.darkGray)

            Spacer()

            Menu {
                ForEach(USPSPackagePreset.all) { preset in
                    Button(preset.menuLabel) {
                        selectedPreset = preset
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedPreset.label)
                        .font(.custom(poppinsMedium, size: 13))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.defaultTheme.opacity(0.04))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.defaultTheme.opacity(0.15), lineWidth: 1)
        )
    }
}
