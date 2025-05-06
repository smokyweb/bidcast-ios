//
//  TabBarViewController.swift
//  Rise Shine Swing
//
//  Created by Abdul-JAM-E-157 on 31/08/24.
//

import UIKit
import SideMenu

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    // Constants for Tab Items
    private enum Tab: Int, CaseIterable {
        case home, myProfile, more
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .myProfile: return "My Profile"
            case .more: return "More"
            }
        }
        
        var imageName: String {
            switch self {
            case .home: return "house.fill"
            case .myProfile: return "person.circle.fill"
            case .more: return "line.3.horizontal"
            }
        }
        
        var viewControllerId: String {
            switch self {
            case .home: return "HomeViewController"
            case .myProfile: return "MoreViewController"
            case .more: return "MoreViewController"
            }
        }
        var storyboardName: String {
            switch self {
            case .home: return "Main"
            case .myProfile: return "More"
            case .more: return "More"
            }
        }
    }
    
    private var controllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setup()
//        configureSideMenu()
    }
    override func viewWillAppear(_ animated: Bool) {
//        setup()
    }
    
   

    private func setup() {
        controllers.removeAll()
        setNavigationBarHidden(true)
        
        for tab in Tab.allCases {
            let vc = Utilities.sharedInstance.getVC(storyBoardName: tab.storyboardName, vcId: tab.viewControllerId)
            let tabBarItem = createTabBarItem(title: tab.title, imageName: tab.imageName)
            vc.tabBarItem = tabBarItem
            controllers.append(vc)
        }
        
        setViewControllers(controllers, animated: true)
        configureTabBarAppearance()
    }
    
    private func createTabBarItem(title: String, imageName: String) -> UITabBarItem {
        let item = UITabBarItem(title: title, image: UIImage(systemName: imageName)?.withTintColor(UIColor.lightGray), selectedImage: UIImage(systemName: imageName)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal))
        item.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .selected)
        item.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
        return item
    }
    
    private func configureTabBarAppearance() {
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .white
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        tabBar.layer.shadowRadius = 8
        tabBar.layer.shadowOpacity = 0.7
        tabBar.layer.masksToBounds = false
    }
    
    private func configureSideMenu() {
        let moreVC = Utilities.sharedInstance.getVC(storyBoardName: "More", vcId: Tab.more.viewControllerId) as! MoreViewController
        
        let menu = SideMenuNavigationController(rootViewController: moreVC)
        menu.menuWidth = 300 // Set menu width
        menu.presentationStyle = .menuSlideIn
        menu.presentationStyle.presentingEndAlpha = 0.5
        SideMenuManager.default.rightMenuNavigationController = menu // Configure the right menu
    }
    
    // Handle tab selection
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = viewControllers?.firstIndex(of: viewController), index == Tab.more.rawValue {
            // Present the side menu
            present(SideMenuManager.default.rightMenuNavigationController!, animated: true, completion: nil)
            return false // Prevent the tab from being selected
        }
        return true // Allow normal selection for other tabs
    }
}


