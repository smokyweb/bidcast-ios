//
//  ViewTeamMembersViewController.swift
//  Well Genius App
//
//  Created by Vivek-JAM-E-328 on 14/12/24.
//

import Foundation
import UIKit
import SVProgressHUD
import DropDown
import FittedSheets

//pageC35.2
enum SelectedMusicSection: Int, CaseIterable {
    case header
    case musicList
    case save
    
    func numberOfRows(data: [SelectedMusicSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
    
    var title: String {
        switch self {
        case .header:
            return "SELECT SONGS"
        case .save:
            return AppString.BtnTitle.submit
        default:
            return ""
        }
    }
}

struct ToggleModel {
    var isSelected: Bool
    var id: Int?
}


class SelectMusicListViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var submitBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    var selectedEquipmentIndexs:[ToggleModel] = []
    var categoryArr: [CategoryModel] = [] // Array of categories (from your API)
    var selectedSongArray: [[SongModel]] = [[], [], [], [], []]
    var submitBtnClosure : ([SongModel]) -> () = {_ in  }
    lazy var sectionData: [SelectedMusicSection: Int] = [
        .header: 1,
        .musicList: 1,
        .save: 0
    ]
    
    var viewModel = MyMusicViewModel()
    var serverSongArr: [SongModel] = [] // Array of categories (from your API)
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewModel()
        self.configureTableView()
        self.tblView.backgroundColor = AppColor.ghostWhite
        setupUI()
    }
    
    func initViewModel() {
        viewModel.userDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchApi()
    }
    
    //MARK: Fetch API
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
//            self.viewModel.getCategoryData()
//            sleep(3)
            self.viewModel.getSongListData()
           
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }

    
    //MARK: configureTableView.
    private func configureTableView(){
        
        //register cells
        let cellIds = [
            LabelCell.identifier,
            NoDataTableViewCell.identifier,
            SubmitCell.identifier,
            EquipmentMultiSelectionCell.identifier
        ]
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.configTblView(bgColor: .ultraLightGray)
        
        tblView.registerCells(for: cellIds)
       
        if #available(iOS 15.0, *) {
            tblView.sectionHeaderTopPadding = 0
        }
    }
    
    
    func setupUI(){
        submitBtn.setupButton(title: AppString.BtnTitle.submit)
        self.submitBtn.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        self.submitBtn.makeCornerRounded(ofSize: Corner_26)
        cancelBtn.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        cancelBtn.makeCornerRounded(ofSize: Corner_26)
        cancelBtn.addBorders(of: .primary, width: Width_01)
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        print("submitButton Clicked")
        var musicIds: [SongModel] = []
        for (index, item) in selectedEquipmentIndexs.enumerated() {
            if item.isSelected , let id = item.id {
                musicIds.append(serverSongArr[index])
            }
        }
        submitBtnClosure(musicIds)
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

//MARK: UITableViewDelegate,UITableViewDataSource.
extension SelectMusicListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SelectedMusicSection(rawValue: section) else { return 0 }
        print("Rows in section\(section) is:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SelectedMusicSection.allCases
        guard let sectionType = section[safe: indexPath.section] else {
            fatalError("Invalid index for LoginTableRow")
        }
       
        switch sectionType {
        case .header:
            let cell = tblView.dequeueCell(with: LabelCell.self)
            cell.contentView.backgroundColor = .ultraLightGray
            cell.innerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = sectionType.title
            cell.titleOlt.textAlignment = .center
            cell.txtColor = .black
            cell.titleOlt.font = OutFitFont.defaultExtraBold(size: 23.0).value
            return cell
            
        case .musicList:
            if self.serverSongArr.isEmpty {
                let cell = tableView.dequeueCell(with: NoDataTableViewCell.self)
                cell.contentView.backgroundColor = AppColor.ghostWhite
                cell.labelOlt.text = AppString.Description.noMusicAvailable
                cell.selectionStyle = .none
                return cell
            }
            else {
                
                let cell = tblView.dequeueCell(with: EquipmentMultiSelectionCell.self)
                let row = serverSongArr[indexPath.row]
                cell.outerViewOlt.backgroundColor = AppColor.ultraLightGray
//                cell.makeCornerRadius = true
                cell.checkBoxBtn.isHidden = false
//                cell.isCornerNeeded = false
                let isTapped = self.selectedEquipmentIndexs[indexPath.row].isSelected

                cell.configure(title: row.title ?? "",
                               imageURl: "",
                               image: nil,
                               isTapped: isTapped,
                               isCornerNeeded: false,
                               makeCornerRadius: true
                )
                cell.descOlt.text = row.artistName ?? "Unknown Artist"
                cell.checkBoxBtn.tag = indexPath.row
                
                cell.checkBoxTappedClosure = { [weak self] sender, isBoxTapped in
                    guard let self = self else { return }
                    self.selectedEquipmentIndexs[sender.tag].isSelected = isBoxTapped
                    self.selectedEquipmentIndexs[sender.tag].id = serverSongArr[sender.tag].id
                    if sender.tag == indexPath.row {
                        tblView.reloadRows(at: [IndexPath(row: sender.tag, section: indexPath.section)], with: .automatic)
                    }
                }
                cell.selectionStyle = .none
                
                return cell
            }
        case .save:
            let cell = tblView.dequeueCell(with: SubmitCell.self)
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.submit)
            cell.selectionStyle = .none
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                self.dismiss(animated: true)
                var musicIds: [SongModel] = []
                for (index, item) in selectedEquipmentIndexs.enumerated() {
                    if item.isSelected , let id = item.id {
                        musicIds.append(serverSongArr[index])
                    }
                }
                submitBtnClosure(musicIds)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = SelectedMusicSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LoginTableRow")
        }
        
        switch rowType {
        case .musicList:
            return 80
        case .save:
            return 85
        default:
            return UITableView.automaticDimension
        }
    }
}

extension SelectMusicListViewController: UserServices {
    
    func reloadData() {
        
        // For songListDict
        if self.viewModel.requestType == .getMusicList {
            if let dict = self.viewModel.songListDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    // Success API Response
                    debugLog("success API Response =====>\n\n\n\n")
                    self.serverSongArr = (dict.data ?? []) ?? []
           
                    // Filter songs whose URL matches the CategoryModel URL
                    self.serverSongArr =  serverSongArr.filter { song in
                        !categoryArr.contains(where: { item in
                            item.music?.contains(where: { item in
                                item.id == song.id
                            }) ?? false
                        })
                    }
                    self.serverSongArr = serverSongArr.filter { song in
                        !selectedSongArray.flatMap { $0 }.contains { selectedSong in
                            // Safely unwrap the optional `id` values before comparing
                            selectedSong.id == song.id
                        }
                    }

                    // Update sectionData
                    self.sectionData[.musicList] = self.serverSongArr.isEmpty ? 1 : self.serverSongArr.count
                    
                    // Reset selectedEquipmentIndexs based on filtered songs
                    self.selectedEquipmentIndexs = self.serverSongArr.map { _ in
                        ToggleModel(isSelected: false)
                    }
                    
                    self.viewModel.requestType = .none
                    self.tblView.reloadData()
                    SVProgressHUD.dismiss()
                case .failure:
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occurred")
                }
            }
        }
        
        // For categoryDict
        if self.viewModel.requestType == .getCategory {
            if let dict = self.viewModel.categoryDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    // Success API Response
                    debugLog("success API Response")
                    self.categoryArr = (dict.data ?? []) ?? []
                    self.viewModel.requestType = .none
                    self.tblView.reloadData()
                case .failure:
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occurred")
                }
            }
        }
    }
    
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
}
