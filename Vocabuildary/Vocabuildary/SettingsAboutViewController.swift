//
//  SettingsAboutViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 06.06.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class SettingsAboutViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "About", for: indexPath)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        switch (indexPath as NSIndexPath).row {
        case 0:
            cell.textLabel?.text = "Version"
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        case 1:
            cell.textLabel?.text = "Build"
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        default:
            cell.textLabel?.text = "Developed by"
            cell.detailTextLabel?.text = "Maciej Kowalski"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Vocabuildary 2016"
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "About"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
