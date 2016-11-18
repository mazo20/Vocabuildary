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
    
    override func viewWillAppear(_ animated: Bool) {
        let image = UIImage(imageLiteralResourceName: "addButton128Dark")
        button.bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        button.setImage(image, for: UIControlState())
        var center = self.tabBar.center
        center.y -= 8
        button.center = center
        button.addTarget(self, action: #selector(TabBarController.addButton(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        let tabBarVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        self.tabBar.backgroundImage = UIImage()
        let bounds = self.tabBar.bounds as CGRect!
        tabBarVisualEffect.frame = bounds!
        self.tabBar.addSubview(tabBarVisualEffect)
        self.tabBar.sendSubview(toBack: tabBarVisualEffect)
    }
    func addButton(_ sender: AnyObject) {
        self.selectedViewController?.loadViewIfNeeded()
        self.performSegue(withIdentifier: "addCardsOrDecks", sender: nil)
    }
    override func viewWillLayoutSubviews() {
        view.bringSubview(toFront: button)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCardsOrDecks" {
            let navController = segue.destination as! UINavigationController
            let viewController = navController.topViewController as! AddDeckViewController
            viewController.deckStore = self.deckStore
        }
    }
}
