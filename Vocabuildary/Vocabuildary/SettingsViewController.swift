//
//  DeckTableViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 13.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        } else {
            return 1
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "New cards per deck"
                cell.detailTextLabel?.text = "\(UserDefaults.standard.object(forKey: "newCards") as! Int)"
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.textLabel?.text = "New cards"
            default:
                cell.textLabel?.text = "Default behaviour"
            }
        case 1:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Rate Vocabuildary"
            case 1:
                cell.textLabel?.text = "Suggest new function"
            default:
                cell.textLabel?.text = "Report a bug"
            }
            cell.accessoryType = .disclosureIndicator
        default:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "About the app"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Learning performance"
        } else if section == 1{
            return "Support & Feedback"
        } else {
            return nil
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Customize the learning frequency and typical behavior"
        } else if section == 1 {
            return "Your feedback helps us improve the app"
        } else {
            return nil
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "NewCards", sender: self)
            })
        } else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                UIApplication.shared.openURL(URL(string : "https://itunes.apple.com/bh/app/facebook/id284882215?mt=8")!)
            } else {
                /*
                var systemInfo = [UInt8](repeating: 0, count: MemoryLayout<utsname>.size)
                let model = systemInfo.withUnsafeMutableBufferPointer { (body: inout UnsafeMutableBufferPointer<UInt8>) -> String? in
                    if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
                        return nil
                    }
                    return String(cString: UnsafePointer((body.baseAddress?.advanced(by: Int(_SYS_NAMELEN * 4)))!))
                }
                 */
                let email = MFMailComposeViewController()
                email.mailComposeDelegate = self
                email.setMessageBody("\n\n\n-----------------\nApp version: \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!)\niOS version: \(UIDevice.current.systemVersion)\nDevice Model: ", isHTML: false)
                if (indexPath as NSIndexPath).row == 1 {
                    email.setSubject("New function")
                } else {
                    email.setSubject("Bug report")
                }
                email.setToRecipients(["maciek.kowalski.nsz@gmail.com"]) // the recipient email address
                //email.preferredStatusBarStyle
                
                if MFMailComposeViewController.canSendMail() {
                    DispatchQueue.main.async(execute: {
                        self.present(email, animated: true, completion: nil)
                    })
                }
            }
        } else if (indexPath as NSIndexPath).section == 2 {
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "About", sender: self)
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
