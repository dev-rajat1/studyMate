//
//  SceneDelegate.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Configures root window, programmatic TabBarController & Navigation hierarchy.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var rootTabBarController: UITabBarController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Seed sample data on first launch for immediate testing
        CoreDataManager.shared.createSampleDataIfEmpty()
        
        // Setup Window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Apply saved theme (System / Light / Dark)
        UserDefaultsManager.shared.applyTheme()
        configureGlobalNavigationAppearance()

        // Build Programmatic Root TabBarController and retain strongly
        let tabBarController = createRootTabBarController()
        self.rootTabBarController = tabBarController

        // Present Animated Splash Screen first, then transition smoothly into TabBarController
        let splashVC = SplashScreenViewController()
        splashVC.onAnimationCompleted = { [weak self, weak window] in
            guard let window = window, let root = self?.rootTabBarController else { return }
            UIView.transition(with: window, duration: 0.45, options: .transitionCrossDissolve, animations: {
                window.rootViewController = root
            }, completion: nil)
        }
        
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
    }

    private func configureGlobalNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemGroupedBackground
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    // MARK: - Programmatic TabBar Hierarchy Setup
    private func createRootTabBarController() -> UITabBarController {
        
        // 1. Tab 1: Study Planner (Multi-Timeframe Timeline)
        let todayVC = TodayViewController()
        let todayNav = UINavigationController(rootViewController: todayVC)
        todayNav.tabBarItem = UITabBarItem(title: "Planner", image: UIImage(systemName: "calendar.badge.clock"), selectedImage: UIImage(systemName: "calendar"))
        
        // 2. Tab 2: Courses
        let coursesVC = CoursesListViewController()
        let coursesNav = UINavigationController(rootViewController: coursesVC)
        coursesNav.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: "books.vertical"), selectedImage: UIImage(systemName: "books.vertical.fill"))
        
        // 3. Tab 3: Analytics
        let statsVC = StatsViewController()
        let statsNav = UINavigationController(rootViewController: statsVC)
        statsNav.tabBarItem = UITabBarItem(title: "Analytics", image: UIImage(systemName: "chart.bar.xaxis"), selectedImage: UIImage(systemName: "chart.bar.xaxis"))
        
        // 4. Tab 4: Settings
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        // TabBar Controller
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [todayNav, coursesNav, statsNav, settingsNav]
        tabBarController.selectedIndex = 1 // Default to Courses tab
        tabBarController.tabBar.tintColor = .systemPurple
        
        return tabBarController
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }
}



