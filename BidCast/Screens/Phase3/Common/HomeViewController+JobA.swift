//
//  HomeViewController+JobA.swift
//  BidCast — iOS parity Job A (App-flow wiring, 2026-04-22)
//
//  The stock Home tab (BidCast/Screens/Main/Home/VIew/HomeViewController.swift)
//  renders static mock cells and has no didSelect routing. For Job A we
//  don't rebuild the feed (Phase 5 / future work). We just add a floating
//  "Shows" action button that opens a sheet with three real Phase 3 entry
//  points so a user can actually reach the scheduled-show + promoted-show
//  flows from Home:
//
//    • Scheduled shows  -> ScheduledShowsViewController (Phase 3g)
//    • Promoted shows   -> PromotedShowsViewController  (Phase 3e)
//    • Schedule a show  -> ScheduleShowEditorViewController (Phase 3g)
//
//  Swizzle viewDidAppear so the stock Home view keeps working — we just
//  overlay the action button the first time the view appears.
//

import UIKit

extension HomeViewController {

    private static var jobAHomeButtonKey: UInt8 = 0

    private var jobAHomeButtonInstalled: Bool {
        get { (objc_getAssociatedObject(self, &Self.jobAHomeButtonKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &Self.jobAHomeButtonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    @objc public func jobAInstallHomeShowsButtonIfNeeded() {
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): Android has
        // no floating blue Shows button on Home — the home feed itself surfaces
        // shows directly. Disable the JobA install entirely so iOS matches.
        // Keep the swizzle hookup intact so other JobA subscribers still fire,
        // and keep the implementation here for reference / potential reuse.
        guard !jobAHomeButtonInstalled else { return }
        jobAHomeButtonInstalled = true
        return
    }

    @objc private func jobAOpenShowsMenu() {
        let sheet = UIAlertController(title: "Shows", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Watch live shows", style: .default) { [weak self] _ in
            // Phase 5: browse the Android `get-live-show` feed and tap a
            // tile to open WatchStreamViewController. Lives under
            // BrowseLiveShowsViewController introduced this phase.
            self?.p3Push(BrowseLiveShowsViewController())
        })
        sheet.addAction(UIAlertAction(title: "Scheduled shows", style: .default) { [weak self] _ in
            self?.p3Push(ScheduledShowsViewController())
        })
        sheet.addAction(UIAlertAction(title: "Promoted shows", style: .default) { [weak self] _ in
            self?.p3Push(PromotedShowsViewController())
        })
        sheet.addAction(UIAlertAction(title: "Schedule a show", style: .default) { [weak self] _ in
            self?.p3Push(ScheduleShowEditorViewController(mode: .create))
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // iPad popover anchoring — fallback to a pseudo origin if needed.
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.maxX - 68, y: view.bounds.maxY - 132,
                                    width: 52, height: 52)
        }
        present(sheet, animated: true)
    }
}

enum JobAHomeSwizzle {
    private static var installed = false
    static func installIfNeeded() {
        guard !installed else { return }
        installed = true
        let cls: AnyClass = HomeViewController.self
        let originalSel = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSel = #selector(HomeViewController.jobA_viewDidAppear(_:))
        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }

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

extension HomeViewController {
    @objc func jobA_viewDidAppear(_ animated: Bool) {
        self.jobA_viewDidAppear(animated)   // real viewDidAppear after IMP swap
        self.jobAInstallHomeShowsButtonIfNeeded()
    }
}
