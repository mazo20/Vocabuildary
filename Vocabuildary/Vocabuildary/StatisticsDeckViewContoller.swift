//
//  StatisticsDeckViewContoller.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 08.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class StatisticsDeckViewController: UITableViewController {
    var delegate: SendDataDelegate!
    var deckStore: DeckStore!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deckStore.deckStore.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DeckCell", forIndexPath: indexPath)
        cell.textLabel?.text = deckStore.deckStore[indexPath.row].name
        return cell
    }
    @IBAction func showAllDecks(sender: AnyObject) {
        self.delegate.sendData(-1)
        dismissViewController()
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate.sendData(indexPath.row)
        dismissViewController()
    }
    @IBAction func cancelBarButton(sender: AnyObject) {
        dismissViewController()
    }
    func dismissViewController() {
        dispatch_async(dispatch_get_main_queue(),{
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose deck to show statistics"
    }
}