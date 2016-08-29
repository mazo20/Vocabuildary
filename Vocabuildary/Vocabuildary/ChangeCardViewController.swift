//
//  ChangeCardViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 04.05.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class ChangeCardViewController: UITableViewController, UITextFieldDelegate {
    
    var deck: Deck!
    var card: Card!
    var frontCardTextField = UITextField()
    var backCardTextField = UITextField()
    var reversedSwitchCard = UISwitch()
    @IBAction func cancelBarButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func doneBarButton(sender: AnyObject) {
        if let front = frontCardTextField.text, let back = backCardTextField.text {
            if front == "" {
                cellInSection(0).bottomLine.backgroundColor = UIColor.redColor()
            } else if back == "" {
                cellInSection(1).bottomLine.backgroundColor = UIColor.redColor()
            } else {
                if front.caseInsensitiveCompare(card.frontCard) == .OrderedSame && back.caseInsensitiveCompare(card.backCard) == .OrderedSame{
                    self.cellInSection(0).bottomLine.backgroundColor = UIColor.greenColor()
                    self.cellInSection(1).bottomLine.backgroundColor = UIColor.greenColor()
                    card.isReversed = reversedSwitchCard.on
                    UIView.animateWithDuration(0.3, animations: {
                        self.cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                        self.cellInSection(1).bottomLine.backgroundColor = UIColor.clearColor()
                        }, completion: { finished in
                            self.dismissViewControllerAnimated(true, completion: nil)
                    })
                } else if front.caseInsensitiveCompare(card.frontCard) == .OrderedSame && back == "" {
                    self.cellInSection(1).bottomLine.backgroundColor = UIColor.redColor()
                } else {
                    for card in deck.deck {
                        if frontCardTextField.text?.caseInsensitiveCompare(card.frontCard) == .OrderedSame {
                            cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                            return
                        }
                    }
                    card.frontCard = frontCardTextField.text!
                    card.backCard = backCardTextField.text!
                    card.isReversed = reversedSwitchCard.on
                    self.cellInSection(0).bottomLine.backgroundColor = UIColor.greenColor()
                    UIView.animateWithDuration(0.3, animations: {
                        self.cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                        }, completion: nil)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1 {
            if textField.text == "" {
                cellInSection(0).bottomLine.backgroundColor = UIColor.redColor()
                return
            }
            if textField.text?.caseInsensitiveCompare(card.frontCard) == .OrderedSame {
                cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                return
            }
            for card in deck.deck {
                if textField.text?.caseInsensitiveCompare(card.frontCard) == .OrderedSame {
                    cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                    return
                } else {
                    cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                }
            }
        } else {
            if textField.text != "" {
                cellInSection(1).bottomLine.backgroundColor = UIColor.clearColor()
            } else {
                cellInSection(1).bottomLine.backgroundColor = UIColor.redColor()
            }
        }
        
    }
    func cellInSection(section: Int) -> EnterCardCell {
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EnterCardCell
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("ChangeCardCell", forIndexPath: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.delegate = self
            if indexPath.section == 0 {
                cell.textField.tag = 1
                cell.textField.text = card.frontCard
                dispatch_async(dispatch_get_main_queue(),{
                    cell.textField.becomeFirstResponder()
                })
                frontCardTextField = cell.textField
                return cell
            } else {
                cell.textField.tag = 2
                cell.textField.text = card.backCard
                backCardTextField = cell.textField
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.settingsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            if indexPath.row == 0 {
                cell.switchButton.on = card.isReversed
                reversedSwitchCard = cell.switchButton
                cell.settingsLabel.text = "Normal and reversed"
            } else {
                cell.settingsLabel.text = "Settings"
            }
            return cell
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Front card"
        } else if section == 1 {
            return "Back card"
        }
        return "Settings"
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    override func viewDidLoad() {
        self.title = deck.name
    }
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
    }
}