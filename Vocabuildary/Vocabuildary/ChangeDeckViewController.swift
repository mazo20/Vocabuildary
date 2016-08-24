//
//  ChangeDeckOrCardViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 04.05.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class ChangeDeckViewController: UITableViewController, UITextFieldDelegate {
    
    var deck: Deck!
    var deckStore: DeckStore!
    var deckTextField = UITextField()
    var deckName: String? = nil
    var prioritySwitch = UISwitch()
    
    @IBAction func cancelBarButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func doneBarButton(sender: AnyObject) {
        print(deck.priority)
        print(prioritySwitch.on)
        if let text = deckTextField.text {
            if text == "" {
                cellInSection(0).bottomLine.backgroundColor = UIColor.redColor()
            } else {
                if text.caseInsensitiveCompare(deck.name) == .OrderedSame {
                    deck.name = text
                    if prioritySwitch.on {
                        deck.priority = 1
                    } else {
                        deck.priority = 0
                    }
                    self.cellInSection(0).bottomLine.backgroundColor = UIColor.greenColor()
                    UIView.animateWithDuration(0.3, animations: {
                        self.cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                        }, completion: { finished in
                           self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    return
                }
                for deck in deckStore.deckStore {
                    if text.caseInsensitiveCompare(deck.name) == .OrderedSame {
                        cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                        return
                    }
                }
                deck.name = text
                if prioritySwitch.on {
                    deck.priority == 1
                } else {
                    deck.priority == 0
                }
                self.cellInSection(0).bottomLine.backgroundColor = UIColor.greenColor()
                UIView.animateWithDuration(0.3, animations: {
                    self.cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                    }, completion: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    @IBAction func backgroundTapped(sender: AnyObject) {
        self.view.endEditing(true)
        deckName = deckTextField.text
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
        deckName = deckTextField.text
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.caseInsensitiveCompare(deck.name) == .OrderedSame {
            cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
            return
        }
        for deck in deckStore.deckStore {
            if textField.text?.caseInsensitiveCompare(deck.name) == .OrderedSame {
                cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                return
            } else {
                cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
            }
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func cellInSection(section: Int) -> EnterCardCell {
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EnterCardCell
        return cell
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ChangeDeckCell", forIndexPath: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.delegate = self
            deckTextField = cell.textField
            if let name = deckName {
                cell.textField.text = name
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    cell.textField.becomeFirstResponder()
                })
                cell.textField.text = deck.name
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            if indexPath.section == 1 {
                if deck.priority == 0 {
                    cell.switchButton.on = false
                }
                prioritySwitch = cell.switchButton
                cell.settingsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.settingsLabel.text = "High priority"
            }
            return cell
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Deck"
        } else {
            return "Deck settings"
        }
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        self.title = deck.name
    }
}