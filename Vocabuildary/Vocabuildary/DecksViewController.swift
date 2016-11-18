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
    
    func whatDeck(_ index: Int) -> Deck {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredDecks[index]
        }
        return deckStore.decks[index]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredDecks.count
        }
        return deckStore.decks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DeckCell", for: indexPath) as! TodayCell
        let deck = whatDeck((indexPath as NSIndexPath).row)
        cell.deckName.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        cell.deckName.text = deck.name
        let cards = deck.whatCards(deck.cards)
        cell.newCards.text = String(cards[0])
        cell.repeatingCards.text = String(cards[1])
        cell.problematicCards.text = String(cards[2])
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard !searchController.isActive || searchController.searchBar.text == "" else { return nil}
        let cards = deckStore.cards
        return "\(cards[0]) cards overall: \(cards[1]) in progress, \(cards[2]) new, \(cards[3]) learned"
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if !searchController.isActive || searchController.searchBar.text == "" {
            deckStore.moveDeckAtIndex((sourceIndexPath as NSIndexPath).row, toIndex: (destinationIndexPath as NSIndexPath).row)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //If the table view is asking to commit a delete command...
        if editingStyle == .delete {
            let deck = whatDeck((indexPath as NSIndexPath).row)
            let alertTitle = "Delete '\(deck.name)'?"
            let alertMessage = "Are you sure you want to delete this deck and all its cards?"
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.deckStore.removeDeck(deck)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.beginUpdates()
                tableView.footerView(forSection: 0)?.textLabel?.text = self.tableView(tableView, titleForFooterInSection: 0)
                tableView.endUpdates()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            let identifier = tableView.isEditing ? "ChangeDeck" : "CardsInDeckViewController"
            self.performSegue(withIdentifier: identifier, sender: self)
        })
    }
    @IBAction func editButton(_ sender: AnyObject) {
        editButtonOutlet.title = tableView.isEditing ? "Edit" : "Done"
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeDeck" {
            var index: Int {
                if let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                    return row
                }
                return deckToEdit
            }
            
            let navController = segue.destination as! UINavigationController
            let changeDeckViewController = navController.topViewController as! ChangeDeckViewController
            changeDeckViewController.deck = whatDeck(index)
            changeDeckViewController.deckStore = deckStore
        } else {
            if let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                //Get the item associated with this row and pass it along
                let cardsInDeckViewController = segue.destination as! CardsInDeckViewController
                cardsInDeckViewController.deck = whatDeck(row)
                cardsInDeckViewController.deckStore = deckStore
            }
        }
    }
    
    @IBAction func searchButton(_ sender: AnyObject) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath),
            let cardsInDeckViewController = storyboard?.instantiateViewController(withIdentifier: "CardsInDeckViewController") as? CardsInDeckViewController else {return nil}
        
        cardsInDeckViewController.deck = whatDeck((indexPath as NSIndexPath).row)
        cardsInDeckViewController.deckStore = deckStore
        previewingContext.sourceRect = cell.frame
        deckToEdit = (indexPath as NSIndexPath).row
        
        return cardsInDeckViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    //MARK: 3DTouch preview actions
    
    func reloadTable() {
        tableView.reloadData()
    }
    
    func editDeck() {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "ChangeDeck", sender: self)
        })
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredDecks = deckStore.decks.filter { deck in
            return deck.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    //MARK: - View customization
    
    override func viewDidLoad() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        tableView.allowsSelectionDuringEditing = true
        
        let tabBar = self.tabBarController as! TabBarController
        self.deckStore = tabBar.deckStore
        
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.isTranslucent = false
        searchController.loadView()
        
        searchController.searchBar.layer.borderWidth = 1;
        searchController.searchBar.layer.borderColor = blueThemeColor().cgColor
        
        let blueView = UIView()
        let blueRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        blueView.frame = blueRect
        blueView.center = CGPoint(x: self.view.frame.size.width/2,y: -self.view.frame.size.height/2)
        blueView.backgroundColor = blueThemeColor()
        self.view.addSubview(blueView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(DecksViewController.reloadTable), name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DecksViewController.editDeck), name: NSNotification.Name(rawValue: "editDeck"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
}
