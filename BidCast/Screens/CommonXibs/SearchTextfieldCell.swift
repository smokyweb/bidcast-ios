//
//  SearchTextfieldCell.swift
//  Well Genius App
//
//  Created by Vivek-JAM-E-328 on 04/09/24.
//

import UIKit

class SearchTextfieldCell: UITableViewCell {

    //MARK: IBOutlets.
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var textfieldOlt: UITextField!
    @IBOutlet weak var filterBtnOlt: UIButton!

    //MARK: properties.
    static let identifier = "SearchTextfieldCell"
    
    var searchText : (String) -> () = {_ in  }
    var filterHistoryBtnTapped: (UIButton) -> () = {_ in }
    var searchTimer: Timer?
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        self.textfieldOlt.delegate = self
    }

    func setupUI() {
        self.outerViewOlt.backgroundColor = .pearl
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        innerViewOlt.dropShadow(opacity: 0.2, shadowRadius: Radius_04, cornerRadius: Corner_08, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
//        self.innerViewOlt.addBorders(of: AppColor.bgColor ?? .bg, width: Width_01)
        // Configure the view for the selected state
    }
    
    //MARK: IBAction.
    @IBAction func didTapFilterBtn(_ sender: UIButton) {
        print("didTapFilter")
//        self.didTapFilter(sender)
        filterHistoryBtnTapped(sender)
    }
}

//MARK: UITextFieldDelegate.
extension SearchTextfieldCell : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        if searchTimer != nil {
            searchTimer?.invalidate()
            searchTimer = nil
        }
        
        // reschedule the search: in 1.0 second, call the searchForKeyword method on the new textfield content
        searchTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(searchForKeyword), userInfo: nil, repeats: false)
        return true;
    }
    
    @objc func searchForKeyword() {
        self.endEditing(true)
        // retrieve the keyword from user info
        let keyword = textfieldOlt.text ?? ""
        
        print("Searching for keyword \(keyword)")
        //if keyword as? String != "" {
        self.searchText(keyword as? String ?? "")
        //}
    }
}
