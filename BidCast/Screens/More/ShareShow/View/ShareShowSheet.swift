import SwiftUI

// MARK: - Share Content Type
enum ShareContentType {
    case show(title: String, username: String, imageURL: String, isLive: Bool, message: String)
    case profile(username: String, imageURL: String, followers: Int, ratings: Int)
    case product(title: String, sellerUsername: String, productImageURL: String, sellerImageURL: String)
}


// MARK: - Dynamic Share Bottom Sheet with Chat Selection
struct DynamicShareBottomSheetView: View {

    @Binding var isPresented: Bool
    let contentType: ShareContentType
    let messageList: [ChatMessage]?
    let onSendToChat: (ChatMessage, String) -> Void

    // UI State
    @State private var showFloatingChat = false

    // Chat State
    @State private var selectedChat: ChatMessage?
    @State private var selectedRoomId: String?
    @State private var chatMessages: [ChatMessage] = []
    @State private var isLoadingMessages = false

    var body: some View {
        ZStack {

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        contentPreviewCard()
                        recentChatsSection()
                        socialShareSection()
                    }
                }
            }
            .background(Color.white)
            .disabled(showFloatingChat)
            .opacity(showFloatingChat ? 0.3 : 1)

            // Floating Chat
            if showFloatingChat,
               let chat = selectedChat,
               let roomId = selectedRoomId {

                FloatingChatView(
                    isPresented: $showFloatingChat,
                    chat: chat,
                    roomId: roomId,
                    messages: chatMessages,
                    isLoading: isLoadingMessages,
                    contentType: contentType,
                    onSend: { message in
                        onSendToChat(chat, message)
                        isPresented = false
                    }
                )
                .transition(.move(edge: .bottom))
            }
        }
    }
    private var header: some View {
        HStack {
            Text("Share")
                .font(.headline)

            Spacer()

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
            }
        }
        .padding()
    }
    private func recentChatsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Send to")
                .font(.headline)
                .padding(.horizontal)

            if messageList?.isEmpty == true {
                Text("No recent chats")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(messageList ?? [], id: \.id) { chat in
                            chatButton(chat)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func chatButton(_ chat: ChatMessage) -> some View {

        let currentUserId = String(UserDefaults.userId)
        let isSender = chat.users.senderId == currentUserId

        let otherUserId = isSender ? chat.users.receiverId : chat.users.senderId
        let roomId = computeRoomId(senderId: currentUserId, receiverId: otherUserId)

        let displayName = isSender ? chat.users.receiverName : chat.users.senderName
        let displayImage = isSender ? chat.users.receiverImage : chat.users.senderImage

        return Button {
            selectedChat = chat
            selectedRoomId = roomId
            isLoadingMessages = true
            FirebaseManager.shared.fetchMessageList(forUserId: "\(UserDefaults.userId)") { messages in
                DispatchQueue.main.async {
                    self.chatMessages = messages
                    self.isLoadingMessages = false
                    self.showFloatingChat = true
                    
                }
            }
            

        } label: {
            VStack(spacing: 6) {
                CustomProfileImage(url: displayImage, isCircular: true)
                    .frame(width: 64, height: 64)

                Text(displayName)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(width: 70)
            }
        }
    }
    // MARK: - Content Preview Card
    @ViewBuilder
    private func contentPreviewCard() -> some View {
        switch contentType {

        case .show(let title, _, let imageURL, let isLive, let message):
            showPreviewCard(
                title: title,
                imageURL: imageURL,
                isLive: isLive,
                message: message
            )

        case .profile(let username, let imageURL, let followers, let ratings):
            profilePreviewCard(
                username: username,
                imageURL: imageURL,
                followers: followers,
                ratings: ratings
            )

        case .product(let title, let sellerUsername, let productImageURL, let sellerImageURL):
            productPreviewCard(
                title: title,
                sellerUsername: sellerUsername,
                productImageURL: productImageURL,
                sellerImageURL: sellerImageURL
            )
        }
    }

    private func showPreviewCard(
        title: String,
        imageURL: String,
        isLive: Bool,
        message: String
    ) -> some View {

        VStack(spacing: 0) {
            HStack{
                ZStack(alignment: .topLeading) {
                    CustomProfileImage(url: imageURL, isCircular: false,size: 200,height: 300)
                        
                        .clipped()
                    
                    if isLive {
                        Text("LIVE")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(6)
                            .padding(8)
                    }
                }
            }
            .frame(width:screenWidth/2)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom(poppinsBold, size: 16.0))

                Text(message)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
        }
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func profilePreviewCard(
        username: String,
        imageURL: String,
        followers: Int,
        ratings: Int
    ) -> some View {

        VStack(spacing: 12) {
            CustomProfileImage(url: imageURL, isCircular: true)
                .frame(width: 80, height: 80)

            Text(username.uppercased())
                .font(.headline)

            HStack(spacing: 32) {
                VStack {
                    Text("\(followers)").bold()
                    Text("Followers").font(.caption)
                }

                VStack {
                    Text("\(ratings)").bold()
                    Text("Ratings").font(.caption)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func productPreviewCard(
        title: String,
        sellerUsername: String,
        productImageURL: String,
        sellerImageURL: String
    ) -> some View {

        VStack(spacing: 0) {
            CustomProfileImage(url: productImageURL, isCircular: false)
                .frame(height: 180)
                .clipped()

            HStack(spacing: 12) {
                CustomProfileImage(url: sellerImageURL, isCircular: true)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(sellerUsername.uppercased())
                        .font(.caption.bold())
                    Text(title)
                        .font(.caption)
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .cornerRadius(16)
        .padding(.horizontal)
    }
    // MARK: - Social Share Section
    @ViewBuilder
    private func socialShareSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Share to")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                spacing: 20
            ) {

                socialShareButton(
                    title: "Copy Link",
                    icon: "link"
                ) {
                    copyShareLink()
                }

                socialShareButton(
                    title: "Facebook",
                    icon: "facebook"
                ) {
                    shareViaWhatsApp()
                }

                socialShareButton(
                    title: "Instagram",
                    icon: "instagram"
                ) {
                    shareViaInstagram()
                }

                socialShareButton(
                    title: "LinkedIn",
                    icon: "linkedin"
                ) {
                    openSystemShareSheet()
                }
            }
            .padding(.horizontal)
        }
    }

    private func socialShareButton(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            VStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func copyShareLink() {
        UIPasteboard.general.string = generateShareLink()
    }

    private func shareViaWhatsApp() {
        guard let url = URL(string: "whatsapp://send?text=\(generateShareLink())") else { return }
        UIApplication.shared.open(url)
    }

    private func shareViaInstagram() {
        openSystemShareSheet()
    }

    private func openSystemShareSheet() {
        let activityVC = UIActivityViewController(
            activityItems: [generateShareLink()],
            applicationActivities: nil
        )

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }

    private func generateShareLink() -> String {
        switch contentType {
        case .show(let title, _, _, _, _):
            return "https://bidcast.app/show/\(title.replacingOccurrences(of: " ", with: "-"))"

        case .profile(let username, _, _, _):
            return "https://bidcast.app/\(username)"

        case .product(let title, _, _, _):
            return "https://bidcast.app/product/\(title.replacingOccurrences(of: " ", with: "-"))"
        }
    }

}



// MARK: - Floating Chat View
struct FloatingChatView: View {

    @Binding var isPresented: Bool
    let chat: ChatMessage
    let roomId: String
    let messages: [ChatMessage]
    let isLoading: Bool
    let contentType: ShareContentType
    let onSend: (String) -> Void

    @State private var messageText = ""

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) {
                header
                messagesView
                inputBar
            }
            .frame(height: 480)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(radius: 20)
        }
        .background(
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
        )
    }
    private var header: some View {
        HStack {
            Text("Chat")
                .font(.headline)

            Spacer()

            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
        }
        .padding()
    }

    private var messagesView: some View {
        ScrollView {
            VStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .padding()
                } else if messages.isEmpty {
                    Text("No messages yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(messages.suffix(10)) { message in
                        MessageBubble(
                            message: message,
                            currentUserId: String(UserDefaults.userId)
                        )
                    }
                }
            }
            .padding()
        }
        .frame(height: 220)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $messageText)
                .textFieldStyle(.roundedBorder)

            Button {
                let final = messageText
                messageText = ""
                onSend(final)
            } label: {
                Image(systemName: "paperplane.fill")
            }
        }
        .padding()
    }

}


// MARK: - Message Bubble Component
struct MessageBubble: View {
    let message: ChatMessage
    let currentUserId: String
    
    var isCurrentUser: Bool {
        message.users.senderId == currentUserId
    }
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .font(.custom(poppinsRegular, size: 13.0))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    .cornerRadius(16)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.custom(poppinsRegular, size: 10.0))
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
    
    private func formatTimestamp(_ timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Helper Function for Room ID
func computeRoomId(senderId: String, receiverId: String) -> String {
    [senderId, receiverId].sorted().joined(separator: "_")
}
