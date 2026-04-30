//
//  TrustedBuyerViewController.swift
//  BidCast — iOS Parity Phase 8 / P2.16 (2026-04-23)
//
//  Full Trusted Buyer management flow. Android reference:
//  `app/src/main/java/io/bidswipe/app/ui/more/TrustedBuyerActivity.kt`.
//
//  Flow summary (verified from the Android activity):
//    1. On appear, GET `buyer-identity/list` and decode `BuyerIdentityData`.
//       - If `image` is non-empty, show it inline plus the status step pills
//         (pending / verified / rejected).
//    2. User taps the upload zone -> PHPicker -> pick one photo of ID.
//    3. On submit, POST `buyer-identity/store` as multipart with `image`.
//    4. On success, re-fetch to update the status pills.
//
//  Differences from Android we deliberately accept (so this lands as one
//  commit instead of dragging in a new cropper dependency):
//    * Android uses `CustomCropImageContract` (camera + gallery with crop);
//      iOS uses stock PHPickerViewController. UX still mirrors the
//      "upload → review → submit" flow.
//    * Android's multi-color status pills are simplified to a status label
//      plus a short explanation. The three states (pending/verified/
//      rejected) all match.
//
//  This replaces the P0.6 placeholder that just read "coming soon".
//

import UIKit
import PhotosUI

final class TrustedBuyerViewController: UIViewController {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let content = UIStackView()
    private let headerLabel = UILabel()
    private let explainLabel = UILabel()
    private let statusLabel = UILabel()
    private let uploadZone = UIButton(type: .system)
    private let imagePreview = UIImageView()
    private let submitButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .large)

    // MARK: - State

    private var selectedImageData: Data?
    private var currentStatus: String?  // pending / verified / rejected
    private var remoteImageURL: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trusted Buyer"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        buildLayout()
        refreshStatusPresentation()
        fetchIdentity()
    }

    // MARK: - Layout

    private func buildLayout() {
        // Scroll container — keeps us safe on small devices when the status
        // copy expands to multiple lines.
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        content.axis = .vertical
        content.spacing = 16
        content.alignment = .fill
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        headerLabel.text = "Verify your identity"
        headerLabel.font = .systemFont(ofSize: 22, weight: .bold)
        headerLabel.numberOfLines = 0

        explainLabel.text = """
        Upload a clear photo of a government-issued ID (driver's license, \
        passport, or state ID). Once verified, you'll get Trusted Buyer perks \
        like instant-bid eligibility and higher spend limits.
        """
        explainLabel.font = .systemFont(ofSize: 14)
        explainLabel.textColor = .secondaryLabel
        explainLabel.numberOfLines = 0

        // Status pill row
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10
        statusLabel.layer.masksToBounds = true
        statusLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)

        // Upload zone — tappable area for the picker.
        uploadZone.setTitle("  Tap to upload photo of ID", for: .normal)
        uploadZone.setImage(UIImage(systemName: "arrow.up.doc"), for: .normal)
        uploadZone.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        uploadZone.tintColor = .label
        uploadZone.contentHorizontalAlignment = .center
        uploadZone.backgroundColor = .secondarySystemBackground
        uploadZone.layer.cornerRadius = 12
        uploadZone.layer.borderColor = UIColor.separator.cgColor
        uploadZone.layer.borderWidth = 1
        uploadZone.addTarget(self, action: #selector(pickImageTapped), for: .touchUpInside)
        uploadZone.heightAnchor.constraint(equalToConstant: 72).isActive = true

        imagePreview.contentMode = .scaleAspectFill
        imagePreview.clipsToBounds = true
        imagePreview.layer.cornerRadius = 12
        imagePreview.backgroundColor = .secondarySystemBackground
        imagePreview.heightAnchor.constraint(equalToConstant: 220).isActive = true
        imagePreview.isHidden = true
        // Tapping the preview reopens the picker to replace the image.
        imagePreview.isUserInteractionEnabled = true
        imagePreview.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(pickImageTapped)))

        submitButton.setTitle("Submit for review", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        submitButton.tintColor = .white
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.layer.cornerRadius = 12
        submitButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        content.addArrangedSubview(headerLabel)
        content.addArrangedSubview(explainLabel)
        content.addArrangedSubview(statusLabel)
        content.addArrangedSubview(uploadZone)
        content.addArrangedSubview(imagePreview)
        content.addArrangedSubview(submitButton)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Status -> UI

    private func refreshStatusPresentation() {
        switch (currentStatus ?? "").lowercased() {
        case "verified":
            statusLabel.text = "✓ Verified — Trusted Buyer perks are active."
            statusLabel.textColor = .white
            statusLabel.backgroundColor = .systemGreen
            statusLabel.isHidden = false
            submitButton.isHidden = true
            submitButton.isEnabled = false
            uploadZone.isHidden = remoteImageURL != nil
        case "rejected":
            statusLabel.text = "! Rejected — Please upload a clearer photo of your ID."
            statusLabel.textColor = .white
            statusLabel.backgroundColor = .systemRed
            statusLabel.isHidden = false
            submitButton.isHidden = false
            submitButton.isEnabled = true
            uploadZone.isHidden = false
        case "pending", "in_review":
            statusLabel.text = "In review — we'll notify you when verification completes."
            statusLabel.textColor = .white
            statusLabel.backgroundColor = .systemOrange
            statusLabel.isHidden = false
            submitButton.isHidden = true
            submitButton.isEnabled = false
            uploadZone.isHidden = remoteImageURL != nil
        default:
            // No prior upload — fresh state.
            statusLabel.text = nil
            statusLabel.isHidden = true
            submitButton.isHidden = false
            submitButton.isEnabled = (selectedImageData != nil)
            uploadZone.isHidden = false
        }
        // Add inset padding on the status pill when visible.
        if !statusLabel.isHidden, let base = statusLabel.text {
            statusLabel.text = "  \(base)  "
        }
    }

    // MARK: - Picker

    @objc private func pickImageTapped() {
        // Don't let an already-verified user re-upload by accident.
        if (currentStatus ?? "").lowercased() == "verified" { return }
        if (currentStatus ?? "").lowercased() == "pending" {
            p3Alert(title: "Still under review",
                    message: "Your previous submission is still being reviewed.")
            return
        }
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Submit

    @objc private func submitTapped() {
        guard let data = selectedImageData else {
            p3Alert(message: "Please choose a photo of your ID.")
            return
        }
        spinner.startAnimating()
        submitButton.isEnabled = false

        Task { [weak self] in
            guard let self = self else { return }
            do {
                _ = try await TrustedBuyerUploader.submit(imageData: data)
                await MainActor.run {
                    self.spinner.stopAnimating()
                    self.selectedImageData = nil
                    self.p3Alert(title: "Submitted",
                                 message: "Your ID is in review. We'll notify you when verification completes.") {
                        self.fetchIdentity()
                    }
                }
            } catch {
                await MainActor.run {
                    self.spinner.stopAnimating()
                    self.submitButton.isEnabled = true
                    self.p3Alert(message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Fetch current status

    private func fetchIdentity() {
        spinner.startAnimating()
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let response: GetBuyerIdentityResponse = try await APIManager.shared.request(
                    type: .fetchBuyerIdentity, header: true
                )
                await MainActor.run {
                    self.spinner.stopAnimating()
                    let data = response.data
                    self.currentStatus = data?.status
                    self.remoteImageURL = (data?.image?.isEmpty ?? true) ? nil : data?.image
                    if let urlStr = self.remoteImageURL, let url = URL(string: urlStr) {
                        self.imagePreview.isHidden = false
                        self.loadRemoteImage(from: url)
                    }
                    self.refreshStatusPresentation()
                }
            } catch {
                await MainActor.run {
                    self.spinner.stopAnimating()
                    // Silent fail is fine on initial load — user may have
                    // never uploaded an ID. We don't block the screen.
                    self.refreshStatusPresentation()
                }
            }
        }
    }

    private func loadRemoteImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imagePreview.image = image
            }
        }.resume()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension TrustedBuyerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let first = results.first else { return }
        let provider = first.itemProvider
        guard provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self, let img = object as? UIImage else { return }
            // Downscale + re-encode to keep upload payload predictable.
            let resized = TrustedBuyerViewController.normalize(image: img)
            let data = resized.jpegData(compressionQuality: 0.8)
            DispatchQueue.main.async {
                self.selectedImageData = data
                self.imagePreview.image = resized
                self.imagePreview.isHidden = false
                self.submitButton.isEnabled = (data != nil)
            }
        }
    }

    private static func normalize(image: UIImage) -> UIImage {
        // Cap to 1600px on the long edge so the multipart body stays small.
        let maxEdge: CGFloat = 1600
        let size = image.size
        let longest = max(size.width, size.height)
        if longest <= maxEdge { return image }
        let scale = maxEdge / longest
        let newSize = CGSize(width: floor(size.width * scale),
                             height: floor(size.height * scale))
        let r = UIGraphicsImageRenderer(size: newSize)
        return r.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// MARK: - Multipart upload helper
//
// Android's TrustedBuyerActivity sends a single `image` part to
// `buyer-identity/store`. We mirror that contract here. Placed in the same
// file as the VC so the flow is easy to audit — if QA hits a backend
// contract tweak, one file owns the whole pipeline.

private enum TrustedBuyerUploader {

    @discardableResult
    static func submit(imageData: Data) async throws -> GetBuyerIdentityResponse {
        let endpoint = APIEndPoint.storeBuyerIdentity(param: [:])
        guard let url = endpoint.url else { throw DataError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Authorization": "Bearer \(UserDefaults.accessToken)"
        ]

        var body = Data()
        let crlf = "\r\n"
        let filename = "\(Int(Date().timeIntervalSince1970))_id_photo.jpeg"
        body.append("--\(boundary)\(crlf)")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\(crlf)")
        body.append("Content-Type: image/jpeg\(crlf + crlf)")
        body.append(imageData)
        body.append(crlf)
        body.append("--\(boundary)--\(crlf)")
        request.httpBody = body

        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 240

        let (data, response) = try await URLSession(configuration: config).data(for: request)
        // P2.17 compatibility: fire the global 401 interceptor if it comes back 401.
        if let http = response as? HTTPURLResponse {
            APIManager.handleStatusCodeIfNeeded(http.statusCode)
        }
        guard let http = response as? HTTPURLResponse,
              200 ... 299 ~= http.statusCode else {
            if let apiError = try? JSONDecoder().decode(ApiError.self, from: data) {
                throw DataError.invalidCode(apiError.message)
            }
            throw DataError.invalidCode("Upload failed. Please try again.")
        }
        return try JSONDecoder().decode(GetBuyerIdentityResponse.self, from: data)
    }
}

// Data.append(_ string: String) is provided by Extensions/Data+Extension.swift.
