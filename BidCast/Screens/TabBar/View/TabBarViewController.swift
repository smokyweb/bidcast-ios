//
//  TabBarViewController.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.
//

import UIKit
import SideMenu

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    // Constants for Tab Items
    private enum Tab: Int, CaseIterable {
        case home, explore, sell, activity, account
        
        var title: String {
            switch self {
            case .home: 
                return "Home"
           
            case .explore:
                return "Explore"
            case .sell:
                return "Sell"
            case .activity:
                return "Activity"
            case .account:
                return "Account"
            }
        }
        
        var imageName: String {
            // VISUAL PARITY 2026-05-01: Android home_menu uses category grid
            // for Explore (`ic_cat_*`), heart for Activity, plus-circle for
            // Sell, person for Account. SF Symbols mapped to the closest
            // visual equivalents.
            switch self {
            case .home:
                return "house.fill"
            case .explore:
                return "square.grid.2x2.fill"
            case .sell:
                return "plus.circle.fill"
            case .activity:
                return "suit.heart.fill"
            case .account:
                return "person.fill"
            }
        }
        
        var viewControllerId: String {
            switch self {
            case .home: 
                return "HomeViewController"
            
            case .explore:
                return "ExploreViewController"
            case .sell:
                return "SellViewController"
            case .activity:
                return "ActivityViewController"
            case .account:
                return "AccountViewController"
            }
        }
        var storyboardName: String {
            switch self {
            case .home:
                return "Home"
           
            case .explore:
                return "Explore"
            case .sell:
                return "Sell"
            case .activity:
                return "Activity"
            case .account:
                return "Account"
            }
        }
    }
    
    private var controllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
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
    
    // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): Android
    // BottomNavigationView (`bottomNavigationStyle` in styles.xml) uses
    // `@color/bottom_nav_color`:
    //   - selected: `@color/scrim` = #000000
    //   - unselected: `@color/outlineVariant` = #B2B4B8
    // and a brand-blue ripple. Match those tints + caption typography
    // here so the iOS tab bar mirrors the Android dash bottom bar.
    private static let tabSelectedColor = UIColor(red: 0x00/255.0, green: 0x00/255.0, blue: 0x00/255.0, alpha: 1.0)
    private static let tabUnselectedColor = UIColor(red: 0xB2/255.0, green: 0xB4/255.0, blue: 0xB8/255.0, alpha: 1.0)

    private func createTabBarItem(title: String, imageName: String) -> UITabBarItem {
        let item = UITabBarItem(
            title: title,
            image: UIImage(systemName: imageName)?
                .withTintColor(Self.tabUnselectedColor, renderingMode: .alwaysOriginal),
            selectedImage: UIImage(systemName: imageName)?
                .withTintColor(Self.tabSelectedColor, renderingMode: .alwaysOriginal)
        )
        item.setTitleTextAttributes(
            [.foregroundColor: Self.tabSelectedColor,
             .font: UIFont.systemFont(ofSize: 11, weight: .semibold)],
            for: .selected)
        item.setTitleTextAttributes(
            [.foregroundColor: Self.tabUnselectedColor,
             .font: UIFont.systemFont(ofSize: 11, weight: .regular)],
            for: .normal)
        return item
    }
    
    private func configureTabBarAppearance() {
        // VISUAL PARITY 2026-05-01: Android sets the bottom bar background
        // to `@color/background` (#FFFFFF) and uses brand blue for the
        // tint. We mirror with a flat white bar + the same selected /
        // unselected colors driven through `tintColor`/`unselectedItemTintColor`.
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
        tabBar.tintColor = Self.tabSelectedColor
        tabBar.unselectedItemTintColor = Self.tabUnselectedColor

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = UIColor(white: 0.0, alpha: 0.08)

            let configure: (UITabBarItemAppearance) -> Void = { itemAppearance in
                itemAppearance.normal.iconColor = Self.tabUnselectedColor
                itemAppearance.normal.titleTextAttributes = [
                    .foregroundColor: Self.tabUnselectedColor,
                    .font: UIFont.systemFont(ofSize: 11, weight: .regular)
                ]
                itemAppearance.selected.iconColor = Self.tabSelectedColor
                itemAppearance.selected.titleTextAttributes = [
                    .foregroundColor: Self.tabSelectedColor,
                    .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
                ]
            }
            configure(appearance.stackedLayoutAppearance)
            configure(appearance.inlineLayoutAppearance)
            configure(appearance.compactInlineLayoutAppearance)

            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }

        // Soft 1px hairline above the bar (Android uses an elevation
        // shadow). Keep it subtle so it doesn't overshadow the content.
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.shadowOpacity = 0.08
        tabBar.layer.masksToBounds = false
    }
    
//    private func configureSideMenu() {
//        let moreVC = Utilities.sharedInstance.getVC(storyBoardName: "More", vcId: Tab.more.viewControllerId) as! MoreViewController
//        
//        let menu = SideMenuNavigationController(rootViewController: moreVC)
//        menu.menuWidth = 300 // Set menu width
//        menu.presentationStyle = .menuSlideIn
//        menu.presentationStyle.presentingEndAlpha = 0.5
//        SideMenuManager.default.rightMenuNavigationController = menu // Configure the right menu
//    }
//    
    // Handle tab selection
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if let index = viewControllers?.firstIndex(of: viewController), index == Tab.more.rawValue {
//            // Present the side menu
//            present(SideMenuManager.default.rightMenuNavigationController!, animated: true, completion: nil)
//            return false // Prevent the tab from being selected
//        }
        return true // Allow normal selection for other tabs
    }
}


