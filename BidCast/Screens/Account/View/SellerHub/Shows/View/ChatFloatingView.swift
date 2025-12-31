//
//  ChatFloatingView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 31/12/25.
//

import Foundation
import SwiftUI

struct FloatingChatView: View {
    @Binding var isPresented: Bool
    let chat: ChatMessage
    let showURL: String
    
    @StateObject private var viewModel: ChatViewModel
    @State private var keyboardHeight: CGFloat = 0
    
    init(isPresented: Binding<Bool>, chat: ChatMessage, showURL: String) {
        self._isPresented = isPresented
        self.chat = chat
        self.showURL = showURL
        
        // Determine other user info from ChatMessage.users
        let otherUserId = chat.users.receiverId != "\(UserDefaults.userId)"
            ? chat.users.receiverId
            : chat.users.senderId
        
        let otherUserName = chat.users.receiverId != "\(UserDefaults.userId)"
            ? chat.users.receiverName
            : chat.users.senderName
        
        let otherUserImage = chat.users.receiverId != "\(UserDefaults.userId)"
            ? chat.users.receiverImage
            : chat.users.senderImage
        
        // Initialize ChatViewModel
        self._viewModel = StateObject(wrappedValue: ChatViewModel(
            currentUserId: "\(UserDefaults.userId)",
            currentUserName: UserDefaults.userName,
            currentUserImage: UserDefaults.profileURL,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserImage: otherUserImage
        ))
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                // Background overlay
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        hideKeyboard()
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
                
                // Floating chat container
                VStack(spacing: 0) {
                    // Header
                    chatHeader
                    
                    // Messages ScrollView
                    ScrollViewReader { proxy in
                        ScrollView {
                            if viewModel.messages.isEmpty {
                                emptyStateView
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.messages) { message in
                                        MessageRow1(
                                            message: message,
                                            currentUserId: viewModel.currentUserId
                                        )
                                        .id(message.id)
                                    }
                                }
                                .padding()
                            }
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            scrollToBottom(proxy: proxy)
                        }
                    }
                    
                    // Input field
                    messageInputField
                }
                .frame(width: screenWidth - 40, height: screenHeight * 0.7)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .offset(y: -keyboardHeight / 2)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(), value: keyboardHeight)
            }
        }
        .onAppear {
            setupChat()
            setupKeyboardObservers()
        }
        .onDisappear {
            viewModel.removeMessageListener()
            removeKeyboardObservers()
        }
    }
    
    // MARK: - Header
    private var chatHeader: some View {
        HStack(spacing: 12) {
            CustomProfileImage(url: viewModel.otherUserImage, isCircular: true)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.otherUserName)
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.primary)
                
                Text("Active now")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                hideKeyboard()
                withAnimation(.spring()) {
                    isPresented = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "message")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("Start the conversation")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
    
    // MARK: - Message Input
    private var messageInputField: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.messageText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .font(.custom(poppinsRegular, size: 14))
            
            Button(action: {
                viewModel.sendMessage()
            }) {
                Image(systemName: viewModel.messageText.isEmpty ? "paperplane" : "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .defaultTheme)
            }
            .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Setup Functions
    private func setupChat() {
        // Start listening for messages
        viewModel.fetchMessages()
        
        // Send show URL as first message after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sendShowURL()
        }
    }
    
    private func sendShowURL() {
        let urlMessage = "Check out this live show: \(showURL)"
        viewModel.messageText = urlMessage
        viewModel.sendMessage()
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Message Row
struct MessageRow1: View {
    let message: ChatMessageModel
    let currentUserId: String
    
    var isFromCurrentUser: Bool {
        message.senderId == currentUserId
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isFromCurrentUser {
                Spacer()
                messageBubble(backgroundColor: .defaultTheme, textColor: .white)
            } else {
                messageBubble(backgroundColor: Color(.systemGray5), textColor: .primary)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func messageBubble(backgroundColor: Color, textColor: Color) -> some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            Text(message.message)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(textColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(18)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = message.message
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }
            
            Text(timeAgoDisplay(from: message.timestamp))
                .font(.custom(poppinsRegular, size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: screenWidth * 0.7, alignment: isFromCurrentUser ? .trailing : .leading)
    }
    
    private func timeAgoDisplay(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}


