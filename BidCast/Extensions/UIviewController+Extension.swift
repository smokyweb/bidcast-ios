//
//  UIviewController.swift
//  Last Minute Louie
//
//  Created by JAM-E-221 on 09/08/24.
//

import Foundation
import UIKit
import SideMenu



extension UIViewController {
    var getTopViewController: UIViewController? {
        return self.topViewController(currentViewController: self)
    }
    
    private func topViewController(currentViewController: UIViewController) -> UIViewController {
        if let tabBarController = currentViewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return self.topViewController(currentViewController: selectedViewController)
        } else if let navigationController = currentViewController as? UINavigationController,
                  let visibleViewController = navigationController.visibleViewController {
            return self.topViewController(currentViewController: visibleViewController)
        } else if let presentedViewController = currentViewController.presentedViewController {
            return self.topViewController(currentViewController: presentedViewController)
        } else {
            return currentViewController
        }
    }
    func goToBack(animated: Bool = true) {
        self.navigationController?.popViewController(animated: animated)
    }
    func openSideMenu(){
        let moreVC = Utilities.sharedInstance.getVC(storyBoardName: "More", vcId: "MoreViewController" ) as! MoreViewController
        let menu = SideMenuNavigationController(rootViewController: moreVC)
        let screenWidth = UIScreen.main.bounds.width
        menu.menuWidth = screenWidth
        menu.blurEffectStyle = .dark
        menu.presentationStyle = .menuDissolveIn
        SideMenuManager.default.rightMenuNavigationController = menu
        SideMenuManager.default.rightMenuNavigationController?.navigationBar.isHidden = true
        present(SideMenuManager.default.rightMenuNavigationController!, animated: true, completion: nil)
    }
    
    func closeSideMenu() {
        if let sideMenuVC = SideMenuManager.default.rightMenuNavigationController {
            sideMenuVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func addTapGestureToDismissMenu() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Handle Tap Outside
    @objc private func handleTapOutside() {
        if let sideMenuVC = SideMenuManager.default.rightMenuNavigationController {
            sideMenuVC.dismiss(animated: true, completion: nil)
        }
    }

    func setNavigationBarHidden(_ isHidden : Bool){
        self.navigationController?.navigationBar.isHidden = isHidden
    }
    
    func setTabBarHidden(_ isHidden : Bool){
        self.tabBarController?.tabBar.isHidden = isHidden
    }
    
    // Generic method to instantiate and push a view controller from a storyboard
    func pushVC<T: UIViewController>(with controller: T.Type, storyboardName: StoryBoard, animated: Bool = true) {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        let identifier = String(describing: controller)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            debugLog("ViewController with identifier \(identifier) not found in storyboard \(storyboardName).")
            return
        }
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    func pushVCWithValue<T: UIViewController>(with controller: T.Type,
                                        storyboardName: StoryBoard,
                                        animated: Bool = true,
                                        setup: (T) -> Void) {
           let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
           let identifier = String(describing: controller)
           
           guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
               debugLog("ViewController with identifier \(identifier) not found in storyboard \(storyboardName).")
               return
           }
           
           // Pass additional data to the view controller using the setup closure
           setup(viewController)
           
           // Push the view controller
           self.navigationController?.pushViewController(viewController, animated: animated)
       }
}
enum StoryBoard: String {
    case main = "Main"
    case onboardings = "Onboardings"
    case more = "More"
    case alert = "Alert"
    case home = "Home"
    case explore = "Explore"
    case sell = "Sell"
    case activity = "Activity"
    case account = "Account"
}

