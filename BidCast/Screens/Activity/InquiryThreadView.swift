//
//  InquiryThreadView.swift
//  BidCast
//
//  Buyer↔Seller inquiry thread view. Displays chat bubbles (mine right-aligned,
//  theirs left-aligned), auto-scrolls to bottom on load and after sending.
//  Sends POST /api/inquiries/{thread}/reply; appends the bubble immediately.
//
//  UX spec: memory/bidcast-inquiry-messaging-spec.md (Thread section)
//

import SwiftUI

struct InquiryThreadView: View {
    let threadId: Int
    var otherUserName: String
    var subject: String?

    @StateObject private var viewModel = InquiryThreadViewModel()
    @Environment(\.presentationMode) var presentationMode

    @State private var messageText: String = ""
    @State private var scrollProxy: ScrollViewProxy? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            PrimaryHeader(
                title: subject ?? otherUserName,
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                count: .constant(0)
            )

            // Messages
            if viewModel.isLoading && viewModel.messages.isEmpty {
                Spacer()
                ProgressView("Loading messages…")
                Spacer()
            } else if let err = viewModel.errorMessage, viewModel.messages.isEmpty {
                Spacer()
                Text(err).foregroundColor(.red).padding()
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { msg in
                                InquiryBubble(message: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        scrollToBottom()
                    }
                }
            }

            // Compose bar
            composeBar
        }
        .background(Color.backGround)
        .navigationBarHidden(true)
        .task { await viewModel.loadThread(threadId: threadId) }
    }

    // MARK: - Compose bar

    private var composeBar: some View {
        HStack(spacing: 10) {
            TextField("Message…", text: $messageText, axis: .vertical)
                .font(.system(size: 15))
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .lineLimit(1...5)

            Button {
                sendMessage()
            } label: {
                if viewModel.isSending {
                    ProgressView()
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .defaultTheme)
                        .frame(width: 36, height: 36)
                }
            }
            .disabled(viewModel.isSending || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: -2)
    }

    private func sendMessage() {
        let text = messageText
        messageText = ""
        Task {
            await viewModel.sendReply(threadId: threadId, text: text)
        }
    }

    private func scrollToBottom() {
        guard let proxy = scrollProxy, let lastId = viewModel.messages.last?.id else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}

// MARK: - Chat bubble

private struct InquiryBubble: View {
    let message: InquiryMessage

    private var timestamp: String {
        let fmts = ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                    "yyyy-MM-dd'T'HH:mm:ssZ"]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for fmt in fmts {
            df.dateFormat = fmt
            if let d = df.date(from: message.createdAt) {
                df.dateFormat = "h:mm a"
                df.locale = .current
                return df.string(from: d)
            }
        }
        return message.createdAt
    }

    var body: some View {
        HStack {
            if message.mine { Spacer(minLength: 48) }

            VStack(alignment: message.mine ? .trailing : .leading, spacing: 4) {
                Text(message.body)
                    .font(.system(size: 14))
                    .foregroundColor(message.mine ? .white : .black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.mine ? Color.defaultTheme : Color(.systemGray5))
                    .cornerRadius(16)
                    .custCornerRadius(message.mine ? 4 : 16, corners: message.mine ? .bottomRight : .bottomLeft)

                Text(timestamp)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            if !message.mine { Spacer(minLength: 48) }
        }
    }
}

// Note: custCornerRadius(_:corners:) is defined globally in NavigationContainer.swift
// using the RoundedCorner shape — no redeclaration needed here.
