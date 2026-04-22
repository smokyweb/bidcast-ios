//
//  ScheduledShowsViewController.swift
//  BidCast — iOS parity Phase 3g (2026-04-22)
//
//  POST /api/get-my-schedule-show — paginated list of the seller's
//  upcoming + past scheduled shows. Tap to edit, swipe to delete.
//

import UIKit
import SVProgressHUD

final class ScheduledShowsViewController: P3ListViewController {

    private var shows: [Show] = []
    private var paging = P3Paging()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scheduled Shows"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self,
            action: #selector(scheduleNew))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "show")
        emptyState.update(title: "No scheduled shows",
                          message: "Schedule a show to go live with products.")
        load(reset: true)
    }

    override func reloadData() { load(reset: true) }

    private func load(reset: Bool) {
        if reset { paging.reset(); shows = [] }
        guard !paging.isLoading, paging.hasMore else { return }
        paging.isLoading = true
        SVProgressHUD.show()

        Task { @MainActor in
            defer {
                self.paging.isLoading = false
                SVProgressHUD.dismiss()
                self.stopRefresh()
            }
            do {
                let fields = ["page": "\(paging.page)"]
                let resp: GetMyShowResponse = try await APIManager.shared.postMultipartForm(
                    type: .getMyScheduledShow(param: [:]),
                    fields: fields, header: true
                )
                let newItems = resp.data ?? []
                if reset { self.shows = newItems } else { self.shows.append(contentsOf: newItems) }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage, totalPages: resp.totalPage))
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.shows.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    @objc private func scheduleNew() {
        p3Push(ScheduleShowEditorViewController(mode: .create))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shows.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "show", for: indexPath)
        let s = shows[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = s.title ?? "Untitled show"
        let dt = [s.date, s.time].compactMap { $0 }.joined(separator: " at ")
        let prod = s.productIds?.count ?? s.products?.count ?? 0
        cfg.secondaryText = "\(dt)  •  \(prod) product\(prod == 1 ? "" : "s")"
        cfg.image = UIImage(systemName: (s.isLive == true) ? "dot.radiowaves.left.and.right" : "calendar")
        cfg.imageProperties.tintColor = (s.isLive == true) ? .systemRed : .systemBlue
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        p3Push(ScheduleShowEditorViewController(mode: .edit(shows[indexPath.row])))
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= shows.count - 3 { load(reset: false) }
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, done in
            self?.shareShow(self?.shows[indexPath.row]); done(true)
        }
        share.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [share])
    }

    private func shareShow(_ show: Show?) {
        guard let show = show, let id = show.id else { return }
        let url = "https://bidcast.betaplanets.com/shows/\(id)"
        let text = "Check out my upcoming show: \(show.title ?? "") — \(url)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(av, animated: true)
    }
}
