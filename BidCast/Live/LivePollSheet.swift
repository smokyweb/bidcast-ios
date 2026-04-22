//
//  LivePollSheet.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 5:
//  Viewer-side live poll UI. Presented when the viewer's socket receives
//  `poll_created`; shows question + tappable options and emits `vote_poll`.
//  Updates live on `poll_vote_update`. Closes on `poll_ended`.
//

import UIKit

public final class LivePollSheet: UIViewController {

    public struct PollData {
        public var pollId: Int
        public var question: String
        public var options: [String]
        public var votes: [Int]
        public var roomId: String

        public init(pollId: Int, question: String, options: [String], votes: [Int], roomId: String) {
            self.pollId = pollId
            self.question = question
            self.options = options
            self.votes = votes
            self.roomId = roomId
        }

        /// Best-effort decode from a socket payload dictionary.
        public static func from(payload: [String: Any], fallbackRoomId: String) -> PollData? {
            let roomId = (payload["room_id"] as? String) ?? fallbackRoomId
            let pollId: Int = {
                if let i = payload["poll_id"] as? Int { return i }
                if let s = payload["poll_id"] as? String { return Int(s) ?? 0 }
                if let i = payload["id"] as? Int { return i }
                return 0
            }()
            let question = (payload["question"] as? String) ?? ""
            var options: [String] = []
            if let arr = payload["options"] as? [String] { options = arr }
            else if let arr = payload["options"] as? [[String: Any]] {
                options = arr.compactMap { $0["text"] as? String ?? $0["label"] as? String }
            }
            var votes: [Int] = Array(repeating: 0, count: options.count)
            if let arr = payload["votes"] as? [Int], arr.count == options.count { votes = arr }
            else if let dict = payload["votes"] as? [String: Int] {
                for (k, v) in dict {
                    if let i = Int(k), i >= 0, i < votes.count { votes[i] = v }
                }
            }
            guard !question.isEmpty, !options.isEmpty else { return nil }
            return PollData(pollId: pollId, question: question, options: options, votes: votes, roomId: roomId)
        }
    }

    public var data: PollData
    public var currentUserId: String
    public var onDismiss: (() -> Void)?
    private var selectedIndex: Int?

    private let questionLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = .boldSystemFont(ofSize: 18)
        l.textColor = .white
        return l
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 10
        return s
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Close", for: .normal)
        b.setTitleColor(.white, for: .normal)
        return b
    }()

    public init(data: PollData, currentUserId: String) {
        self.data = data
        self.currentUserId = currentUserId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
        card.layer.cornerRadius = 14
        view.addSubview(card)
        card.addSubview(questionLabel)
        card.addSubview(stack)
        card.addSubview(closeButton)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            questionLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            questionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            questionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            closeButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        render()
    }

    public func update(with payload: [String: Any]) {
        // poll_vote_update / poll_vote_result listener hands us new votes.
        if let arr = payload["votes"] as? [Int], arr.count == data.options.count {
            data.votes = arr
        } else if let dict = payload["votes"] as? [String: Int] {
            for (k, v) in dict {
                if let i = Int(k), i >= 0, i < data.votes.count { data.votes[i] = v }
            }
        }
        render()
    }

    @objc private func closeTapped() {
        dismiss(animated: true) { [weak self] in self?.onDismiss?() }
    }

    private func render() {
        questionLabel.text = data.question
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let total = max(1, data.votes.reduce(0, +))
        for (i, option) in data.options.enumerated() {
            let row = pollRow(
                index: i,
                text: option,
                votes: i < data.votes.count ? data.votes[i] : 0,
                total: total,
                selected: selectedIndex == i
            )
            stack.addArrangedSubview(row)
        }
    }

    private func pollRow(index: Int, text: String, votes: Int, total: Int, selected: Bool) -> UIView {
        let container = UIControl()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = selected ? UIColor.systemBlue.withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(0.12)
        container.layer.cornerRadius = 10
        container.heightAnchor.constraint(equalToConstant: 44).isActive = true
        container.tag = index

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        let pct = Int(round(Double(votes) * 100.0 / Double(total)))
        label.text = "\(text)   \(pct)%  (\(votes))"
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        container.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        return container
    }

    @objc private func optionTapped(_ sender: UIControl) {
        guard selectedIndex == nil else { return }
        selectedIndex = sender.tag
        render()
        BidcastSocketManager.shared.emitVotePoll(
            roomId: data.roomId,
            pollId: data.pollId,
            optionIndex: sender.tag,
            userId: currentUserId
        )
    }
}
