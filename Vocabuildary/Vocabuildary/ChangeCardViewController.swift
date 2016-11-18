//
//  ChangeCardViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 04.05.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class ChangeCardViewController: UITableViewController, UITextFieldDelegate, CorrectText {
    
    internal var deckStore: DeckStore!
    var deck: Deck?
    var card: Card!
    var frontCardTextField = UITextField()
    var backCardTextField = UITextField()
    var reversedSwitchCard = UISwitch()
    
    @IBAction func cancelBarButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func animateGreenLineInCell(forSection section: Int) {
        self.cellInSection(section).bottomLine.backgroundColor = UIColor.green
        UIView.animate(withDuration: 0.7, animations: {
            self.cellInSection(section).bottomLine.backgroundColor = UIColor.clear
        }, completion: nil)
    }
    
    func cellInSection(_ section: Int) -> EnterCardCell {
        let indexPath = IndexPath(row: 0, section: section)
        return tableView.cellForRow(at: indexPath) as! EnterCardCell
    }
    
    func checkCardTextField() {
        let frontText = checkForText(inTextField: frontCardTextField, forSection: 0)
        let backText = checkForText(inTextField: backCardTextField, forSection: 1)
        guard let front = frontText, let _ = backText else { return }
        if hasSameCard(name: front) && front.caseInsensitiveCompare(card.frontCard) != .orderedSame {
            cellInSection(0).bottomLine.backgroundColor = UIColor.yellow
            return
        }
    }
    
    @IBAction func doneBarButton(_ sender: AnyObject) {
        checkCardTextField()
        if cellInSection(0).bottomLine.backgroundColor == UIColor.clear && cellInSection(1).bottomLine.backgroundColor == UIColor.clear {
            card.frontCard = frontCardTextField.text!
            card.isReversed = reversedSwitchCard.isOn
            animateGreenLineInCell(forSection: 0)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkCardTextField()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 || (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeCardCell", for: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            cell.textField.delegate = self
            if (indexPath as NSIndexPath).section == 0 {
                cell.textField.text = frontCardTextField.text
                frontCardTextField = cell.textField
            } else {
                cell.textField.text = backCardTextField.text
                backCardTextField = cell.textField
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.settingsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            if indexPath.row == 0 {
                cell.switchButton.isOn = card.isReversed
                reversedSwitchCard = cell.switchButton
                cell.settingsLabel.text = "Normal and reversed"
            } else {
                cell.settingsLabel.text = "Settings"
            }
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Front card"
        case 1: return "Back card"
        case 2: return "Settings"
        default: return nil
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    override func viewDidLoad() {
        self.title = deck!.name
        frontCardTextField.text = card.frontCard
        backCardTextField.text = card.backCard
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
}
