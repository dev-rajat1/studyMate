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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Seed sample data on first launch for immediate testing
        CoreDataManager.shared.createSampleDataIfEmpty()
        
        // Setup Window
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Build Programmatic Root TabBarController
        let tabBarController = createRootTabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        // Apply saved theme (System / Light / Dark)
        UserDefaultsManager.shared.applyTheme()
    }

    // MARK: - Programmatic TabBar Hierarchy Setup
    private func createRootTabBarController() -> UITabBarController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 1. Tab 1: Study Planner (Multi-Timeframe Timeline)
        let todayVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "TodayViewController")
        let todayNav = UINavigationController(rootViewController: todayVC)
        todayNav.tabBarItem = UITabBarItem(title: "Planner", image: UIImage(systemName: "calendar.badge.clock"), selectedImage: UIImage(systemName: "calendar"))
        
        // 2. Tab 2: Courses
        let coursesVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "CoursesListViewController")
        let coursesNav = UINavigationController(rootViewController: coursesVC)
        coursesNav.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: "books.vertical"), selectedImage: UIImage(systemName: "books.vertical.fill"))
        
        // 3. Tab 3: Analytics
        let statsVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "StatsViewController")
        let statsNav = UINavigationController(rootViewController: statsVC)
        statsNav.tabBarItem = UITabBarItem(title: "Analytics", image: UIImage(systemName: "chart.bar.xaxis"), selectedImage: UIImage(systemName: "chart.bar.xaxis"))
        
        // 4. Tab 4: Settings
        let settingsVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
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



