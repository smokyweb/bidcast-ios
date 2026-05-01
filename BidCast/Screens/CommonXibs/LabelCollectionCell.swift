//
//  LabelCollectionCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 07/05/25.
//
//  VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): the home feed used
//  to render `Live Now | Popular | Coming Soon` as a single static label with
//  literal pipe separators. Android renders three discrete tappable tabs with
//  the active tab in solid black/bold and inactive tabs in mediumLightGray
//  (see fragment_home.xml > heading LinearLayout). This cell is now a
//  programmatic 3-tab row that matches that.
//
//  Tap callbacks are exposed via `didTapTab` so the parent (HomeViewController)
//  can trigger filter changes when filtering is wired up. The chosen index is
//  also remembered visually so the cell can be reconfigured after dequeue.
//

import UIKit

class LabelCollectionCell: UICollectionViewCell {

    @IBOutlet weak var labelOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    static let identifier = "LabelCollectionCell"

    /// Index of the currently active tab (0 = Live Now, 1 = Popular, 2 = Coming Soon).
    var selectedIndex: Int = 0 {
        didSet { applyTabStyles() }
    }

    /// Optional tap callback so HomeViewController can react to filter taps.
    var didTapTab: (Int) -> Void = { _ in }

    private let tabsStack = UIStackView()
    private var tabButtons: [UIButton] = []
    private let tabTitles = ["Live Now", "Popular", "Coming Soon"]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Hide the stub label that's still in the xib for outlet wiring.
        labelOlt?.isHidden = true
        labelOlt?.text = nil
        outerViewOlt?.backgroundColor = .white
        setupTabs()
    }

    private func setupTabs() {
        tabsStack.translatesAutoresizingMaskIntoConstraints = false
        tabsStack.axis = .horizontal
        tabsStack.alignment = .center
        tabsStack.distribution = .fill
        tabsStack.spacing = 24

        for (idx, title) in tabTitles.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            btn.tag = idx
            btn.contentEdgeInsets = .zero
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            tabButtons.append(btn)
            tabsStack.addArrangedSubview(btn)
        }

        // Trailing spacer pushes the tabs to the leading edge.
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tabsStack.addArrangedSubview(spacer)

        let host: UIView = outerViewOlt ?? contentView
        host.addSubview(tabsStack)
        NSLayoutConstraint.activate([
            tabsStack.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 16),
            tabsStack.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -16),
            tabsStack.centerYAnchor.constraint(equalTo: host.centerYAnchor)
        ])

        applyTabStyles()
    }

    private func applyTabStyles() {
        for (idx, btn) in tabButtons.enumerated() {
            let active = idx == selectedIndex
            // Android: active = scrim/black, inactive = outlineVariant (#B2B4B8).
            btn.setTitleColor(active ? UIColor(white: 0.05, alpha: 1.0)
                                     : UIColor(red: 0.70, green: 0.70, blue: 0.72, alpha: 1.0),
                              for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(
                ofSize: 17,
                weight: active ? .bold : .semibold
            )
        }
    }

    @objc private func tabTapped(_ sender: UIButton) {
        let idx = sender.tag
        if idx != selectedIndex {
            selectedIndex = idx
        }
        didTapTab(idx)
    }
}
