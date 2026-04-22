//
//  ChatThreadViewController.swift
//  BidCast — iOS parity Phase 3c (2026-04-22)
//

import UIKit

final class ChatThreadViewController: UIViewController,
                                      UITableViewDataSource, UITableViewDelegate,
                                      UITextFieldDelegate {

    private let conversation: Conversation
    private let store: ChatStore = ChatStoreRegistry.active
    private var messages: [ChatMessage] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputField: UITextField = {
        let f = UITextField()
        f.placeholder = "Type a message…"
        f.borderStyle = .roundedRect
        f.returnKeyType = .send
        return f
    }()
    private let sendBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Send", for: .normal)
        return b
    }()

    init(conversation: Conversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
        self.title = conversation.otherUser?.name ?? conversation.otherUser?.username ?? "Chat"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNav()
        setupLayout()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "msg")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive

        inputField.delegate = self
        sendBtn.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        store.observeMessages(conversationId: conversation.id) { [weak self] msgs in
            guard let self = self else { return }
            self.messages = msgs
            self.tableView.reloadData()
            if !msgs.isEmpty {
                let idx = IndexPath(row: msgs.count - 1, section: 0)
                self.tableView.scrollToRow(at: idx, at: .bottom, animated: false)
            }
            self.store.markAsRead(conversationId: self.conversation.id,
                                  userId: UserDefaults.loggedInUserId)
        }
    }

    private func setupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain, target: self, action: #selector(showOptions))
    }

    private func setupLayout() {
        let bar = UIView()
        bar.backgroundColor = .secondarySystemBackground
        bar.translatesAutoresizingMaskIntoConstraints = false

        let hStack = UIStackView(arrangedSubviews: [inputField, sendBtn])
        hStack.axis = .horizontal
        hStack.spacing = 8
        hStack.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(hStack)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(bar)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bar.topAnchor),

            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            hStack.topAnchor.constraint(equalTo: bar.topAnchor, constant: 8),
            hStack.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -8),
            hStack.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -12),

            sendBtn.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func sendTapped() {
        guard let text = inputField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty else { return }
        inputField.text = ""
        store.sendMessage(conversationId: conversation.id,
                          senderId: UserDefaults.loggedInUserId,
                          body: text) { _ in }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped(); return true
    }

    @objc private func showOptions() {
        let sheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let other = conversation.otherUser?.id
        sheet.addAction(UIAlertAction(title: "Block user", style: .destructive, handler: { [weak self] _ in
            guard let oid = other else { return }
            self?.store.blockUser(userId: oid) { res in
                DispatchQueue.main.async {
                    switch res {
                    case .success: self?.p3Alert(title: "Blocked", message: "User has been blocked.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                    case .failure(let e): self?.p3Alert(message: e.localizedDescription)
                    }
                }
            }
        }))
        sheet.addAction(UIAlertAction(title: "Report user", style: .destructive, handler: { [weak self] _ in
            guard let oid = other else { return }
            self?.promptReport(userId: oid)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func promptReport(userId: Int) {
        let alert = UIAlertController(title: "Report user",
                                      message: "What's happening?", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "Reason" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            let reason = alert.textFields?.first?.text ?? ""
            self?.store.reportUser(userId: userId, reason: reason) { _ in
                DispatchQueue.main.async {
                    self?.p3Alert(title: "Thanks", message: "Report submitted.")
                }
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "msg", for: indexPath)
        cell.selectionStyle = .none
        let m = messages[indexPath.row]
        let isMine = (m.senderId ?? -1) == UserDefaults.loggedInUserId

        for sub in cell.contentView.subviews { sub.removeFromSuperview() }
        let bubble = UILabel()
        bubble.text = m.body
        bubble.numberOfLines = 0
        bubble.font = .systemFont(ofSize: 15)
        bubble.textColor = isMine ? .white : .label
        bubble.backgroundColor = isMine ? .systemBlue : .secondarySystemBackground
        bubble.layer.cornerRadius = 12
        bubble.clipsToBounds = true
        bubble.layer.masksToBounds = true
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.preferredMaxLayoutWidth = 260
        // pad
        bubble.layer.shadowOffset = .zero
        cell.contentView.addSubview(bubble)

        // leading/trailing alignment via side anchors
        let side: NSLayoutConstraint = isMine
            ? bubble.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            : bubble.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16)
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
            bubble.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
            bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            side
        ])
        // inset the text inside the label via a bit of attributed padding
        if let t = m.body {
            let para = NSMutableParagraphStyle(); para.firstLineHeadIndent = 10
            bubble.attributedText = NSAttributedString(string: t, attributes: [
                .paragraphStyle: para,
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: (isMine ? UIColor.white : UIColor.label)
            ])
        }
        return cell
    }
}
