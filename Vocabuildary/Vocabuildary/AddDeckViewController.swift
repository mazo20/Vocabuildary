//
//  AddDeckViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 14.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class AddDeckViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SendDataDelegate{
    
    var deckStore: DeckStore!
    var card = Card(frontCard: "",backCard: "")
    var deck = Deck(name: "")
    var frontCardTextField = UITextField()
    var backCardTextField = UITextField()
    var deckTextField = UITextField()
    var deckToAddCardsTo = -1
    var reversedSwitchCard = UISwitch()
    var prioritySwitch = UISwitch()
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBAction func doneBarButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func changeView(sender: AnyObject) {
        tableView.reloadData()
    }
    @IBAction func addButton(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            if let front = frontCardTextField.text {
                if let back = backCardTextField.text {
                    card.backCard = back
                    card.frontCard = front
                    if deckToAddCardsTo != -1 {
                        for card in deckStore.deckStore[deckToAddCardsTo].deck {
                            if frontCardTextField.text?.caseInsensitiveCompare(card.frontCard) == .OrderedSame {
                                cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                                return
                            }
                        }
                    }
                    if front == "" {
                        print("No cards to add")
                        cellInSection(0).bottomLine.backgroundColor = UIColor.redColor()
                        if back == "" {
                            cellInSection(1).bottomLine.backgroundColor = UIColor.redColor()
                        } else {
                            cellInSection(1).bottomLine.backgroundColor = UIColor.clearColor()
                        }
                    } else if back == "" {
                        print("No cards to add")
                        cellInSection(1).bottomLine.backgroundColor = UIColor.redColor()
                        cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                    } else if deckStore.deckStore.count >= deckToAddCardsTo && deckToAddCardsTo != -1{
                        card.reversed = reversedSwitchCard.on
                        print(card.reversed)
                        deckStore.deckAtIndex(deckToAddCardsTo).addCard(card)
                        card = Card(frontCard: "", backCard: "")
                        frontCardTextField.text = nil
                        backCardTextField.text = nil
                        frontCardTextField.becomeFirstResponder()
                        cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                        cellInSection(1).bottomLine.backgroundColor = UIColor.clearColor()
                        cellInSection(2).bottomLine.backgroundColor = UIColor.clearColor()
                        self.cellInSection(0).bottomLine.backgroundColor = UIColor.greenColor()
                        self.cellInSection(1).bottomLine.backgroundColor = UIColor.greenColor()
                        UIView.animateWithDuration(0.7, animations: {
                            self.cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                            self.cellInSection(1).bottomLine.backgroundColor = UIColor.clearColor()
                            }, completion: nil)
                    } else {
                        print("No deck to add cards to")
                        cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                        cellInSection(1).bottomLine.backgroundColor = UIColor.clearColor()
                        cellInSection(2).bottomLine.backgroundColor = UIColor.redColor()
                    }
                }
            }
        } else {
            if let deckName = deckTextField.text {
                if deckName != "" {
                    for deck in deckStore.deckStore {
                        if deckName.caseInsensitiveCompare(deck.name) == .OrderedSame {
                            cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                            return
                        }
                    }
                    if prioritySwitch.on {
                        deck.priority = 1
                    } else {
                        deck.priority = 0
                    }
                    deck.name = deckName
                    deckStore.addDeck(deck)
                    deck = Deck(name: "")
                    deckTextField.text = nil
                    self.cellInSection(0).bottomLine.backgroundColor = UIColor.greenColor()
                    UIView.animateWithDuration(0.7, animations: {
                        self.cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
                        }, completion: nil)
                } else {
                    cellInSection(0).bottomLine.backgroundColor = UIColor.redColor()
                }
            }
        }
    }
    func cellInSection(section: Int) -> EnterCardCell {
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! EnterCardCell
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return 1
        }
        if section == 3 {
            return 1
        }
        return 1
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if segmentedControl.selectedSegmentIndex == 1 {
            return 2
        }
        return 4
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 1 {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddDecksTextCell", forIndexPath: indexPath) as! EnterCardCell
                cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.textField.delegate = self
                if cell.textField.tag != 3 {
                    dispatch_async(dispatch_get_main_queue(),{
                        cell.textField.becomeFirstResponder()
                    })
                }
                cell.textField.tag = 3
                deckTextField = cell.textField
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
                cell.settingsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.settingsLabel.text = "High priority"
                cell.switchButton.on = false
                prioritySwitch = cell.switchButton
                return cell
            }
        }
        if indexPath.section == 0 || indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("AddCardsTextCell", forIndexPath: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.delegate = self
            if indexPath.section == 0 {
                if cell.textField.tag != 1 {
                    dispatch_async(dispatch_get_main_queue(),{
                        cell.textField.becomeFirstResponder()
                    })
                }
                cell.textField.tag = 1
                frontCardTextField = cell.textField
            } else {
                cell.textField.tag = 2
                backCardTextField = cell.textField
            }
            return cell
        } else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCellWithIdentifier("AddCardsTextCell", forIndexPath: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            cell.textField.hidden = true
            if deckToAddCardsTo == -1 {
                cell.textLabel?.text = ""
            } else {
                cell.textLabel?.text = deckStore.deckStore[deckToAddCardsTo].name
                cell.bottomLine.backgroundColor = UIColor.clearColor()
            }
            cell.accessoryType = .DisclosureIndicator
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.settingsLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            if indexPath.row == 0 {
                cell.switchButton.on = true
                reversedSwitchCard = cell.switchButton
                cell.settingsLabel.text = "Normal and reversed"
            } else {
                cell.settingsLabel.text = "Settings"
            }
            return cell
        }
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 1 {
            if section == 0 {
                return "Deck"
            } else {
                return "Deck settings"
            }
        }
        if section == 0 {
            return "Front card"
        } else if section == 1 {
            return "Back card"
        } else if section == 2 {
            return "Deck to add cards to"
        }
        return "Card settings"
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1 && deckToAddCardsTo != -1 {
            for card in deckStore.deckStore[deckToAddCardsTo].deck {
                if textField.text?.caseInsensitiveCompare(card.frontCard) == .OrderedSame {
                    cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                    return
                }
            }
            cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
        } else if textField.tag == 3 {
            for deck in deckStore.deckStore {
                if textField.text?.caseInsensitiveCompare(deck.name) == .OrderedSame {
                    cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                    return
                }
            }
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 && segmentedControl.selectedSegmentIndex == 0{
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("chooseDeck",sender: self)
            })
        }
    }
    @IBAction func backgroundTapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chooseDeck" {
            let navController = segue.destinationViewController as! UINavigationController
            let viewController = navController.topViewController as! AddCardsDeckViewController
            viewController.deckStore = self.deckStore
            viewController.delegate = self
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    func sendData(data: Int) {
        deckToAddCardsTo = data
    }
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        if deckToAddCardsTo != -1 {
            cellInSection(0).bottomLine.backgroundColor = UIColor.clearColor()
            for card in deckStore.deckStore[deckToAddCardsTo].deck {
                if frontCardTextField.text?.caseInsensitiveCompare(card.frontCard) == .OrderedSame {
                    cellInSection(0).bottomLine.backgroundColor = UIColor.orangeColor()
                    continue
                }
            }
        }
    }
    override func viewDidLoad() {
        if let nav = self.navigationController {
            let lineView = UIView(frame: CGRectMake(0, nav.navigationBar.frame.size.height,self.view.frame.size.width,1))
            lineView.backgroundColor = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
            nav.navigationBar.addSubview(lineView)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(true)
    }
}