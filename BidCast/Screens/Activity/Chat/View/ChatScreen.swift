//
//  ChatScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/07/25.
//

import SwiftUI
import AlertToast

//MARK: ChatScreen
struct ChatScreen: View {
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var chatPath: String = ""
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    var notiViewModel = NotificationViewModel()

    init(viewModel: ChatViewModel) {
        _chatPath = State(initialValue: viewModel.chatPath)
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            messagesView
            Divider()
            inputBar
        }
        .background(Color(red: 248/255, green: 250/255, blue: 253/255))
        .navigationBarHidden(true)
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
    }

    private var headerView: some View {
        ChatHeaderView(
            profileImage: viewModel.otherUserImage,
            userName: viewModel.otherUserName.capitalizingFirstLetter(),
            onBack: { presentationMode.wrappedValue.dismiss() },
            onMore: { print("More tapped") }
        )
    }

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
            .onChange(of: viewModel.messages.count) { _ in
                DispatchQueue.main.async {
                    if let last = viewModel.messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchMessages()
            }
            .onDisappear {
                viewModel.removeMessageListener()
            }
        }
    }

    
    private var groupedMessages: [Date: [ChatMessageModel]] {
        Dictionary(grouping: viewModel.messages) { message in
            let date = Date(timeIntervalSince1970: TimeInterval(message.timestamp))
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
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            label = formatter.string(from: date)
        }

        return Text(label)
            .font(.custom(poppinsMedium, size: 13))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
    }


    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Type here...", text: $viewModel.messageText)
                .padding(12)
                .font(.custom(poppinsRegular, size: 13.0))
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Button(action: {
                let trimmedText = viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmedText.isEmpty else {
                    // Show toast
                    hudMsg = "Please enter a message to send"
                    showhud = true
                    return
                }

                viewModel.sendMessage()
                sendChatNotificatio(receiverID: viewModel.otherUserId, message: trimmedText)
                viewModel.messageText = ""
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.defaultTheme))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
    }

    
    private func sendChatNotificatio(receiverID : String , message : String){
        let param = SendChatNotification(receiver_id: Int(receiverID) ?? 0, message: message)
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            print("Send Notification Param \(param)")
            await notiViewModel.SendNotification(param: param)
        }
    }
}



//MARK: ChatBubble
struct ChatBubble: View {
    let message: ChatMessageModel
    let isCurrentUser: Bool

    var body: some View {
        HStack {

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.message)
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
        }
        .padding(.horizontal, 4)
    }

    private func formatTime(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
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
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 36, height: 36)
            }

            if let url = URL(string: profileImage), !profileImage.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else {
                        Image("defaultUser")
                            .resizable()
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Image("defaultUser")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }

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


