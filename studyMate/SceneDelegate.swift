//
//  SceneDelegate.swift
//  studyMate
//
//  Created for StudyMate AI.
//  Purpose: Configures root window, programmatic TabBarController & Navigation hierarchy with modern iOS 18 glass styling.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Seed sample data on first launch for immediate testing
        CoreDataManager.shared.createSampleDataIfEmpty()
        
        // Setup Window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Apply Global Modern Appearance
        setupGlobalAppearance()
        
        // Build Programmatic Root TabBarController
        let tabBarController = createRootTabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        // Apply saved theme (System / Light / Dark)
        UserDefaultsManager.shared.applyTheme()
    }

    // MARK: - Global Appearance Setup
    private func setupGlobalAppearance() {
        // Navigation Bar Appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.shadowColor = UIColor.separator.withAlphaComponent(0.2)
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = .systemPurple
        
        // Tab Bar Appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.shadowColor = UIColor.separator.withAlphaComponent(0.2)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().tintColor = .systemPurple
    }

    // MARK: - Programmatic TabBar Hierarchy Setup
    private func createRootTabBarController() -> UITabBarController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 1. Tab 1: Today
        let todayVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "TodayViewController")
        let todayNav = UINavigationController(rootViewController: todayVC)
        todayNav.tabBarItem = UITabBarItem(title: "Today", image: UIImage(systemName: "sparkles.rectangle.stack"), selectedImage: UIImage(systemName: "sparkles.rectangle.stack.fill"))
        
        // 2. Tab 2: Courses
        let coursesVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "CoursesListViewController")
        let coursesNav = UINavigationController(rootViewController: coursesVC)
        coursesNav.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: "books.vertical"), selectedImage: UIImage(systemName: "books.vertical.fill"))
        
        // 3. Tab 3: Stats
        let statsVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "StatsViewController")
        let statsNav = UINavigationController(rootViewController: statsVC)
        statsNav.tabBarItem = UITabBarItem(title: "Stats", image: UIImage(systemName: "chart.bar.xaxis"), selectedImage: UIImage(systemName: "chart.bar.xaxis"))
        
        // 4. Tab 4: Settings
        let settingsVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        // TabBar Controller
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [todayNav, coursesNav, statsNav, settingsNav]
        tabBarController.selectedIndex = 1 // Default to Courses tab
        tabBarController.tabBar.tintColor = .systemPurple
        
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.shadowColor = UIColor.separator.withAlphaComponent(0.2)
            tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance
            tabBarController.tabBar.standardAppearance = tabBarAppearance
        }
        
        return tabBarController
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }
}


