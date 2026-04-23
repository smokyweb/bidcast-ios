//
//  ClipEditViewController.swift
//  BidCast — iOS Parity Phase 8 / P2.14 (2026-04-23)
//
//  Android port: `ui/sellerProfile/ClipEditActivity.kt`. On Android this
//  screen captures / trims / captions a clip from a live show recording
//  and uploads it via `make-clip`. The full camera + trim pipeline is
//  substantial (AVFoundation composition, thumbnail generation, upload
//  progress). The P2.14 commit delivers the plumbing and an intentional
//  "coming soon" capture path; the data model (ClipEntry) and the REST
//  contract (`make-clip`) are all in place so follow-up commit P2.14b
//  can fill this in without touching the list VC again.
//
//  Today's behaviour:
//    * If opened with an existing `ClipEntry` (tapped from the owner's
//      list), play the clip via AVPlayer and expose a "Delete" action
//      (no backend delete-clip endpoint is registered in iOS yet, so
//      it surfaces a "coming soon" toast on tap).
//    * If opened fresh (`clip == nil`), show the capture prompt.
//

import UIKit
import AVKit

final class ClipEditViewController: UIViewController {

    private let clip: ClipEntry?

    init(clip: ClipEntry?) {
        self.clip = clip
        super.init(nibName: nil, bundle: nil)
        self.title = clip == nil ? "Record Clip" : "Clip"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        if clip != nil {
            configureEditMode()
        } else {
            configureCaptureMode()
        }
    }

    // MARK: - Edit (play + manage an existing clip)

    private func configureEditMode() {
        guard let clip = clip, let urlStr = clip.clipUrl, let url = URL(string: urlStr) else {
            showPlaceholder(icon: "film",
                            title: "Clip missing",
                            body: "This clip isn't playable right now. Please try another clip.")
            return
        }

        let player = AVPlayer(url: url)
        let pvc = AVPlayerViewController()
        pvc.player = player
        addChild(pvc)
        pvc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pvc.view)
        NSLayoutConstraint.activate([
            pvc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pvc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pvc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pvc.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55)
        ])
        pvc.didMove(toParent: self)

        let toolbar = UIStackView()
        toolbar.axis = .vertical
        toolbar.spacing = 12
        toolbar.isLayoutMarginsRelativeArrangement = true
        toolbar.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        toolbar.addArrangedSubview(titleLabel(clip: clip))
        toolbar.addArrangedSubview(makeButton(title: "Share link", systemIcon: "square.and.arrow.up") { [weak self] in
            self?.shareClip(clip)
        })
        toolbar.addArrangedSubview(makeButton(title: "Delete (coming soon)", systemIcon: "trash",
                                              tint: .systemRed) { [weak self] in
            self?.presentComingSoon(message: "Deleting clips from iOS is a follow-up release.")
        })

        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: pvc.view.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        player.play()
    }

    private func titleLabel(clip: ClipEntry) -> UILabel {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 15, weight: .medium)
        let idPart = clip.id.map { "#\($0) " } ?? ""
        let showPart = clip.showId.map { " from show \($0)" } ?? ""
        l.text = "Clip \(idPart)\(showPart)"
        return l
    }

    // MARK: - Capture (placeholder path)

    private func configureCaptureMode() {
        showPlaceholder(
            icon: "video.badge.plus",
            title: "Clip capture is coming soon",
            body: """
            Android currently captures clips from inside a live show. On iOS \
            we're planning a follow-up release where you'll be able to:
            \u{2022} Trim a highlight from a recorded show
            \u{2022} Add a caption and thumbnail
            \u{2022} Publish it to your Clips feed

            For now you can browse clips here, but new ones have to be \
            recorded on Android.
            """
        )
    }

    // MARK: - Helpers

    private func shareClip(_ clip: ClipEntry) {
        guard let urlStr = clip.clipUrl, let url = URL(string: urlStr) else { return }
        let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(sheet, animated: true)
    }

    private func presentComingSoon(message: String) {
        let a = UIAlertController(title: "Coming soon", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    private func makeButton(title: String,
                            systemIcon: String,
                            tint: UIColor = .systemBlue,
                            action: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.tinted()
        cfg.title = title
        cfg.image = UIImage(systemName: systemIcon)
        cfg.imagePadding = 8
        cfg.baseForegroundColor = tint
        b.configuration = cfg
        b.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return b
    }

    private func showPlaceholder(icon: String, title: String, body: String) {
        let icon = UIImageView(image: UIImage(systemName: icon))
        icon.tintColor = .systemPink
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.font = .systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            icon.widthAnchor.constraint(equalToConstant: 64),
            icon.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
}
