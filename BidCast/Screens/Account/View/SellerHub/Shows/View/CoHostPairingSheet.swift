//
//  CoHostPairingSheet.swift
//  BidCast
//
//  Basecamp #9934001770 (2026-05-27): co-host pairing sheet for the host
//  side. Generates a 6-character pairing code via POST /api/product/co-host/pair
//  and displays it for the second device to enter on /app/co-host-join.
//

import SwiftUI

struct CoHostPairingSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    let scheduleShowId: Int

    @State private var pairingCode: String = "——————"
    @State private var pairingId: Int? = nil
    @State private var expiresAt: String? = nil
    @State private var statusMessage: String = ""
    @State private var statusColor: Color = .secondary
    @State private var isGenerating: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Pair Second Device")
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.black)
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Text("Open Bidcast on your second device, sign in with the same seller account, and enter this 6-character code to pair it as a co-host for the current show.")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            // Code box
            VStack(spacing: 8) {
                Text(pairingCode)
                    .font(.system(size: 36, weight: .heavy, design: .monospaced))
                    .foregroundColor(.blue)
                    .tracking(6)
                if let exp = expiresAt {
                    Text(exp)
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.blue.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.blue.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue.opacity(0.3), lineWidth: 2))
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Action buttons
            HStack(spacing: 8) {
                Button(action: { Task { await generateCode() } }) {
                    HStack {
                        if isGenerating { ProgressView().tint(.white) }
                        Text(isGenerating ? "Generating…" : "Generate new code")
                            .font(.custom(poppinsSemiBold, size: 14))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(24)
                }
                .disabled(isGenerating)

                if let _ = pairingId {
                    Button(action: { Task { await revokeCode() } }) {
                        Text("Revoke")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(24)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.custom(poppinsRegular, size: 11))
                    .foregroundColor(statusColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
            }

            Spacer()
        }
        .onAppear { Task { await generateCode() } }
    }

    private func generateCode() async {
        await MainActor.run {
            isGenerating = true
            statusMessage = "Generating code…"
            statusColor = .secondary
        }
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/co-host/pair") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["schedule_show_id": scheduleShowId])
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            let status = (json?["status"] as? String) ?? ""
            await MainActor.run {
                isGenerating = false
                if status == "success", let row = json?["data"] as? [String: Any] {
                    pairingCode = (row["pairing_code"] as? String) ?? "——————"
                    pairingId = row["id"] as? Int
                    if let exp = row["expires_at"] as? String {
                        expiresAt = "Expires at \(exp.prefix(16))"
                    }
                    statusMessage = "Share this code with your second device."
                    statusColor = .green
                } else {
                    statusMessage = (json?["message"] as? String) ?? "Could not generate code."
                    statusColor = .red
                }
            }
        } catch {
            await MainActor.run {
                isGenerating = false
                statusMessage = "Network error."
                statusColor = .red
            }
        }
    }

    private func revokeCode() async {
        guard let id = pairingId else { return }
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/co-host/\(id)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            _ = try await URLSession.shared.data(for: req)
            await MainActor.run {
                pairingCode = "——————"
                pairingId = nil
                expiresAt = nil
                statusMessage = "Pairing revoked."
                statusColor = .gray
            }
        } catch {
            await MainActor.run {
                statusMessage = "Could not revoke pairing."
                statusColor = .red
            }
        }
    }
}
