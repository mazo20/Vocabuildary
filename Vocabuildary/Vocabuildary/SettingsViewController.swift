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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        } else {
            return 1
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath)
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "New cards per deck"
                cell.detailTextLabel?.text = "\(NSUserDefaults.standardUserDefaults().objectForKey("newCards") as! Int)"
                cell.accessoryType = .DisclosureIndicator
            case 1:
                cell.textLabel?.text = "New cards"
            default:
                cell.textLabel?.text = "Default behaviour"
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Rate Vocabuildary"
            case 1:
                cell.textLabel?.text = "Suggest new function"
            default:
                cell.textLabel?.text = "Report a bug"
            }
            cell.accessoryType = .DisclosureIndicator
        default:
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = "About the app"
        }
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Learning performance"
        } else if section == 1{
            return "Support & Feedback"
        } else {
            return nil
        }
    }
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Customize the learning frequency and typical behavior"
        } else if section == 1 {
            return "Your feedback helps us improve the app"
        } else {
            return nil
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("NewCards", sender: self)
            })
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/bh/app/facebook/id284882215?mt=8")!)
            } else {
                var systemInfo = [UInt8](count: sizeof(utsname), repeatedValue: 0)
                let model = systemInfo.withUnsafeMutableBufferPointer { (inout body: UnsafeMutableBufferPointer<UInt8>) -> String? in
                    if uname(UnsafeMutablePointer(body.baseAddress)) != 0 {
                        return nil
                    }
                    return String.fromCString(UnsafePointer(body.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))))
                }
                let email = MFMailComposeViewController()
                email.mailComposeDelegate = self
                email.setMessageBody("\n\n\n-----------------\nApp version: \(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")!)\niOS version: \(UIDevice.currentDevice().systemVersion)\nDevice Model: \(model!)", isHTML: false)
                if indexPath.row == 1 {
                    email.setSubject("New function")
                } else {
                    email.setSubject("Bug report")
                }
                email.setToRecipients(["maciek.kowalski.nsz@gmail.com"]) // the recipient email address
                email.preferredStatusBarStyle()
                
                if MFMailComposeViewController.canSendMail() {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.presentViewController(email, animated: true, completion: nil)
                    })
                }
            }
        } else if indexPath.section == 2 {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("About", sender: self)
            })
        }
    }
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
