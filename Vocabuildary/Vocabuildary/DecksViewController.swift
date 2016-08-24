//
//  DecksViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 13.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class DecksViewController: UITableViewController, UISearchControllerDelegate, UIViewControllerPreviewingDelegate, UISearchResultsUpdating {
    
    var deckStore: DeckStore!
    var filteredDecks = [Deck]()
    var deckToEdit = 0
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var editButtonOutlet: UIBarButtonItem!
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredDecks.count
        }
        return deckStore.deckStore.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DeckCell", forIndexPath: indexPath) as! TodayCell
        let deck: Deck
        if searchController.active && searchController.searchBar.text != "" {
            deck = filteredDecks[indexPath.row]
        } else {
            deck = deckStore.deckStore[indexPath.row]
        }
        cell.deckName.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.deckName.text = deck.name
        var cards = [0,0,0]
        for card in deck.deck {
            if card.n == 0 {
                cards[0]+=1
            } else if card.Q < 1.5 {
                cards[2]+=1
            } else {
                cards[1]+=1
            }
        }
        cell.newCards.text = String(cards[0])
        cell.repeatingCards.text = String(cards[1])
        cell.problematicCards.text = String(cards[2])
        cell.accessoryType = .DisclosureIndicator

        return cell
    }
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return nil
        }
        let cards = deckStore.cards
        return "\(cards[0]) cards overall, \(cards[1]) to study, \(cards[2]) not yet shown, \(cards[3]) learned"
    }
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if !searchController.active || searchController.searchBar.text == "" {
            deckStore.moveDeckAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //If the table view is asking to commit a delete command...
        if editingStyle == .Delete {
            let deck: Deck
            if searchController.active && searchController.searchBar.text != "" {
                deck = filteredDecks[indexPath.row]
            } else {
                deck = deckStore.deckStore[indexPath.row]
            }
            let alertTitle = "Delete '\(deck.name)'?"
            let alertMessage = "Are you sure you want to delete this deck and all its cards?"
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                //Remove the item from the store
                self.deckStore.removeDeck(deck)
                //Also remove that row
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                tableView.beginUpdates()
                tableView.footerViewForSection(0)?.textLabel?.text = self.tableView(tableView, titleForFooterInSection: 0)
                tableView.endUpdates()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            //Present the alert controller
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("ChangeDeck", sender: self)
            })
        } else {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("CardsInDeckViewController", sender: self)
            })
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChangeDeck" {
            var index = 0
            if let row = tableView.indexPathForSelectedRow?.row {
                index = row
            } else {
                index = deckToEdit
            }
            let deck: Deck
            if searchController.active && searchController.searchBar.text != "" {
                deck = filteredDecks[index]
            } else {
                deck = deckStore.deckStore[index]
            }
            let navController = segue.destinationViewController as! UINavigationController
            let changeDeckViewController = navController.topViewController as! ChangeDeckViewController
            changeDeckViewController.deck = deck
            changeDeckViewController.deckStore = deckStore
        } else {
            if let row = tableView.indexPathForSelectedRow?.row {
                //Get the item associated with this row and pass it along
                let deck: Deck
                if searchController.active && searchController.searchBar.text != "" {
                    deck = filteredDecks[row]
                } else {
                    deck = deckStore.deckStore[row]
                }
                let cardsInDeckViewController = segue.destinationViewController as! CardsInDeckViewController
                cardsInDeckViewController.deck = deck
                cardsInDeckViewController.deckStore = deckStore
            }
        }
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        searchController.searchBar.becomeFirstResponder()
    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else {return nil}
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {return nil}
        
        guard let cardsInDeckViewController = storyboard?.instantiateViewControllerWithIdentifier("CardsInDeckViewController") as? CardsInDeckViewController else {return nil}
        let deck: Deck
        if searchController.active && searchController.searchBar.text != "" {
            deck = filteredDecks[indexPath.row]
        } else {
            deck = deckStore.deckStore[indexPath.row]
        }
        cardsInDeckViewController.deck = deck
        cardsInDeckViewController.deckStore = deckStore
        previewingContext.sourceRect = cell.frame
        deckToEdit = indexPath.row
        
        return cardsInDeckViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    //MARK: 3DTouch preview actions
    func reloadTable() {
        tableView.reloadData()
    }
    func editDeck() {
        dispatch_async(dispatch_get_main_queue(),{
            self.performSegueWithIdentifier("ChangeDeck", sender: self)
        })
    }
    
    override func viewDidLoad() {
        if( traitCollection.forceTouchCapability == .Available){
            registerForPreviewingWithDelegate(self, sourceView: view)
        }
        tableView.allowsSelectionDuringEditing = true
        
        let tabBar = self.tabBarController as! TabBarController
        self.deckStore = tabBar.deckStore
        
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.translucent = false
        searchController.loadView()
        
        let lineView = UIView(frame: CGRectMake(0,(self.navigationController?.navigationBar.frame.size.height)!,self.view.frame.size.width,1))
        lineView.backgroundColor = blueThemeColor()
        self.navigationController?.navigationBar.addSubview(lineView)
        
        searchController.searchBar.layer.borderWidth = 1;
        searchController.searchBar.layer.borderColor = blueThemeColor().CGColor
        
        let blueView = UIView()
        let blueRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        blueView.frame = blueRect
        blueView.center = CGPointMake(self.view.frame.size.width/2,-self.view.frame.size.height/2)
        blueView.backgroundColor = blueThemeColor()
        self.view.addSubview(blueView)
    }
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredDecks = deckStore.deckStore.filter { deck in
            return deck.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecksViewController.reloadTable), name: "reloadTable", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DecksViewController.editDeck), name: "editDeck", object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
