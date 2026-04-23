//
//  ChatThreadViewController.swift
//  BidCast — iOS parity Phase 3c (2026-04-22)
//

import UIKit
import PhotosUI

final class ChatThreadViewController: UIViewController,
                                      UITableViewDataSource, UITableViewDelegate,
                                      UITextFieldDelegate,
                                      PHPickerViewControllerDelegate {

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
    // P2.13 — attach-image button; shares the input bar with the text field.
    private let attachBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        b.tintColor = .systemBlue
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
        attachBtn.addTarget(self, action: #selector(attachImageTapped), for: .touchUpInside)

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

        // P2.13 — input row is now [attach] [text field] [send].
        let hStack = UIStackView(arrangedSubviews: [attachBtn, inputField, sendBtn])
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

            attachBtn.widthAnchor.constraint(equalToConstant: 28),
            sendBtn.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - P2.13 image attach

    @objc private func attachImageTapped() {
        var cfg = PHPickerConfiguration()
        cfg.filter = .images
        cfg.selectionLimit = 1
        let picker = PHPickerViewController(configuration: cfg)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let first = results.first else { return }
        first.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.uploadAndSendImage(image)
            }
        }
    }

    private func uploadAndSendImage(_ image: UIImage) {
        // Cap to 1600px on the long edge to keep the multipart body small.
        let prepared = Self.resized(image: image, maxEdge: 1600)
        guard let jpeg = prepared.jpegData(compressionQuality: 0.8) else {
            p3Alert(message: "Couldn't prepare the image.")
            return
        }
        store.sendImageMessage(
            conversationId: conversation.id,
            senderId: UserDefaults.loggedInUserId,
            jpegData: jpeg
        ) { [weak self] res in
            DispatchQueue.main.async {
                switch res {
                case .success: break
                case .failure(let err):
                    self?.p3Alert(title: "Couldn't send image", message: err.localizedDescription)
                }
            }
        }
    }

    private static func resized(image: UIImage, maxEdge: CGFloat) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        if longest <= maxEdge { return image }
        let scale = maxEdge / longest
        let new = CGSize(width: floor(size.width * scale),
                         height: floor(size.height * scale))
        let r = UIGraphicsImageRenderer(size: new)
        return r.image { _ in image.draw(in: CGRect(origin: .zero, size: new)) }
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

        // P2.13 — image-type messages render as a tappable thumbnail.
        if (m.mediaType ?? "").lowercased() == "image",
           let urlStr = m.mediaUrl, let url = URL(string: urlStr) {
            configureImageCell(cell, url: url, isMine: isMine, raw: m)
            return cell
        }

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

    // MARK: - P2.13 image cell rendering

    private func configureImageCell(_ cell: UITableViewCell,
                                    url: URL,
                                    isMine: Bool,
                                    raw: ChatMessage) {
        let thumb = UIImageView()
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 12
        thumb.backgroundColor = .secondarySystemBackground
        thumb.isUserInteractionEnabled = true
        cell.contentView.addSubview(thumb)

        let side: NSLayoutConstraint = isMine
            ? thumb.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            : thumb.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16)
        NSLayoutConstraint.activate([
            thumb.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
            thumb.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
            thumb.widthAnchor.constraint(equalToConstant: 200),
            thumb.heightAnchor.constraint(equalToConstant: 200),
            side
        ])
        // Lazy load the thumbnail. URLSession caches by default.
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                thumb.image = image
            }
        }.resume()

        // Tap-to-fullscreen (present a simple AVPlayer-free image viewer).
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewImageTapped(_:)))
        tap.accessibilityHint = url.absoluteString
        thumb.addGestureRecognizer(tap)
        thumb.accessibilityHint = url.absoluteString
    }

    @objc private func previewImageTapped(_ gr: UITapGestureRecognizer) {
        guard let view = gr.view,
              let urlStr = view.accessibilityHint,
              let url = URL(string: urlStr) else { return }
        let vc = ChatImagePreviewViewController(imageURL: url)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

// MARK: - Image preview (P2.13)

/// Minimal full-screen image viewer. Pinches to zoom, tap-to-dismiss.
/// Kept inside the same file so the chat image feature is easy to audit.
private final class ChatImagePreviewViewController: UIViewController, UIScrollViewDelegate {
    private let imageURL: URL
    private let scroll = UIScrollView()
    private let imageView = UIImageView()

    init(imageURL: URL) {
        self.imageURL = imageURL
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.delegate = self
        scroll.maximumZoomScale = 4
        scroll.minimumZoomScale = 1
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        view.addSubview(scroll)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        scroll.addSubview(imageView)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: scroll.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        let close = UIButton(type: .system)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setTitle("Done", for: .normal)
        close.setTitleColor(.white, for: .normal)
        close.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        close.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        view.addSubview(close)
        NSLayoutConstraint.activate([
            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tap)

        URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}
