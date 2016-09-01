//
//  addCardsDeckViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 14.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

protocol SendDataDelegate {
    func sendData(data: Int)
}

class AddCardsDeckViewController: UITableViewController {
    // TIP: delegate powinien byc zadeklarowany jako weak i byc optionalem, bo inaczej doprowadzisz do retain cycle
    // Poczytaj o retain cycles / ARC w iOS
    var delegate: SendDataDelegate!             // weak var delegate: SendDataDelegate?
    var deckStore: DeckStore!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deckStore.deckStore.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeckCell", forIndexPath: indexPath)
        cell.textLabel?.text = deckStore.deckStore[indexPath.row].name
        return cell
    }
    @IBAction func cancelBarButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(),{
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose deck to add cards to"
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate.sendData(indexPath.row)
        dispatch_async(dispatch_get_main_queue(),{
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}