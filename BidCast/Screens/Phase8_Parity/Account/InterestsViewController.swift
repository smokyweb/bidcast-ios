//
//  InterestsViewController.swift
//  BidCast — iOS Parity Phase 8 / P0.6 (2026-04-23)
//
//  Stub reachable from the Account tab grid. Android's
//  `InterestsFragment` lets users pick favorite categories; porting the
//  full multi-select sheet is scheduled for a later phase. For P0 we
//  give QA something to tap into with the category context visible.
//

import UIKit
import Kingfisher

final class InterestsViewController: UIViewController {

    private var categories: [CategoryModel] = []
    private let stack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Interests"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        buildLayout()
        Task { await loadCategories() }
    }

    private func buildLayout() {
        let header = UILabel()
        header.text = "Pick the categories you care about most."
        header.font = .systemFont(ofSize: 14)
        header.textColor = .secondaryLabel
        header.numberOfLines = 0
        header.textAlignment = .center

        let todo = UILabel()
        todo.text = "Multi-select + save will come in a follow-up phase (P2)."
        todo.font = .systemFont(ofSize: 12, weight: .semibold)
        todo.textColor = .tertiaryLabel
        todo.numberOfLines = 0
        todo.textAlignment = .center

        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])
        stack.addArrangedSubview(header)
        stack.addArrangedSubview(todo)
    }

    @MainActor
    private func loadCategories() async {
        do {
            let resp: ExploreGetCategoryResponse = try await APIManager.shared.request(
                type: APIEndPoint.getCategory, header: true
            )
            self.categories = resp.data ?? []
            renderChips()
        } catch {
            debugLog("[Interests] getCategory failed -> \(error.localizedDescription)")
        }
    }

    private func renderChips() {
        // Remove any existing chip rows (keep header + todo)
        while stack.arrangedSubviews.count > 2 {
            stack.arrangedSubviews.last?.removeFromSuperview()
        }

        // Simple 2-column wrap using nested stack rows. Good enough for stub.
        var row: UIStackView?
        for (idx, cat) in categories.enumerated() {
            if idx % 2 == 0 {
                row = UIStackView()
                row?.axis = .horizontal
                row?.spacing = 12
                row?.distribution = .fillEqually
                stack.addArrangedSubview(row!)
            }
            let chip = makeChip(title: cat.name ?? "Category")
            row?.addArrangedSubview(chip)
        }
        // Pad the last row so chips don't stretch too wide
        if let r = row, r.arrangedSubviews.count == 1 {
            let pad = UIView()
            r.addArrangedSubview(pad)
        }
    }

    private func makeChip(title: String) -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 10
        let l = UILabel()
        l.text = title
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(l)
        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 12),
            l.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -12),
            l.topAnchor.constraint(equalTo: v.topAnchor, constant: 14),
            l.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -14)
        ])
        return v
    }
}
