//
//  CreatePollSheet.swift
//  BidCast
//
//  iOS Parity Phase 6b (2026-04-22) — Host-side Create Poll sheet.
//
//  Mirrors Android `AgoraPublisherActivity.createPollSheet()` and the
//  PWA's `#createPollModal` (startShow.blade.php, 2026-04-22 deploy).
//
//  Socket contract (matches Android SocketManager.kt, already in
//  BidcastSocketManager.emitCreatePoll):
//    create_poll { room_id, question, options: [String], duration: seconds }
//
//  The host can pick from 2 to 4 options and choose a duration
//  (15 / 30 / 60 / custom seconds). Android uses minutes; we expose
//  seconds because the Node handler expects `duration` in seconds
//  (see PWA report — "duration_seconds" maps to Node's `duration`
//  field). Android sends `duration * 60` — we document that here
//  and keep iOS on seconds for alignment with the PWA.
//

import UIKit

public final class CreatePollSheet: UIViewController {

    public var roomId: String
    public var onSubmitted: ((_ question: String, _ options: [String], _ durationSeconds: Int) -> Void)?

    private static let maxOptions = 4
    private static let minOptions = 2

    private let scroll = UIScrollView()
    private let card = UIView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.alignment = .fill
        return s
    }()

    private let questionField: UITextField = {
        let t = UITextField()
        t.placeholder = "Poll question"
        t.borderStyle = .roundedRect
        t.font = .systemFont(ofSize: 15)
        t.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return t
    }()

    private var optionFields: [UITextField] = []
    private let optionsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        return s
    }()
    private lazy var addOptionButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+ Add option", for: .normal)
        b.contentHorizontalAlignment = .leading
        return b
    }()

    private let durationSegment: UISegmentedControl = {
        let s = UISegmentedControl(items: ["15s", "30s", "60s", "Custom"])
        s.selectedSegmentIndex = 1 // default 30s
        return s
    }()
    private let customDurationField: UITextField = {
        let t = UITextField()
        t.placeholder = "Custom duration (seconds)"
        t.keyboardType = .numberPad
        t.borderStyle = .roundedRect
        t.isHidden = true
        return t
    }()

    private let submitButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Create Poll"
        cfg.baseBackgroundColor = .systemBlue
        b.configuration = cfg
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    public init(roomId: String) {
        self.roomId = roomId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Create Poll"

        setupLayout()
        addOption()
        addOption()

        durationSegment.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        addOptionButton.addTarget(self, action: #selector(addOptionTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        card.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        durationSegment.translatesAutoresizingMaskIntoConstraints = false
        customDurationField.translatesAutoresizingMaskIntoConstraints = false
        questionField.translatesAutoresizingMaskIntoConstraints = false
        addOptionButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scroll)
        scroll.addSubview(card)
        card.addSubview(stack)

        let hint = makeSectionLabel("Ask your viewers a question")
        let optsLabel = makeSectionLabel("Options (2–\(Self.maxOptions))")
        let durLabel = makeSectionLabel("Duration")

        stack.addArrangedSubview(hint)
        stack.addArrangedSubview(questionField)
        stack.addArrangedSubview(optsLabel)
        stack.addArrangedSubview(optionsStack)
        stack.addArrangedSubview(addOptionButton)
        stack.addArrangedSubview(durLabel)
        stack.addArrangedSubview(durationSegment)
        stack.addArrangedSubview(customDurationField)
        stack.addArrangedSubview(submitButton)
        stack.addArrangedSubview(cancelButton)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            card.topAnchor.constraint(equalTo: scroll.topAnchor),
            card.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            card.widthAnchor.constraint(equalTo: scroll.widthAnchor),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            submitButton.heightAnchor.constraint(equalToConstant: 46),
        ])
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    private func addOption() {
        guard optionFields.count < Self.maxOptions else { return }
        let f = UITextField()
        f.placeholder = "Option \(optionFields.count + 1)"
        f.borderStyle = .roundedRect
        f.heightAnchor.constraint(equalToConstant: 40).isActive = true
        optionFields.append(f)
        optionsStack.addArrangedSubview(f)
        addOptionButton.isHidden = optionFields.count >= Self.maxOptions
    }

    @objc private func addOptionTapped() { addOption() }

    @objc private func durationChanged() {
        customDurationField.isHidden = durationSegment.selectedSegmentIndex != 3
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func submit() {
        let question = (questionField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else {
            showError("Please enter a poll question.")
            return
        }
        let options = optionFields
            .map { ($0.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard options.count >= Self.minOptions else {
            showError("Please enter at least \(Self.minOptions) options.")
            return
        }
        let durationSeconds: Int
        switch durationSegment.selectedSegmentIndex {
        case 0: durationSeconds = 15
        case 1: durationSeconds = 30
        case 2: durationSeconds = 60
        case 3:
            let raw = (customDurationField.text ?? "").trimmingCharacters(in: .whitespaces)
            guard let n = Int(raw), n >= 5, n <= 600 else {
                showError("Custom duration must be 5–600 seconds.")
                return
            }
            durationSeconds = n
        default: durationSeconds = 30
        }

        BidcastSocketManager.shared.emitCreatePoll(
            roomId: roomId,
            question: question,
            options: options,
            durationSeconds: durationSeconds
        )
        onSubmitted?(question, options, durationSeconds)
        dismiss(animated: true)
    }

    private func showError(_ msg: String) {
        let a = UIAlertController(title: "Missing info", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
