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

    private let pinnedCard = PinnedProductCard()

    // QA-FIX-cmo93i6xk00oc3u1hmlx3xtof polish: "Winning: {name}" / "You're
    // winning!" chip under the pinned card. Driven from onHighestBid +
    // resetPerItemBidState.
    private let leaderChip: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .boldSystemFont(ofSize: 11)
        l.textColor = .white
        l.text = ""
        l.textAlignment = .center
        l.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        l.layer.cornerRadius = 8
        l.layer.masksToBounds = true
        l.isHidden = true
        return l
    }()

    // Private "Your max: $X" indicator — only visible to the local user.
    // Updated whenever the local user sets a proxy max bid.
    private let myMaxBidLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 10, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.65)
        l.textAlignment = .center
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.text = ""
        l.isHidden = true
        return l
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
    /// Bounded chat buffer (200-msg cap + dedup by message id).
    /// See BidCast/Live/Chat/LiveChatMessage.swift.
    private let chatBuffer = LiveChatBuffer(capacity: 200)
    private let statusBanner = LiveBanner()
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

    // QA-FIX-cmo93i77500oe3u1h32urq42p (iOS parity with Android bfc09c4):
    // Track whether the current item has received at least one live bid
    // since it started. If the bid timer expires with zero bids we must
    // locally end the item and stop letting users bid (server does not
    // emit bid_finalized for no-bid items, so without this flag the bid
    // button stays live forever).
    private var hasActiveBid: Bool = false

    // QA-FIX-cmo93i77500oe3u1h32urq42p: once the timer has expired locally
    // (no-bid case) OR server-finalized, block further bid emits until a
    // new auction starts.
    private var isBiddingClosed: Bool = false

    // QA-FIX-cmo93i6xk00oc3u1hmlx3xtof (iOS parity with Android bfc09c4):
    // user id of the current leader on the live auction. Used to detect
    // "I am the current winner" so that the max-bid input sheet acts as
    // a proxy ceiling instead of immediately bumping the public bid.
    private var currentLeaderUserId: String = ""

    // QA-FIX-cmo93i6xk00oc3u1hmlx3xtof: the logged-in user's pending proxy
    // ceiling (max bid) for the current auction. When another user places
    // a bid below this ceiling, the backend should auto-bump the leader's
    // public bid by one increment (proxy-bid behavior).
    private var myProxyMaxBid: Double = 0

    // Cached display name of the current leader — used by the
    // "Winning: {name}" chip. Captured from onHighestBid payload.
    private var currentLeaderName: String = ""

    // Tracks the last integer second we fired a haptic on, so we don't
    // repeat-fire haptics when bid_timer_update arrives multiple times
    // in the same second.
    private var lastHapticTickSecond: Int = -1
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
        view.addSubview(statusBanner)
        view.addSubview(closeButton)
        view.addSubview(viewerCountLabel)
        view.addSubview(bidTimerLabel)
        view.addSubview(highestBidLabel)
        view.addSubview(pinnedCard)
        view.addSubview(leaderChip)
        view.addSubview(myMaxBidLabel)
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

            statusBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            statusBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusBanner.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            statusBanner.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

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

            pinnedCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            pinnedCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            pinnedCard.bottomAnchor.constraint(equalTo: chatTableView.topAnchor, constant: -8),
            pinnedCard.heightAnchor.constraint(equalToConstant: 78),

            leaderChip.topAnchor.constraint(equalTo: pinnedCard.bottomAnchor, constant: 4),
            leaderChip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            leaderChip.heightAnchor.constraint(equalToConstant: 18),
            leaderChip.widthAnchor.constraint(greaterThanOrEqualToConstant: 110),

            myMaxBidLabel.centerYAnchor.constraint(equalTo: leaderChip.centerYAnchor),
            myMaxBidLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            myMaxBidLabel.heightAnchor.constraint(equalToConstant: 18),
            myMaxBidLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),

            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            chatTableView.bottomAnchor.constraint(equalTo: chatInput.topAnchor, constant: -8),
            chatTableView.heightAnchor.constraint(equalToConstant: 180),

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
        chatTableView.register(LiveChatMessageCell.self, forCellReuseIdentifier: LiveChatMessageCell.reuseId)
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(tappedClose), for: .touchUpInside)
        chatInput.addTarget(self, action: #selector(submitChat), for: .editingDidEndOnExit)
        bidButton.addTarget(self, action: #selector(tappedBid), for: .touchUpInside)
        maxBidButton.addTarget(self, action: #selector(tappedMaxBid), for: .touchUpInside)
        tipButton.addTarget(self, action: #selector(tappedTip), for: .touchUpInside)
        raidButton.addTarget(self, action: #selector(tappedRaid), for: .touchUpInside)
        pinnedCard.onTap = { [weak self] in self?.tappedBid() }
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
                // Parse defensively — if the server ever sends non-numeric,
                // treat as Int.max (still running) so we don't prematurely
                // close the item on a bad payload. Mirrors Android bfc09c4.
                self.lastBidTimerSeconds = Int(Double(remainingStr) ?? Double(Int.max))
                self.pinnedCard.updateTimer(seconds: self.lastBidTimerSeconds)
                // When an auction is live (timer > 0) show bid controls
                if (self.lastBidTimerSeconds) > 0 {
                    self.auctionClosed = false
                } else {
                    self.auctionClosed = true
                }
                self.refreshBidControlsVisibility()
                self.applyCountdownPolish(seconds: self.lastBidTimerSeconds)

                // QA-FIX-cmo93i77500oe3u1h32urq42p: timer hit zero AND nobody
                // ever bid on this item → the server is not going to emit
                // bid_finalized, so we must end the item locally: hide the
                // bid controls and flip isBiddingClosed so any further tap
                // is refused. Mirrors Android WatchStreamFragment bfc09c4.
                if self.lastBidTimerSeconds <= 0 && !self.hasActiveBid && !self.isBiddingClosed {
                    self.isBiddingClosed = true
                    self.bidTimerLabel.isHidden = true
                    self.bidButton.isHidden = true
                    self.maxBidButton.isHidden = true
                    self.appendSystemChat("No bids — item ended.")
                }
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
                self.pinnedCard.updateHighestBid(self.currentHighestBidAmount)
            }
            if let pid = payload["product_id"] as? String {
                self.currentProductId = pid
            }

            // QA-FIX-cmo93i77500oe3u1h32urq42p: a real bid arrived, so the
            // item is no longer "no-bid". The timer-expiry safety net
            // should not fire for this item.
            self.hasActiveBid = true
            self.isBiddingClosed = false

            // QA-FIX-cmo93i6xk00oc3u1hmlx3xtof: remember who the current
            // leader is so the max-bid input sheet can switch between
            // "proxy ceiling" (leader) and "normal public bid" (challenger).
            let bidderUserId = self.stringValue(from: payload["user_id"]) ?? ""
            self.currentLeaderUserId = bidderUserId
            self.currentLeaderName = (payload["user_name"] as? String) ?? ""
            // If someone else took the lead, clear our stale proxy ceiling
            // so we don't silently skip real bids later.
            if bidderUserId != self.currentUserId {
                self.myProxyMaxBid = 0
                self.updateMyMaxBidIndicator()
            }
            self.updateLeaderDisplay()
        }

        socket.onBidFinalized { [weak self] payload in
            guard let self = self, self.roomMatches(payload) else { return }
            self.bidTimerLabel.isHidden = true
            self.auctionClosed = true
            // QA-FIX-cmo93i77500oe3u1h32urq42p: server-side finalize should
            // also lock out further client bid attempts until the next
            // auction starts.
            self.isBiddingClosed = true
            self.refreshBidControlsVisibility()
            self.pinnedCard.updateTimer(seconds: 0)
            if let winner = payload["user_name"] as? String,
               let amount = self.stringValue(from: payload["bid_amount"]) {
                self.appendSystemChat("\(winner) won at $\(amount)")
            }
        }

        socket.onAuctionStarted { [weak self] payload in
            guard let self = self else { return }
            // QA-FIX-cmo93i77500oe3u1h32urq42p / cmo93i6xk00oc3u1hmlx3xtof:
            // reset per-item flags on every new auction so a previously
            // ended item doesn't leave bid layout hidden / stale leader.
            self.resetPerItemBidState()
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
            let msg = LiveChatMessage.fromChatPayload(payload)
            self.appendChatMessage(msg)
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
            // QA-FIX-cmo93i77500oe3u1h32urq42p / cmo93i6xk00oc3u1hmlx3xtof:
            // reset per-item flags + fade the pinned card in on rotation.
            self.animatePinnedCardRotation {
                if let title = (payload["product"] as? [String: Any])?["title"] as? String {
                    self.currentProductTitle = title
                    self.appendSystemChat("Now selling: \(title)")
                    self.pinnedCard.updateTitle(title)
                }
                if let pid = (payload["product"] as? [String: Any])?["id"] as? String
                    ?? payload["product_id"] as? String {
                    self.currentProductId = pid
                }
                self.currentHighestBidAmount = 0
                self.updateBidButtonAmount()
                self.pinnedCard.updateHighestBid(0)
                self.resetPerItemBidState()
            }
        }

        socket.onProductPinned { [weak self] payload in
            guard let self = self else { return }
            if let title = (payload["product"] as? [String: Any])?["title"] as? String {
                self.currentProductTitle = title
                self.pinnedCard.updateTitle(title)
            }
            if let pid = (payload["product"] as? [String: Any])?["id"] as? String
                ?? payload["product_id"] as? String {
                self.currentProductId = pid
            }
        }

        socket.onProductUnpinned { [weak self] _ in
            self?.currentProductTitle = ""
            self?.pinnedCard.updateTitle(nil)
            self?.pinnedCard.updateHighestBid(0)
            self?.pinnedCard.updateTimer(seconds: -1)
            self?.resetPerItemBidState()
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
        // Show a persistent "Reconnecting..." banner while the socket is
        // disconnected, and clear it once we reconnect. Matches Android's
        // WatchStreamFragment connection banner.
        socket.onConnectionChange { [weak self] connected in
            guard let self = self else { return }
            if connected {
                self.statusBanner.hide()
            } else {
                self.statusBanner.show("Reconnecting...", style: .warning, duration: 0)
            }
        }

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
        // QA-FIX-cmo93i77500oe3u1h32urq42p: refuse bids once the item has
        // ended locally (no-bid timer expiry) or server-side. Mirrors
        // Android WatchStreamFragment.attemptBid() in bfc09c4.
        guard !isBiddingClosed else {
            appendSystemChat("This item has ended.")
            return
        }
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
        // QA-FIX-cmo93i77500oe3u1h32urq42p: block max-bid on ended items.
        guard !isBiddingClosed else {
            appendSystemChat("This item has ended.")
            return
        }

        // QA-FIX-cmo93i6xk00oc3u1hmlx3xtof (iOS parity with Android bfc09c4):
        // Proxy-bid behavior. If the current user is already the winning
        // bidder, the typed amount is a *max bid ceiling*, not a new public
        // bid. We must NOT emit place_bid — that would publicly bump the
        // displayed bid right away. Instead we store it locally and tell
        // the server about the new ceiling via set_max_bid. The public bid
        // should only auto-increase when someone else bids under this
        // ceiling (backend proxy logic).
        let amImLeader = !currentLeaderUserId.isEmpty &&
                         currentLeaderUserId == currentUserId

        let title = amImLeader ? "Raise your max bid" : "Place bid"
        let message = amImLeader
            ? "You're already winning — this will raise your max bid without bumping the visible bid."
            : "Enter an amount greater than the current highest bid."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.placeholder = amImLeader ? "Your max ceiling" : "Bid amount"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: amImLeader ? "Set max" : "Place bid",
                                      style: .default) { [weak self] _ in
            guard let self = self, let context = self.context else { return }
            let raw = (alert.textFields?.first?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !raw.isEmpty, let priceVal = Double(raw) else { return }

            // Guard against downward bids — mirrors Android price validation.
            if priceVal <= self.currentHighestBidAmount && !amImLeader {
                self.appendSystemChat("Bid amount must be greater than the current highest bid.")
                return
            }

            if amImLeader {
                // Leader → proxy ceiling only. Do NOT emit place_bid.
                self.myProxyMaxBid = priceVal
                BidcastSocketManager.shared.emitSetMaxBid(
                    roomId: context.roomId,
                    userId: self.currentUserId,
                    productId: self.currentProductId,
                    maxBid: raw
                )
                self.updateMyMaxBidIndicator()
                self.appendSystemChat("Max bid set. Your bid will auto-increase only if someone else bids.")
            } else {
                // Non-leader → standard place_bid. Takes the lead at this amount.
                BidcastSocketManager.shared.emitPlaceBid(
                    roomId: context.roomId,
                    userId: self.currentUserId,
                    userName: self.currentUserName,
                    userImage: self.currentUserImage,
                    productId: self.currentProductId,
                    bidAmount: raw,
                    auctionTypeId: context.auctionTypeId
                )
                self.appendSystemChat("Bid placed at $\(raw).")
            }
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
        let m = LiveChatMessage(
            senderName: name,
            senderImage: nil,
            body: message
        )
        appendChatMessage(m)
    }

    private func appendChatMessage(_ message: LiveChatMessage) {
        let added = chatBuffer.append(message)
        if !added { return }
        chatTableView.reloadData()
        let last = chatBuffer.messages.count - 1
        if last >= 0 {
            chatTableView.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: false)
        }
    }

    private func appendSystemChat(_ message: String) {
        appendChatMessage(.system(message))
    }

    // MARK: - QA-FIX bid state helpers (Android bfc09c4 parity)

    /// Reset per-item bid state on a new item event. Mirrors Android
    /// WatchStreamFragment blocks in auction_started / break_spot /
    /// room-state / auction_next_product handlers (bfc09c4).
    private func resetPerItemBidState() {
        hasActiveBid = false
        isBiddingClosed = false
        currentLeaderUserId = ""
        myProxyMaxBid = 0
        lastHapticTickSecond = -1
        stopTimerPulse()
        updateLeaderDisplay()
        updateMyMaxBidIndicator()
    }

    /// Show "Winning: {leader_name}" chip under the pinned card, or
    /// "You're winning!" if the current user is the leader.
    private func updateLeaderDisplay() {
        guard !currentLeaderUserId.isEmpty else {
            leaderChip.isHidden = true
            return
        }
        if currentLeaderUserId == currentUserId {
            leaderChip.text = "  👑 You're winning!  "
            leaderChip.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.85)
        } else {
            // We don't always have the leader's name in scope here; the
            // last onHighestBid set currentLeaderName if available.
            let name = currentLeaderName.isEmpty ? "Another bidder" : currentLeaderName
            leaderChip.text = "  Winning: \(name)  "
            leaderChip.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        }
        leaderChip.isHidden = false
    }

    /// Show/hide the private "Your max: $X" indicator for the current user.
    private func updateMyMaxBidIndicator() {
        if myProxyMaxBid > 0 {
            myMaxBidLabel.text = String(format: "  Your max: $%.0f  ", myProxyMaxBid)
            myMaxBidLabel.isHidden = false
        } else {
            myMaxBidLabel.isHidden = true
        }
    }

    /// Animate the pinned card: fade out, call mutate() to swap data,
    /// then fade back in. Used on auction_next_product (timer-driven
    /// rotation from `run_next_product`).
    private func animatePinnedCardRotation(mutate: @escaping () -> Void) {
        UIView.animate(withDuration: 0.18, animations: { [weak self] in
            self?.pinnedCard.alpha = 0.0
        }, completion: { [weak self] _ in
            mutate()
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.pinnedCard.alpha = 1.0
            }
        })
    }

    // MARK: Countdown polish (red + pulse under 10s, haptic under 5s)

    private func applyCountdownPolish(seconds: Int) {
        if seconds <= 0 {
            stopTimerPulse()
            bidTimerLabel.textColor = .white
            return
        }
        if seconds <= 10 {
            bidTimerLabel.textColor = .systemRed
            startTimerPulse()
        } else {
            bidTimerLabel.textColor = .white
            stopTimerPulse()
        }
        if seconds <= 5 && seconds != lastHapticTickSecond {
            lastHapticTickSecond = seconds
            let gen = UIImpactFeedbackGenerator(style: seconds == 1 ? .heavy : .light)
            gen.impactOccurred()
        }
    }

    private func startTimerPulse() {
        guard bidTimerLabel.layer.animation(forKey: "pulse") == nil else { return }
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1.0
        anim.toValue = 0.45
        anim.duration = 0.5
        anim.autoreverses = true
        anim.repeatCount = .infinity
        bidTimerLabel.layer.add(anim, forKey: "pulse")
    }

    private func stopTimerPulse() {
        bidTimerLabel.layer.removeAnimation(forKey: "pulse")
        bidTimerLabel.layer.opacity = 1.0
    }
}

// MARK: - UITableViewDataSource

extension WatchStreamViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatBuffer.messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveChatMessageCell.reuseId, for: indexPath) as! LiveChatMessageCell
        cell.configure(with: chatBuffer.messages[indexPath.row])
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
        statusBanner.show("Video error: \(error)", style: .error, duration: 3.0)
    }

    public func agoraConnectionStateChanged(state: Int, reason: Int) {
        // Agora connection states (iOS SDK): 1=disconnected, 2=connecting,
        // 3=connected, 4=reconnecting, 5=failed
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

// MARK: - UITextField helper

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftViewMode = .always
    }
}
