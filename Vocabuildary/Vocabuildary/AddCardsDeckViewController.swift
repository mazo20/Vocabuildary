//
//  addCardsDeckViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 14.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

protocol SendDeckDelegate {
    func sendDeck(_ deck: Deck?)
}

class AddCardsDeckViewController: UITableViewController {
    var delegate: SendDeckDelegate!
    var deckStore: DeckStore!
    
    @IBAction func cancelBarButton(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deckStore.decks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeckCell", for: indexPath)
        cell.textLabel?.text = deckStore.decks[(indexPath as NSIndexPath).row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose deck to add cards to"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.sendDeck(deckStore.decks[indexPath.row])
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
