//
//  AppDelegate.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 29.02.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let deckStore = DeckStore()
    var shortcutItem: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            performShortcutDelegate = false
        }
        
        UISearchBar.appearance().barTintColor = blueThemeColor()
        UISearchBar.appearance().tintColor = blueThemeColor()
        UISearchBar.appearance().barStyle  = .black
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = blueThemeColor()
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white], for: UIControlState())
        
        let tabController = window!.rootViewController as! TabBarController
        tabController.deckStore = deckStore
        
        if UserDefaults.standard.object(forKey: "newCards") == nil {
            UserDefaults.standard.set(5, forKey: "newCards")
        }
        if UserDefaults.standard.object(forKey: "lastDay") == nil {
            UserDefaults.standard.set(Date(), forKey: "lastDay")
        }
        
        return performShortcutDelegate
    }
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    func handleShortcut(_ shortcutItem:UIApplicationShortcutItem) -> Bool {
        var succeeded = false
        let tabBar = window?.rootViewController as! TabBarController
        if shortcutItem.type == "addCardsOrDecks" {
            if !tabBar.isBeingPresented {
                tabBar.dismiss(animated: true, completion: nil)
            }
            if tabBar.selectedViewController == nil {
                tabBar.selectedViewController = tabBar.viewControllers![0]
            }
            let navController = tabBar.selectedViewController as! UINavigationController
            navController.popToViewController(navController.viewControllers[0], animated: false)
            tabBar.performSegue(withIdentifier: "addCardsOrDecks", sender: self)
            succeeded = true
        } else if shortcutItem.type == "today" {
            if !tabBar.isBeingPresented {
                tabBar.dismiss(animated: true, completion: nil)
            }
            tabBar.selectedViewController = tabBar.viewControllers![0]
            let navController = tabBar.selectedViewController as! UINavigationController
            navController.popToViewController(navController.viewControllers[0], animated: false)
            succeeded = true
        } else if shortcutItem.type == "statistics" {
            tabBar.selectedViewController = tabBar.viewControllers![3]
            if !tabBar.isBeingPresented {
                tabBar.dismiss(animated: true, completion: nil)
            }
            succeeded = true
        }
        return succeeded
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let success = deckStore.saveChanges()
        if success {
            print("Saved all of the items")
        } else {
            print("Couldn't save any of the items")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        guard let shortcut = shortcutItem else { return }
        _ = handleShortcut(shortcut)
        self.shortcutItem = nil
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Application did become active")
        
        guard let shortcut = shortcutItem else { return }
        
        print("- Shortcut property has been set")
        
        _ = handleShortcut(shortcut)
        
        self.shortcutItem = nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
