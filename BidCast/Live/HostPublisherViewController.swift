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
    private lazy var runNextButton = makeButton("Skip to Next Item")
    // iOS Parity Phase 6g (2026-04-22): compact top-right More Options
    // button that presents an action sheet with the 5 live-host features
    // (Poll / Tip Settings / Randomizer / Raid / Skip) + End show.
    // Matches Android AgoraPublisherActivity "More" menu + the PWA
    // More Options dropdown.
    private lazy var moreOptionsButton = makeButton("⊕ More Options")
    private lazy var muteButton = makeButton("Mute / Unmute")
    private lazy var cameraButton = makeButton("Switch Camera")
    private lazy var closeButton = makeButton("End / Close")

    private let noMoreItemsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "No more items in the queue"
        l.textColor = .systemOrange
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

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

    // iOS Parity Phase 6g (2026-04-22) state guards:
    //   - Only one poll may be active at a time. Flipped on
    //     `poll_created` from the server for this room, cleared on
    //     `poll_ended`.
    //   - Only one randomizer (freebie) active at a time. Flipped on
    //     `create-freebie` / `get-freebie`, cleared on winner.
    //   - Remaining pinned products counter from `auction_next_product`
    //     `remaining_pinned_products` field; drives the "No more items"
    //     indicator.
    private var pollActive = false
    private var randomizerActive = false
    private var remainingPinnedProducts: Int = -1

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

        // iOS Parity Phase 6g: slim primary stack (frequent actions) +
        // More Options action sheet for the 5 live-host features. This
        // mirrors Android's compact host toolbar rather than the long
        // debug vertical list we scaffolded in Phase 2.
        [pinFirstButton, startAuctionButton, runNextButton, moreOptionsButton, muteButton, cameraButton, closeButton].forEach { stack.addArrangedSubview($0) }
        view.addSubview(noMoreItemsLabel)

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

            noMoreItemsLabel.topAnchor.constraint(equalTo: currentProductLabel.bottomAnchor, constant: 2),
            noMoreItemsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noMoreItemsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noMoreItemsLabel.heightAnchor.constraint(equalToConstant: 16),

            stack.topAnchor.constraint(equalTo: noMoreItemsLabel.bottomAnchor, constant: 10),
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
        moreOptionsButton.addTarget(self, action: #selector(showMoreOptions), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    // iOS Parity Phase 6g: central More Options menu. This is the
    // single entry point for Poll / Tip Settings / Randomizer / Raid.
    // Skip-to-next and End are also surfaced here for discoverability;
    // Skip is additionally in the main stack (`runNextButton`).
    @objc private func showMoreOptions() {
        let sheet = UIAlertController(title: "Live Options", message: nil, preferredStyle: .actionSheet)

        let pollTitle = pollActive ? "End Active Poll" : "📊 Create Poll"
        sheet.addAction(UIAlertAction(title: pollTitle, style: .default) { [weak self] _ in
            guard let self = self else { return }
            if self.pollActive {
                self.endActivePoll()
            } else {
                self.presentCreatePollSheet()
            }
        })
        sheet.addAction(UIAlertAction(title: "💲 Tip Settings", style: .default) { [weak self] _ in
            self?.presentTipSettingsSheet()
        })
        let randTitle = randomizerActive ? "🎯 Randomizer (running)" : "🎯 Randomizer"
        let randAction = UIAlertAction(title: randTitle, style: .default) { [weak self] _ in
            self?.presentRandomizerSheet()
        }
        randAction.isEnabled = !randomizerActive
        sheet.addAction(randAction)
        sheet.addAction(UIAlertAction(title: "👥 Raid Another Host", style: .default) { [weak self] _ in
            self?.presentRaidSheet()
        })
        sheet.addAction(UIAlertAction(title: "⏭ Skip to Next Item", style: .default) { [weak self] _ in
            self?.runNextProduct()
        })
        sheet.addAction(UIAlertAction(title: "End Show", style: .destructive) { [weak self] _ in
            self?.closeTapped()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = moreOptionsButton
            popover.sourceRect = moreOptionsButton.bounds
        }
        present(sheet, animated: true)
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
                // Host countdown polish: text red under 10s, matches
                // viewer UX and gives host visual cue before auto-advance.
                let seconds = Int(Double(remaining) ?? Double(Int.max))
                self.timerLabel.textColor = (0...10).contains(seconds) ? .systemRed : .white
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
            // iOS Parity Phase 6f (2026-04-22): remaining-queue counter
            // drives the "No more items" indicator. Node emits this as
            // `remaining_pinned_products` in the auction_next_product
            // payload (see PWA spec 2026-04-22).
            if let remaining = payload["remaining_pinned_products"] as? Int {
                self.remainingPinnedProducts = remaining
                self.noMoreItemsLabel.isHidden = remaining > 0
            }
        }

        socket.onRunNextProductError { [weak self] payload in
            guard let self = self else { return }
            let message = payload["message"] as? String ?? "run_next_product failed"
            self.appendSystem(message)
            // If the server reports the queue is empty, show the indicator.
            let lc = message.lowercased()
            if lc.contains("no more") || lc.contains("empty") || lc.contains("no product") {
                self.remainingPinnedProducts = 0
                self.noMoreItemsLabel.isHidden = false
            }
        }

        // iOS Parity Phase 6b: host-side poll state tracking. Flip
        // `pollActive` when the server confirms a new poll for this room
        // and clear it on `poll_ended`. Capture the poll_id so the host
        // can emit `end_poll` before duration expires.
        socket.onPollCreated { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            self.pollActive = true
            if let i = payload["poll_id"] as? Int { self.activePollId = i }
            else if let s = payload["poll_id"] as? String, let i = Int(s) { self.activePollId = i }
            self.appendSystem("Poll is live.")
        }
        socket.onPollEnded { [weak self] _ in
            guard let self = self else { return }
            self.pollActive = false
            self.activePollId = nil
            self.appendSystem("Poll ended.")
        }

        // iOS Parity Phase 6d: host-side randomizer state. `get-freebie`
        // broadcasts the running freebie state; clear on winner.
        socket.onFreebie { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            self.randomizerActive = true
            if let arr = payload["users"] as? [Any] {
                self.appendSystem("Randomizer entries: \(arr.count)")
            }
        }

        socket.onFreebieWinner { [weak self] payload in
            guard let self = self else { return }
            let name = payload["user_name"] as? String ?? "Someone"
            self.appendSystem("Randomizer winner: \(name)")
            self.randomizerActive = false
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
        // Phase 7a analytics
        AnalyticsService.shared.logStartShow(showId: context.roomId)

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

    // Phase 7e (2026-04-22): belt-and-suspenders cleanup on dealloc.
    deinit {
        if let context = context {
            BidcastSocketManager.shared.emitLeaveRoom(
                roomId: context.roomId,
                userId: currentUserId.isEmpty ? context.sellerId : currentUserId
            )
        }
        BidcastAgoraEngine.shared.leaveChannel()
        DebugLogger.log("HostPublisherViewController deinit")
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

    // iOS Parity Phase 6b (2026-04-22): Create Poll presents the new
    // CreatePollSheet with dynamic options + duration choices. Only one
    // poll may be active; if one is already running, we show the
    // "End Active Poll" path instead (wired in showMoreOptions).
    private func presentCreatePollSheet() {
        guard let context = context else { return }
        if pollActive {
            appendSystem("A poll is already running.")
            return
        }
        let sheet = CreatePollSheet(roomId: context.roomId)
        sheet.onSubmitted = { [weak self] q, _, _ in
            guard let self = self else { return }
            self.appendSystem("Poll created: \(q)")
            // Phase 7a analytics
            if let c = self.context {
                AnalyticsService.shared.logCreatePoll(showId: c.roomId)
            }
        }
        let nav = UINavigationController(rootViewController: sheet)
        present(nav, animated: true)
    }

    private var activePollId: Int?

    private func endActivePoll() {
        guard let context = context else { return }
        guard let pid = activePollId else {
            appendSystem("No active poll id recorded; cannot end poll.")
            pollActive = false
            return
        }
        BidcastSocketManager.shared.emitEndPoll(roomId: context.roomId, pollId: String(pid))
        appendSystem("Ending poll...")
    }

    // iOS Parity Phase 6c (2026-04-22): Tip Settings presents the new
    // HostTipSettingsSheet which emits `tip_setting_save` directly.
    private func presentTipSettingsSheet() {
        guard let context = context else { return }
        let sheet = HostTipSettingsSheet(showId: context.showId)
        sheet.onSaved = { [weak self] _, _ in
            self?.appendSystem("Tip settings saved.")
        }
        let nav = UINavigationController(rootViewController: sheet)
        present(nav, animated: true)
    }

    // iOS Parity Phase 6d (2026-04-22): Randomizer uses the new
    // HostRandomizerSheet (start → live → winner stages).
    private func presentRandomizerSheet() {
        guard let context = context else { return }
        if randomizerActive {
            appendSystem("A randomizer is already running.")
            return
        }
        let sheet = HostRandomizerSheet(
            roomId: context.roomId,
            defaultProductId: currentPinnedProductId
        )
        sheet.currentUserId = currentUserId
        sheet.onFinalized = { [weak self] in
            self?.randomizerActive = false
        }
        let nav = UINavigationController(rootViewController: sheet)
        present(nav, animated: true)
        randomizerActive = true
        // Phase 7a analytics
        AnalyticsService.shared.logRunRandomizer(showId: context.roomId)
    }

    // iOS Parity Phase 6e (2026-04-22): Raid uses the new HostRaidSheet
    // which fetches live hosts via GET /api/get-live-seller.
    private func presentRaidSheet() {
        guard let context = context else { return }
        let sheet = HostRaidSheet(
            sourceRoomId: context.roomId,
            sourceHostId: context.sellerId
        )
        sheet.onRaidSent = { [weak self] targetRoom, _ in
            guard let self = self, let context = self.context else { return }
            self.appendSystem("Raid sent to \(targetRoom). Ending your show…")
            // Phase 7a analytics
            AnalyticsService.shared.logStartRaid(showId: context.roomId, targetShowId: targetRoom)
            AnalyticsService.shared.logEndShow(showId: context.roomId)
            // Mirror Android behavior: after raid, end own room + dismiss.
            BidcastSocketManager.shared.emitEndRoom(roomId: context.roomId)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.dismiss(animated: true)
            }
        }
        let nav = UINavigationController(rootViewController: sheet)
        present(nav, animated: true)
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
        // Phase 7a analytics: end_show event before dismissal.
        if let context = context {
            AnalyticsService.shared.logEndShow(showId: context.roomId)
            BidcastSocketManager.shared.emitEndRoom(roomId: context.roomId)
        }
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

// (private `subscript(safe:)` extension removed in Phase 6g — no
// longer needed after migrating host options from UIAlertController
// multi-field forms to dedicated sheets.)
