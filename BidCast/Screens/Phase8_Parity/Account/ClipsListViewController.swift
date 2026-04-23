//
//  ClipsListViewController.swift
//  BidCast — iOS Parity Phase 8 / P2.14 (2026-04-23)
//
//  Android port: `ui/sellerProfile/ClipsFragment.kt` + associated view
//  model. Renders a grid of clip thumbnails and plays the selected clip
//  via AVPlayer in a modal. Optionally takes a seller id — when nil the
//  VC shows the current user's own clips (matches Android's behaviour:
//  `sellerId == null` triggers edit mode at ClipEditActivity, here we
//  just show the list; capture/edit is a placeholder follow-up).
//
//  Replaces the P0.6 placeholder (`ClipsPlaceholderViewController`).
//  The placeholder remains in the project for screens that want a
//  "coming soon" panel (e.g. Seller Profile Clips tab pre-P2.14).
//
//  Networking contract — GET api/get-clips?seller_id=<id>&page=<n>:
//    - Android returns `GetClipsResponse` = APIPaginated<ClipEntry>.
//    - iOS uses `ClipEntry` already declared in
//      `BidCast/Models/LiveStream/ShowModels.swift`.
//

import UIKit
import AVKit

final class ClipsListViewController: UIViewController,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegate,
                                     UICollectionViewDelegateFlowLayout {

    // MARK: - Input

    /// If nil, the list shows the current user's own clips (from Android's
    /// behaviour: `sellerId == null` means "my" clips). Non-nil -> that
    /// seller's public clips feed.
    private let sellerId: Int?

    // MARK: - State

    private var clips: [ClipEntry] = []
    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    private var hasFetchedOnce = false

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ClipThumbCell.self, forCellWithReuseIdentifier: ClipThumbCell.reuseId)
        cv.dataSource = self
        cv.delegate = self
        cv.alwaysBounceVertical = true
        return cv
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No clips yet."
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 14)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()

    // MARK: - Init

    init(sellerId: Int? = nil) {
        self.sellerId = sellerId
        super.init(nibName: nil, bundle: nil)
        self.title = "Clips"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(spinner)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
        // Only the "my clips" variant shows the record entry (edit mode
        // on Android) — keep it behind a placeholder for now.
        if sellerId == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "video.badge.plus"),
                style: .plain,
                target: self,
                action: #selector(openEditorTapped)
            )
        }
        fetchPage(reset: true)
    }

    // MARK: - Fetch

    private func fetchPage(reset: Bool) {
        guard !isFetching else { return }
        isFetching = true
        if reset {
            currentPage = 1
            clips = []
            emptyLabel.isHidden = true
        }
        spinner.startAnimating()
        Task { [weak self] in
            guard let self = self else { return }
            defer {
                self.isFetching = false
                self.spinner.stopAnimating()
            }
            do {
                let resp: GetClipsResponse = try await APIManager.shared.request(
                    type: .getUserClips(
                        sellerId: self.sellerId.map(String.init),
                        page: String(self.currentPage)
                    ),
                    header: true
                )
                let new = resp.data ?? []
                await MainActor.run {
                    if reset { self.clips = [] }
                    self.clips.append(contentsOf: new)
                    self.currentPage = resp.currentPage ?? self.currentPage
                    self.totalPages = resp.totalPage ?? self.currentPage
                    self.hasFetchedOnce = true
                    self.emptyLabel.isHidden = !self.clips.isEmpty
                    self.collectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.hasFetchedOnce = true
                    self.emptyLabel.text = self.clips.isEmpty
                        ? "Couldn't load clips.\n\((error as? DataError)?.getErrorMessage() ?? error.localizedDescription)"
                        : "No clips yet."
                    self.emptyLabel.isHidden = !self.clips.isEmpty
                }
            }
        }
    }

    // MARK: - Data source

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return clips.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ClipThumbCell.reuseId, for: indexPath) as! ClipThumbCell
        cell.configure(with: clips[indexPath.item])
        return cell
    }

    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 3-up grid like Android.
        let columns: CGFloat = 3
        let spacing: CGFloat = 8
        let hInset: CGFloat = 24
        let width = floor((collectionView.bounds.width - hInset - spacing * (columns - 1)) / columns)
        return CGSize(width: width, height: width * 1.4)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        // Infinite scroll near the bottom.
        if indexPath.item >= clips.count - 3,
           currentPage < totalPages,
           !isFetching {
            currentPage += 1
            fetchPage(reset: false)
        }
    }

    // MARK: - Selection

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let clip = clips[indexPath.item]
        // Tap-through:
        //   - If this is the *owner's* list (sellerId == nil) push ClipEdit;
        //     matches Android's `isEdit = (sellerId == null)` path.
        //   - Otherwise just play the clip.
        if sellerId == nil {
            let editor = ClipEditViewController(clip: clip)
            navigationController?.pushViewController(editor, animated: true)
            return
        }
        playClip(clip)
    }

    private func playClip(_ clip: ClipEntry) {
        guard let urlStr = clip.clipUrl, let url = URL(string: urlStr) else {
            let a = UIAlertController(title: "Unavailable",
                                      message: "This clip is missing a video URL.",
                                      preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }
        let player = AVPlayer(url: url)
        let pvc = AVPlayerViewController()
        pvc.player = player
        pvc.modalPresentationStyle = .fullScreen
        present(pvc, animated: true) {
            player.play()
        }
    }

    @objc private func openEditorTapped() {
        navigationController?.pushViewController(ClipEditViewController(clip: nil), animated: true)
    }
}

// MARK: - Clip thumb cell

private final class ClipThumbCell: UICollectionViewCell {
    static let reuseId = "ClipThumbCell"

    private let thumb = UIImageView()
    private let playIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 8
        thumb.backgroundColor = .secondarySystemBackground
        contentView.addSubview(thumb)

        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.image = UIImage(systemName: "play.circle.fill")
        playIcon.tintColor = .white.withAlphaComponent(0.9)
        playIcon.contentMode = .scaleAspectFit
        contentView.addSubview(playIcon)

        NSLayoutConstraint.activate([
            thumb.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumb.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumb.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            playIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playIcon.widthAnchor.constraint(equalToConstant: 36),
            playIcon.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(with clip: ClipEntry) {
        thumb.image = UIImage(systemName: "film")
        thumb.tintColor = .tertiaryLabel
        if let urlStr = clip.thumbnailUrl, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.thumb.image = image
                    self?.thumb.tintColor = nil
                }
            }.resume()
        }
    }
}
