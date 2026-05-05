//
//  PremierShopViewController.swift
//  BidCast — iOS parity Phase 3e (rebuilt 2026-05-05, MC cmossz7o700irf3hge7fzidk9)
//
//  Visual parity rebuild to mirror Android `fragment_premier_shop.xml` exactly:
//
//   1. Top "Pro Tip" info card  — primaryContainer-tinted, ic_info + welcome
//   2. Premium hero card        — `@color/primary` blue with crown + headline +
//                                  overlapping white "Your Shop" stats card
//                                  (Rating / Response / Delivery rings)
//   3. Policy Standing card     — current standing, monthly review row,
//                                  Current Progress + linear progress bar +
//                                  next review note
//   4. Become a Premier Shop    — descriptive blurb + Requirements list
//   5. Apply button             — pinned to bottom safe area; disabled-look
//                                  (gray) when progress < 100, primary blue
//                                  otherwise. Tap behavior preserved exactly:
//                                  shows "Not Eligible Yet" alert below 100%,
//                                  fires apply-premier-shop POST at 100%.
//
//  GET  /api/get-premier-shop   -> PremierShopData
//  POST /api/apply-premier-shop -> enroll in premier program
//
//  Existing logic preserved verbatim: load(), parseProgressPercent(),
//  applyToPremier()'s gated alert + POST path. Endpoints / models untouched.
//

import UIKit
import SVProgressHUD

final class PremierShopViewController: UIViewController {

    // MARK: - Layout root
    private let scroll = UIScrollView()
    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16          // matches Android `@dimen/margin` between cards
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        // Android uses `@dimen/margin` (~16dp) horizontally on each card and
        // a top margin of one `@dimen/margin`. Apply once at the stack level.
        s.layoutMargins = .init(top: 16, left: 16, bottom: 24, right: 16)
        return s
    }()

    // MARK: - Bottom-pinned Apply button
    private let applyBtn: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 12
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitle("Apply for Premier Status", for: .normal)
        return b
    }()

    // MARK: - Dynamic refs we update after API load
    private weak var welcomeLabel: UILabel?
    private weak var becomeLabel: UILabel?
    private weak var progressLabel: UILabel?
    private weak var progressBar: UIProgressView?
    private weak var nextReviewLabel: UILabel?
    private weak var requirementsStack: UIStackView?
    private weak var heroSubtitle: UILabel?

    private var data: PremierShopData?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Premier Shop"
        view.backgroundColor = .systemGroupedBackground

        buildLayout()
        load()
    }

    // MARK: - Static layout (built once, populated by render())
    private func buildLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(contentStack)

        view.addSubview(applyBtn)
        applyBtn.addTarget(self, action: #selector(applyToPremier), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Apply button pinned to bottom safe area, full-width with 16pt
            // horizontal margins (Android `@dimen/margin`) and 52pt height
            // (matches `@style/appBtn`).
            applyBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            applyBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            applyBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyBtn.heightAnchor.constraint(equalToConstant: 52),

            // Scroll view fills above the apply button.
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: applyBtn.topAnchor, constant: -8),

            // Content stack: pinned to scroll content area, locked to scroll
            // width so only vertical scrolling is enabled.
            contentStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])

        // Skeleton structure — the same cards as Android, populated even
        // before the API responds so the layout doesn't "pop in".
        contentStack.addArrangedSubview(makeProTipCard())
        contentStack.addArrangedSubview(makeHeroAndStatsCard())
        contentStack.addArrangedSubview(makePolicyStandingCard())
        contentStack.addArrangedSubview(makeBecomePremierCard())

        applyApplyButtonStyle(progress: 0)
    }

    // MARK: - Card 1: top Pro Tip info card
    /// Android: a primaryContainer-tinted rounded card with `ic_info` +
    /// `welcome_text`. iOS uses a soft tint of `.primary` for the
    /// background and `info.circle.fill` SFSymbol.
    private func makeProTipCard() -> UIView {
        let card = roundedCard(corner: 12)
        // primaryContainer ≈ a much lighter tint of the brand blue.
        card.backgroundColor = UIColor.primary.withAlphaComponent(0.10)

        let icon = UIImageView(image: UIImage(systemName: "info.circle.fill"))
        icon.tintColor = UIColor.primary
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13)
        label.textColor = .label
        label.text = "Pro Tip text here"
        label.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel = label

        let row = UIStackView(arrangedSubviews: [icon, label])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)

        card.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.topAnchor),
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24)
        ])
        return card
    }

    // MARK: - Card 2: Hero (blue) + overlapping white stats card
    /// Android stacks two `ConstraintLayout` children: a 7:4.5 blue header
    /// containing the crown + headline, and a white MaterialCardView with
    /// `marginTop=130dp` overlapping it from below. Reproduce that with a
    /// container view and explicit anchors.
    private func makeHeroAndStatsCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // --- Blue hero ---
        let hero = UIView()
        hero.translatesAutoresizingMaskIntoConstraints = false
        hero.backgroundColor = UIColor.primary
        hero.layer.cornerRadius = 12
        hero.layer.masksToBounds = true

        let crown = UIImageView(image: UIImage(systemName: "crown.fill"))
        crown.tintColor = .white
        crown.contentMode = .scaleAspectFit
        crown.translatesAutoresizingMaskIntoConstraints = false

        let heroTitle = UILabel()
        heroTitle.text = "Become a Premier Shop"
        heroTitle.font = .systemFont(ofSize: 20, weight: .bold)
        heroTitle.textColor = .white
        heroTitle.textAlignment = .center
        heroTitle.numberOfLines = 0

        let heroSub = UILabel()
        heroSub.text = "Join the elite sellers and unlock exclusive benefits"
        heroSub.font = .systemFont(ofSize: 14)
        heroSub.textColor = .white
        heroSub.textAlignment = .center
        heroSub.numberOfLines = 0
        heroSubtitle = heroSub

        let heroStack = UIStackView(arrangedSubviews: [crown, heroTitle, heroSub])
        heroStack.axis = .vertical
        heroStack.alignment = .center
        heroStack.spacing = 8
        heroStack.translatesAutoresizingMaskIntoConstraints = false
        heroStack.isLayoutMarginsRelativeArrangement = true
        heroStack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)

        hero.addSubview(heroStack)
        NSLayoutConstraint.activate([
            heroStack.topAnchor.constraint(equalTo: hero.topAnchor),
            heroStack.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            heroStack.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            heroStack.bottomAnchor.constraint(equalTo: hero.bottomAnchor),
            crown.widthAnchor.constraint(equalToConstant: 36),
            crown.heightAnchor.constraint(equalToConstant: 30)
        ])

        // --- White stats card (overlaps hero by 30pt) ---
        let stats = roundedCard(corner: 16)
        stats.translatesAutoresizingMaskIntoConstraints = false
        stats.backgroundColor = .systemBackground
        stats.layer.borderWidth = 4
        stats.layer.borderColor = UIColor.systemGroupedBackground.cgColor

        // Header row inside stats: shop icon + Your Shop / Regular Member
        let shopBadge = UIView()
        shopBadge.translatesAutoresizingMaskIntoConstraints = false
        shopBadge.backgroundColor = UIColor.primary.withAlphaComponent(0.12)
        shopBadge.layer.cornerRadius = 24
        let shopIcon = UIImageView(image: UIImage(systemName: "bag.fill"))
        shopIcon.tintColor = UIColor.primary
        shopIcon.contentMode = .scaleAspectFit
        shopIcon.translatesAutoresizingMaskIntoConstraints = false
        shopBadge.addSubview(shopIcon)

        let shopTitle = UILabel()
        shopTitle.text = "Your Shop"
        shopTitle.font = .systemFont(ofSize: 17, weight: .semibold)

        let shopSub = UILabel()
        shopSub.text = "Regular Member"
        shopSub.font = .systemFont(ofSize: 13)
        shopSub.textColor = .secondaryLabel

        let shopText = UIStackView(arrangedSubviews: [shopTitle, shopSub])
        shopText.axis = .vertical
        shopText.spacing = 2

        let header = UIStackView(arrangedSubviews: [shopBadge, shopText])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 12

        // Stats row: Rating | Response | Delivery rings
        let ratingCol   = makeStatRing(value: "N/A", label: "Rating",   progress: 0.0)
        let responseCol = makeStatRing(value: "N/A", label: "Response", progress: 0.0)
        let deliveryCol = makeStatRing(value: "N/A", label: "Delivery", progress: 0.0)

        let div1 = makeVerticalDivider()
        let div2 = makeVerticalDivider()

        let statsRow = UIStackView(arrangedSubviews: [ratingCol, div1, responseCol, div2, deliveryCol])
        statsRow.axis = .horizontal
        statsRow.alignment = .fill
        statsRow.distribution = .fill
        statsRow.spacing = 8

        // Equal width for the three stat columns.
        ratingCol.widthAnchor.constraint(equalTo: responseCol.widthAnchor).isActive = true
        responseCol.widthAnchor.constraint(equalTo: deliveryCol.widthAnchor).isActive = true
        div1.widthAnchor.constraint(equalToConstant: 1).isActive = true
        div2.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let statsInner = UIStackView(arrangedSubviews: [header, statsRow])
        statsInner.axis = .vertical
        statsInner.spacing = 12
        statsInner.translatesAutoresizingMaskIntoConstraints = false
        statsInner.isLayoutMarginsRelativeArrangement = true
        statsInner.layoutMargins = .init(top: 20, left: 16, bottom: 16, right: 16)

        stats.addSubview(statsInner)
        NSLayoutConstraint.activate([
            statsInner.topAnchor.constraint(equalTo: stats.topAnchor),
            statsInner.leadingAnchor.constraint(equalTo: stats.leadingAnchor),
            statsInner.trailingAnchor.constraint(equalTo: stats.trailingAnchor),
            statsInner.bottomAnchor.constraint(equalTo: stats.bottomAnchor),
            shopBadge.widthAnchor.constraint(equalToConstant: 48),
            shopBadge.heightAnchor.constraint(equalToConstant: 48),
            shopIcon.centerXAnchor.constraint(equalTo: shopBadge.centerXAnchor),
            shopIcon.centerYAnchor.constraint(equalTo: shopBadge.centerYAnchor),
            shopIcon.widthAnchor.constraint(equalToConstant: 24),
            shopIcon.heightAnchor.constraint(equalToConstant: 24)
        ])

        // --- Compose hero + overlapping stats inside the container ---
        container.addSubview(hero)
        container.addSubview(stats)
        NSLayoutConstraint.activate([
            // Hero pinned top, ratio 7:4.5 (Android `layout_constraintDimensionRatio`)
            hero.topAnchor.constraint(equalTo: container.topAnchor),
            hero.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hero.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hero.heightAnchor.constraint(equalTo: hero.widthAnchor, multiplier: 4.5 / 7.0),

            // Stats card overlaps hero from `marginTop=130dp` and pins to
            // container bottom.
            stats.topAnchor.constraint(equalTo: container.topAnchor, constant: 130),
            stats.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stats.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stats.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func makeStatRing(value: String, label: String, progress: CGFloat) -> UIView {
        let col = UIView()
        col.translatesAutoresizingMaskIntoConstraints = false

        // Square ring view that fills the column width.
        let ringHost = UIView()
        ringHost.translatesAutoresizingMaskIntoConstraints = false

        let ring = CircularProgressRingView()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.progress = progress
        ringHost.addSubview(ring)

        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.textAlignment = .center
        valueLbl.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLbl.textColor = .systemGreen     // Android tertiary ≈ green
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        ringHost.addSubview(valueLbl)

        let captionLbl = UILabel()
        captionLbl.text = label
        captionLbl.textAlignment = .center
        captionLbl.font = .systemFont(ofSize: 12)
        captionLbl.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [ringHost, captionLbl])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        col.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: col.topAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: col.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: col.trailingAnchor, constant: -4),
            stack.bottomAnchor.constraint(equalTo: col.bottomAnchor, constant: -4),

            // Square ring host
            ringHost.heightAnchor.constraint(equalTo: ringHost.widthAnchor),
            ring.topAnchor.constraint(equalTo: ringHost.topAnchor),
            ring.leadingAnchor.constraint(equalTo: ringHost.leadingAnchor),
            ring.trailingAnchor.constraint(equalTo: ringHost.trailingAnchor),
            ring.bottomAnchor.constraint(equalTo: ringHost.bottomAnchor),

            // Value label centered inside ring
            valueLbl.centerXAnchor.constraint(equalTo: ringHost.centerXAnchor),
            valueLbl.centerYAnchor.constraint(equalTo: ringHost.centerYAnchor),
            valueLbl.leadingAnchor.constraint(greaterThanOrEqualTo: ringHost.leadingAnchor, constant: 6),
            valueLbl.trailingAnchor.constraint(lessThanOrEqualTo: ringHost.trailingAnchor, constant: -6)
        ])
        return col
    }

    private func makeVerticalDivider() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.separator
        return v
    }

    // MARK: - Card 3: Policy Standing
    private func makePolicyStandingCard() -> UIView {
        let card = roundedCard(corner: 16)
        card.backgroundColor = .systemBackground

        // Policy Standing header row
        let title = UILabel()
        title.text = "Policy Standing"
        title.font = .systemFont(ofSize: 17, weight: .semibold)

        let standing = UILabel()
        standing.text = "Excellent"
        standing.font = .systemFont(ofSize: 15, weight: .bold)
        standing.textColor = .systemGreen
        standing.setContentHuggingPriority(.required, for: .horizontal)

        let topRow = UIStackView(arrangedSubviews: [title, standing])
        topRow.axis = .horizontal
        topRow.alignment = .center

        let standardsBlurb = UILabel()
        standardsBlurb.text = "Maintain high standards across orders, response time, and delivery to keep your premier eligibility on track."
        standardsBlurb.font = .systemFont(ofSize: 13)
        standardsBlurb.textColor = .secondaryLabel
        standardsBlurb.numberOfLines = 0

        // Monthly Evaluation row (icon + title/details)
        let evalIcon = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        evalIcon.tintColor = UIColor.primary
        evalIcon.contentMode = .scaleAspectFit
        evalIcon.translatesAutoresizingMaskIntoConstraints = false

        let evalTitle = UILabel()
        evalTitle.text = "Monthly Evaluation"
        evalTitle.font = .systemFont(ofSize: 16, weight: .semibold)

        let evalSub = UILabel()
        evalSub.text = "Performance reviewed every 30 days"
        evalSub.font = .systemFont(ofSize: 14)
        evalSub.textColor = .label
        evalSub.numberOfLines = 0

        let evalText = UIStackView(arrangedSubviews: [evalTitle, evalSub])
        evalText.axis = .vertical
        evalText.spacing = 2

        let evalRow = UIStackView(arrangedSubviews: [evalIcon, evalText])
        evalRow.axis = .horizontal
        evalRow.alignment = .center
        evalRow.spacing = 12

        // Current Progress label row
        let progressLeft = UILabel()
        progressLeft.text = "Current Progress"
        progressLeft.font = .systemFont(ofSize: 14)
        progressLeft.textColor = .secondaryLabel

        let progressRight = UILabel()
        progressRight.text = "0%"
        progressRight.font = .systemFont(ofSize: 15, weight: .semibold)
        progressLabel = progressRight

        let progRow = UIStackView(arrangedSubviews: [progressLeft, progressRight])
        progRow.axis = .horizontal

        let bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.progressTintColor = UIColor.primary
        bar.trackTintColor = UIColor.primary.withAlphaComponent(0.15)
        bar.layer.cornerRadius = 4
        bar.clipsToBounds = true
        bar.progress = 0
        progressBar = bar

        let nextReview = UILabel()
        nextReview.text = "Next Review in 7 days"
        nextReview.font = .systemFont(ofSize: 14)
        nextReview.textColor = .secondaryLabel
        nextReviewLabel = nextReview

        let inner = UIStackView(arrangedSubviews: [
            topRow, standardsBlurb, evalRow, progRow, bar, nextReview
        ])
        inner.axis = .vertical
        inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        inner.isLayoutMarginsRelativeArrangement = true
        inner.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)

        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            evalIcon.widthAnchor.constraint(equalToConstant: 32),
            evalIcon.heightAnchor.constraint(equalToConstant: 32),
            bar.heightAnchor.constraint(equalToConstant: 8)
        ])
        return card
    }

    // MARK: - Card 4: Become a Premier Shop + requirements list
    private func makeBecomePremierCard() -> UIView {
        let card = roundedCard(corner: 16)
        card.backgroundColor = .systemBackground

        let title = UILabel()
        title.text = "Become a Premier Shop"
        title.font = .systemFont(ofSize: 17, weight: .semibold)

        let blurb = UILabel()
        blurb.text = ""
        blurb.font = .systemFont(ofSize: 14)
        blurb.textColor = .secondaryLabel
        blurb.numberOfLines = 0
        becomeLabel = blurb

        let reqHeader = UILabel()
        reqHeader.text = "Requirements"
        reqHeader.font = .systemFont(ofSize: 15, weight: .semibold)

        let reqs = UIStackView()
        reqs.axis = .vertical
        reqs.spacing = 8
        requirementsStack = reqs

        let inner = UIStackView(arrangedSubviews: [title, blurb, reqHeader, reqs])
        inner.axis = .vertical
        inner.spacing = 10
        inner.translatesAutoresizingMaskIntoConstraints = false
        inner.isLayoutMarginsRelativeArrangement = true
        inner.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)

        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        return card
    }

    private func roundedCard(corner: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = corner
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.masksToBounds = false
        return v
    }

    // MARK: - Apply button styling (mirrors Android disabled-look pattern)
    private func applyApplyButtonStyle(progress: Int) {
        if progress >= 100 {
            applyBtn.backgroundColor = UIColor.primary
            applyBtn.setTitleColor(.white, for: .normal)
        } else {
            applyBtn.backgroundColor = UIColor.systemGray3
            applyBtn.setTitleColor(.white, for: .normal)
        }
    }

    // MARK: - Data load
    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let resp: GetPremierShopResponse = try await APIManager.shared.request(
                    type: .getPremierShop, header: true
                )
                self.data = resp.data
                self.render()
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    // MARK: - Populate dynamic fields after API response
    private func render() {
        guard let d = data else { return }

        if let pageDetails = d.pageDetails, !pageDetails.isEmpty {
            welcomeLabel?.text = pageDetails
        }

        if let pageTitle = d.pageTitle, !pageTitle.isEmpty {
            // Hero subtitle line carries any pitch text returned by API.
            heroSubtitle?.text = pageTitle
        }

        let progressInt = parseProgressPercent(d.currentProgress)
        progressLabel?.text = "\(progressInt)%"
        progressBar?.setProgress(Float(progressInt) / 100.0, animated: false)

        if let next = d.nextReview, !next.isEmpty {
            nextReviewLabel?.text = next
        }

        if let detail = d.shopDetails, !detail.isEmpty {
            becomeLabel?.text = detail
        } else if let pd = d.pageDetails {
            becomeLabel?.text = pd
        }

        // Requirements list: clear + repopulate
        requirementsStack?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let reqs = d.requirements?.compactMap({ $0 }), !reqs.isEmpty {
            for r in reqs {
                requirementsStack?.addArrangedSubview(makeRequirementRow(r))
            }
        }

        applyApplyButtonStyle(progress: progressInt)
    }

    private func makeRequirementRow(_ r: PremierShopRequirement) -> UIView {
        let dot = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        dot.tintColor = UIColor.primary
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.contentMode = .scaleAspectFit

        let title = UILabel()
        title.font = .systemFont(ofSize: 14, weight: .medium)
        title.text = r.platform ?? "Requirement"
        title.numberOfLines = 0

        let sub = UILabel()
        sub.font = .systemFont(ofSize: 13)
        sub.textColor = .secondaryLabel
        sub.text = r.url ?? ""
        sub.numberOfLines = 0

        let text = UIStackView(arrangedSubviews: [title, sub])
        text.axis = .vertical
        text.spacing = 2

        let row = UIStackView(arrangedSubviews: [dot, text])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 10

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 18),
            dot.heightAnchor.constraint(equalToConstant: 18)
        ])
        return row
    }

    /// Parses Android-style progress strings like "75%" or "75" into an Int.
    /// Returns 0 when the value is missing or unparseable so we err on the
    /// side of showing the "Not Eligible Yet" sheet.
    private func parseProgressPercent(_ value: String?) -> Int {
        guard let v = value?.replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines), !v.isEmpty,
              let n = Int(v) else { return 0 }
        return n
    }

    // MARK: - Apply
    @objc private func applyToPremier() {
        // QA-FIX (MC task cmolwmp0i00f64315lqq37lv3 - preserved): Android branches on
        // current progress and shows a "Not Eligible Yet" message when the
        // seller is below 100% instead of firing the apply API. Mirror that.
        let progress = parseProgressPercent(data?.currentProgress)
        if progress < 100 {
            p3Alert(
                title: "Not Eligible Yet",
                message: "You are at \(progress)% of the Premier Shop requirements. Reach 100% to apply."
            )
            return
        }
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .applyPremierShop, fields: [:], header: true
                )
                self.p3Alert(title: "Submitted",
                             message: "Your Premier Shop application is under review.")
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}

// MARK: - Local circular progress ring
/// Android uses `MaterialCircularProgressIndicator`; iOS recreates the same
/// look with two concentric stroked layers. Kept private to this file —
/// nothing else in the app needs it.
private final class CircularProgressRingView: UIView {

    var progress: CGFloat = 0 {
        didSet { progressLayer.strokeEnd = max(0, min(1, progress)) }
    }

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 6
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.primary.cgColor
        progressLayer.lineWidth = 6
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = min(bounds.width, bounds.height) / 2 - trackLayer.lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: center,
                                radius: r,
                                startAngle: -.pi / 2,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        trackLayer.frame = bounds
        progressLayer.frame = bounds
    }
}
