//
//  CardsInDeckViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 14.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class CardsInDeckViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var deck: Deck!
    var filteredCards = Deck(name: "")
    var deckStore: DeckStore!
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var editButtonOutlet: UIBarButtonItem!
    @IBOutlet var searchButton: UIBarButtonItem!
    
    func whatDeck() -> Deck {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCards
        }
        return self.deck
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return whatDeck().cards.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CardsInDeckCell", for: indexPath) as! CardCell
        let deck = whatDeck()
        let card = deck.cards[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = card.frontCard + " - " + card.backCard
        let color: UIColor
        switch card.status {
        case .new: color = UIColor(red: 0.2, green: 0.6, blue: 0, alpha: 1)
        case .easy: color = blueThemeColor()
        case .hard: color = UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)
        default: color = UIColor.black
        }
        cell.statusDot.backgroundColor = color
        cell.statusDot.layer.cornerRadius = 2
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        whatDeck().moveCardAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = whatDeck().cards[(indexPath as NSIndexPath).row]
            
            let alertTitle = "Delete '\(card.frontCard) - \(card.backCard)'?"
            let alertMessage = "Are you sure you want to delete this card?"
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                //Remove the item from the store
                self.deck.removeCard(card)
                //Also remove that row
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func editButton(_ sender: AnyObject) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            editButtonOutlet.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            editButtonOutlet.title = "Done"
        }
    }
    override var previewActionItems : [UIPreviewActionItem] {
        let deleteAction = UIPreviewAction(title: "Delete", style: .destructive, handler: { (action, viewController) -> Void in
            //Remove the deck from the store
            self.deckStore.removeDeck(self.deck)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadTable"), object: nil))
        })
        let editAction = UIPreviewAction(title: "Edit", style: .default) { (action, viewController) -> Void in
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "editDeck"), object: nil))
        }
        let cancelAction = UIPreviewAction(title: "Cancel", style: .default, handler: { (action, viewController) -> Void in })
        let groupDeleteAction = UIPreviewActionGroup(title: "Delete", style: .destructive, actions: [deleteAction,cancelAction])
        return [editAction, groupDeleteAction]
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        }
        var cardType = [0, 0, 0, 0]
        for card in deck.cards {
            switch card.status {
            case .easy, .hard: cardType[1]+=1
            case .new: cardType[2]+=1
            case .learned: cardType[3]+=1
            }
        }
        cardType[0] = cardType[1] + cardType[2] + cardType[3]
        return "\(cardType[0]) cards overall: \(cardType[1]) in progress, \(cardType[2]) new, \(cardType[3]) learned"
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "ChangeCard", sender: self)
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeCard" {
            if let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                let navController = segue.destination as! UINavigationController
                let changeCardViewController = navController.topViewController as! ChangeCardViewController
                let deck = whatDeck()
                changeCardViewController.deck = deck
                changeCardViewController.card = deck.cards[row]
            }
        }
    }
    override func viewDidLoad() {
        tableView.allowsSelectionDuringEditing = true
        self.title = deck.name
        filteredCards.name = deck.name
        
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.searchBar.isTranslucent = false
        searchController.loadView()
        
        let blueView = UIView()
        let blueRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        blueView.frame = blueRect
        blueView.center = CGPoint(x: self.view.frame.size.width/2,y: -self.view.frame.size.height/2)
        blueView.backgroundColor = blueThemeColor()
        self.view.addSubview(blueView)
        
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = blueThemeColor().cgColor
    }
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCards.cards = deck.cards.filter { card in
            let text = card.frontCard + " - " + card.backCard
            return text.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    @IBAction func searchButton(_ sender: AnyObject) {
        searchController.searchBar.becomeFirstResponder()
    }
    deinit {
        searchController.loadViewIfNeeded()
    }    
}
