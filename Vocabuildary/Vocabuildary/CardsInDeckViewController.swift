//
//  CardsInDeckViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 14.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class CardsInDeckViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating  {
    
    var deck: Deck!
    var filteredCards = Deck(name: "")
    var deckStore: DeckStore!
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var editButtonOutlet: UIBarButtonItem!
    @IBOutlet var searchButton: UIBarButtonItem!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredCards.deck.count
        }
        return deck.deck.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CardsInDeckCell", forIndexPath: indexPath)
        let deck: Deck
        if searchController.active && searchController.searchBar.text != "" {
            deck = filteredCards
        } else {
            deck = self.deck
        }
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.text = deck.deck[indexPath.row].frontCard + " - " + deck.deck[indexPath.row].backCard
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36
    }
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if searchController.active && searchController.searchBar.text != "" {
            deck.moveDeckAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        } else {
            filteredCards.moveDeckAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let deck: Deck
            if searchController.active && searchController.searchBar.text != "" {
                deck = filteredCards
            } else {
                deck = self.deck
            }
            let card = deck.deck[indexPath.row]
            
            let alertTitle = "Delete '\(card.frontCard) - \(card.backCard)'?"
            let alertMessage = "Are you sure you want to delete this card?"
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                //Remove the item from the store
                self.deck.removeCard(card)
                //Also remove that row
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func editButton(sender: AnyObject) {
        if tableView.editing == true {
            tableView.setEditing(false, animated: true)
            editButtonOutlet.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            editButtonOutlet.title = "Done"
        }
    }
    override func previewActionItems() -> [UIPreviewActionItem] {
        let deleteAction = UIPreviewAction(title: "Delete", style: .Destructive, handler: { (action, viewController) -> Void in
            //Remove the deck from the store
            self.deckStore.removeDeck(self.deck)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "reloadTable", object: nil))
        })
        let editAction = UIPreviewAction(title: "Edit", style: .Default) { (action, viewController) -> Void in
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "editDeck", object: nil))
        }
        let cancelAction = UIPreviewAction(title: "Cancel", style: .Default, handler: { (action, viewController) -> Void in
        })
        let groupDeleteAction = UIPreviewActionGroup(title: "Delete", style: .Destructive, actions: [deleteAction,cancelAction])
        return [editAction, groupDeleteAction]
    }
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return nil
        }
        var cards = 0
        var notShown = 0
        var learned = 0
        for card in deck.deck {
            let d = card.days.count
            cards+=1
            if card.n == 0 {
                notShown+=1
            }
            if d>1 {
                if card.days[d-1]-card.days[d-2] > 60 {
                    learned+=1
                }
            }
        }
        return "\(cards) cards overall, \(cards-notShown-learned) to study, \(notShown) not yet shown, \(learned) learned"
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(),{
            self.performSegueWithIdentifier("ChangeCard", sender: self)
        })
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChangeCard" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let navController = segue.destinationViewController as! UINavigationController
                let changeCardViewController = navController.topViewController as! ChangeCardViewController
                let deck: Deck
                if searchController.active && searchController.searchBar.text != "" {
                    deck = filteredCards
                } else {
                    deck = self.deck
                }
                changeCardViewController.deck = deck
                changeCardViewController.card = deck.deck[row]
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
        searchController.searchBar.translucent = false
        searchController.loadView()
        
        let blueView = UIView()
        let blueRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        blueView.frame = blueRect
        blueView.center = CGPointMake(self.view.frame.size.width/2,-self.view.frame.size.height/2)
        blueView.backgroundColor = blueThemeColor()
        self.view.addSubview(blueView)
        
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = blueThemeColor().CGColor
    }
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCards.deck = deck.deck.filter { card in
            let text = card.frontCard + " - " + card.backCard
            return text.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    @IBAction func searchButton(sender: AnyObject) {
        searchController.searchBar.becomeFirstResponder()
    }
    deinit {
        searchController.loadViewIfNeeded()
    }    
}