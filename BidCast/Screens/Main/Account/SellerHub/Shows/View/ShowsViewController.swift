//
//  ShowsViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//
//  FIXED (cmp3z7e4400k54axyxucdv6qm) 2026-05-13:
//  Replaced all hardcoded placeholder data ("MTG Cards Sale", "Feb 15, 2025",
//  "8:00 PM EST", "156 RSVPs") with real API calls:
//    • Upcoming tab  → POST api/get-my-schedule-show  (seller's scheduled shows)
//    • Past tab      → POST api/get-live-show  type=live  (previously-live shows)
//  Date and time fields now come from Show.date / Show.time returned by the API.
//

import UIKit
import SVProgressHUD
import Kingfisher

enum ShowsTransactionSection: Int, CaseIterable {
    case segment
    case showDetails
    case pastDetails

    func numberOfRows(data: [ShowsTransactionSection: Int]) -> Int {
        return data[self] ?? 1
    }
}

enum segmentType: String {
    case shows
    case pastShows
}

class ShowsViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!

    // MARK: - Properties

    var isPastShow = false
    var segmentType: segmentType = .shows

    /// Upcoming (scheduled) shows from api/get-my-schedule-show
    private var upcomingShows: [Show] = []
    /// Past / live shows from api/get-live-show
    private var pastShows: [Show] = []

    private var isLoadingUpcoming = false
    private var isLoadingPast = false

    var sectionData: [ShowsTransactionSection: Int] = [
        .segment: 1,
        .showDetails: 0,
        .pastDetails: 0
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    // MARK: - Setup

    private func loadInit() {
        configureTableView()
        configureHeaderView()
        fetchUpcomingShows()
    }

    private func configureTableView() {
        tblView.dataSource = self
        tblView.delegate = self
        let cellIds = [
            NoDataTableViewCell.identifier,
            SegmentCell.identifier,
            ShowInventoryCell.identifier
        ]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        tblView.configTblView(bgColor: .pearl)
    }

    func configureHeaderView() {
        headerView.headerViewSetup(
            rightButtonHidden: false,
            leftButtonHidden: false,
            headerName: AppString.VCName.shows
        )
    }

    @objc private func didTabBack() {
        goToBack()
    }

    // MARK: - Segment switching

    private func reloadDataForSelectedSegment() {
        switch segmentType {
        case .shows:
            sectionData = [
                .segment: 1,
                .showDetails: upcomingShows.isEmpty ? 1 : upcomingShows.count,
                .pastDetails: 0
            ]
        case .pastShows:
            sectionData = [
                .segment: 1,
                .showDetails: 0,
                .pastDetails: pastShows.isEmpty ? 1 : pastShows.count
            ]
        }
        tblView.reloadData()
    }

    // MARK: - API: Upcoming shows (api/get-my-schedule-show)

    private func fetchUpcomingShows() {
        guard !isLoadingUpcoming else { return }
        isLoadingUpcoming = true
        SVProgressHUD.show()

        Task { @MainActor in
            defer {
                self.isLoadingUpcoming = false
                SVProgressHUD.dismiss()
            }
            do {
                let resp: GetMyShowResponse = try await APIManager.shared.postMultipartForm(
                    type: .getMyScheduledShow(param: [:]),
                    fields: ["page": "1"],
                    header: true
                )
                self.upcomingShows = resp.data ?? []
            } catch {
                debugLog("[Shows] getMyScheduledShow failed: \(error.localizedDescription)")
                self.upcomingShows = []
            }
            // Also fetch past shows in parallel
            await fetchPastShows()
            reloadDataForSelectedSegment()
        }
    }

    // MARK: - API: Past / live shows (api/get-live-show type=live)

    private func fetchPastShows() async {
        guard !isLoadingPast else { return }
        isLoadingPast = true
        defer { isLoadingPast = false }

        do {
            let resp: GetMyShowResponse = try await APIManager.shared.postMultipartForm(
                type: .getLiveShow(param: [:]),
                fields: ["type": "live", "page": "1", "category": "all"],
                header: true
            )
            self.pastShows = resp.data ?? []
        } catch {
            debugLog("[Shows] getLiveShow (past) failed: \(error.localizedDescription)")
            self.pastShows = []
        }
    }

    // MARK: - Helpers

    /// Format Show.date + Show.time into a readable schedule string.
    /// API returns date as "YYYY-MM-DD" and time as "HH:mm:ss".
    private func formatSchedule(date: String?, time: String?) -> String {
        var parts: [String] = []
        if let d = date, !d.isEmpty {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let parsed = df.date(from: d) {
                let out = DateFormatter()
                out.dateFormat = "MMM d, yyyy"
                parts.append(out.string(from: parsed))
            } else {
                parts.append(d)
            }
        }
        if let t = time, !t.isEmpty {
            let tf = DateFormatter()
            tf.dateFormat = "HH:mm:ss"
            if let parsed = tf.date(from: t) {
                let out = DateFormatter()
                out.dateFormat = "h:mm a"
                parts.append(out.string(from: parsed))
            } else {
                // fallback: try shorter format
                let tf2 = DateFormatter()
                tf2.dateFormat = "HH:mm"
                if let parsed2 = tf2.date(from: t) {
                    let out = DateFormatter()
                    out.dateFormat = "h:mm a"
                    parts.append(out.string(from: parsed2))
                } else {
                    parts.append(t)
                }
            }
        }
        return parts.joined(separator: "  •  ")
    }

    private func thumbnailURL(for show: Show) -> URL? {
        let candidates = (show.imgThumbnail ?? []) + (show.thumbnail ?? [])
        return candidates.compactMap { $0.flatMap { URL(string: $0) } }.first
    }

    private func configure(cell: ShowInventoryCell, with show: Show) {
        cell.titleOlt.text = show.title ?? "Untitled show"
        cell.descriptionOlt.text = formatSchedule(date: show.date, time: show.time)
        cell.priceDeatilOlt.text = show.category?.name ?? ""
        let viewers = show.viewerCount ?? 0
        cell.stockOlt.text = viewers > 0 ? "\(viewers) viewers" : ""
        cell.selectionStyle = .none

        if let url = thumbnailURL(for: show) {
            cell.imageOlt.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "video.fill")
            )
        } else {
            cell.imageOlt.image = UIImage(systemName: "video.fill")
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ShowsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        ShowsTransactionSection.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ShowsTransactionSection(rawValue: section) else { return 0 }
        return sectionType.numberOfRows(data: sectionData)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ShowsTransactionSection.allCases[safe: indexPath.section] else {
            return UITableViewCell()
        }

        switch rowType {
        case .segment:
            let cell = tblView.dequeueCell(with: SegmentCell.self)
            cell.configure(isNavFor: "ShowVC")
            cell.onSegmentChanged = { [weak self] selectedIndex in
                guard let self = self else { return }
                self.segmentType = selectedIndex == 0 ? .shows : .pastShows
                self.reloadDataForSelectedSegment()
            }
            cell.selectionStyle = .none
            return cell

        case .showDetails:
            // Show empty-state if no upcoming shows
            if upcomingShows.isEmpty {
                let cell = tblView.dequeueCell(with: NoDataTableViewCell.self)
                return cell
            }
            let cell = tblView.dequeueCell(with: ShowInventoryCell.self)
            configure(cell: cell, with: upcomingShows[indexPath.row])
            return cell

        case .pastDetails:
            // Show empty-state if no past shows
            if pastShows.isEmpty {
                let cell = tblView.dequeueCell(with: NoDataTableViewCell.self)
                return cell
            }
            let cell = tblView.dequeueCell(with: ShowInventoryCell.self)
            configure(cell: cell, with: pastShows[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ShowsTransactionSection.allCases[safe: indexPath.section] else {
            return UITableView.automaticDimension
        }
        switch rowType {
        case .segment:
            return Const.Height.segment
        case .showDetails, .pastDetails:
            return Const.Height.AutomaticDimension
        }
    }
}
