//
//  EquipmentRowCell.swift
//  Well Genius App
//
//  Created by JamTech on 14/01/25.
//

import UIKit

class EquipmentMultiSelectionCell: UITableViewCell {

    //MARK: IBOutlets
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var descOlt: UILabel!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    var makeCornerRadius: Bool = false
    var isCornerNeeded: Bool = true
    var imageIcon = UIImage(named: "1")
    var title: String = ""
    
    var borderColor: UIColor?
    var isTapped: Bool = false
    var rightBtnImage: UIImage? = UIImage(named: "forward")
    var rightBtnTappedClosure : (UIButton) -> () = {_ in  }
    var checkBoxTappedClosure : (UIButton, Bool) -> () = {_, _ in  }
    
    //MARK: properties.
    static let identifier = "EquipmentMultiSelectionCell"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.innerViewOlt.backgroundColor = .white
        self.contentView.backgroundColor = .white
        self.titleOlt.font =  JostFont.defaultSemiBold(size: 13.0).value
        self.descOlt.font = JostFont.defaultRegular(size: 12.0).value
        self.checkBoxBtn.setImage(UIImage(systemName: "square")?.withRenderingMode(.alwaysTemplate), for: .normal)
        innerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
    }
    
    func configure(title: String, imageURl: String, image: UIImage? = UIImage(named: "1"), isTapped: Bool = false, isCornerNeeded: Bool = false, makeCornerRadius: Bool = false) {
//        if imageURl == "" {
//            self.imageOlt.image = image
//        }
//        else  {
//            let img = "\(BASE_URL_IMAGE)/\(imageURl)".addingPercentEncodingForURL() ?? ""
//            Utilities.sharedInstance.setImageWithUrl(imgStr: img, imgView: self.imageOlt)
////        }
//        self.imageOlt.contentMode = .scaleAspectFit
//        self.imageOlt.isHidden = true
        self.titleOlt.text = title
        
        if isCornerNeeded {
            if !makeCornerRadius{
                
                //give decent corners
//                imageOlt.makeCornerRounded(ofSize: Corner_08)
                innerViewOlt.makeCornerRounded(ofSize: Corner_08)
            }
//            else {
//                //make rounded corners
//                self.imageOlt.makeCircular()
//            }
        }else  {
//            imageOlt.makeCornerRounded(ofSize: Corner_00)
            innerViewOlt.clipsToBounds = true
        }
       
//        square
        if isTapped {
            self.innerViewOlt.addBorders(of: AppColor.primary ?? .primary, width: 2)
            self.checkBoxBtn.setImage(UIImage(systemName: "checkmark.square.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.checkBoxBtn.tintColor = AppColor.primary
        }
        else  {
            //show simple check box without border
            self.innerViewOlt.addBorders(of: .clear, width: 1)
            self.checkBoxBtn.setImage(UIImage(systemName: "square")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.checkBoxBtn.tintColor = AppColor.mediumGray
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
    }
    
    func configure() {
//        self.imageOlt.image = imageIcon
        self.titleOlt.text = title
    }
    
    @IBAction func rightBtnClicked(sender: UIButton) {
        rightBtnTappedClosure(sender)
    }
    
    @IBAction func checkBoxBtnTapped(sender: UIButton) {
        print("checkBoxBtnTapped: \(isTapped)")
        self.isTapped.toggle()
        checkBoxTappedClosure(sender, isTapped)
    }
}
