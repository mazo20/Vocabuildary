//
//  NewCardsPerDeckViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 07.06.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class NewCardsPerDeckViewController: UITableViewController {
    
    var newCards: Int!
    fileprivate let cards = [1, 3, 5, 10, 15, 20, 30, 50, 100]
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCards", for: indexPath)
        cell.accessoryType = .none
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.textLabel?.text = "\(cards[(indexPath as NSIndexPath).row]) card"
        default:
            cell.textLabel?.text = "\(cards[(indexPath as NSIndexPath).row]) cards"
        }
        if (indexPath as NSIndexPath).row == cards.index(of: newCards) {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "New cards per deck per day"
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newCards = cards[(indexPath as NSIndexPath).row]
        UserDefaults.standard.set(newCards, forKey: "newCards")
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    override func viewDidLoad() {
        newCards = UserDefaults.standard.object(forKey: "newCards") as! Int
        tableView.tintColor = blueThemeColor()
    }
    
}
