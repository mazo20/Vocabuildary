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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var performShortcutDelegate = true
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            performShortcutDelegate = false
        }
        
        UISearchBar.appearance().barTintColor = blueThemeColor()
        UISearchBar.appearance().tintColor = blueThemeColor()
        UISearchBar.appearance().barStyle  = .Black
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = blueThemeColor()
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        
        let tabController = window!.rootViewController as! TabBarController
        tabController.deckStore = deckStore
        
        if NSUserDefaults.standardUserDefaults().objectForKey("newCards") == nil {
            NSUserDefaults.standardUserDefaults().setObject(5, forKey: "newCards")
        }
        if NSUserDefaults.standardUserDefaults().objectForKey("today") == nil {
            NSUserDefaults.standardUserDefaults().setObject(NSDate().today, forKey: "today")
        }
        
        return performShortcutDelegate
    }
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem))
    }
    func handleShortcut(shortcutItem:UIApplicationShortcutItem) -> Bool {
        var succeeded = false
        let tabBar = window?.rootViewController as! TabBarController
        
        // TIP: Lepiej jakbys zrobil z tych stringow Constanty, 
        // np jako struct ShortcutItemType { static let AddCardsOrDecks, itd.. }
        if shortcutItem.type == "addCardsOrDecks" {
            if !tabBar.isBeingPresented() {
                tabBar.dismissViewControllerAnimated(true, completion: nil)
            }
            if tabBar.selectedViewController == nil {
                tabBar.selectedViewController = tabBar.viewControllers![0]
            }
            let navController = tabBar.selectedViewController as! UINavigationController
            navController.popToViewController(navController.viewControllers[0], animated: false)
            tabBar.performSegueWithIdentifier("addCardsOrDecks", sender: self)
            succeeded = true
        } else if shortcutItem.type == "today" {
            if !tabBar.isBeingPresented() {
                tabBar.dismissViewControllerAnimated(true, completion: nil)
            }
            tabBar.selectedViewController = tabBar.viewControllers![0]
            let navController = tabBar.selectedViewController as! UINavigationController
            navController.popToViewController(navController.viewControllers[0], animated: false)
            succeeded = true
        } else if shortcutItem.type == "statistics" {
            tabBar.selectedViewController = tabBar.viewControllers![3]
            if !tabBar.isBeingPresented() {
                tabBar.dismissViewControllerAnimated(true, completion: nil)
            }
            succeeded = true
        }
        return succeeded
    }

    func applicationDidEnterBackground(application: UIApplication) {
        let success = deckStore.saveChanges()
        if success {
            print("Saved all of the items")
        } else {
            print("Couldn't save any of the items")
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        guard let shortcut = shortcutItem else { return }
        handleShortcut(shortcut)
        self.shortcutItem = nil
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Application did become active")
        
        guard let shortcut = shortcutItem else { return }
        
        print("- Shortcut property has been set")
        
        handleShortcut(shortcut)
        
        self.shortcutItem = nil
    }

}