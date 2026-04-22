//
//  LiveBanner.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Lightweight top-of-screen status banner for live stream screens.
//  Used by WatchStreamViewController + HostPublisherViewController to
//  surface transient connection state (Reconnecting..., Video error,
//  etc.) without covering the remote video.
//
//  Android parity: WatchStreamFragment + AgoraPublisherActivity show a
//  small Snackbar / Toast at the top of the screen for the same states.
//

import UIKit

public final class LiveBanner: UIView {

    public enum Style {
        case warning   // orange
        case error     // red
        case info      // blue-grey

        var backgroundColor: UIColor {
            switch self {
            case .warning: return UIColor.systemOrange.withAlphaComponent(0.9)
            case .error:   return UIColor.systemRed.withAlphaComponent(0.9)
            case .info:    return UIColor.darkGray.withAlphaComponent(0.9)
            }
        }
    }

    private let label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .boldSystemFont(ofSize: 13)
        l.textColor = .white
        l.numberOfLines = 2
        l.textAlignment = .center
        return l
    }()

    private var hideWorkItem: DispatchWorkItem?

    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
        clipsToBounds = true
        isHidden = true
        isUserInteractionEnabled = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    /// Show the banner for `duration` seconds. `duration == 0` means
    /// "sticky" — the banner stays until `hide()` is called explicitly.
    /// Used for "Reconnecting..." which should persist until we reconnect.
    public func show(_ message: String, style: Style = .info, duration: TimeInterval = 2.5) {
        hideWorkItem?.cancel()
        label.text = message
        backgroundColor = style.backgroundColor
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.2) { self.alpha = 1 }

        guard duration > 0 else { return }
        let work = DispatchWorkItem { [weak self] in self?.hide() }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }

    public func hide() {
        hideWorkItem?.cancel()
        hideWorkItem = nil
        UIView.animate(withDuration: 0.2, animations: { self.alpha = 0 }) { _ in
            self.isHidden = true
        }
    }
}
