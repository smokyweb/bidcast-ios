import UIKit

class SelectDaySliderCell: UITableViewCell {

    // MARK: IBOutlets
    var daysArr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var collectionViewOlt: UICollectionView!

    // MARK: Properties
    static let identifier = "SelectDaySliderCell"
    var selectedDays: Set<Int> = []  // Store the selected indexes
    var onDaysSelected: (([String]) -> Void)?  // Closure to send selected days back

    // MARK: - Initializations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }

    // MARK: Configure method
    func configure() {
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource = self
        let cellIds = [SelectDaysCollection.identifier, NoDataTableViewCell.identifier]
        collectionViewOlt.registerCells(for: cellIds)
        self.collectionViewOlt.reloadData()
        self.collectionViewOlt.showsHorizontalScrollIndicator = false
        self.collectionViewOlt.allowsMultipleSelection = true  // Enable multiple selection
        self.outerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_14, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        lblTitle.font =  JostFont.defaultSemiBold(size: 13.0).value
    }

    // MARK: CollectionView Handling

    func updateCellAppearance(for indexPath: IndexPath) {
        if let cell = collectionViewOlt.cellForItem(at: indexPath) as? SelectDaysCollection {
            if selectedDays.contains(indexPath.row) {
                cell.innerView.backgroundColor = .lightBlue
                cell.lblTitle.textColor = AppColor.white
            } else {
                cell.innerView.backgroundColor = .bgTextField
                cell.lblTitle.textColor = AppColor.mediumDark
            }
        }
    }

    func notifySelectionChanged() {
        // Convert the selected indices to day names and pass them back using the closure
        let selectedDayNames = selectedDays.map { daysArr[$0] }
        onDaysSelected?(selectedDayNames)  // Execute the closure with the selected days
    }
}

//MARK: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout.
extension SelectDaySliderCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysArr.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectDaysCollection.identifier, for: indexPath) as! SelectDaysCollection
        cell.lblTitle.text = daysArr[indexPath.row]
        
        // Update the cell appearance based on selection
        if selectedDays.contains(indexPath.row) {
            cell.innerView.backgroundColor = AppColor.lightBlue
            cell.lblTitle.textColor = .white
            cell.lblTitle.font = JostFont.defaultSemiBold(size: 13.0).value
        } else {
            cell.innerView.backgroundColor = .bgTextField
            cell.lblTitle.textColor = AppColor.mediumDark
            cell.lblTitle.font = AppFont.placeHolder
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDays.insert(indexPath.row)  // Add the selected index to the set
        updateCellAppearance(for: indexPath)
        notifySelectionChanged()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedDays.remove(indexPath.row)  // Remove the deselected index from the set
        updateCellAppearance(for: indexPath)
        notifySelectionChanged()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 // Total padding (left + right)
        let itemsPerRow: CGFloat = 7
        let totalSpacing = (itemsPerRow - 1) * 8 // Space between items

        let width = (collectionView.frame.width - padding - totalSpacing) / itemsPerRow
        let height: CGFloat = 70
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

