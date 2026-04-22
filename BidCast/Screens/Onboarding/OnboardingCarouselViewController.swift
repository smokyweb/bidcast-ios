//
//  OnboardingCarouselViewController.swift
//  BidCast
//
//  iOS Parity Phase 7c (2026-04-22): 4-screen first-launch tutorial.
//
//  Matches Android's onboarding flow (Welcome / Bid + Tip / Sell / Notify).
//  Shows only on first launch. Tracked via UserDefaults key
//  `OnboardingHasCompletedKey`.
//
//  Integration (one line in SceneDelegate or AppDelegate):
//      OnboardingCarouselViewController.presentIfNeeded(from: rootVC)

import UIKit

final class OnboardingCarouselViewController: UIPageViewController,
                                               UIPageViewControllerDataSource,
                                               UIPageViewControllerDelegate {

    static let hasCompletedKey = "OnboardingHasCompletedKey"

    // MARK: - Slides

    private struct Slide {
        let titleKey: String
        let bodyKey: String
        let emoji: String
    }

    private let slides: [Slide] = [
        .init(titleKey: "onboarding_welcome_title",
              bodyKey: "onboarding_welcome_body",
              emoji: "👋"),
        .init(titleKey: "onboarding_bid_title",
              bodyKey: "onboarding_bid_body",
              emoji: "💸"),
        .init(titleKey: "onboarding_sell_title",
              bodyKey: "onboarding_sell_body",
              emoji: "🛒"),
        .init(titleKey: "onboarding_notify_title",
              bodyKey: "onboarding_notify_body",
              emoji: "🔔")
    ]

    private var pageControllers: [UIViewController] = []

    private let skipButton = UIButton(type: .system)
    private let pageControl = UIPageControl()
    private let primaryButton = UIButton(type: .system)

    // MARK: - Class API

    /// Returns true if the onboarding has already been completed. Callers
    /// should check this before presenting.
    static var hasCompleted: Bool {
        UserDefaults.standard.bool(forKey: hasCompletedKey)
    }

    /// Mark the onboarding as completed (won't show again until key cleared).
    static func markCompleted() {
        UserDefaults.standard.set(true, forKey: hasCompletedKey)
    }

    /// One-shot presenter. No-op if user has already completed onboarding.
    @discardableResult
    static func presentIfNeeded(from presenter: UIViewController) -> Bool {
        guard !hasCompleted else { return false }
        let vc = OnboardingCarouselViewController()
        vc.modalPresentationStyle = .fullScreen
        presenter.present(vc, animated: true)
        return true
    }

    // MARK: - Lifecycle

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) { fatalError("not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        dataSource = self
        delegate = self

        pageControllers = slides.enumerated().map { idx, slide in
            let vc = UIViewController()
            vc.view.backgroundColor = .systemBackground

            let titleLbl = UILabel()
            titleLbl.text = L10n(slide.titleKey)
            titleLbl.font = .systemFont(ofSize: 28, weight: .bold)
            titleLbl.textAlignment = .center
            titleLbl.numberOfLines = 0
            titleLbl.translatesAutoresizingMaskIntoConstraints = false

            let bodyLbl = UILabel()
            bodyLbl.text = L10n(slide.bodyKey)
            bodyLbl.font = .systemFont(ofSize: 17)
            bodyLbl.textColor = .secondaryLabel
            bodyLbl.textAlignment = .center
            bodyLbl.numberOfLines = 0
            bodyLbl.translatesAutoresizingMaskIntoConstraints = false

            let emojiLbl = UILabel()
            emojiLbl.text = slide.emoji
            emojiLbl.font = .systemFont(ofSize: 80)
            emojiLbl.textAlignment = .center
            emojiLbl.translatesAutoresizingMaskIntoConstraints = false

            vc.view.addSubview(emojiLbl)
            vc.view.addSubview(titleLbl)
            vc.view.addSubview(bodyLbl)

            NSLayoutConstraint.activate([
                emojiLbl.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                emojiLbl.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor, constant: -80),

                titleLbl.topAnchor.constraint(equalTo: emojiLbl.bottomAnchor, constant: 32),
                titleLbl.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 32),
                titleLbl.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -32),

                bodyLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 12),
                bodyLbl.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 32),
                bodyLbl.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -32)
            ])

            _ = idx
            return vc
        }

        if let first = pageControllers.first {
            setViewControllers([first], direction: .forward, animated: false)
        }

        setupOverlayControls()
        refreshButtons(forIndex: 0)
    }

    // MARK: - Overlay controls (skip / pagecontrol / primary)

    private func setupOverlayControls() {
        skipButton.setTitle(L10n("skip"), for: .normal)
        skipButton.setTitleColor(.secondaryLabel, for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(finishOnboarding), for: .touchUpInside)

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.pageIndicatorTintColor = .tertiaryLabel
        pageControl.isUserInteractionEnabled = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        var cfg = UIButton.Configuration.filled()
        cfg.baseBackgroundColor = .systemBlue
        cfg.cornerStyle = .medium
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32)
        primaryButton.configuration = cfg
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        view.addSubview(skipButton)
        view.addSubview(pageControl)
        view.addSubview(primaryButton)

        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            skipButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            skipButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            pageControl.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            primaryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    private func refreshButtons(forIndex idx: Int) {
        pageControl.currentPage = idx
        let isLast = (idx == slides.count - 1)
        var cfg = primaryButton.configuration
        cfg?.title = isLast ? L10n("onboarding_get_started") : L10n("continue")
        primaryButton.configuration = cfg
        skipButton.isHidden = isLast
    }

    private func currentIndex() -> Int {
        guard let vc = viewControllers?.first,
              let idx = pageControllers.firstIndex(of: vc) else { return 0 }
        return idx
    }

    // MARK: - Actions

    @objc private func primaryTapped() {
        let idx = currentIndex()
        if idx >= slides.count - 1 {
            finishOnboarding()
        } else {
            let next = idx + 1
            setViewControllers([pageControllers[next]], direction: .forward, animated: true) { [weak self] _ in
                self?.refreshButtons(forIndex: next)
            }
        }
    }

    @objc private func finishOnboarding() {
        OnboardingCarouselViewController.markCompleted()
        dismiss(animated: true)
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pageControllers.firstIndex(of: viewController), idx > 0 else { return nil }
        return pageControllers[idx - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pageControllers.firstIndex(of: viewController),
              idx < pageControllers.count - 1 else { return nil }
        return pageControllers[idx + 1]
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed {
            refreshButtons(forIndex: currentIndex())
        }
    }
}
