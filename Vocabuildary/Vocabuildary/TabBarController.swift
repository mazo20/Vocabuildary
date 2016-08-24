//
//  TabBarController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 24.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var deckStore: DeckStore!
    
    override func viewWillAppear(animated: Bool) {
        let image = UIImage(imageLiteral: "addButton128Dark")
        button.bounds = CGRectMake(0, 0, image.size.width, image.size.height)
        button.setImage(image, forState: .Normal)
        var center = self.tabBar.center
        center.y -= 8
        button.center = center
        button.addTarget(self, action: #selector(TabBarController.addButton(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        let tabBarVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        self.tabBar.backgroundImage = UIImage()
        let bounds = self.tabBar.bounds as CGRect!
        tabBarVisualEffect.frame = bounds
        self.tabBar.addSubview(tabBarVisualEffect)
        self.tabBar.sendSubviewToBack(tabBarVisualEffect)
    }
    func addButton(sender: AnyObject) {
        self.selectedViewController?.loadViewIfNeeded()
        self.performSegueWithIdentifier("addCardsOrDecks", sender: nil)
    }
    override func viewWillLayoutSubviews() {
        view.bringSubviewToFront(button)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCardsOrDecks" {
            let navController = segue.destinationViewController as! UINavigationController
            let viewController = navController.topViewController as! AddDeckViewController
            viewController.deckStore = self.deckStore
        }
    }
}