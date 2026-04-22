//
//  ConversationListViewController.swift
//  BidCast — iOS parity Phase 3c (2026-04-22)
//
//  Lists 1:1 conversations from `ChatStore`. Android uses Firebase as the
//  backing store; iOS uses `InMemoryChatStore` until Phase 4 swaps in
//  FirebaseChatStore.
//

import UIKit

final class ConversationListViewController: P3ListViewController {

    private var conversations: [Conversation] = []
    private let store: ChatStore = InMemoryChatStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Messages"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                            style: .plain, target: self, action: #selector(newChat)),
            UIBarButtonItem(image: UIImage(systemName: "person.slash"),
                            style: .plain, target: self, action: #selector(openBlocked))
        ]

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "conv")
        emptyState.update(title: "No messages",
                          message: "Start a conversation with a seller or buyer.")

        let currentUserId = UserDefaults.loggedInUserId
        store.observeConversations(currentUserId: currentUserId) { [weak self] conversations in
            self?.conversations = conversations
            self?.tableView.reloadData()
            self?.emptyStateIsVisible = conversations.isEmpty
        }
    }

    override func reloadData() { /* live observer updates automatically */ stopRefresh() }

    @objc private func newChat() {
        let picker = NewChatSearchViewController { [weak self] user in
            self?.openConversation(withUserId: user.id ?? 0,
                                   otherUser: self?.conversationUser(from: user))
        }
        p3Push(picker)
    }

    @objc private func openBlocked() {
        p3Push(BlockedUsersViewController())
    }

    private func openConversation(withUserId otherId: Int, otherUser: UserPublic?) {
        let mine = UserDefaults.loggedInUserId
        let convId = [mine, otherId].sorted().map(String.init).joined(separator: "_")
        let conv = Conversation(id: convId,
                                participants: [mine, otherId],
                                lastMessage: nil, lastMessageAt: nil,
                                unreadCount: 0, otherUser: otherUser, isMuted: false)
        let vc = ChatThreadViewController(conversation: conv)
        p3Push(vc)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conv", for: indexPath)
        let c = conversations[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = c.otherUser?.name ?? c.otherUser?.username ?? "Conversation"
        cfg.secondaryText = c.lastMessage ?? ""
        cfg.image = UIImage(systemName: "person.crop.circle.fill")
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatThreadViewController(conversation: conversations[indexPath.row])
        p3Push(vc)
    }

    private func conversationUser(from s: SearchUserEntry) -> UserPublic {
        UserPublic(id: s.id, bio: nil, email: nil,
                   firstName: nil, lastName: nil,
                   name: s.name, username: s.username,
                   profileImage: s.profileImage, thumbnail: nil,
                   referralCode: nil, roleId: nil, isActive: nil,
                   rating: nil, isFollowed: nil)
    }
}

// MARK: - UserDefaults helper

extension UserDefaults {
    /// Best-effort fetch of the logged-in user id so chat can build a
    /// deterministic conversationId. Android uses the same pattern.
    static var loggedInUserId: Int {
        if let id = UserDefaults.standard.value(forKey: "loggedInUserId") as? Int {
            return id
        }
        // Try pulling from the stored profile JSON; fall back to 0 so chat
        // still renders with a "self" id. Real wiring lands once
        // EditProfileViewModel stores it.
        return 0
    }
}
