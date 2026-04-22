//
//  WatchStreamViewController.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 2, milestone 3:
//  iOS viewer for a live show. Thin parity with Android
//  `WatchStreamFragment.kt`. Uses BidcastSocketManager + BidcastAgoraEngine
//  foundations from milestones 1 and 2.
//
//  Scope for this milestone:
//    - join room via socket (`join_room`)
//    - join Agora channel as audience, render remote video
//    - listen for bid_timer_update / get_highest_bid / bid_finalized / chat_get
//      / viewerCount / receiveRaid / poll_created / poll_vote_update / poll_ended
//      / get-freebie / tip_setting_updated / auction_next_product
//    - send chat
//
//  Bidding UI, polls UI, tips UI, raid UI, freebie UI follow in later
//  milestones. What's below is the functional spine so those can be added
//  without rewriting the controller.
//

import UIKit

public final class WatchStreamViewController: UIViewController {

    // MARK: Inputs
    public var context: LiveShowContext!
    public var currentUserId: String = ""
    public var currentUserName: String = ""
    public var currentUserImage: String = ""

    // MARK: UI (programmatic, minimal)
    private let remoteVideoView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .black
        return v
    }()

    private let viewerCountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 12)
        l.text = "LIVE 0"
        l.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        return l
    }()

    private let bidTimerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 13)
        l.text = ""
        l.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.isHidden = true
        return l
    }()

    private let highestBidLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 14)
        l.text = ""
        l.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.isHidden = true
        return l
    }()

    private let bidButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Bid", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 16)
        b.backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        b.layer.cornerRadius = 22
        b.isHidden = true
        return b
    }()

    private let maxBidButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Max", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 13)
        b.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.9)
        b.layer.cornerRadius = 16
        b.isHidden = true
        return b
    }()

    private let tipButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Tip", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 13)
        b.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        b.layer.cornerRadius = 16
        return b
    }()

    private let raidButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Raid", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 13)
        b.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.9)
        b.layer.cornerRadius = 16
        return b
    }()

    private let chatTableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        t.separatorStyle = .none
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 48
        return t
    }()

    private let chatInput: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        t.textColor = .white
        t.placeholder = "Say something..."
        t.attributedPlaceholder = NSAttributedString(
            string: "Say something...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
        t.layer.cornerRadius = 18
        t.setLeftPadding(12)
        return t
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("✕", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 22)
        return b
    }()

    // MARK: State
    private var chatMessages: [(name: String, message: String)] = []
    private var currentProductId: String?
    private var currentHighestBidAmount: Double = 0
    private var startingBidAmount: Double = 0
    private var lastBidTimerSeconds: Int = -1
    /// Mirrors Android WatchStreamFragment's `allowBidForAll` flag. When the
    /// host has bidding disabled (or this viewer is not eligible), bidding
    /// controls stay hidden regardless of timer state.
    private var allowBidForAll: Bool = true
    /// Once an auction ends (timer 0 or bid_finalized) we lock bid controls
    /// until the next auction_started / auction_next_product payload.
    private var auctionClosed: Bool = true
    private weak var pollSheet: LivePollSheet?
    private weak var freebieSheet: LiveFreebieSheet?
    private var latestTipMessage: String = ""
    private var currentProductTitle: String = ""

    // MARK: Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        setupActions()
        bindSocketListeners()
        joinEverything()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        leaveEverything()
    }

    // MARK: Setup

    private func setupViews() {
        view.addSubview(remoteVideoView)
        view.addSubview(closeButton)
        view.addSubview(viewerCountLabel)
        view.addSubview(bidTimerLabel)
        view.addSubview(highestBidLabel)
        view.addSubview(chatTableView)
        view.addSubview(chatInput)
        view.addSubview(bidButton)
        view.addSubview(maxBidButton)
        view.addSubview(tipButton)
        view.addSubview(raidButton)

        NSLayoutConstraint.activate([
            remoteVideoView.topAnchor.constraint(equalTo: view.topAnchor),
            remoteVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            remoteVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            remoteVideoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),

            viewerCountLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            viewerCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            viewerCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 72),
            viewerCountLabel.heightAnchor.constraint(equalToConstant: 24),

            bidTimerLabel.topAnchor.constraint(equalTo: viewerCountLabel.bottomAnchor, constant: 8),
            bidTimerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bidTimerLabel.heightAnchor.constraint(equalToConstant: 24),

            highestBidLabel.topAnchor.constraint(equalTo: bidTimerLabel.bottomAnchor, constant: 8),
            highestBidLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            highestBidLabel.heightAnchor.constraint(equalToConstant: 24),

            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            chatTableView.bottomAnchor.constraint(equalTo: chatInput.topAnchor, constant: -8),
            chatTableView.heightAnchor.constraint(equalToConstant: 220),

            chatInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chatInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            chatInput.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            chatInput.heightAnchor.constraint(equalToConstant: 36),

            bidButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bidButton.bottomAnchor.constraint(equalTo: chatInput.topAnchor, constant: -12),
            bidButton.widthAnchor.constraint(equalToConstant: 110),
            bidButton.heightAnchor.constraint(equalToConstant: 44),

            maxBidButton.trailingAnchor.constraint(equalTo: bidButton.leadingAnchor, constant: -10),
            maxBidButton.centerYAnchor.constraint(equalTo: bidButton.centerYAnchor),
            maxBidButton.widthAnchor.constraint(equalToConstant: 60),
            maxBidButton.heightAnchor.constraint(equalToConstant: 32),

            tipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tipButton.centerYAnchor.constraint(equalTo: bidButton.centerYAnchor),
            tipButton.widthAnchor.constraint(equalToConstant: 62),
            tipButton.heightAnchor.constraint(equalToConstant: 32),

            raidButton.leadingAnchor.constraint(equalTo: tipButton.trailingAnchor, constant: 10),
            raidButton.centerYAnchor.constraint(equalTo: bidButton.centerYAnchor),
            raidButton.widthAnchor.constraint(equalToConstant: 68),
            raidButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        chatTableView.dataSource = self
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(tappedClose), for: .touchUpInside)
        chatInput.addTarget(self, action: #selector(submitChat), for: .editingDidEndOnExit)
        bidButton.addTarget(self, action: #selector(tappedBid), for: .touchUpInside)
        maxBidButton.addTarget(self, action: #selector(tappedMaxBid), for: .touchUpInside)
        tipButton.addTarget(self, action: #selector(tappedTip), for: .touchUpInside)
        raidButton.addTarget(self, action: #selector(tappedRaid), for: .touchUpInside)
    }

    private func bindSocketListeners() {
        let socket = BidcastSocketManager.shared

        socket.onViewerCount { [weak self] payload in
            guard let self = self else { return }
            guard self.roomMatches(payload) else { return }
            if let n = payload["viewer_count"] as? Int {
                self.viewerCountLabel.text = "LIVE \(n)"
            } else if let n = payload["count"] as? Int {
                self.viewerCountLabel.text = "LIVE \(n)"
            }
        }

        socket.onBidTimerUpdate { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            let remainingStr = self.stringValue(from: payload["remaining"]) ??
                               self.stringValue(from: payload["time"]) ??
                               self.stringValue(from: payload["duration"])
            if let remainingStr = remainingStr {
                self.bidTimerLabel.text = "Ends in \(remainingStr)"
                self.bidTimerLabel.isHidden = false
                self.lastBidTimerSeconds = Int(Double(remainingStr) ?? -1)
                // When an auction is live (timer > 0) show bid controls
                if (self.lastBidTimerSeconds) > 0 {
                    self.auctionClosed = false
                } else {
                    self.auctionClosed = true
                }
                self.refreshBidControlsVisibility()
            }
        }

        socket.onHighestBid { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            if let amountStr = self.stringValue(from: payload["bid_amount"]) ??
                               self.stringValue(from: payload["amount"]) {
                self.highestBidLabel.text = "Highest bid $\(amountStr)"
                self.highestBidLabel.isHidden = false
                self.currentHighestBidAmount = Double(amountStr) ?? 0
                self.updateBidButtonAmount()
            }
            if let pid = payload["product_id"] as? String {
                self.currentProductId = pid
            }
        }

        socket.onBidFinalized { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            self.bidTimerLabel.isHidden = true
            self.auctionClosed = true
            self.refreshBidControlsVisibility()
            if let winner = payload["user_name"] as? String,
               let amount = self.stringValue(from: payload["bid_amount"]) {
                self.appendSystemChat("\(winner) won at $\(amount)")
            }
        }

        socket.onAuctionStarted { [weak self] payload in
            guard let self = self else { return }
            if let starting = self.stringValue(from: payload["starting_bid_amount"]),
               let dv = Double(starting) {
                self.startingBidAmount = dv
                self.currentHighestBidAmount = 0
                self.updateBidButtonAmount()
            }
            if let pid = (payload["product"] as? [String: Any])?["id"] as? String
                ?? payload["product_id"] as? String {
                self.currentProductId = pid
            }
            self.auctionClosed = false
            self.refreshBidControlsVisibility()
            self.appendSystemChat("Auction started.")
        }

        socket.onAllowBidForAllUpdate { [weak self] payload in
            guard let self = self else { return }
            if let allow = payload["allow_bid_for_all"] as? Bool {
                self.allowBidForAll = allow
                self.refreshBidControlsVisibility()
                self.appendSystemChat(allow ? "Host enabled bidding for everyone." : "Host disabled bidding.")
            }
        }

        socket.onChat { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            let name = payload["user_name"] as? String ?? "User"
            let message = payload["message"] as? String ?? ""
            self.appendChat(name: name, message: message)
        }

        socket.onRaidReceived { [weak self] payload in
            guard let self = self else { return }
            let sourceHostName = payload["source_host_name"] as? String ?? "another host"
            self.appendSystemChat("Incoming raid from \(sourceHostName).")
            // On Android the target room's viewers are prompted to jump shows.
            // On iOS we pop a confirm alert with the option to redirect.
            guard let targetRoom = payload["target_room_id"] as? String,
                  let context = self.context,
                  targetRoom != context.roomId else { return }
            let alert = UIAlertController(
                title: "Raid incoming",
                message: "\(sourceHostName) is raiding into another room. Join them?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
            alert.addAction(UIAlertAction(title: "Join", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.appendSystemChat("Joining raid target \(targetRoom)…")
                // Best-effort immediate handoff when the raid payload already
                // contains everything needed for the destination room.
                if let rtcToken = payload["target_rtc_token"] as? String,
                   !rtcToken.isEmpty {
                    let appId = (payload["target_agora_app_id"] as? String)
                        ?? (self.context?.agoraAppId ?? "")
                    let targetShowId = (payload["target_show_id"] as? String)
                        ?? (payload["show_id"] as? String)
                        ?? ""
                    let targetSellerId = (payload["target_host_id"] as? String)
                        ?? (payload["seller_id"] as? String)
                        ?? ""
                    let targetSellerName = (payload["target_host_name"] as? String)
                        ?? (payload["seller_name"] as? String)
                        ?? "Seller"
                    let targetContext = LiveShowContext(
                        showId: targetShowId,
                        roomId: targetRoom,
                        rtcToken: rtcToken,
                        agoraAppId: appId,
                        sellerId: targetSellerId,
                        sellerName: targetSellerName,
                        sellerImage: payload["seller_image"] as? String,
                        categoryId: nil,
                        auctionTypeId: nil,
                        productIds: [],
                        isHost: false
                    )
                    self.leaveEverything()
                    let vc = WatchStreamViewController()
                    vc.context = targetContext
                    vc.currentUserId = self.currentUserId
                    vc.currentUserName = self.currentUserName
                    vc.currentUserImage = self.currentUserImage
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                    return
                }
                self.appendSystemChat("Raid target is missing rtc token, staying in current room.")
            })
            self.present(alert, animated: true)
        }

        socket.onPollCreated { [weak self] payload in
            guard let self = self, let context = self.context else { return }
            self.appendSystemChat("Poll started: \(payload["question"] as? String ?? "")")
            if let data = LivePollSheet.PollData.from(payload: payload, fallbackRoomId: context.roomId) {
                let sheet = LivePollSheet(data: data, currentUserId: self.currentUserId)
                sheet.onDismiss = { [weak self] in self?.pollSheet = nil }
                self.pollSheet = sheet
                self.present(sheet, animated: true)
            }
        }
        socket.onPollUpdate { [weak self] payload in
            self?.pollSheet?.update(with: payload)
        }
        socket.onPollVoteResult { [weak self] payload in
            self?.pollSheet?.update(with: payload)
        }
        socket.onPollEnded { [weak self] _ in
            self?.appendSystemChat("Poll ended.")
            self?.pollSheet?.dismiss(animated: true)
            self?.pollSheet = nil
        }
        socket.onVoteError { [weak self] payload in
            let msg = payload["message"] as? String ?? "Unable to cast vote."
            self?.appendSystemChat(msg)
        }

        socket.onFreebie { [weak self] payload in
            guard let self = self, let context = self.context else { return }
            self.appendSystemChat("Freebie / randomizer running!")
            let title = (payload["product"] as? [String: Any])?["title"] as? String
                ?? (payload["product_title"] as? String)
                ?? self.currentProductTitle
            let duration: Int = {
                if let i = payload["time"] as? Int { return i }
                if let s = payload["time"] as? String, let i = Int(s) { return i }
                return 0
            }()
            if self.freebieSheet != nil { return }
            let sheet = LiveFreebieSheet(
                roomId: context.roomId,
                currentUserId: self.currentUserId,
                productTitle: title ?? "",
                durationSeconds: duration
            )
            self.freebieSheet = sheet
            self.present(sheet, animated: true)
        }
        socket.onFreebieWinner { [weak self] payload in
            let name = (payload["user_name"] as? String) ?? "Someone"
            self?.appendSystemChat("\(name) won the freebie.")
            self?.freebieSheet?.announceWinner(name)
        }

        socket.onTipSettingUpdated { [weak self] payload in
            if let msg = payload["tip_message"] as? String, !msg.isEmpty {
                self?.latestTipMessage = msg
                self?.appendSystemChat("Tip note: \(msg)")
            }
        }

        socket.onAuctionNextProduct { [weak self] payload in
            guard let self = self else { return }
            if let title = (payload["product"] as? [String: Any])?["title"] as? String {
                self.currentProductTitle = title
                self.appendSystemChat("Now selling: \(title)")
            }
            if let pid = (payload["product"] as? [String: Any])?["id"] as? String
                ?? payload["product_id"] as? String {
                self.currentProductId = pid
            }
            self.currentHighestBidAmount = 0
            self.updateBidButtonAmount()
        }

        socket.onProductPinned { [weak self] payload in
            guard let self = self else { return }
            if let title = (payload["product"] as? [String: Any])?["title"] as? String {
                self.currentProductTitle = title
            }
        }

        socket.onRoomEnded { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            self.appendSystemChat("Show ended.")
        }
    }

    // MARK: Join/leave

    private func joinEverything() {
        guard let context = context else { return }
        let socket = BidcastSocketManager.shared
        socket.connect(userId: currentUserId.isEmpty ? "0" : currentUserId)
        socket.emitJoinRoom(roomId: context.roomId, userId: currentUserId)

        let agora = BidcastAgoraEngine.shared
        agora.delegate = self
        agora.configure(appId: context.agoraAppId)

        let uid = UInt(currentUserId) ?? 0
        agora.joinChannel(
            token: context.rtcToken,
            channel: context.roomId,
            uid: uid,
            role: .audience,
            localVideoView: nil
        )
    }

    private func leaveEverything() {
        guard let context = context else { return }
        let socket = BidcastSocketManager.shared
        socket.emitLeaveRoom(roomId: context.roomId, userId: currentUserId)
        BidcastAgoraEngine.shared.leaveChannel()
    }

    // MARK: Actions

    @objc private func tappedClose() {
        dismiss(animated: true)
    }

    // MARK: Bid actions

    private func nextBidAmount() -> Double {
        // Mirror Android WatchStreamFragment increment logic: next bid =
        // max(highest + $1, starting). If neither is known, bail to 1.
        let base = max(currentHighestBidAmount, startingBidAmount)
        return base > 0 ? base + 1 : 1
    }

    private func updateBidButtonAmount() {
        let next = nextBidAmount()
        bidButton.setTitle(String(format: "Bid $%.0f", next), for: .normal)
    }

    private func refreshBidControlsVisibility() {
        let shouldShow = !auctionClosed && allowBidForAll && lastBidTimerSeconds > 0
        bidButton.isHidden = !shouldShow
        maxBidButton.isHidden = !shouldShow
        if shouldShow { updateBidButtonAmount() }
    }

    @objc private func tappedBid() {
        guard let context = context else { return }
        // Server-side also enforces these, but we fail fast client-side too
        // so the host and viewer stay visually consistent.
        guard !auctionClosed else {
            appendSystemChat("Auction is closed — waiting on next item.")
            return
        }
        guard allowBidForAll else {
            appendSystemChat("Bidding is currently disabled.")
            return
        }
        guard lastBidTimerSeconds > 0 else {
            appendSystemChat("Timer ended — no more bids accepted.")
            return
        }
        let next = nextBidAmount()
        BidcastSocketManager.shared.emitPlaceBid(
            roomId: context.roomId,
            userId: currentUserId,
            userName: currentUserName,
            userImage: currentUserImage,
            productId: currentProductId,
            bidAmount: String(format: "%.0f", next),
            auctionTypeId: context.auctionTypeId
        )
    }

    @objc private func tappedMaxBid() {
        let alert = UIAlertController(title: "Max bid", message: "Set the most you're willing to pay. The system will bid for you up to this amount.", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.placeholder = "Max amount"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
            guard let self = self, let context = self.context else { return }
            let raw = alert.textFields?.first?.text ?? ""
            guard !raw.isEmpty else { return }
            BidcastSocketManager.shared.emitSetMaxBid(
                roomId: context.roomId,
                userId: self.currentUserId,
                productId: self.currentProductId,
                maxBid: raw
            )
            self.appendSystemChat("Max bid set to $\(raw).")
        })
        present(alert, animated: true)
    }

    @objc private func tappedTip() {
        guard let context = context else { return }
        let sheet = LiveTipSheet(
            roomId: context.roomId,
            showId: context.showId,
            sellerId: context.sellerId,
            currentUserId: currentUserId
        )
        sheet.onSent = { [weak self] amount in
            self?.appendSystemChat("You tipped $\(amount).")
        }
        present(sheet, animated: true)
    }

    @objc private func tappedRaid() {
        let alert = UIAlertController(title: "Raid", message: "Enter the target room id to raid into.", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Target room id"
            tf.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let self = self, let context = self.context else { return }
            let targetRoom = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !targetRoom.isEmpty else { return }
            BidcastSocketManager.shared.emitCreateRaid(
                sourceRoomId: context.roomId,
                targetRoomId: targetRoom,
                sourceHostId: context.sellerId,
                targetHostId: ""
            )
            self.appendSystemChat("Raid requested to room \(targetRoom).")
        })
        present(alert, animated: true)
    }

    @objc private func submitChat() {
        guard let context = context else { return }
        let text = (chatInput.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        BidcastSocketManager.shared.emitChat(
            roomId: context.roomId,
            userId: currentUserId,
            userName: currentUserName,
            userImage: currentUserImage,
            message: text
        )
        chatInput.text = ""
    }

    // MARK: Helpers

    private func roomMatches(_ payload: [String: Any]) -> Bool {
        guard let context = context else { return false }
        if let rid = payload["room_id"] as? String {
            return rid == context.roomId
        }
        return true
    }

    private func stringValue(from any: Any?) -> String? {
        if let s = any as? String { return s }
        if let i = any as? Int { return String(i) }
        if let d = any as? Double { return String(d) }
        return nil
    }

    private func appendChat(name: String, message: String) {
        chatMessages.append((name: name, message: message))
        chatTableView.reloadData()
        let last = chatMessages.count - 1
        if last >= 0 {
            chatTableView.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
        }
    }

    private func appendSystemChat(_ message: String) {
        appendChat(name: "system", message: message)
    }
}

// MARK: - UITableViewDataSource

extension WatchStreamViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatMessages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let entry = chatMessages[indexPath.row]
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.attributedText = NSAttributedString(
            string: "\(entry.name): \(entry.message)",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 13)
            ]
        )
        return cell
    }
}

// MARK: - BidcastAgoraEngineDelegate

extension WatchStreamViewController: BidcastAgoraEngineDelegate {

    public func agoraJoined(channel: String, uid: UInt) {
        #if DEBUG
        print("[WatchStream] agoraJoined channel=\(channel) uid=\(uid)")
        #endif
    }

    public func agoraLeft(channel: String) {}

    public func agoraRemoteJoined(uid: UInt) {
        BidcastAgoraEngine.shared.bindRemoteView(uid: uid, into: remoteVideoView)
    }

    public func agoraRemoteLeft(uid: UInt) {
        #if DEBUG
        print("[WatchStream] remote left uid=\(uid)")
        #endif
    }

    public func agoraError(_ error: String) {
        appendSystemChat("stream error: \(error)")
    }
}

// MARK: - UITextField helper

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftViewMode = .always
    }
}
