//
//  InquiryInboxViewModel.swift
//  BidCast
//
//  ObservableObject ViewModel for InquiryInboxView.
//  Loads GET /api/inquiries (list threads) + GET /api/inquiries/unread-count.
//  Pattern matches existing HomeViewModel / SearchViewModel conventions.
//

import Foundation

@MainActor
final class InquiryInboxViewModel: ObservableObject {
    @Published var threads: [InquiryThread] = []
    @Published var unreadTotal: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func loadInbox(role: String? = nil) {
        Task { await fetchThreads(role: role) }
    }

    func refreshInbox(role: String? = nil) async {
        await fetchThreads(role: role)
    }

    private func fetchThreads(role: String?) async {
        isLoading = true
        errorMessage = nil
        do {
            let resp: InquiryListResponse = try await APIManager.shared.request(
                type: APIEndPoint.getInquiries(role: role),
                header: true
            )
            threads = resp.data ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadUnreadCount() {
        Task {
            do {
                let resp: InquiryUnreadCountResponse = try await APIManager.shared.request(
                    type: APIEndPoint.getInquiryUnreadCount,
                    header: true
                )
                unreadTotal = resp.data?.unreadTotal ?? 0
            } catch {
                // Non-fatal — badge just stays 0
            }
        }
    }
}
