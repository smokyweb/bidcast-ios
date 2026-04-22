//
//  HostRaidSheet.swift
//  BidCast
//
//  iOS Parity Phase 6e (2026-04-22) — Host-side Raid target picker.
//
//  Mirrors:
//    - Android `AgoraPublisherActivity.showSellerSheet()`
//      (`SocketManager.kt` L391-428 `createRaid` / `receiveRaid`)
//    - PWA `#raidModal` in startShow.blade.php (2026-04-22).
//
//  Socket contract (already in BidcastSocketManager.emitCreateRaid):
//    createRaid { source_room_id, target_room_id,
//                 source_host_id, target_host_id }
//
//  Flow:
//    1. Fetch currently-live hosts via GET /api/get-live-seller.
//    2. Host taps a seller row → Raid button enables.
//    3. Tap Raid → emit createRaid, then leaveRoom + endRoom on the
//       source room, dismiss, and signal the host VC via `onRaidSent`
//       so it can tear itself down and return to the home screen.
//
//  Note: the `target_rtc_token` the viewers need in order to hop
//  channels in-place is looked up server-side and echoed back in the
//  `receiveRaid` payload — no iOS-side token fetch needed here.
//

import UIKit

public final class HostRaidSheet: UIViewController {

    public var sourceRoomId: String
    public var sourceHostId: String
    public var onRaidSent: ((_ targetRoomId: String, _ targetHostId: String) -> Void)?

    private let table = UITableView()
    private let loader = UIActivityIndicatorView(style: .medium)
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No other hosts are live right now."
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    private let raidButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Raid"
        cfg.baseBackgroundColor = .systemPurple
        b.configuration = cfg
        b.isEnabled = false
        return b
    }()
    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        return b
    }()

    private var hosts: [LiveSellerEntry] = []
    private var selectedIndex: Int?

    public init(sourceRoomId: String, sourceHostId: String) {
        self.sourceRoomId = sourceRoomId
        self.sourceHostId = sourceHostId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Raid"
        setupLayout()
        Task { await load() }
    }

    private func setupLayout() {
        table.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        raidButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let hint = UILabel()
        hint.text = "Send your viewers to another live host. They'll hop channels automatically."
        hint.font = .systemFont(ofSize: 13)
        hint.textColor = .secondaryLabel
        hint.numberOfLines = 0
        hint.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hint)
        view.addSubview(table)
        view.addSubview(loader)
        view.addSubview(emptyLabel)
        view.addSubview(raidButton)
        view.addSubview(cancelButton)

        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "host")
        table.rowHeight = 56
        table.backgroundColor = .clear

        raidButton.addTarget(self, action: #selector(raidTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            hint.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            hint.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hint.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            table.topAnchor.constraint(equalTo: hint.bottomAnchor, constant: 10),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: raidButton.topAnchor, constant: -10),

            loader.centerXAnchor.constraint(equalTo: table.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: table.centerYAnchor),

            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emptyLabel.centerYAnchor.constraint(equalTo: table.centerYAnchor),

            raidButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            raidButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            raidButton.heightAnchor.constraint(equalToConstant: 46),
            raidButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),

            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    @MainActor
    private func load() async {
        loader.startAnimating()
        emptyLabel.isHidden = true
        do {
            let resp: GetLiveSellerResponse = try await APIManager.shared.request(
                type: APIEndPoint.getLiveSeller, header: true
            )
            var list: [LiveSellerEntry] = resp.data ?? []
            // Filter out self so host can't raid into their own show.
            list = list.filter { String($0.id ?? -1) != sourceHostId }
            self.hosts = list
            self.table.reloadData()
            self.emptyLabel.isHidden = !list.isEmpty
        } catch {
            debugLog("[Raid] get-live-seller error: \(error.localizedDescription)")
            self.emptyLabel.text = "Couldn't load live hosts. Try again shortly."
            self.emptyLabel.isHidden = false
        }
        loader.stopAnimating()
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func raidTapped() {
        guard let idx = selectedIndex, idx < hosts.count else { return }
        let picked = hosts[idx]
        let targetRoom = picked.roomId ?? ""
        let targetHostId = String(picked.id ?? 0)
        guard !targetRoom.isEmpty, targetHostId != "0" else { return }

        BidcastSocketManager.shared.emitCreateRaid(
            sourceRoomId: sourceRoomId,
            targetRoomId: targetRoom,
            sourceHostId: sourceHostId,
            targetHostId: targetHostId
        )
        onRaidSent?(targetRoom, targetHostId)
        dismiss(animated: true)
    }
}

extension HostRaidSheet: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        hosts.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "host", for: indexPath)
        let entry = hosts[indexPath.row]
        cell.textLabel?.text = entry.name ?? "Seller \(entry.id ?? 0)"
        cell.detailTextLabel?.text = "Room \(entry.roomId ?? "—")"
        cell.accessoryType = selectedIndex == indexPath.row ? .checkmark : .none
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        raidButton.isEnabled = true
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
