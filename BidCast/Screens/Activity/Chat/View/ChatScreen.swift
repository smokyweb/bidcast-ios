//
//  ChatScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/07/25.
//

import SwiftUI
import AlertToast

struct ChatScreen: View {

    // MC task cmp7dvsuh00fu4fwpkdhcv1dv (2026-05-15): incoming messages were
    // never appearing on iOS even though Android could see them and the iOS
    // device could send. Root cause: `@ObservedObject` combined with a VM
    // constructed inside `init(viewModel:)` meant SwiftUI rebuilt the entire
    // ChatViewModel on every parent re-render of ChatScreen (NavigationLink
    // / ActivityScreen). The prior VM got deinit'd (which detached the RTDB
    // listener), and the brand-new VM had an empty messages array with no
    // listener attached — `.onAppear` already fired on first appear so it
    // never re-fired to call `fetchMessages()` again. Switching to
    // `@StateObject` makes SwiftUI own the VM's lifetime against the view
    // identity, so it survives parent rebuilds and the listener stays alive.
    @StateObject var viewModel: ChatViewModel

    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @Environment(\.presentationMode) var presentationMode

    var notiViewModel = NotificationViewModel()

    init(viewModel: ChatModel) {
        let model = ChatViewModel(
            currentUserId: viewModel.currentUserId,
            currentUserName: viewModel.currentUserName,
            currentUserImage: viewModel.currentUserImage,
            otherUserId: viewModel.otherUserId,
            otherUserName: viewModel.otherUserName,
            otherUserImage: viewModel.otherUserImage
        )
        // IMPORTANT: assign via the StateObject wrapper, not `self.viewModel`,
        // so the wrappedValue closure only fires once for this view identity.
        _viewModel = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        VStack(spacing: 0) {

            headerView

            messagesView

            Divider()

            inputBar
        }
        .background(.backGround)
        .navigationBarHidden(true)
    }

    // MARK: - Header
    private var headerView: some View {
        ChatHeaderView(
            profileImage: viewModel.otherUserImage,
            userName: viewModel.otherUserName.capitalizingFirstLetter(),
            onBack: { presentationMode.wrappedValue.dismiss() },
            onMore: { print("More tapped") }
        )
    }

    // MARK: - Messages
    private var messagesView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(groupedMessages.keys.sorted(), id: \.self) { dateKey in
                        Section(header: dateHeader(for: dateKey)) {
                            ForEach(groupedMessages[dateKey] ?? []) { message in
                                ChatBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == viewModel.currentUserId
                                )
                                .id(message.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
            }
            .onAppear {
                viewModel.fetchMessages()
            }
            .onDisappear {
                viewModel.removeMessageListener()
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let last = viewModel.messages.last {
                    withAnimation {
                        scrollProxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // GROUPING BY DATE
    private var groupedMessages: [Date: [ChatMessageModel]] {
        Dictionary(grouping: viewModel.messages) { msg in
            let date = Date(timeIntervalSince1970: TimeInterval(msg.timestamp))
            return Calendar.current.startOfDay(for: date)
        }
    }

    private func dateHeader(for date: Date) -> some View {
        let label: String

        if Calendar.current.isDateInToday(date) {
            label = "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            label = "Yesterday"
        } else {
            let f = DateFormatter()
            f.dateStyle = .medium
            label = f.string(from: date)
        }

        return Text(label)
            .font(.custom("Poppins-Medium", size: 13))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 10) {

            TextField("Type here...", text: $viewModel.messageText)
                .padding(12)
                .font(.custom("Poppins-Regular", size: 13))
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.defaultTheme))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func sendMessage() {
        let text = viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            hudMsg = "Please enter a message"
            showhud = true
            return
        }

        viewModel.sendMessage()
        sendChatNotification(receiverID: viewModel.otherUserId, message: text)
    }

    private func sendChatNotification(receiverID: String, message: String) {
        let param = SendChatNotification(
            receiver_id: Int(receiverID) ?? 0,
            message: message
        )

        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            await notiViewModel.SendNotification(param: param)
        }
    }
}




//MARK: ChatBubble
struct ChatBubble: View {
    let message: ChatMessageModel
    let isCurrentUser: Bool
    @EnvironmentObject var deepLinkManager: DeepLinkManager

    var body: some View {
        HStack {

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(attributedMessage(message.message))
                    .font(.custom(poppinsRegular, size: 13.0))
                    .padding(12)
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .background(isCurrentUser ? .defaultTheme : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isCurrentUser ? .trailing : .leading)

                HStack(spacing: 4) {
                    if !isCurrentUser {
                        Text(formatTime(TimeInterval(message.timestamp)))
                            .font(.custom(poppinsRegular, size: 11.0))
                            .foregroundColor(.gray)
                    }

                    if isCurrentUser {
                        Text(formatTime(TimeInterval(message.timestamp)))
                            .font(.custom(poppinsRegular, size: 11.0))
                            .foregroundColor(.gray)

//                        Image(systemName: "checkmark.double")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 14, height: 14)
//                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
                .padding(.top, 2)
                .padding(.leading, isCurrentUser ? 0 : 12)
                .padding(.trailing, isCurrentUser ? 12 : 0)

            }
            .environment(\.openURL, OpenURLAction { url in
                handleChatLink(url)
                return .handled   // 🚨 THIS STOPS SAFARI
            })
        }
        .padding(.horizontal, 4)
    }
    private func handleChatLink(_ url: URL) {

        // Match only your live-show links
        guard url.path == "/live-show" else { return }

        // Extract query params
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let roomId = components.queryItems?
                .first(where: { $0.name == "roomid" })?
                .value
        else {
            return
        }

        print("✅ Live room id:", roomId)

        // Trigger app navigation (NOT Safari)
        deepLinkManager.openLiveShow(id: roomId)
    }
    private func formatTime(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    func attributedMessage(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)

        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let matches = detector.matches(
                in: text,
                options: [],
                range: NSRange(location: 0, length: text.utf16.count)
            )

            for match in matches {
                guard let range = Range(match.range, in: attributed),
                      let url = match.url else { continue }

                attributed[range].link = url
                attributed[range].foregroundColor = .blue
                attributed[range].underlineStyle = .single
            }
        }
        return attributed
    }
}




//MARK: ChatHeaderView
struct ChatHeaderView: View {
    var profileImage: String
    var userName: String
    var onBack: () -> Void
    var onMore: () -> Void
    var showMoreButton: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .font(.custom(poppinsBold, size: 16))
                    .frame(width: 36, height: 36)
            }

            CustomProfileImage(url: profileImage, isCircular: true, size: 44)
//            if let url = URL(string: profileImage), !profileImage.isEmpty {
//                AsyncImage(url: url) { phase in
//                    if let image = phase.image {
//                        image.resizable()
//                    } else {
//                        Image("defaultUser")
//                            .resizable()
//                    }
//                }
//                .frame(width: 44, height: 44)
//                .clipShape(Circle())
//            } else {
//                Image("defaultUser")
//                    .resizable()
//                    .frame(width: 44, height: 44)
//                    .clipShape(Circle())
//            }

            Text(userName)
                .font(.custom(poppinsSemiBold, size: 14.0))
                .foregroundColor(.black)
                .lineLimit(1)

            Spacer()

            if showMoreButton {
                Button(action: onMore) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(width: 36, height: 36)
                }
            }
        }
        .padding(.horizontal, 16)
//        .padding(.top, 12)
        .frame(height: 50)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }
}


