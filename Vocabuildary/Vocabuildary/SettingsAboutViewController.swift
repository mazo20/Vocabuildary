//
//  SettingsAboutViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 06.06.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class SettingsAboutViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("About", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.detailTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Version"
            cell.detailTextLabel?.text = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        case 1:
            cell.textLabel?.text = "Build"
            cell.detailTextLabel?.text = "341.0"
        default:
            cell.textLabel?.text = "Developed by"
            cell.detailTextLabel?.text = "Maciej Kowalski"
        }
        return cell
    }
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Vocabuildary 2016"
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "About"
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
