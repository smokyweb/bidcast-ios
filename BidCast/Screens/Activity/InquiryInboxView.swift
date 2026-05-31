//
//  InquiryInboxView.swift
//  BidCast
//
//  Buyer↔Seller inquiry inbox. Lists all inquiry threads for the current user,
//  newest first. Tap a row to open InquiryThreadView.
//  Pull-to-refresh reloads the list.
//
//  UX spec: memory/bidcast-inquiry-messaging-spec.md (Inbox section)
//

import SwiftUI
import AlertToast

struct InquiryInboxView: View {
    @StateObject private var viewModel = InquiryInboxViewModel()
    @Environment(\.presentationMode) var presentationMode

    // Navigation to thread
    @State private var selectedThreadId: Int? = nil
    @State private var navigateToThread: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Inquiries",
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                count: .constant(viewModel.unreadTotal)
            )

            if viewModel.isLoading && viewModel.threads.isEmpty {
                Spacer()
                ProgressView("Loading inquiries…")
                Spacer()
            } else if let err = viewModel.errorMessage, viewModel.threads.isEmpty {
                Spacer()
                Text(err).foregroundColor(.red).padding()
                Spacer()
            } else if viewModel.threads.isEmpty {
                Spacer()
                NoDataView(message: "No inquiries yet")
                Spacer()
            } else {
                List {
                    ForEach(viewModel.threads) { thread in
                        InquiryThreadRow(thread: thread)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedThreadId = thread.id
                                navigateToThread = true
                            }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refreshInbox()
                }
            }

            // Navigation link (hidden) — CusNavLink pattern used throughout the app
            if let threadId = selectedThreadId {
                CusNavLink(
                    doNavigate: $navigateToThread,
                    destination: InquiryThreadView(threadId: threadId,
                                                   otherUserName: viewModel.threads.first(where: { $0.id == threadId })?.otherUser.displayName ?? "Seller",
                                                   subject: viewModel.threads.first(where: { $0.id == threadId })?.subject)
                )
            }
        }
        .background(Color.backGround)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadInbox()
            viewModel.loadUnreadCount()
        }
    }
}

// MARK: - Thread Row

private struct InquiryThreadRow: View {
    let thread: InquiryThread

    private var avatarURL: URL? {
        guard let s = thread.otherUser.profileImage, !s.isEmpty else { return nil }
        return URL(string: s)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            AsyncImage(url: avatarURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray.opacity(0.4))
                }
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.otherUser.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Spacer()
                    if let time = thread.lastMessageAt {
                        Text(time.toShortTimeAgo())
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                Text(thread.subject ?? "Inquiry")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Unread badge
            if thread.unreadCount > 0 {
                Text("\(thread.unreadCount)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.defaultTheme)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

// MARK: - Convenience: short time-ago formatter for inbox rows

private extension String {
    func toShortTimeAgo() -> String {
        let fmts = ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                    "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        var date: Date? = nil
        for fmt in fmts {
            formatter.dateFormat = fmt
            if let d = formatter.date(from: self) { date = d; break }
        }
        guard let d = date else { return self }
        let secs = -d.timeIntervalSinceNow
        if secs < 60 { return "now" }
        if secs < 3600 { return "\(Int(secs / 60))m" }
        if secs < 86400 { return "\(Int(secs / 3600))h" }
        return "\(Int(secs / 86400))d"
    }
}
