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
            .background(.backGround)
            .disabled(showFloatingChat)
            .opacity(showFloatingChat ? 0.3 : 1)

           
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
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.black)   // ✅ make it black

            }
        }
        .padding()
    }
    private func recentChatsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Send to")
                .font(.headline)
                .padding(.horizontal)
                .foregroundColor(.black)

            if messageList?.isEmpty == true {
                Text("No recent chats")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(messageList ?? [], id: \.id) { chat in
                            chatButton(chat) { chat, text in
                                onSendToChat(chat,text)
                            }
                               
                                
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func chatButton(
        _ chat: ChatMessage,
        onTap: @escaping (ChatMessage, String) -> Void
    ) -> some View {

        let currentUserId = String(UserDefaults.userId)
        let isSender = chat.users.senderId == currentUserId

        let otherUserId = isSender ? chat.users.receiverId : chat.users.senderId
        let roomId = computeRoomId(senderId: currentUserId, receiverId: otherUserId)

        let displayName = isSender ? chat.users.receiverName : chat.users.senderName
        let displayImage = isSender ? chat.users.receiverImage : chat.users.senderImage

        return Button {
            onTap(chat, roomId)
        } label: {
            VStack(spacing: 6) {
                CustomProfileImage(url: displayImage, isCircular: true)
                    .frame(width: 64, height: 64)
                    .allowsHitTesting(false)

                Text(displayName)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(width: 70)
                    .foregroundColor(.black)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                            .foregroundColor(.black)
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
                    .foregroundColor(.black)

                Text(message)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.backGround)
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
                .foregroundColor(.black)

            HStack(spacing: 32) {
                VStack {
                    Text("\(followers)").bold()
                        .foregroundColor(.black)
                    Text("Followers").font(.caption)
                        .foregroundColor(.black)
                }

                VStack {
                    Text("\(ratings)").bold()
                        .foregroundColor(.black)
                    Text("Ratings").font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.backGround)
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
                        .foregroundColor(.black)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.black)
                }

                Spacer()
            }
            .padding()
            .background(.backGround)
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
                .foregroundColor(.black)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                spacing: 20
            ) {

                socialShareButton(
                    title: "Copy Link",
                    icon: "link"
                ) {
                    copyLink()
                }

                socialShareButton(
                    title: "Facebook",
                    icon: "facebook"
                ) {
                    shareToFacebook()
                }

                socialShareButton(
                    title: "Instagram",
                    icon: "instagram"
                ) {
                    shareToInstagramStory()
                }

                socialShareButton(
                    title: "LinkedIn",
                    icon: "linkedin"
                ) {
                    shareToLinkedIn()
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
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func copyLink() {
            UIPasteboard.general.string = generateShareLink()
        }

        private func shareToFacebook() {
            openWebShare(
                "https://www.facebook.com/sharer/sharer.php?u="
            )
        }

        private func shareToLinkedIn() {
            openWebShare(
                "https://www.linkedin.com/sharing/share-offsite/?url="
            )
        }

        
    private func openWebShare(_ base: String) {
           let link = generateShareLink()
           let encoded = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

           guard let url = URL(string: base + encoded) else { return }
           UIApplication.shared.open(url)
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
    private func shareToInstagramStory() {
        let link = generateShareLink()

        guard let url = URL(string: "instagram-stories://share") else {
            openSystemShareSheet()
            return
        }

        if UIApplication.shared.canOpenURL(url) {

            let pasteboardItems: [[String: Any]] = [
                ["com.instagram.sharedSticker.backgroundText": link]
            ]

            UIPasteboard.general.setItems(
                pasteboardItems,
                options: [.expirationDate: Date().addingTimeInterval(300)]
            )

            UIApplication.shared.open(url, options: [:], completionHandler: nil)

        } else {
            openSystemShareSheet()
        }
    }


    private func generateShareLink() -> String {
        switch contentType {

        case .show(_, let username, _, _, _):
            // username is used as roomid
            return "\(ShareConfig.baseURL)/live-show?roomid=\(username)"

        case .profile(let username, _, _, _):
            return "\(ShareConfig.baseURL)/profile?username=\(username)"

        case .product(let title, let sellerUsername, _, _):
            let slug = slugify(title)
            return "\(ShareConfig.baseURL)/product?title=\(slug)&seller=\(sellerUsername)"
        }
    }
    private func slugify(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
    }
}

struct ShareConfig {
    static let baseURL = "https://www.backend.bidcast.betaplanets.com"
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
                    .background(isCurrentUser ? Color.defaultTheme : Color(.systemGray5))
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
