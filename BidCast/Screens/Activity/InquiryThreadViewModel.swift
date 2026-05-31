//
//  InquiryThreadViewModel.swift
//  BidCast
//
//  ObservableObject ViewModel for InquiryThreadView.
//  Loads GET /api/inquiries/{thread} (messages + marks read).
//  Sends POST /api/inquiries/{thread}/reply to append a reply.
//  Sends POST /api/inquiries to start a new thread (Message Seller entry).
//

import Foundation

@MainActor
final class InquiryThreadViewModel: ObservableObject {
    @Published var messages: [InquiryMessage] = []
    @Published var subject: String? = nil
    @Published var isLoading: Bool = false
    @Published var isSending: Bool = false
    @Published var errorMessage: String? = nil

    /// Load messages for an existing thread (also marks other party's unread as read).
    func loadThread(threadId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let resp: InquiryThreadResponse = try await APIManager.shared.request(
                type: APIEndPoint.getInquiryThread(threadId: threadId),
                header: true
            )
            messages = resp.data?.messages ?? []
            subject  = resp.data?.subject
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Send a reply to an existing thread.
    /// Appends an optimistic bubble immediately so the user sees it right away,
    /// matching the Android implementation that suffered from a missing LayoutManager
    /// and lost sent messages (spec note: "make sure new platforms render the appended message").
    func sendReply(threadId: Int, text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Optimistic append
        let optimistic = InquiryMessage(
            id: Int.max,           // placeholder id
            senderId: UserDefaults.userId,
            mine: true,
            body: trimmed,
            readAt: nil,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        messages.append(optimistic)
        isSending = true
        errorMessage = nil

        do {
            let param = InquiryReplyRequest(message: trimmed)
            let resp: InquirySendResponse = try await APIManager.shared.request(
                type: APIEndPoint.replyInquiry(threadId: threadId, param: param),
                header: true
            )
            // Replace optimistic bubble with the real message_id by reloading thread
            if resp.data != nil {
                await loadThread(threadId: threadId)
            }
        } catch {
            // Remove optimistic bubble on failure
            messages.removeAll { $0.id == Int.max }
            errorMessage = error.localizedDescription
        }
        isSending = false
    }

    /// Start a new thread (Message Seller). Returns the thread_id so the caller
    /// can display the thread. Uses POST /api/inquiries which finds-or-creates
    /// the thread for (buyer, seller, product_id) tuple.
    func startThread(sellerId: Int, productId: Int?, message: String) async -> Int? {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        isSending = true
        errorMessage = nil
        defer { isSending = false }
        do {
            let param = StartInquiryRequest(
                seller_id: sellerId,
                message: trimmed,
                product_id: productId
            )
            let resp: InquirySendResponse = try await APIManager.shared.request(
                type: APIEndPoint.startInquiry(param: param),
                header: true
            )
            if let threadId = resp.data?.threadId {
                await loadThread(threadId: threadId)
                return threadId
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        return nil
    }
}
