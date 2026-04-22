//
//  TutorialsListViewController.swift
//  BidCast — iOS parity Phase 3h (2026-04-22)
//
//  GET /api/how-to-sell     -> HowToSellStep[]
//  GET /api/get-prepare     -> PrepareStep[]
//  GET /api/get-lesson      -> LessonEntry[]
//  Single segmented screen that flips between the three bundles.
//

import UIKit
import SVProgressHUD

final class TutorialsListViewController: UIViewController, UITableViewDataSource {

    private let segmented = UISegmentedControl(items: ["How to sell", "Prepare", "Lessons"])
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var howTo: [HowToSellStep] = []
    private var prepare: [PrepareStep] = []
    private var lessons: [LessonEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tutorials"
        view.backgroundColor = .systemBackground

        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "t")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70

        view.addSubview(segmented)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        loadAll()
    }

    private func loadAll() {
        SVProgressHUD.show()
        Task { @MainActor in
            // NOTE 2026-04-22: deferred dismiss matches the pattern used by
            // other Phase 3 screens (SellerOffersViewController /
            // P3AnalyticsViewController) and avoids the Swift 6 ambiguity
            // where `SVProgressHUD.dismiss()` inside an async context can
            // resolve to the async `dismissWithCompletion:` bridge.
            defer { SVProgressHUD.dismiss(withDelay: 0) }
            async let howTask: GetHowToSellResponse = APIManager.shared.request(type: .getHowToSellStep, header: true)
            async let prepTask: GetPrepareStepResponse = APIManager.shared.request(type: .getPrepareStep, header: true)
            async let lesTask: GetLessonsResponse = APIManager.shared.request(type: .getLesson, header: true)
            do {
                let how = try await howTask
                let prep = try await prepTask
                let les = try await lesTask
                self.howTo = how.data ?? []
                self.prepare = prep.data ?? []
                self.lessons = les.data ?? []
                self.tableView.reloadData()
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    @objc private func segmentChanged() { tableView.reloadData() }

    private var currentCount: Int {
        switch segmented.selectedSegmentIndex {
        case 0: return howTo.count
        case 1: return prepare.count
        case 2: return lessons.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "t", for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        cfg.textProperties.numberOfLines = 0
        cfg.secondaryTextProperties.numberOfLines = 0
        switch segmented.selectedSegmentIndex {
        case 0:
            let s = howTo[indexPath.row]
            cfg.text = s.title
            cfg.secondaryText = s.description
        case 1:
            let s = prepare[indexPath.row]
            cfg.text = s.title
            cfg.secondaryText = s.description
        default:
            let s = lessons[indexPath.row]
            cfg.text = s.title
            cfg.secondaryText = s.description
            cfg.image = UIImage(systemName: "play.rectangle")
        }
        cell.contentConfiguration = cfg
        return cell
    }
}
