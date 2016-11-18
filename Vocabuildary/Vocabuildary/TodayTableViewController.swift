//
//  DeckTableViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 03.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit
//import CloudKit

class TodayTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    
    //MARK: Properties
    
    var deckStore: DeckStore!
    var decksForToday = [Deck]()
    var numberOfCards: [Int] {
        var array = [0, 0, 0]
        for deck in decksForToday {
            let whatCards = deck.whatCards(deck.cardsForToday)
            for i in 0...2 {
                array[i]+=whatCards[i]
            }
        }
        return array
    }
    //MARK: Outlets
    @IBOutlet var informationView: UIView!
    @IBOutlet var problematicCards: UILabel!
    @IBOutlet var repeatingCards: UILabel!
    @IBOutlet var newCards: UILabel!
    @IBOutlet var allCards: UILabel!
    @IBOutlet var toStudy: UILabel!
    @IBOutlet var notShown: UILabel!
    @IBOutlet var learned: UILabel!
    
    //MARK: TableView methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decksForToday.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayCell", for: indexPath) as! TodayCell
        cell.deckName.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        let deck = decksForToday[indexPath.row]
        cell.deckName.text = deck.name
        let cardsInDeck = deck.whatCards(deck.cardsForToday)
        cell.newCards.text = String(cardsInDeck[0])
        cell.repeatingCards.text = String(cardsInDeck[1])
        cell.problematicCards.text = String(cardsInDeck[2])
        if cardsInDeck == [0, 0, 0] {
            cell.newCards.textColor = UIColor.gray
            cell.repeatingCards.textColor = UIColor.gray
            cell.problematicCards.textColor = UIColor.gray
        } else {
            cell.newCards.textColor = UIColor(red: 0.2, green: 0.6, blue: 0, alpha: 1)
            cell.repeatingCards.textColor = blueThemeColor()
            cell.problematicCards.textColor = UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)
        }
        return cell
    }
    
    //MARK: Segues and 3D Touch
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        //self.performSegueWithIdentifier("exit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let row = tableView.indexPathForSelectedRow?.row {
            let beforeLearningViewController = segue.destination as! BeforeLearningViewController
            beforeLearningViewController.deck = decksForToday[row]
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {return nil}
        guard let cell = tableView.cellForRow(at: indexPath) else {return nil}
        guard let beforeLearningViewController = storyboard?.instantiateViewController(withIdentifier: "BeforeLearningViewController") as? BeforeLearningViewController else {return nil}
        
        beforeLearningViewController.deck = decksForToday[(indexPath as NSIndexPath).row]
        previewingContext.sourceRect = cell.frame
        
        return beforeLearningViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    //MARK: - View customization
    
    override func viewDidLoad() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        let tabBar = self.tabBarController as! TabBarController
        self.deckStore = tabBar.deckStore
        
        newCards.text = String(numberOfCards[0])
        repeatingCards.text = String(numberOfCards[1])
        problematicCards.text = String(numberOfCards[2])
        allCards.text = String(deckStore.cards[0])
        toStudy.text = String(deckStore.cards[1])
        notShown.text = String(deckStore.cards[2])
        learned.text = String(deckStore.cards[3])
        
        
        navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        navigationItem.backBarButtonItem?.title = ""
        
        let blueView = UIView()
        let blueRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width*3, height: self.view.frame.size.height)
        blueView.frame = blueRect
        blueView.center = CGPoint(x: self.view.frame.size.width/2,y: -self.view.frame.size.height/2)
        blueView.backgroundColor = blueThemeColor()
        self.view.addSubview(blueView)
        
        let bounds = informationView.bounds as CGRect!
        let infoView = UIView()
        infoView.frame = bounds!
        infoView.backgroundColor = UIColor.blueThemeColor()
        informationView.addSubview(infoView)
        informationView.sendSubview(toBack: infoView)
        let lineView1 = UIView()
        lineView1.frame = CGRect(x: (self.view.frame.size.width-16)/3+8, y: infoView.frame.size.height/6+3, width: 0.5, height: infoView.frame.size.height*3/6)
        lineView1.backgroundColor = UIColor.white
        informationView.addSubview(lineView1)
        let lineView2 = UIView()
        lineView2.frame = CGRect(x: (self.view.frame.size.width-16)/3*2+8, y: infoView.frame.size.height/6+3, width: 0.5, height: infoView.frame.size.height*3/6)
        lineView2.backgroundColor = UIColor.white
        informationView.addSubview(lineView2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TodayTableViewController.appBecomeActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil )
    }
    
    func appBecomeActive() {
        viewDidAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        decksForToday = [Deck]()
        var emptyDecks = [Deck]()
        for deck in deckStore.decks {
            deck.cardsInDeckForToday()
            if deck.cardsForToday.count > 0 {
                decksForToday.append(deck)
            } else {
                emptyDecks.append(deck)
            }
        }
        decksForToday = decksForToday + emptyDecks
        tableView.reloadData()
        newCards.text = String(numberOfCards[0])
        repeatingCards.text = String(numberOfCards[1])
        problematicCards.text = String(numberOfCards[2])
        allCards.text = String(deckStore.cards[0])
        toStudy.text = String(deckStore.cards[1])
        notShown.text = String(deckStore.cards[2])
        learned.text = String(deckStore.cards[3])
        
    }
}
