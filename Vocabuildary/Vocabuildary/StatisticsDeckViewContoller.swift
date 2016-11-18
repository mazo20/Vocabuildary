//
//  StatisticsDeckViewContoller.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 08.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class StatisticsDeckViewController: UITableViewController {
    var delegate: SendDeckDelegate!
    var deckStore: DeckStore!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deckStore.decks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeckCell", for: indexPath)
        cell.textLabel?.text = deckStore.decks[indexPath.row].name
        return cell
    }
    @IBAction func showAllDecks(_ sender: AnyObject) {
        self.delegate.sendDeck(nil)
        dismissViewController()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.sendDeck(deckStore.decks[indexPath.row])
        dismissViewController()
    }
    @IBAction func cancelBarButton(_ sender: AnyObject) {
        dismissViewController()
    }
    func dismissViewController() {
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose deck to show statistics"
    }
}
