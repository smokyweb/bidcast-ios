//
//  DatePickerViewController.swift
//  BidCast
//
//  Created by JAM-E-221 on 12/09/24.
//

import UIKit

protocol DatePickerViewControllerDelegate: AnyObject {
    func datePickerViewController(_ controller: DatePickerViewController, didPickYear year: Int)
}

class DatePickerViewController: UIViewController {
    
    //MARK: Properties.
    weak var delegate: DatePickerViewControllerDelegate?
    private let datePicker = UIDatePicker()
    private let toolbar = UIToolbar()
    
    // MARK: Life Cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDatePicker()
        setupToolbar()
        setupLayout()
    }
    // MARK: setupDatePicker.
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        // Initially set the date picker to the current year
        let currentYear = Calendar.current.component(.year, from: Date())
        datePicker.setDate(Calendar.current.date(from: DateComponents(year: currentYear)) ?? Date(), animated: false)
    }
    // MARK: setupToolbar.
    private func setupToolbar() {
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
    }
    // MARK: setupLayout.
    private func setupLayout() {
        view.addSubview(datePicker)
        view.addSubview(toolbar)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func donePressed() {
        let selectedDate = datePicker.date
        let year = Calendar.current.component(.year, from: selectedDate)
        delegate?.datePickerViewController(self, didPickYear: year)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        // Optionally handle date changes
    }
}
