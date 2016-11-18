//
//  AddDeckViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 14.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

protocol CorrectText {
    var deckStore: DeckStore! { get set }
    var deck: Deck? { get set }
    func cellInSection(_ section: Int) -> EnterCardCell
}

extension CorrectText {
    func checkTextField(withName textField: UITextField, forSection section: Int) {
        guard let text = checkForText(inTextField: textField, forSection: section) else { return }
        if textField.tag == 0 {
            if hasSameCard(name: text) {
                cellInSection(section).bottomLine.backgroundColor = UIColor.yellow
            }
        } else if textField.tag == 2 {
            if hasSameDeck(name: text) {
                cellInSection(section).bottomLine.backgroundColor = UIColor.yellow
            } 
        }
    }
    func hasSameDeck(name: String) -> Bool {
        return deckStore.decks.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame })
    }
    func hasSameCard(name: String) -> Bool {
        if let deck = deck, deck.cards.contains(where: { $0.frontCard.caseInsensitiveCompare(name) == .orderedSame }) { return true }
        return false
    }
    func checkForText(inTextField textField: UITextField, forSection section: Int) -> String? {
        if let text = textField.text, text != "" {
            cellInSection(section).bottomLine.backgroundColor = UIColor.clear
            if textField.text!.characters.last! == " " {
                textField.text!.characters.removeLast(1)
            }
            return textField.text!
        } else {
            cellInSection(section).bottomLine.backgroundColor = UIColor.red
            return nil
        }
    }
}

class AddDeckViewController: UIViewController, CorrectText {
    
    enum TextType {
        case deck
        case card
    }
    
    var deckStore: DeckStore!
    var deck: Deck?
    var frontCardTextField = UITextField()
    var backCardTextField = UITextField()
    var deckTextField = UITextField()
    var reversedSwitchCard = UISwitch()
    var prioritySwitch = UISwitch()
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    
    @IBAction func doneBarButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeView(_ sender: AnyObject) {
        tableView.reloadData()
    }
    
    func animateGreenLineInCell(forSection section: Int) {
        self.cellInSection(section).bottomLine.backgroundColor = UIColor.green
        UIView.animate(withDuration: 0.7, animations: {
            self.cellInSection(section).bottomLine.backgroundColor = UIColor.clear
            }, completion: nil)
    }
    
    @IBAction func addButton(_ sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            checkTextField(withName: frontCardTextField, forSection: 0)
            checkTextField(withName: backCardTextField, forSection: 1)
            
            if self.cellInSection(0).bottomLine.backgroundColor == UIColor.clear && self.cellInSection(1).bottomLine.backgroundColor == UIColor.clear {
                if let deck = deck {
                    if frontCardTextField.text!.characters.last! == " " {
                        frontCardTextField.text!.characters.removeLast(1)
                    }
                    if backCardTextField.text!.characters.last! == " " {
                        backCardTextField.text!.characters.removeLast(1)
                    }
                    let card = Card(frontCard: frontCardTextField.text!, backCard: backCardTextField.text!, isReversed: reversedSwitchCard.isOn)
                    deck.cards.append(card)
                    
                    animateGreenLineInCell(forSection: 0)
                    animateGreenLineInCell(forSection: 1)
                    
                    frontCardTextField.text = nil
                    backCardTextField.text = nil
                    frontCardTextField.becomeFirstResponder()
                } else {
                    cellInSection(2).bottomLine.backgroundColor = UIColor.red
                }
            }
            
        } else {
            checkTextField(withName: deckTextField, forSection: 0)
            if self.cellInSection(0).bottomLine.backgroundColor == UIColor.clear {
                animateGreenLineInCell(forSection: 0)
                let deck = Deck(name: deckTextField.text!)
                //deck.priority = prioritySwitch.isOn ? 1 : 0
                deckStore.decks.append(deck)
                deckTextField.text = nil
                deckTextField.becomeFirstResponder()
            }
        }
    }
    
    func cellInSection(_ section: Int) -> EnterCardCell {
        let indexPath = IndexPath(row: 0, section: section)
        return tableView.cellForRow(at: indexPath) as! EnterCardCell
    }
    
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseDeck" {
            let navController = segue.destination as! UINavigationController
            let viewController = navController.topViewController as! AddCardsDeckViewController
            viewController.deckStore = self.deckStore
            viewController.delegate = self
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
}
extension AddDeckViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        var section = textField.tag
        if textField.tag == 2 { section = 0 }
        checkTextField(withName: textField, forSection: section)
        if segmentedControl.selectedSegmentIndex == 0  && (frontCardTextField.text == nil || frontCardTextField.text == "") && (backCardTextField.text == nil || backCardTextField.text == "") {
            self.cellInSection(0).bottomLine.backgroundColor = UIColor.clear
            self.cellInSection(1).bottomLine.backgroundColor = UIColor.clear
        } else if segmentedControl.selectedSegmentIndex == 1 && (deckTextField.text == nil || deckTextField.text == "") {
            self.cellInSection(0).bottomLine.backgroundColor = UIColor.clear
        }
    }
}

extension AddDeckViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? 4 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 1 {
            if (indexPath as NSIndexPath).section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddDecksTextCell", for: indexPath) as! EnterCardCell
                cell.textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                cell.textField.delegate = self
                cell.textField.becomeFirstResponder()
                cell.textField.tag = 2
                deckTextField = cell.textField
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.settingsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                cell.settingsLabel.text = "High priority"
                cell.switchButton.isOn = false
                prioritySwitch = cell.switchButton
                return cell
            }
        }
        if (indexPath as NSIndexPath).section == 0 || (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardsTextCell", for: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            cell.textField.delegate = self
            if (indexPath as NSIndexPath).section == 0 {
                cell.textField.becomeFirstResponder()
                cell.textField.tag = 0
                frontCardTextField = cell.textField
            } else {
                cell.textField.tag = 1
                backCardTextField = cell.textField
            }
            return cell
        } else if (indexPath as NSIndexPath).section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCardsTextCell", for: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            cell.textField.isHidden = true
            cell.accessoryType = .disclosureIndicator
            if let deck = deck {
                cell.textLabel?.text = deck.name
                cell.bottomLine.backgroundColor = UIColor.clear
            } else {
                cell.textLabel?.text = ""
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.settingsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            cell.switchButton.isOn = true
            reversedSwitchCard = cell.switchButton
            cell.settingsLabel.text = "Normal and reversed"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segmentedControl.selectedSegmentIndex == 1 {
            return section == 0 ? "Deck" : "Deck settings"
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 2 && segmentedControl.selectedSegmentIndex == 0{
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "chooseDeck",sender: self)
            })
        }
    }
}

extension AddDeckViewController: SendDeckDelegate {
    func sendDeck(_ deck: Deck?) {
        if let deck = deck {
            self.deck = deck
            cellInSection(2).bottomLine.backgroundColor = UIColor.clear
        }
    }
}
