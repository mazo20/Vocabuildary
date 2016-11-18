//
//  ChangeDeckOrCardViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 04.05.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class ChangeDeckViewController: UITableViewController, UITextFieldDelegate, CorrectText {
    
    var deck: Deck?
    var deckStore: DeckStore!
    var deckTextField = UITextField()
    var deckName: String? = nil
    var prioritySwitch = UISwitch()
    
    @IBAction func cancelBarButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneBarButton(_ sender: AnyObject) {
        checkDeckTextField()
        if cellInSection(0).bottomLine.backgroundColor == UIColor.clear {
            animateGreenLineInCell(forSection: 0)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func checkDeckTextField() {
        guard let name = checkForText(inTextField: deckTextField, forSection: 0) else { return }
        if hasSameDeck(name: name) && name.caseInsensitiveCompare(deck!.name) != .orderedSame {
            cellInSection(0).bottomLine.backgroundColor = UIColor.yellow
            return
        }
        deck!.name = name
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkDeckTextField()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChangeDeckCell", for: indexPath) as! EnterCardCell
            cell.textField.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            cell.textField.delegate = self
            cell.textField.text = deckTextField.text
            deckTextField = cell.textField
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            if (indexPath as NSIndexPath).section == 1 {
                //if deck.priority == 0 {
                 //   cell.switchButton.isOn = false
                //}
                prioritySwitch = cell.switchButton
                cell.settingsLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                cell.settingsLabel.text = "High priority"
            }
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Deck" : "Deck settings"
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    @IBAction func backgroundTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        self.title = deck!.name
        deckTextField.text = deck!.name
    }
}
