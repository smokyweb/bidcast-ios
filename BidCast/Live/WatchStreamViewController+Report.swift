//
//  WatchStreamViewController+Report.swift
//  BidCast — iOS Parity Phase 8 / P2.19 (2026-04-23)
//
//  Adds the live-viewer overflow entry ("Report seller" / "Block seller")
//  so users can flag bad behaviour mid-show. Android reference:
//  `WatchStreamFragment`'s overflow menu, which surfaces
//  `RaiseTicketActivity` (report) and the same `block-unblock-user`
//  endpoint already used by ChatThreadViewController on iOS.
//
//  Why a swizzle + extension rather than editing
//  `WatchStreamViewController.swift` directly?
//    - That file is already ~1,200 lines and owns the entire viewer
//      pipeline. Touching it for UI-only additions is risky.
//    - Extending via a viewDidAppear swizzle is the same pattern used by
//      JobAHomeSwizzle / JobAAccountSwizzle / JobAActivitySwizzle, so we
//      keep the codebase consistent.
//
//  All networking is delegated to InMemoryChatStore (reportUser /
//  blockUser) which already wraps /api/report-seller + /api/block-unblock-
//  user. Chat overflow uses the exact same helpers — parity is preserved.
//

import UIKit

// MARK: - Overflow install

extension WatchStreamViewController {

    private static let p2ViewerOverflowTag = 99_194   // P2.19 sentinel

    /// Installs the overflow button exactly once per VC instance.
    /// Host sessions get nothing — hosts can't report themselves.
    @objc public func p2_installViewerOverflowIfNeeded() {
        if view.viewWithTag(WatchStreamViewController.p2ViewerOverflowTag) != nil { return }
        // Defensive: context is an IUO; bail silently if the viewer is
        // still being set up.
        guard self.context != nil else { return }
        if self.context.isHost { return }

        let btn = UIButton(type: .system)
        btn.tag = WatchStreamViewController.p2ViewerOverflowTag
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        btn.tintColor = .white
        btn.accessibilityLabel = "More actions"
        btn.addTarget(self, action: #selector(p2_viewerOverflowTapped), for: .touchUpInside)
        view.addSubview(btn)

        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -56),
            btn.widthAnchor.constraint(equalToConstant: 36),
            btn.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func p2_viewerOverflowTapped() {
        guard let context = self.context, !context.isHost else { return }
        let sellerName = context.sellerName.isEmpty ? "seller" : context.sellerName
        let sheet = UIAlertController(
            title: "Actions",
            message: "What would you like to do?",
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: "Report \(sellerName)", style: .destructive) { [weak self] _ in
            self?.p2_promptReport()
        })
        sheet.addAction(UIAlertAction(title: "Block \(sellerName)", style: .destructive) { [weak self] _ in
            self?.p2_confirmBlock()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // iPad anchor
        if let popover = sheet.popoverPresentationController,
           let btn = view.viewWithTag(WatchStreamViewController.p2ViewerOverflowTag) {
            popover.sourceView = btn
            popover.sourceRect = btn.bounds
        }
        present(sheet, animated: true)
    }

    private func p2_promptReport() {
        guard let context = self.context,
              let sellerId = Int(context.sellerId) else { return }
        let alert = UIAlertController(
            title: "Report seller",
            message: "Briefly describe what happened. Our team will review.",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "Reason"
            tf.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .destructive) { [weak self] _ in
            let reason = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !reason.isEmpty else { return }
            InMemoryChatStore.shared.reportUser(userId: sellerId, reason: reason) { res in
                DispatchQueue.main.async {
                    switch res {
                    case .success:
                        self?.p2_showToast(title: "Thanks", body: "Report submitted.")
                    case .failure(let err):
                        self?.p2_showToast(title: "Report failed", body: err.localizedDescription)
                    }
                }
            }
        })
        present(alert, animated: true)
    }

    private func p2_confirmBlock() {
        guard let context = self.context,
              let sellerId = Int(context.sellerId) else { return }
        let alert = UIAlertController(
            title: "Block \(context.sellerName)?",
            message: "You'll stop seeing their shows and messages. You can unblock later from Account \u{2192} Blocked users.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            InMemoryChatStore.shared.blockUser(userId: sellerId) { res in
                DispatchQueue.main.async {
                    switch res {
                    case .success:
                        self?.p2_showToast(title: "Blocked", body: "You've blocked this seller.")
                        // Continuing to watch a blocked seller makes no
                        // sense — leave the live show.
                        self?.dismiss(animated: true)
                    case .failure(let err):
                        self?.p2_showToast(title: "Block failed", body: err.localizedDescription)
                    }
                }
            }
        })
        present(alert, animated: true)
    }

    private func p2_showToast(title: String, body: String) {
        let a = UIAlertController(title: title, message: body, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Swizzle installer (mirrors JobAHomeSwizzle pattern)

enum P2ViewerReportSwizzle {
    private static var installed = false
    static func installIfNeeded() {
        guard !installed else { return }
        installed = true
        let cls: AnyClass = WatchStreamViewController.self
        let originalSel = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSel = #selector(WatchStreamViewController.p2_viewDidAppear(_:))
        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }

        // Prefer class_addMethod so swizzling survives subclasses that
        // don't override viewDidAppear.
        let didAdd = class_addMethod(
            cls,
            originalSel,
            method_getImplementation(swizzled),
            method_getTypeEncoding(swizzled)
        )
        if didAdd {
            class_replaceMethod(
                cls,
                swizzledSel,
                method_getImplementation(original),
                method_getTypeEncoding(original)
            )
        } else {
            method_exchangeImplementations(original, swizzled)
        }
    }
}

extension WatchStreamViewController {
    @objc func p2_viewDidAppear(_ animated: Bool) {
        self.p2_viewDidAppear(animated)  // real viewDidAppear after IMP swap
        self.p2_installViewerOverflowIfNeeded()
    }
}
