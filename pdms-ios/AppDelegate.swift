//
//  AppDelegate.swift
//  pdms-ios
//
//  Created by IMEDS on 14-12-5.
//  Copyright (c) 2014年 unimedsci. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UITabBarControllerDelegate {

    var window: UIWindow?
    var previousViewController : UIViewController?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if let controller = window?.rootViewController as? UITabBarController {
            controller.delegate = self
            if let barItems = controller.tabBar.items {
                if let homeBarItem = barItems[0] as? UITabBarItem {
                    homeBarItem.image = UIImage(named: "home")
                    homeBarItem.selectedImage = UIImage(named: "home-selected")
                }
                if let allPatientsBarItem = barItems[1] as? UITabBarItem {
                    allPatientsBarItem.image = UIImage(named: "allpatient")
                    allPatientsBarItem.selectedImage = UIImage(named: "allpatient-selected")
                }

                if let userBarItem = barItems[2] as? UITabBarItem {
                    userBarItem.image = UIImage(named: "user")
                    userBarItem.selectedImage = UIImage(named: "huser-selected")
                }

            }
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        self.previousViewController = tabBarController.selectedViewController
        return true
    }
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if self.previousViewController == viewController {
            if let navigationController = viewController as? UINavigationController {
                for viewController in navigationController.viewControllers {
                    if let tableViewController = viewController as? UITableViewController {
                        tableViewController.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    }
                }
            }
        }
    }

}

