//
//  SceneDelegate.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 06/05/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var navController : UINavigationController!
    private var sessionExpiredObserver: NSObjectProtocol?
    // P2.17 — Android shows one "Session expired" toast per signed-out event
    // even if many requests race. Debounce on iOS the same way: once we've
    // handled a 401, ignore subsequent broadcasts until the user signs back
    // in (i.e. navigateToLandingScreen is called).
    private var hasHandledSessionExpired = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        self.navigateToLandingScreen()
        self.installSessionExpiredObserver()
        // Phase 8 / P2.21 (2026-04-23): Android does NOT ship a first-launch
        // onboarding carousel, and the flow-diff report flagged ours as an
        // iOS-only divergence. Drop it so first-launch is identical on both
        // platforms. `OnboardingCarouselViewController` is kept in the repo
        // (and in the xcodeproj) so it can be reinstated later if product
        // decides to add a carousel to both clients, but it is no longer
        // auto-presented.
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    //MARK: navigateToLandingScreen.
    func navigateToLandingScreen(){
        var viewController = UIViewController()
        if UserDefaults.accessToken == "" {
            let storyboard = UIStoryboard(name: "Onboardings", bundle: nil)
            viewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            
        }else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            viewController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        }
        navController = UINavigationController(rootViewController: viewController)
        navController?.interactivePopGestureRecognizer?.isEnabled = true
        navController?.setNavigationBarHidden(true, animated: false)
        navController.isNavigationBarHidden = true
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        // Coming back to the sign-in screen resets our debounce so the
        // next 401 after a successful login is handled normally.
        hasHandledSessionExpired = false
    }

    // MARK: - P2.17 global session-expired handling

    /// Listens for `.bidcastAPISessionExpired` broadcasts from APIManager
    /// and, on the main thread, surfaces a single alert then pops back to
    /// `SignInViewController`. Matches Android's
    /// `BaseRepository.getHttpErrorMessage(401)` behaviour (which shows a
    /// "Session expired. Please login again." dialog).
    private func installSessionExpiredObserver() {
        sessionExpiredObserver = NotificationCenter.default.addObserver(
            forName: .bidcastAPISessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presentSessionExpiredAlertIfNeeded()
        }
    }

    private func presentSessionExpiredAlertIfNeeded() {
        guard !hasHandledSessionExpired else { return }
        hasHandledSessionExpired = true

        // Make sure the token really is cleared even if this notification
        // fired before APIManager's own clear (e.g. if another subsystem
        // raised it manually).
        UserDefaults.accessToken = ""

        let alert = UIAlertController(
            title: "Session expired",
            message: "Session expired. Please login again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToLandingScreen()
        })

        // Present on the topmost view controller if possible so we don't
        // accidentally dismiss something the user was mid-way through.
        let presenter = SceneDelegate.topmostViewController(from: window?.rootViewController)
        (presenter ?? window?.rootViewController)?.present(alert, animated: true)
    }

    private static func topmostViewController(from root: UIViewController?) -> UIViewController? {
        guard let root else { return nil }
        if let presented = root.presentedViewController {
            return topmostViewController(from: presented)
        }
        if let nav = root as? UINavigationController {
            return topmostViewController(from: nav.visibleViewController) ?? nav
        }
        if let tab = root as? UITabBarController {
            return topmostViewController(from: tab.selectedViewController) ?? tab
        }
        return root
    }

    deinit {
        if let obs = sessionExpiredObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
}

