//
//  ScheduleShowEditorViewController.swift
//  BidCast — iOS parity Phase 3g (2026-04-22)
//
//  POST /api/store-schedule-show  — create show
//  POST /api/update-schedule-show — edit show
//
//  Minimum-viable form: title, description, date, time, category. Products
//  attachment + thumbnail + sales format use the same backend fields;
//  attach-products picker comes in a follow-up pass.
//

import UIKit
import SVProgressHUD

final class ScheduleShowEditorViewController: UIViewController {

    enum Mode {
        case create
        case edit(Show)
    }
    private let mode: Mode

    private let titleField = UITextField()
    private let descField = UITextView()
    private let datePicker = UIDatePicker()
    private let categoryField = UITextField()
    private var selectedCategoryId: Int?
    private var availableCategories: [Category] = []

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        switch mode {
        case .create: self.title = "Schedule show"
        case .edit(let s): self.title = s.title ?? "Edit show"
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(save))
        if case .edit = mode {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Delete", style: .plain, target: self, action: #selector(deleteShow))
            navigationItem.leftBarButtonItem?.tintColor = .systemRed
        }

        setupLayout()
        loadCategories()
        if case .edit(let s) = mode { populate(from: s) }
    }

    private func setupLayout() {
        titleField.placeholder = "Show title"
        titleField.borderStyle = .roundedRect

        categoryField.placeholder = "Category"
        categoryField.borderStyle = .roundedRect
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickCategory))
        categoryField.isUserInteractionEnabled = true
        categoryField.addGestureRecognizer(tap)

        descField.font = .systemFont(ofSize: 15)
        descField.layer.borderColor = UIColor.separator.cgColor
        descField.layer.borderWidth = 1
        descField.layer.cornerRadius = 8
        descField.heightAnchor.constraint(equalToConstant: 120).isActive = true

        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        if #available(iOS 13.4, *) { datePicker.preferredDatePickerStyle = .inline }

        let stack = UIStackView(arrangedSubviews: [
            label("Title"), titleField,
            label("When"), datePicker,
            label("Category"), categoryField,
            label("Description (optional)"), descField,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -32)
        ])
    }

    private func label(_ s: String) -> UILabel {
        let l = UILabel()
        l.text = s
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    private func loadCategories() {
        Task { @MainActor in
            do {
                let resp: GetCategoryResponse = try await APIManager.shared.request(
                    type: .getCategory, header: true
                )
                self.availableCategories = resp.data ?? []
            } catch {
                self.availableCategories = []
            }
        }
    }

    @objc private func pickCategory() {
        guard !availableCategories.isEmpty else {
            p3Alert(message: "Categories still loading. Try again in a moment.")
            return
        }
        let sheet = UIAlertController(title: "Choose category", message: nil, preferredStyle: .actionSheet)
        for c in availableCategories.prefix(20) {
            sheet.addAction(UIAlertAction(title: c.name ?? "—", style: .default) { [weak self] _ in
                self?.selectedCategoryId = c.id
                self?.categoryField.text = c.name
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func populate(from show: Show) {
        titleField.text = show.title
        if let cid = show.categoryId {
            selectedCategoryId = cid
            categoryField.text = show.category?.name ?? "Category #\(cid)"
        }
        // date + time parsing best-effort
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(identifier: "UTC")
        if let d = show.date, let t = show.time {
            let composite = "\(d) \(t)"
            if let date = df.date(from: composite) { datePicker.date = date }
        }
    }

    // MARK: - Submit

    @objc private func save() {
        guard let t = titleField.text, !t.isEmpty else {
            p3Alert(title: "Missing info", message: "Show title is required."); return
        }
        let dateFormat = DateFormatter(); dateFormat.dateFormat = "yyyy-MM-dd"
        let timeFormat = DateFormatter(); timeFormat.dateFormat = "HH:mm:ss"
        dateFormat.timeZone = TimeZone.current
        timeFormat.timeZone = TimeZone.current
        let dateStr = dateFormat.string(from: datePicker.date)
        let timeStr = timeFormat.string(from: datePicker.date)

        var fields: [String: String] = [
            "title": t,
            "date": dateStr,
            "time": timeStr,
            "language": "en"
        ]
        if let cid = selectedCategoryId { fields["category_id"] = "\(cid)" }
        if let desc = descField.text, !desc.isEmpty {
            // Android doesn't show a 'description' key for schedule-show,
            // but the BidSwipe PWA does. Send it — backend ignores unknown keys.
            fields["description"] = desc
        }

        let endpoint: APIEndPoint
        if case .edit(let s) = mode, let id = s.id {
            fields["show_id"] = "\(id)"
            endpoint = .updateScheduleShow(param: [:])
        } else {
            endpoint = .storeScheduleShow(param: [:])
        }

        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let _: CreateShowResponse = try await APIManager.shared.postMultipartForm(
                    type: endpoint, fields: fields, header: true
                )
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    @objc private func deleteShow() {
        guard case .edit(let s) = mode, let id = s.id else { return }
        p3Confirm(title: "Delete show",
                  message: "This will cancel the scheduled show.",
                  destructive: true) {
            SVProgressHUD.show()
            Task { @MainActor in
                defer { SVProgressHUD.dismiss() }
                do {
                    let fields = ["show_id": "\(id)", "status": "cancelled"]
                    // Android doesn't ship a dedicated delete-show endpoint —
                    // update-schedule-show with status=cancelled is the idiom.
                    let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                        type: .updateScheduleShow(param: [:]),
                        fields: fields, header: true
                    )
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
                }
            }
        }
    }
}
