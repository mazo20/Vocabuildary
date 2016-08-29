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
    private let cards = [1, 3, 5, 10, 15, 20, 30, 50, 100]
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewCards", forIndexPath: indexPath)
        cell.accessoryType = .None
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "\(cards[indexPath.row]) card"
        default:
            cell.textLabel?.text = "\(cards[indexPath.row]) cards"
        }
        if indexPath.row == cards.indexOf(newCards) {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "New cards per deck per day"
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        newCards = cards[indexPath.row]
        NSUserDefaults.standardUserDefaults().setObject(newCards, forKey: "newCards")
        NSUserDefaults.standardUserDefaults().synchronize()
        tableView.reloadData()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    override func viewDidLoad() {
        newCards = NSUserDefaults.standardUserDefaults().objectForKey("newCards") as! Int
        tableView.tintColor = blueThemeColor()
    }
    
}
