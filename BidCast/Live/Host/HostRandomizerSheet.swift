//
//  HostRandomizerSheet.swift
//  BidCast
//
//  iOS Parity Phase 6d (2026-04-22) — Host-side Randomizer (Freebie)
//  flow.
//
//  Mirrors:
//    - Android `AgoraPublisherActivity` `showFreebieStartSheet()` +
//      `showRandomizerSheet()`
//    - PWA `#randomizerModal` in startShow.blade.php (3 stages).
//
//  Socket contract (already in BidcastSocketManager):
//    emit   create-freebie       { room_id, product_id, time }
//    emit   enter-in-freebie     { room_id, user_id }          (viewer)
//    emit   finalize-freebie     { room_id }
//    emit   remove-freebie-user  { room_id, user_id }
//    listen get-freebie          state + entries
//    listen get-freebie-winner   { user_name, user_id, ... }
//
//  Stages:
//    A. Start — host picks productId + duration seconds (10–300).
//    B. Live — shows countdown + entry count. "Spin" fires
//       `finalize-freebie`.
//    C. Winner — banner with winner name, auto-closes after 6s.
//

import UIKit

public final class HostRandomizerSheet: UIViewController {

    public enum Stage { case start, live, winner }

    public var roomId: String
    public var defaultProductId: String?
    public var currentUserId: String = ""
    public var onFinalized: (() -> Void)?

    private var stage: Stage = .start
    private var durationSeconds: Int = 30
    private var productIdField: UITextField?
    private var durationField: UITextField?
    private var countdownTimer: Timer?
    private var countdownRemaining: Int = 0
    private var entryCount: Int = 0

    // UI roots per stage
    private let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    public init(roomId: String, defaultProductId: String? = nil) {
        self.roomId = roomId
        self.defaultProductId = defaultProductId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Randomizer"
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        bindSocketListeners()
        renderStart()
    }

    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: Socket

    private func bindSocketListeners() {
        let socket = BidcastSocketManager.shared
        socket.onFreebie { [weak self] payload in
            guard let self = self else { return }
            if let arr = payload["users"] as? [[String: Any]] {
                self.entryCount = arr.count
            } else if let n = payload["entry_count"] as? Int {
                self.entryCount = n
            }
            if self.stage == .live { self.renderLive() }
        }
        socket.onFreebieWinner { [weak self] payload in
            guard let self = self else { return }
            let name = (payload["user_name"] as? String) ?? "A viewer"
            self.stage = .winner
            self.renderWinner(name: name)
            self.onFinalized?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [weak self] in
                self?.dismiss(animated: true)
            }
        }
    }

    // MARK: Stage: Start

    private func renderStart() {
        container.subviews.forEach { $0.removeFromSuperview() }

        let hint = makeHint("Give a product away at random. Viewers tap Enter during the window; tap Spin to pick a winner.")
        let productLbl = makeSection("Product ID")
        let pField = UITextField()
        pField.borderStyle = .roundedRect
        pField.placeholder = "product_id (uses pinned if blank)"
        pField.text = defaultProductId
        pField.translatesAutoresizingMaskIntoConstraints = false
        pField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        productIdField = pField

        let durLbl = makeSection("Entry window (seconds, 10–300)")
        let dField = UITextField()
        dField.borderStyle = .roundedRect
        dField.placeholder = "30"
        dField.text = "30"
        dField.keyboardType = .numberPad
        dField.translatesAutoresizingMaskIntoConstraints = false
        dField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        durationField = dField

        let startBtn = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Start Randomizer"
        cfg.baseBackgroundColor = .systemPink
        startBtn.configuration = cfg
        startBtn.translatesAutoresizingMaskIntoConstraints = false
        startBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true
        startBtn.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [hint, productLbl, pField, durLbl, dField, startBtn, cancelBtn])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }

    @objc private func startTapped() {
        let pid = (productIdField?.text ?? "").trimmingCharacters(in: .whitespaces)
        let durRaw = (durationField?.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !pid.isEmpty else {
            showError("Enter a product ID (or ensure a product is pinned).")
            return
        }
        let dur = Int(durRaw) ?? 30
        guard dur >= 10, dur <= 300 else {
            showError("Duration must be 10–300 seconds.")
            return
        }
        durationSeconds = dur
        countdownRemaining = dur
        BidcastSocketManager.shared.emitCreateFreebie(
            roomId: roomId,
            productId: pid,
            timeSeconds: String(dur)
        )
        stage = .live
        renderLive()
        startCountdown()
    }

    // MARK: Stage: Live

    private let timerLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        l.textAlignment = .center
        l.textColor = .label
        return l
    }()
    private let entryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.textAlignment = .center
        return l
    }()
    private let spinButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Spin / Pick Winner"
        cfg.baseBackgroundColor = .systemPurple
        b.configuration = cfg
        return b
    }()

    private func renderLive() {
        container.subviews.forEach { $0.removeFromSuperview() }

        let hint = makeHint("Randomizer is live. Viewers see an Enter button.")
        timerLabel.text = formatCountdown(countdownRemaining)
        entryLabel.text = "\(entryCount) \(entryCount == 1 ? "entry" : "entries")"
        spinButton.translatesAutoresizingMaskIntoConstraints = false
        spinButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        spinButton.removeTarget(nil, action: nil, for: .allEvents)
        spinButton.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)

        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Close (let it run to end)", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [hint, timerLabel, entryLabel, spinButton, cancelBtn])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }

    @objc private func spinTapped() {
        BidcastSocketManager.shared.emitFinalizeFreebie(roomId: roomId)
        // Server will emit get-freebie-winner → we render winner stage.
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            self.countdownRemaining -= 1
            if self.countdownRemaining <= 0 {
                self.countdownRemaining = 0
                t.invalidate()
                // Server should auto-finalize; if not, host can still tap Spin.
            }
            if self.stage == .live {
                self.timerLabel.text = self.formatCountdown(self.countdownRemaining)
            }
        }
    }

    // MARK: Stage: Winner

    private func renderWinner(name: String) {
        container.subviews.forEach { $0.removeFromSuperview() }
        countdownTimer?.invalidate()

        let emoji = UILabel()
        emoji.text = "🎉"
        emoji.font = .systemFont(ofSize: 60)
        emoji.textAlignment = .center

        let t = UILabel()
        t.text = "Winner"
        t.font = .boldSystemFont(ofSize: 20)
        t.textAlignment = .center

        let n = UILabel()
        n.text = name
        n.font = .boldSystemFont(ofSize: 28)
        n.textAlignment = .center
        n.textColor = .systemPink

        let closeBtn = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Done"
        closeBtn.configuration = cfg
        closeBtn.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [emoji, t, n, closeBtn])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }

    // MARK: Helpers

    @objc private func cancelTapped() {
        countdownTimer?.invalidate()
        dismiss(animated: true)
    }

    private func showError(_ msg: String) {
        let a = UIAlertController(title: "Invalid input", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    private func makeHint(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }
    private func makeSection(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    private func formatCountdown(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
