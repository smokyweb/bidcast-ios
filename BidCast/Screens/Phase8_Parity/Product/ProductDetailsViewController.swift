//
//  ProductDetailsViewController.swift
//  BidCast — iOS Parity Phase 8 / P0.1 (2026-04-23)
//
//  Standalone product-details screen. Mirrors Android's
//  `ProductDetailsFragment` (app/src/main/java/io/bidswipe/app/ui/product).
//
//  Layout (vertical stack):
//    ┌──────────────────────────────┐
//    │   Image / video gallery      │  ← horizontal paging (Kingfisher + AVPlayer)
//    ├──────────────────────────────┤
//    │   Title                      │
//    │   Price  [Buy Now / Auction] │
//    │   Condition / SKU chips      │
//    ├──────────────────────────────┤
//    │   Seller card (avatar,name,  │ ← tap → SellerPublicProfileViewController
//    │   username, Follow)          │
//    ├──────────────────────────────┤
//    │   Description                │
//    ├──────────────────────────────┤
//    │   [Save]        [Buy Now ▶]  │ ← bottom bar pinned
//    └──────────────────────────────┘
//
//  Buy-Now entry: P0.2 wires this button to push
//  `CheckoutViewController(productId:)` — P0.1 leaves the handler stubbed to
//  keep commits atomic and review small.
//

import UIKit
import AVKit
import Kingfisher

final class ProductDetailsViewController: UIViewController {

    // MARK: - Input

    let productId: Int
    init(productId: Int) {
        self.productId = productId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - State

    private var details: ParityProductDetailsData?
    private var isSaved: Bool = false
    private var gallery: [ProductMediaItem] = []

    // MARK: - UI

    private let scroll = UIScrollView()
    private let contentStack = UIStackView()
    private let galleryCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .systemGroupedBackground
        return cv
    }()
    private let pageControl = UIPageControl()
    private let titleLbl = UILabel()
    private let priceLbl = UILabel()
    private let pricingBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): Android
        // pricing accent is `@color/primary` (#0058BD) for non-auction
        // listings — switch from iOS dynamic systemBlue to AppColor.primary.
        l.backgroundColor = AppColor.primary
        l.layer.cornerRadius = 6
        l.layer.masksToBounds = true
        l.textAlignment = .center
        return l
    }()
    private let conditionLbl = UILabel()
    private let skuLbl = UILabel()
    private let sellerCard: UIControl = {
        let v = UIControl()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 12
        return v
    }()
    private let sellerAvatar: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .tertiarySystemFill
        iv.image = UIImage(systemName: "person.crop.circle")
        iv.tintColor = .systemGray
        return iv
    }()
    private let sellerName = UILabel()
    private let sellerUsername = UILabel()
    private let descriptionLbl = UILabel()
    private let bottomBar = UIView()
    private let saveBtn = UIButton(type: .system)
    private let buyNowBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Product"
        setupLayout()
        configureCollection()
        Task { await loadDetails() }
    }

    // MARK: - Layout

    private func setupLayout() {
        // Scroll + stack
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16)
        scroll.addSubview(contentStack)

        bottomBar.backgroundColor = .secondarySystemBackground
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            contentStack.topAnchor.constraint(equalTo: scroll.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 76)
        ])

        // Gallery container (collection + page control)
        let galleryWrap = UIView()
        galleryWrap.translatesAutoresizingMaskIntoConstraints = false
        galleryCollection.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        // VISUAL PARITY 2026-05-01: Android selected dot color is
        // `@color/primary` (brand blue).
        pageControl.currentPageIndicatorTintColor = AppColor.primary
        pageControl.pageIndicatorTintColor = .tertiaryLabel
        galleryWrap.addSubview(galleryCollection)
        galleryWrap.addSubview(pageControl)
        NSLayoutConstraint.activate([
            galleryCollection.topAnchor.constraint(equalTo: galleryWrap.topAnchor),
            galleryCollection.leadingAnchor.constraint(equalTo: galleryWrap.leadingAnchor),
            galleryCollection.trailingAnchor.constraint(equalTo: galleryWrap.trailingAnchor),
            galleryCollection.bottomAnchor.constraint(equalTo: galleryWrap.bottomAnchor),
            galleryCollection.heightAnchor.constraint(equalToConstant: 340),
            pageControl.centerXAnchor.constraint(equalTo: galleryWrap.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: galleryWrap.bottomAnchor, constant: -6)
        ])
        contentStack.addArrangedSubview(galleryWrap)

        // Title
        titleLbl.font = .systemFont(ofSize: 20, weight: .bold)
        titleLbl.numberOfLines = 0
        contentStack.addArrangedSubview(wrapInMargins(titleLbl))

        // Price row
        priceLbl.font = .systemFont(ofSize: 22, weight: .heavy)
        priceLbl.textColor = .label
        pricingBadge.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let priceRow = UIStackView(arrangedSubviews: [priceLbl, pricingBadge])
        priceRow.axis = .horizontal
        priceRow.spacing = 10
        priceRow.alignment = .center
        pricingBadge.heightAnchor.constraint(equalToConstant: 26).isActive = true
        pricingBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        contentStack.addArrangedSubview(wrapInMargins(priceRow))

        // Condition + SKU
        conditionLbl.font = .systemFont(ofSize: 13)
        conditionLbl.textColor = .secondaryLabel
        skuLbl.font = .systemFont(ofSize: 13)
        skuLbl.textColor = .secondaryLabel
        let chipRow = UIStackView(arrangedSubviews: [conditionLbl, skuLbl])
        chipRow.axis = .horizontal
        chipRow.spacing = 12
        contentStack.addArrangedSubview(wrapInMargins(chipRow))

        // Seller card
        sellerCard.translatesAutoresizingMaskIntoConstraints = false
        sellerAvatar.translatesAutoresizingMaskIntoConstraints = false
        sellerName.font = .systemFont(ofSize: 15, weight: .semibold)
        sellerUsername.font = .systemFont(ofSize: 13)
        sellerUsername.textColor = .secondaryLabel
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.translatesAutoresizingMaskIntoConstraints = false
        sellerCard.addSubview(sellerAvatar)
        let infoStack = UIStackView(arrangedSubviews: [sellerName, sellerUsername])
        infoStack.axis = .vertical
        infoStack.spacing = 2
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        sellerCard.addSubview(infoStack)
        sellerCard.addSubview(chevron)
        NSLayoutConstraint.activate([
            sellerAvatar.leadingAnchor.constraint(equalTo: sellerCard.leadingAnchor, constant: 12),
            sellerAvatar.centerYAnchor.constraint(equalTo: sellerCard.centerYAnchor),
            sellerAvatar.widthAnchor.constraint(equalToConstant: 44),
            sellerAvatar.heightAnchor.constraint(equalToConstant: 44),
            infoStack.leadingAnchor.constraint(equalTo: sellerAvatar.trailingAnchor, constant: 12),
            infoStack.centerYAnchor.constraint(equalTo: sellerCard.centerYAnchor),
            infoStack.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            chevron.trailingAnchor.constraint(equalTo: sellerCard.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: sellerCard.centerYAnchor),
            sellerCard.heightAnchor.constraint(equalToConstant: 68)
        ])
        sellerAvatar.layer.cornerRadius = 22
        sellerCard.addTarget(self, action: #selector(onTapSeller), for: .touchUpInside)
        contentStack.addArrangedSubview(wrapInMargins(sellerCard))

        // Description
        let descTitle = UILabel()
        descTitle.text = "Description"
        descTitle.font = .systemFont(ofSize: 14, weight: .semibold)
        descTitle.textColor = .secondaryLabel
        descriptionLbl.font = .systemFont(ofSize: 15)
        descriptionLbl.numberOfLines = 0
        let descStack = UIStackView(arrangedSubviews: [descTitle, descriptionLbl])
        descStack.axis = .vertical
        descStack.spacing = 6
        contentStack.addArrangedSubview(wrapInMargins(descStack))

        // Bottom bar buttons
        var saveCfg = UIButton.Configuration.bordered()
        saveCfg.title = "Save"
        saveCfg.image = UIImage(systemName: "heart")
        saveCfg.imagePadding = 6
        saveBtn.configuration = saveCfg
        saveBtn.addTarget(self, action: #selector(onTapSave), for: .touchUpInside)

        var buyCfg = UIButton.Configuration.filled()
        buyCfg.title = "Buy Now"
        buyCfg.image = UIImage(systemName: "cart.fill")
        buyCfg.imagePadding = 6
        // VISUAL PARITY 2026-05-01: Android `buyButton` uses `@style/appBtn`
        // = brand blue. Switch from `.systemGreen` to AppColor.primary so
        // the primary CTA on this screen matches the rest of the app.
        buyCfg.baseBackgroundColor = AppColor.primary
        buyNowBtn.configuration = buyCfg
        buyNowBtn.addTarget(self, action: #selector(onTapBuyNow), for: .touchUpInside)

        let btnRow = UIStackView(arrangedSubviews: [saveBtn, buyNowBtn])
        btnRow.axis = .horizontal
        btnRow.spacing = 12
        btnRow.distribution = .fill
        saveBtn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        buyNowBtn.setContentHuggingPriority(.defaultLow, for: .horizontal)
        btnRow.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(btnRow)
        NSLayoutConstraint.activate([
            btnRow.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            btnRow.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            btnRow.centerYAnchor.constraint(equalTo: bottomBar.safeAreaLayoutGuide.centerYAnchor)
        ])

        // Spinner overlay
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        navigationItem.largeTitleDisplayMode = .never
    }

    /// Wrap a view with its own inner margins so the outer `contentStack`
    /// margins don't double-apply when nested.
    private func wrapInMargins(_ v: UIView) -> UIView {
        let w = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        w.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: w.topAnchor),
            v.bottomAnchor.constraint(equalTo: w.bottomAnchor),
            v.leadingAnchor.constraint(equalTo: w.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: w.trailingAnchor)
        ])
        return w
    }

    // MARK: - Collection

    private func configureCollection() {
        galleryCollection.register(ProductGalleryCell.self,
                                   forCellWithReuseIdentifier: ProductGalleryCell.reuseId)
        galleryCollection.dataSource = self
        galleryCollection.delegate = self
    }

    // MARK: - Data load

    @MainActor
    private func loadDetails() async {
        spinner.startAnimating()
        defer { spinner.stopAnimating() }
        do {
            let fields: [String: String] = ["product_id": "\(productId)"]
            let resp: ProductDetailsResponse = try await APIManager.shared.postMultipartForm(
                type: .getProductDetails(param: fields),
                fields: fields,
                header: true
            )
            self.details = resp.data
            self.isSaved = resp.data?.productSaveStatus ?? false
            self.gallery = resp.data?.galleryItems ?? []
            render()
        } catch {
            let msg: String
            if let de = error as? DataError {
                msg = de.getErrorMessage()
            } else {
                msg = error.localizedDescription
            }
            let alert = UIAlertController(title: "Couldn't load product", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func render() {
        guard let d = details else { return }
        title = d.title ?? "Product"
        titleLbl.text = d.title
        priceLbl.text = d.displayPrice
        pricingBadge.text = "  \(d.pricingBadgeText)  "
        // VISUAL PARITY 2026-05-01: auction listings keep the purple badge
        // (matches Android's distinct auction color), buy-now listings use
        // brand blue.
        pricingBadge.backgroundColor = (d.auction == true) ? .systemPurple : AppColor.primary
        conditionLbl.text = d.productCondition.map { "Condition: \($0)" }
        skuLbl.text = (d.sku ?? "").isEmpty ? nil : "SKU: \(d.sku ?? "")"
        descriptionLbl.text = (d.description ?? "").isEmpty
            ? "No description provided."
            : d.description

        // Seller card
        sellerName.text = d.user?.name ?? "Seller"
        if let u = d.user?.username, !u.isEmpty {
            sellerUsername.text = "@\(u)"
        } else if let e = d.user?.email, !e.isEmpty {
            sellerUsername.text = e
        } else {
            sellerUsername.text = nil
        }
        if let raw = d.user?.profileImage,
           let url = URL(string: raw),
           !raw.isEmpty {
            sellerAvatar.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.crop.circle")
            )
        } else {
            sellerAvatar.image = UIImage(systemName: "person.crop.circle")
        }

        // Save button visual
        updateSaveButtonState()

        // Gallery
        pageControl.numberOfPages = gallery.count
        pageControl.isHidden = gallery.count <= 1
        galleryCollection.reloadData()
    }

    private func updateSaveButtonState() {
        var cfg = saveBtn.configuration ?? UIButton.Configuration.bordered()
        if isSaved {
            cfg.title = "Saved"
            cfg.image = UIImage(systemName: "heart.fill")
            cfg.baseForegroundColor = .systemPink
        } else {
            cfg.title = "Save"
            cfg.image = UIImage(systemName: "heart")
            // VISUAL PARITY 2026-05-01: Follow / Save accent uses brand blue.
            cfg.baseForegroundColor = AppColor.primary
        }
        saveBtn.configuration = cfg
    }

    // MARK: - Actions

    @objc private func onTapSeller() {
        guard let uid = details?.user?.id ?? details?.userId else { return }
        let vc = SellerPublicProfileViewController(userId: uid)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func onTapSave() {
        guard let pid = details?.id ?? Optional(productId) else { return }
        let newSaved = !isSaved
        isSaved = newSaved
        updateSaveButtonState()
        // Optimistic — Android uses `api/product/save` (saveSellerProduct).
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let fields: [String: String] = [
                    "product_id": "\(pid)",
                    "status": newSaved ? "1" : "0"
                ]
                let _: APIResponse<AnyCodable> = try await APIManager.shared.postMultipartForm(
                    type: .saveSellerProduct(param: fields),
                    fields: fields,
                    header: true
                )
            } catch {
                // revert on failure
                await MainActor.run {
                    self.isSaved = !newSaved
                    self.updateSaveButtonState()
                }
            }
        }
    }

    /// Buy Now handler — pushes `CheckoutViewController(productId:)` so the
    /// buyer lands on the existing Phase 4 checkout flow.
    /// Wired as part of iOS Parity P0.2.
    @objc func onTapBuyNow() {
        let pid = details?.id ?? productId
        let vc = CheckoutViewController(productId: pid)
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            // Fallback: wrap in a nav and present modally. Should not happen
            // in normal tab flow, but keeps the button functional from
            // contexts like deep-link opened in a bare VC.
            let wrap = UINavigationController(rootViewController: vc)
            wrap.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            present(wrap, animated: true)
        }
    }
}

// MARK: - Collection data source

extension ProductDetailsViewController: UICollectionViewDataSource,
                                        UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(gallery.count, 1) // show placeholder cell if empty
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductGalleryCell.reuseId, for: indexPath
        ) as! ProductGalleryCell
        if indexPath.item < gallery.count {
            cell.configure(with: gallery[indexPath.item])
        } else {
            cell.configure(with: nil)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: collectionView.bounds.height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === galleryCollection else { return }
        let page = Int(round(scrollView.contentOffset.x / max(scrollView.bounds.width, 1)))
        pageControl.currentPage = page
    }
}

// MARK: - Gallery cell

final class ProductGalleryCell: UICollectionViewCell {
    static let reuseId = "ProductGalleryCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .tertiarySystemFill
        return iv
    }()
    private let playIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        iv.layer.shadowColor = UIColor.black.cgColor
        iv.layer.shadowRadius = 4
        iv.layer.shadowOpacity = 0.4
        iv.layer.shadowOffset = CGSize(width: 0, height: 1)
        return iv
    }()

    private var videoURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addSubview(playIcon)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            playIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 64),
            playIcon.heightAnchor.constraint(equalToConstant: 64)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        contentView.addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: ProductMediaItem?) {
        guard let item = item else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
            playIcon.isHidden = true
            videoURL = nil
            return
        }
        playIcon.isHidden = !item.isVideo
        videoURL = item.isVideo ? URL(string: item.url) : nil
        if let url = URL(string: item.url) {
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "photo"),
                options: [.transition(.fade(0.2))]
            )
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }

    @objc private func onTap() {
        // If it's a video, present a fullscreen player.
        guard let url = videoURL else { return }
        let parent = firstAvailableViewController()
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        parent?.present(vc, animated: true) {
            player.play()
        }
    }

    private func firstAvailableViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return nil
    }
}
