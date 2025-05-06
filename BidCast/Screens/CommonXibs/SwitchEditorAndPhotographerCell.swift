//
//  SwitchEditorAndPhotographerCell.swift
//  Profeshie App
//
//  Created by JAM-E-214 on 05/02/25.
//

import UIKit

class SwitchEditorAndPhotographerCell: UITableViewCell {
    
    
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var switchOlt: UISwitch!
    
    //MARK: properties.
    
    var didtabSwitch : (Bool,Int)->() = {_,_ in}
    
    static let identifier = "SwitchEditorAndPhotographerCell"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func switchbtnAction(_ sender: UISwitch) {
        
        if (sender.isOn == true){
            print("on")
            self.didtabSwitch(true,sender.tag)
        }
        else{
            print("off")
            self.didtabSwitch(false,sender.tag)
        }
    }
    
    
}
