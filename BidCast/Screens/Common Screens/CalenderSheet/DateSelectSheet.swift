//
//  EmployeeDateSelectSheet.swift
//  Last Minute Louie
//
//  Created by JAM-E-221 on 29/05/24.
//

import UIKit

class DateSelectSheet: UIViewController {
    
    //MARK: IBOutlets.
    @IBOutlet weak var sessionShittedTableView: UITableView!
    @IBOutlet weak var SubmitBtn: UIButton!
    
    //MARK: Properties.
    //  private var viewModel = HomeViewModel()
    //var date = ""
    var pickedDate : (String) -> () = { _ in }
    var datesArr = [String]()
    var numbeOfDate = ""
    var pickedDateArr : ([String]) -> () = { _ in }
    
    
    // MARK: Life Cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialSetup()
    }
    
    // MARK: loadInitialSetup.
    private func loadInitialSetup(){
        configureViews()
    }
    
    // MARK: configureViews.
    private func configureViews() {
        sessionShittedTableView.delegate = self
        sessionShittedTableView.dataSource = self
        self.sessionShittedTableView.register(UINib(nibName: "CalandarTableViewCell", bundle: nil), forCellReuseIdentifier: "CalandarTableViewCell")
        self.sessionShittedTableView.layer.cornerRadius = 30
        self.SubmitBtn.makeCornerRounded(ofSize: Corner_08)
        self.SubmitBtn.addTarget(self, action: #selector(didTabSubmitDate), for: .touchUpInside)
        if self.numbeOfDate == "Multiple"{
            self.SubmitBtn.isHidden = false
        }else{
            self.SubmitBtn.isHidden = true
        }
    }
    
    // MARK: Methods
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc private func didTabSubmitDate() {
        debugLog(self.datesArr)
        self.pickedDateArr(self.datesArr)
    }
    
    @IBAction func backaction(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
}

// MARK: UITableViewDataSource,UITableViewDelegate.
extension DateSelectSheet: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalandarTableViewCell") as? CalandarTableViewCell else {
            return UITableViewCell()
        }
        cell.iscoming = "BookSession"
        
        if self.numbeOfDate == "Multiple"{
            cell.multipleSelection = true
        }else{
            cell.multipleSelection = false
        }
        cell.setUpCalender()
        cell.selectedDate = { dateSelect in
            
            if self.numbeOfDate == "Multiple"{
                self.datesArr.append(dateSelect)
            }else{
                
                self.pickedDate(dateSelect)
            }
        }
        cell.selectionStyle  = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
}

