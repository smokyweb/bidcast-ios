//
//  HostTipSettingsSheet.swift
//  BidCast
//
//  iOS Parity Phase 6c (2026-04-22) — Host-side Tip Settings sheet,
//  presented from HostPublisherViewController's More Options menu
//  while a show is live.
//
//  Mirrors:
//    - Android `AgoraPublisherActivity.tipSettingsSheet()`
//      (`SocketManager.kt` L621–640 `saveTipSetting`)
//    - PWA `#tipSettingModal` in startShow.blade.php (2026-04-22 deploy)
//
//  Socket contract (BidcastSocketManager.emitSaveTipSetting):
//    tip_setting_save { show_id, tip_message, show_in_live_chat }
//
//  This is the in-show setting (message + show-in-chat toggle). The
//  preset 5 tip tiers are a separate pre-show setting handled by
//  TipSettingsViewController; we keep those out of scope here to match
//  Android's split between `TipSettingActivity` (pre-show tier config)
//  and the in-show sheet for the chat-visibility toggle + greeting.
//

import UIKit

public final class HostTipSettingsSheet: UIViewController {

    public var showId: String
    public var initialMessage: String
    public var initialShowInChat: Bool
    public var onSaved: ((_ message: String, _ showInChat: Bool) -> Void)?

    private let messageView: UITextView = {
        let t = UITextView()
        t.font = .systemFont(ofSize: 15)
        t.layer.cornerRadius = 10
        t.layer.borderColor = UIColor.separator.cgColor
        t.layer.borderWidth = 1
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    private let chatToggle: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Save Tip Setting"
        cfg.baseBackgroundColor = .systemBlue
        b.configuration = cfg
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    public init(showId: String, initialMessage: String = "", initialShowInChat: Bool = true) {
        self.showId = showId
        self.initialMessage = initialMessage
        self.initialShowInChat = initialShowInChat
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Tip Setting"

        let titleHint = UILabel()
        titleHint.text = "Message shown to viewers when they open the tip sheet"
        titleHint.font = .systemFont(ofSize: 13, weight: .semibold)
        titleHint.textColor = .secondaryLabel
        titleHint.numberOfLines = 0
        titleHint.translatesAutoresizingMaskIntoConstraints = false

        let toggleLabel = UILabel()
        toggleLabel.text = "Show tips in live chat"
        toggleLabel.font = .systemFont(ofSize: 15)
        toggleLabel.translatesAutoresizingMaskIntoConstraints = false

        let toggleRow = UIStackView(arrangedSubviews: [toggleLabel, UIView(), chatToggle])
        toggleRow.axis = .horizontal
        toggleRow.alignment = .center
        toggleRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleHint)
        view.addSubview(messageView)
        view.addSubview(toggleRow)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            titleHint.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleHint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleHint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            messageView.topAnchor.constraint(equalTo: titleHint.bottomAnchor, constant: 8),
            messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            messageView.heightAnchor.constraint(equalToConstant: 120),

            toggleRow.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 16),
            toggleRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toggleRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            saveButton.topAnchor.constraint(equalTo: toggleRow.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 46),

            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        messageView.text = initialMessage
        chatToggle.isOn = initialShowInChat

        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func save() {
        let message = (messageView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let showInChat = chatToggle.isOn
        BidcastSocketManager.shared.emitSaveTipSetting(
            showId: showId,
            tipMessage: message,
            showInLiveChat: showInChat
        )
        onSaved?(message, showInChat)
        dismiss(animated: true)
    }
}
