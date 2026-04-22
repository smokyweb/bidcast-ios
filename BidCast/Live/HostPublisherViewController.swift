//
//  HostPublisherViewController.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 2, milestone 4:
//  iOS host-side live publisher scaffold mirroring Android
//  `AgoraPublisherActivity.kt` behavior enough to create/join room,
//  publish camera/mic, pin a product, start an auction, push timer updates,
//  and run the next product when timer expires.
//
//  Scope for this milestone:
//    - room_create emit on load
//    - Agora join as broadcaster with local preview
//    - pin_product / start_auction / run_next_product emits
//    - listen for bid_timer_update / auction_next_product / get_highest_bid /
//      bid_finalized / viewerCount / chat_get
//    - host button for "Run Next"
//
//  This is intentionally programmatic and isolated. Navigation wiring,
//  richer inventory UI, sudden-death controls, poll/tip/raid/randomizer UI,
//  and backend-backed scheduler editors follow later.
//

import UIKit

public final class HostPublisherViewController: UIViewController {

    // MARK: Inputs
    public var context: LiveShowContext!
    public var currentUserId: String = ""
    public var currentUserName: String = ""
    public var currentUserImage: String = ""

    // MARK: UI
    private let localVideoView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .black
        return v
    }()

    private let viewerCountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        l.font = .boldSystemFont(ofSize: 12)
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.text = "LIVE 0"
        return l
    }()

    private let timerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        l.font = .boldSystemFont(ofSize: 12)
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.text = "Timer idle"
        return l
    }()

    private let highestBidLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        l.font = .boldSystemFont(ofSize: 12)
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.text = "No bids yet"
        return l
    }()

    private let currentProductLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.numberOfLines = 2
        l.font = .boldSystemFont(ofSize: 15)
        l.text = "No pinned product"
        return l
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 10
        s.alignment = .fill
        return s
    }()

    private func makeButton(_ title: String) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        b.layer.cornerRadius = 10
        b.heightAnchor.constraint(equalToConstant: 42).isActive = true
        return b
    }

    private lazy var pinFirstButton = makeButton("Pin First Product")
    private lazy var startAuctionButton = makeButton("Start Auction")
    private lazy var runNextButton = makeButton("Run Next")
    private lazy var pollButton = makeButton("Create Poll")
    private lazy var tipSettingsButton = makeButton("Tip Settings")
    private lazy var raidButton = makeButton("Raid")
    private lazy var randomizerButton = makeButton("Start Randomizer")
    private lazy var muteButton = makeButton("Mute / Unmute")
    private lazy var cameraButton = makeButton("Switch Camera")
    private lazy var closeButton = makeButton("End / Close")

    private let chatTableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        t.separatorStyle = .none
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 44
        return t
    }()

    // MARK: State
    private var isMuted = false
    /// Bounded chat buffer (200-msg cap + dedup by message id) shared with
    /// the viewer path (LiveChatBuffer, see Live/Chat/LiveChatMessage.swift).
    private let chatBuffer = LiveChatBuffer(capacity: 200)
    private let statusBanner = LiveBanner()
    private var currentPinnedProductId: String?
    private var currentPinnedProductTitle: String?
    private var lastBidTimerSeconds: Int = -1
    private var hasAutoAdvancedForCurrentTimer = false

    // MARK: Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        setupActions()
        bindSocketListeners()
        startHostSession()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        teardownHostSession()
    }

    // MARK: Setup

    private func setupViews() {
        view.addSubview(localVideoView)
        view.addSubview(statusBanner)
        view.addSubview(viewerCountLabel)
        view.addSubview(timerLabel)
        view.addSubview(highestBidLabel)
        view.addSubview(currentProductLabel)
        view.addSubview(stack)
        view.addSubview(chatTableView)

        [pinFirstButton, startAuctionButton, runNextButton, pollButton, tipSettingsButton, raidButton, randomizerButton, muteButton, cameraButton, closeButton].forEach { stack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            localVideoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            localVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            localVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            localVideoView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.38),

            statusBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            statusBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusBanner.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            statusBanner.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            viewerCountLabel.topAnchor.constraint(equalTo: localVideoView.bottomAnchor, constant: 12),
            viewerCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            viewerCountLabel.widthAnchor.constraint(equalToConstant: 82),
            viewerCountLabel.heightAnchor.constraint(equalToConstant: 26),

            timerLabel.topAnchor.constraint(equalTo: localVideoView.bottomAnchor, constant: 12),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 110),
            timerLabel.heightAnchor.constraint(equalToConstant: 26),

            highestBidLabel.topAnchor.constraint(equalTo: localVideoView.bottomAnchor, constant: 12),
            highestBidLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            highestBidLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 110),
            highestBidLabel.heightAnchor.constraint(equalToConstant: 26),

            currentProductLabel.topAnchor.constraint(equalTo: viewerCountLabel.bottomAnchor, constant: 14),
            currentProductLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currentProductLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: currentProductLabel.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            chatTableView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 12),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            chatTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])

        chatTableView.dataSource = self
        chatTableView.register(LiveChatMessageCell.self, forCellReuseIdentifier: LiveChatMessageCell.reuseId)
    }

    private func setupActions() {
        pinFirstButton.addTarget(self, action: #selector(pinFirstProduct), for: .touchUpInside)
        startAuctionButton.addTarget(self, action: #selector(startAuction), for: .touchUpInside)
        runNextButton.addTarget(self, action: #selector(runNextProduct), for: .touchUpInside)
        pollButton.addTarget(self, action: #selector(createPoll), for: .touchUpInside)
        tipSettingsButton.addTarget(self, action: #selector(configureTipSettings), for: .touchUpInside)
        raidButton.addTarget(self, action: #selector(sendRaid), for: .touchUpInside)
        randomizerButton.addTarget(self, action: #selector(startRandomizer), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func bindSocketListeners() {
        let socket = BidcastSocketManager.shared

        socket.onRoomCreated { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            self.appendSystem("Room created / confirmed.")
        }

        socket.onViewerCount { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            if let n = payload["viewer_count"] as? Int ?? payload["count"] as? Int {
                self.viewerCountLabel.text = "LIVE \(n)"
            }
        }

        socket.onBidTimerUpdate { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            let remaining = self.stringValue(payload["remaining"]) ?? self.stringValue(payload["time"]) ?? self.stringValue(payload["duration"])
            if let remaining = remaining {
                self.timerLabel.text = "Timer \(remaining)"
                let seconds = Int(Double(remaining) ?? -1)
                // Reset edge detector when a new positive timer starts.
                if seconds > 0 && seconds != self.lastBidTimerSeconds {
                    self.hasAutoAdvancedForCurrentTimer = false
                }
                // Core bug fix for task cmo93i7ga:
                // If the timer reaches zero and the host has not already
                // advanced the item for this auction cycle, request the next
                // product automatically. This mirrors the Android/PWA host
                // behavior Trey asked us to restore.
                if seconds == 0 && !self.hasAutoAdvancedForCurrentTimer {
                    self.hasAutoAdvancedForCurrentTimer = true
                    if let context = self.context {
                        BidcastSocketManager.shared.emitRunNextProduct(roomId: context.roomId)
                        self.appendSystem("Timer hit 0, auto-requested next item.")
                    }
                }
                self.lastBidTimerSeconds = seconds
            }
        }

        socket.onHighestBid { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            if let amount = self.stringValue(payload["bid_amount"]) ?? self.stringValue(payload["amount"]) {
                self.highestBidLabel.text = "Highest $\(amount)"
            }
        }

        socket.onBidFinalized { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            let winner = payload["user_name"] as? String ?? "User"
            let amount = self.stringValue(payload["bid_amount"]) ?? "?"
            self.appendSystem("Sold to \(winner) at $\(amount)")
            self.timerLabel.text = "Timer idle"
            self.lastBidTimerSeconds = -1
            self.hasAutoAdvancedForCurrentTimer = false
        }

        socket.onChat { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            let msg = LiveChatMessage.fromChatPayload(payload)
            if self.chatBuffer.append(msg) {
                self.chatTableView.reloadData()
                self.scrollChatToBottom()
            }
        }

        socket.onAuctionStarted { [weak self] _ in
            self?.appendSystem("Auction started.")
            self?.lastBidTimerSeconds = -1
            self?.hasAutoAdvancedForCurrentTimer = false
        }

        socket.onProductPinned { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            self.currentPinnedProductId = payload["product_id"] as? String
            let title = (payload["product"] as? [String: Any])?["title"] as? String
            self.currentPinnedProductTitle = title
            self.currentProductLabel.text = title.map { "Pinned: \($0)" } ?? "Pinned product id: \(self.currentPinnedProductId ?? "?")"
        }

        socket.onAuctionNextProduct { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            let title = (payload["product"] as? [String: Any])?["title"] as? String
            let productId = (payload["product"] as? [String: Any])?["id"] as? String ?? payload["product_id"] as? String
            self.currentPinnedProductId = productId
            self.currentPinnedProductTitle = title
            self.currentProductLabel.text = title.map { "Now selling: \($0)" } ?? "Now selling next item"
            self.timerLabel.text = "Timer restarted"
            self.lastBidTimerSeconds = -1
            self.hasAutoAdvancedForCurrentTimer = false
            self.appendSystem("Advanced to next item.")
        }

        socket.onRunNextProductError { [weak self] payload in
            let message = payload["message"] as? String ?? "run_next_product failed"
            self?.appendSystem(message)
        }

        socket.onFreebieWinner { [weak self] payload in
            let name = payload["user_name"] as? String ?? "Someone"
            self?.appendSystem("Randomizer winner: \(name)")
        }
    }

    // MARK: Host session

    private func startHostSession() {
        guard let context = context else { return }

        let socket = BidcastSocketManager.shared
        socket.connect(userId: currentUserId.isEmpty ? context.sellerId : currentUserId)
        // Reconnect banner while socket bounces.
        socket.onConnectionChange { [weak self] connected in
            guard let self = self else { return }
            if connected {
                self.statusBanner.hide()
            } else {
                self.statusBanner.show("Reconnecting...", style: .warning, duration: 0)
            }
        }
        socket.emitRoomCreate(payload: [
            "room_id": context.roomId,
            "show_id": context.showId,
            "seller_id": context.sellerId,
            "seller_name": context.sellerName,
            "seller_image": context.sellerImage ?? "",
            "auction_type_id": context.auctionTypeId ?? NSNull(),
            "product_ids": context.productIds
        ])
        socket.emitJoinRoom(roomId: context.roomId, userId: currentUserId.isEmpty ? context.sellerId : currentUserId)
        socket.emitJoinShow(roomId: context.roomId, userId: currentUserId.isEmpty ? context.sellerId : currentUserId)

        let agora = BidcastAgoraEngine.shared
        agora.delegate = self
        agora.configure(appId: context.agoraAppId)
        let uid = UInt(currentUserId.isEmpty ? context.sellerId : currentUserId) ?? 0
        agora.joinChannel(token: context.rtcToken, channel: context.roomId, uid: uid, role: .broadcaster, localVideoView: localVideoView)
    }

    private func teardownHostSession() {
        guard let context = context else { return }
        BidcastSocketManager.shared.emitLeaveRoom(roomId: context.roomId, userId: currentUserId.isEmpty ? context.sellerId : currentUserId)
        BidcastAgoraEngine.shared.leaveChannel()
    }

    // MARK: Actions

    @objc private func pinFirstProduct() {
        guard let context = context, let first = context.productIds.first else {
            appendSystem("No scheduled products available to pin.")
            return
        }
        currentPinnedProductId = first
        currentProductLabel.text = "Pinned product id: \(first)"
        BidcastSocketManager.shared.emitPinProduct(roomId: context.roomId, productId: first)
    }

    @objc private func startAuction() {
        guard let context = context else { return }
        let productIds = currentPinnedProductId.map { [$0] } ?? context.productIds.prefix(1).map { $0 }
        guard !productIds.isEmpty else {
            appendSystem("No product selected for auction.")
            return
        }
        BidcastSocketManager.shared.emitStartAuction(
            roomId: context.roomId,
            productIds: productIds,
            startingBidAmount: "1",
            requireTime: 30,
            counterBidTime: 5,
            suddenDeath: false,
            auctionTypeId: context.auctionTypeId
        )
        timerLabel.text = "Timer 30"
    }

    @objc private func runNextProduct() {
        guard let context = context else { return }
        BidcastSocketManager.shared.emitRunNextProduct(roomId: context.roomId)
        appendSystem("Requested next item.")
    }

    @objc private func createPoll() {
        guard let context = context else { return }
        let alert = UIAlertController(title: "Create poll", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Question" }
        alert.addTextField { $0.placeholder = "Option 1" }
        alert.addTextField { $0.placeholder = "Option 2" }
        alert.addTextField { $0.placeholder = "Duration seconds (default 30)"; $0.keyboardType = .numberPad }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            let fields = alert.textFields ?? []
            let question = fields[safe: 0]?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let o1 = fields[safe: 1]?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let o2 = fields[safe: 2]?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let duration = Int(fields[safe: 3]?.text ?? "") ?? 30
            guard !question.isEmpty, !o1.isEmpty, !o2.isEmpty else { return }
            BidcastSocketManager.shared.emitCreatePoll(roomId: context.roomId, question: question, options: [o1, o2], durationSeconds: duration)
            self?.appendSystem("Poll created.")
        })
        present(alert, animated: true)
    }

    @objc private func configureTipSettings() {
        guard let context = context else { return }
        let alert = UIAlertController(title: "Tip settings", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Tip message shown to viewers" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            let msg = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !msg.isEmpty else { return }
            BidcastSocketManager.shared.emitSaveTipSetting(showId: context.showId, tipMessage: msg, showInLiveChat: true)
            self?.appendSystem("Tip settings updated.")
        })
        present(alert, animated: true)
    }

    @objc private func startRandomizer() {
        guard let context = context else { return }
        let alert = UIAlertController(title: "Randomizer", message: "Give away an item at random.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Product id"; $0.text = self.currentPinnedProductId }
        alert.addTextField { $0.placeholder = "Duration seconds (default 30)"; $0.keyboardType = .numberPad }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Start", style: .default) { [weak self] _ in
            let pid = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let dur = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let secs = Int(dur) ?? 30
            guard !pid.isEmpty else { return }
            BidcastSocketManager.shared.emitCreateFreebie(roomId: context.roomId, productId: pid, timeSeconds: String(secs))
            self?.appendSystem("Randomizer started for product \(pid).")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(secs)) {
                BidcastSocketManager.shared.emitFinalizeFreebie(roomId: context.roomId)
                self?.appendSystem("Randomizer finalized.")
            }
        })
        present(alert, animated: true)
    }

    @objc private func sendRaid() {
        guard let context = context else { return }
        let alert = UIAlertController(title: "Raid", message: "Send your viewers to another room.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Target room id" }
        alert.addTextField { $0.placeholder = "Target host id (optional)" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            let targetRoom = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let targetHost = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !targetRoom.isEmpty else { return }
            BidcastSocketManager.shared.emitCreateRaid(sourceRoomId: context.roomId, targetRoomId: targetRoom, sourceHostId: context.sellerId, targetHostId: targetHost)
            self?.appendSystem("Raid requested to \(targetRoom).")
        })
        present(alert, animated: true)
    }

    @objc private func toggleMute() {
        isMuted.toggle()
        BidcastAgoraEngine.shared.setMicrophoneMuted(isMuted)
        appendSystem(isMuted ? "Microphone muted." : "Microphone live.")
    }

    @objc private func switchCamera() {
        BidcastAgoraEngine.shared.switchCamera()
        appendSystem("Camera switched.")
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: Helpers

    private func roomMatches(_ payload: [String: Any]) -> Bool {
        guard let context = context else { return false }
        if let rid = payload["room_id"] as? String { return rid == context.roomId }
        return true
    }

    private func stringValue(_ any: Any?) -> String? {
        if let s = any as? String { return s }
        if let i = any as? Int { return String(i) }
        if let d = any as? Double { return String(d) }
        return nil
    }

    private func appendSystem(_ message: String) {
        if chatBuffer.append(.system(message)) {
            chatTableView.reloadData()
            scrollChatToBottom()
        }
    }

    private func scrollChatToBottom() {
        let last = chatBuffer.messages.count - 1
        guard last >= 0 else { return }
        chatTableView.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: false)
    }
}

extension HostPublisherViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatBuffer.messages.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveChatMessageCell.reuseId, for: indexPath) as! LiveChatMessageCell
        cell.configure(with: chatBuffer.messages[indexPath.row])
        return cell
    }
}

extension HostPublisherViewController: BidcastAgoraEngineDelegate {
    public func agoraJoined(channel: String, uid: UInt) { appendSystem("Agora joined channel \(channel).") }
    public func agoraLeft(channel: String) { appendSystem("Agora left channel \(channel).") }
    public func agoraRemoteJoined(uid: UInt) {}
    public func agoraRemoteLeft(uid: UInt) {}
    public func agoraError(_ error: String) {
        appendSystem(error)
        statusBanner.show("Video error: \(error)", style: .error, duration: 3.0)
    }
    public func agoraConnectionStateChanged(state: Int, reason: Int) {
        switch state {
        case 4:
            statusBanner.show("Reconnecting video...", style: .warning, duration: 0)
        case 3:
            statusBanner.hide()
        case 5:
            statusBanner.show("Video connection failed", style: .error, duration: 4.0)
        default:
            break
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
