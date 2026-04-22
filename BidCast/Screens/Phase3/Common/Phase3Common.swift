//
//  Phase3Common.swift
//  BidCast — iOS parity Phase 3 (2026-04-22)
//
//  Shared UIKit helpers used across Phase 3 feature screens. Keeps
//  each feature VC focused on data + layout and avoids re-implementing
//  the same navigation push / empty-state / error-alert boilerplate.
//
//  Naming: prefix `P3` to keep the namespace obviously Phase 3 so older
//  storyboard-based screens (HomeVC, AccountVC, SellerHub stubs) aren't
//  accidentally migrated onto this layer until we consciously decide to.
//

import UIKit

// MARK: - Navigation push helper (programmatic, no storyboard)

extension UIViewController {

    /// Programmatic push that tolerates being hosted inside a UITabBar /
    /// plain UIViewController container. Falls back to `present` with a
    /// wrapping UINavigationController when there's no nav stack.
    func p3Push(_ vc: UIViewController, animated: Bool = true) {
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: animated)
        } else if let tabNav = self.tabBarController?.navigationController {
            tabNav.pushViewController(vc, animated: animated)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: animated)
        }
    }

    /// Show a simple error alert.
    func p3Alert(title: String = "Error",
                 message: String,
                 okTitle: String = "OK",
                 completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default) { _ in completion?() }
        )
        self.present(alert, animated: true)
    }

    /// Confirm-style two-button alert (Yes/No).
    func p3Confirm(title: String,
                   message: String,
                   yesTitle: String = "Yes",
                   noTitle: String = "Cancel",
                   destructive: Bool = false,
                   onYes: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: noTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: yesTitle,
                                      style: destructive ? .destructive : .default) { _ in onYes() })
        self.present(alert, animated: true)
    }
}

// MARK: - Pagination state

/// Lightweight struct that every paginated ViewModel in Phase 3 uses to
/// track `isLoading`, `currentPage`, `hasMore`.
struct P3Paging {
    var page: Int = 1
    var totalPages: Int = 1
    var isLoading: Bool = false
    var hasMore: Bool { page <= totalPages }

    mutating func reset() { page = 1; totalPages = 1; isLoading = false }
    mutating func advance(from response: P3PaginationInfo?) {
        guard let r = response else { totalPages = page; return }
        page += 1
        totalPages = r.totalPages ?? page
    }
}

/// Minimal pagination info extracted from any backend envelope
/// (covers both `total_page` + `totalPage` spellings seen on the BidCast
/// backend).
struct P3PaginationInfo {
    let currentPage: Int?
    let totalPages: Int?
}

// MARK: - Empty state view

/// Drop-in "no results / broken state" view used by every list screen.
final class P3EmptyStateView: UIView {

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .center
        s.spacing = 12
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    let iconView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.tintColor = UIColor.systemGray3
        v.widthAnchor.constraint(equalToConstant: 56).isActive = true
        v.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return v
    }()

    let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    init(icon: UIImage? = UIImage(systemName: "tray"),
         title: String = "Nothing here yet",
         message: String = "") {
        super.init(frame: .zero)
        iconView.image = icon
        titleLabel.text = title
        messageLabel.text = message
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(stack)
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
    }

    func update(title: String, message: String = "") {
        titleLabel.text = title
        messageLabel.text = message
    }
}

// MARK: - Base list view controller

/// UITableView wrapper that every Phase 3 list screen subclasses. Handles:
///  - refreshControl + pull-to-refresh
///  - empty-state swap
///  - bottom-of-scroll infinite scroll hook
///  - "Retry" from error alert -> re-invoke `loadInitial()`.
class P3ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 80
        t.tableFooterView = UIView()
        return t
    }()

    let refreshControl = UIRefreshControl()
    let emptyState = P3EmptyStateView()
    var emptyStateIsVisible: Bool = false {
        didSet { emptyState.isHidden = !emptyStateIsVisible }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(p3HandleRefresh), for: .valueChanged)

        view.addSubview(emptyState)
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        emptyState.isHidden = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyState.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyState.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func p3HandleRefresh() {
        reloadData()
    }

    /// Subclasses override to kick off a fresh fetch.
    func reloadData() { /* override */ }

    // MARK: - Required UITableView stubs (subclasses override)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }

    func stopRefresh() {
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }
}

// MARK: - Image loading shim (Kingfisher optional)

extension UIImageView {
    /// Convenience `setImage` that uses Kingfisher if imported, otherwise
    /// falls back to a background URLSession load. Callers already pull
    /// Kingfisher from Podfile.
    func p3Load(_ urlString: String?, placeholder: UIImage? = nil) {
        self.image = placeholder
        guard let s = urlString, let url = URL(string: s) else { return }
        // Use URLSession directly to avoid a hard-dep on Kingfisher here;
        // Kingfisher-using callers can do their own thing.
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.image = img }
        }.resume()
    }
}

// MARK: - Amount / date formatters

enum P3Format {
    static let currency: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = "$"
        f.maximumFractionDigits = 2
        return f
    }()

    static func currency(_ value: Double?) -> String {
        guard let v = value else { return "—" }
        return currency.string(from: NSNumber(value: v)) ?? "$\(v)"
    }

    static func currency(_ stringValue: String?) -> String {
        guard let s = stringValue, let d = Double(s) else { return stringValue ?? "—" }
        return currency(d)
    }

    static let dateIn: ISO8601DateFormatter = ISO8601DateFormatter()
    static let dateOut: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static func date(_ iso: String?) -> String {
        guard let iso = iso, !iso.isEmpty else { return "—" }
        if let d = dateIn.date(from: iso) {
            return dateOut.string(from: d)
        }
        // Fallback for `yyyy-MM-dd HH:mm:ss` which Laravel often emits.
        let fallback = DateFormatter()
        fallback.dateFormat = "yyyy-MM-dd HH:mm:ss"
        fallback.timeZone = TimeZone(identifier: "UTC")
        if let d = fallback.date(from: iso) {
            return dateOut.string(from: d)
        }
        return iso
    }
}
