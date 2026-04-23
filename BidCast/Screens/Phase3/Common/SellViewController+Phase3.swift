//
//  SellViewController+Phase3.swift
//  BidCast — iOS parity Phase 3i (2026-04-22)
//
//  Takes the empty 29-line Sell storyboard stub and turns it into a real
//  Sell tab. Rather than modify the .storyboard / pbxproj aggressively,
//  we extend the existing SellViewController class so the first time it
//  appears, it embeds our Phase 3 P3SellHomeViewController as a child.
//  This keeps the TabBarViewController routing untouched and avoids a
//  storyboard rewrite.
//

import UIKit

extension SellViewController {

    /// Called from a swizzled viewWillAppear. Guarded so we only embed
    /// once per VC lifecycle.
    private static var p3EmbedKey: UInt8 = 0

    private var p3HasEmbedded: Bool {
        get { (objc_getAssociatedObject(self, &Self.p3EmbedKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &Self.p3EmbedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    @objc public func p3EmbedSellHomeIfNeeded() {
        guard !p3HasEmbedded else { return }
        p3HasEmbedded = true

        // Clear any placeholder subviews the storyboard dropped in.
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .systemGroupedBackground

        let home = P3SellHomeViewController()
        let nav = UINavigationController(rootViewController: home)
        addChild(nav)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nav.view)
        NSLayoutConstraint.activate([
            nav.view.topAnchor.constraint(equalTo: view.topAnchor),
            nav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        nav.didMove(toParent: self)
    }
}

// MARK: - Method swizzle so existing Sell storyboard stub picks up the embed.
//
// AppDelegate's didFinishLaunchingWithOptions calls
// `P3SellSwizzle.installIfNeeded()` once on app launch.

enum P3SellSwizzle {
    private static var installed = false
    static func installIfNeeded() {
        guard !installed else { return }
        installed = true
        let cls: AnyClass = SellViewController.self
        let originalSel = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSel = #selector(SellViewController.p3_viewWillAppear(_:))
        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }

        // Safe subclass swizzle pattern: if SellViewController inherits
        // UIViewController.viewWillAppear without overriding it, a raw
        // method_exchangeImplementations would mutate UIViewController's IMP
        // globally and crash other controllers (including UINavigationController)
        // with an unrecognized selector during launch.
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

extension SellViewController {
    @objc func p3_viewWillAppear(_ animated: Bool) {
        // Because we swapped the IMPs, this call actually invokes the
        // real UIViewController.viewWillAppear.
        self.p3_viewWillAppear(animated)
        self.p3EmbedSellHomeIfNeeded()
    }
}
