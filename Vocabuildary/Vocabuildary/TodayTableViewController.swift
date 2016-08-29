//
//  DeckTableViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 03.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class TodayTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    
    //MARK: Properties
    
    var deckStore: DeckStore!
    var decks = [Deck]()
    var otherDecks = [Deck]()
    var newCardsToShow: Int!
    var today = NSDate().today
    var numberOfCards: [Int] {
        var array = [0, 0, 0]
        for deck in decks {
            array[0]+=deck.whatCards[0]
            array[1]+=deck.whatCards[1]
            array[2]+=deck.whatCards[2]
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
    //MARK: - Cards to show algorithm
    /**
     Algorithm that chooses cards to show for today
    */
    func searchForCards() {
        if NSUserDefaults.standardUserDefaults().objectForKey("today") as! NSDate != NSDate().today {
            NSUserDefaults.standardUserDefaults().setObject(NSDate().today, forKey: "today")
            for deck in deckStore.deckStore {
                deck.newCardsToday = 0
            }
        }
        var decks = [Deck]()
        var otherDecks = [Deck]()
        for deck in deckStore.deckStore {
            if deck.deck.count == 0 {
                continue
            }
            let newDeck = Deck(name: deck.name)
            newDeck.time = deck.time
            let d = Deck(name: deck.name)
            d.newCardsToday = deck.newCardsToday
            for card in deck.deck {
                d.addCard(card)
            }
            if d.name != "Welcome to Vocabuildary!" {
                d.shuffle()
            }
            let userDefaultsNewCards = NSUserDefaults.standardUserDefaults().objectForKey("newCards") as! Int
            if newCardsToShow != userDefaultsNewCards {
                for card in d.deck {
                    if card.numberOfViews == 0 {
                        card.date = NSDate().today
                    }
                }
            }
            for card in d.deck {
                if NSDate().compare(card.date) != .OrderedAscending {
                    if card.numberOfViews == 0 {
                        if d.newCardsToday < NSUserDefaults.standardUserDefaults().objectForKey("newCards") as! Int {
                            newDeck.addCard(card)
                            d.newCardsToday+=1
                        }
                    } else {
                        newDeck.addCard(card)
                    }
                } else {
                    if card.numberOfViews == 0 {
                        let nextDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: NSDate().today, options: NSCalendarOptions.init(rawValue: 0))
                        card.date = nextDate!
                    }
                }
            }
            if newDeck.deck.count > 0 {
                decks.append(newDeck)
            } else {
                otherDecks.append(newDeck)
            }
        }
        self.decks = decks+otherDecks
    }
    
    //MARK: TableView methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TodayCell", forIndexPath: indexPath) as! TodayCell
        cell.deckName.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        cell.deckName.text = decks[indexPath.row].name
        let cardsInDeck = decks[indexPath.row].whatCards
        cell.newCards.text = String(cardsInDeck[0])
        cell.repeatingCards.text = String(cardsInDeck[1])
        cell.problematicCards.text = String(cardsInDeck[2])
        if cardsInDeck == [0, 0, 0] {
            cell.newCards.textColor = UIColor.grayColor()
            cell.repeatingCards.textColor = UIColor.grayColor()
            cell.problematicCards.textColor = UIColor.grayColor()
        } else {
            cell.newCards.textColor = UIColor(red: 0.2, green: 0.6, blue: 0, alpha: 1)
            cell.repeatingCards.textColor = blueThemeColor()
            cell.problematicCards.textColor = UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)
        }
        return cell
    }
    
    //MARK: Segues and 3D Touch
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        //self.performSegueWithIdentifier("exit", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let row = tableView.indexPathForSelectedRow?.row {
            //Get the item associated with this row and pass it along
            let deck = decks[row]
            let beforeLearningViewController = segue.destinationViewController as! BeforeLearningViewController
            beforeLearningViewController.deck = deck
            beforeLearningViewController.deckInDeckStore = deckStore.deckWithName(deck.name)
            beforeLearningViewController.deckStore = deckStore
        }
    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRowAtPoint(location) else {return nil}
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else {return nil}
        
        guard let beforeLearningViewController = storyboard?.instantiateViewControllerWithIdentifier("BeforeLearningViewController") as? BeforeLearningViewController else {return nil}
        beforeLearningViewController.deck = decks[indexPath.row]
        beforeLearningViewController.deckInDeckStore = deckStore.deckWithName(decks[indexPath.row].name)
        beforeLearningViewController.deckStore = deckStore
        previewingContext.sourceRect = cell.frame
        
        return beforeLearningViewController
    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    //MARK: - View customization
    
    override func viewDidLoad() {
        newCardsToShow = NSUserDefaults.standardUserDefaults().objectForKey("newCards") as! Int
        if( traitCollection.forceTouchCapability == .Available){
            registerForPreviewingWithDelegate(self, sourceView: view)
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
        
        searchForCards()
        
        navigationController?.navigationItem.backBarButtonItem?.title = "Back"
        navigationItem.backBarButtonItem?.title = ""
        
        let blueView = UIView()
        let blueRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        blueView.frame = blueRect
        blueView.center = CGPointMake(self.view.frame.size.width/2,-self.view.frame.size.height/2)
        blueView.backgroundColor = blueThemeColor()
        self.view.addSubview(blueView)
        
        let lineView = UIView(frame: CGRectMake(0,self.navigationController!.navigationBar.frame.size.height,self.view.frame.size.width,1))
        lineView.backgroundColor = blueThemeColor()
        self.navigationController?.navigationBar.addSubview(lineView)
        
        let bounds = informationView.bounds as CGRect!
        let infoView = UIView()
        infoView.frame = bounds
        infoView.backgroundColor = blueThemeColor()
        informationView.addSubview(infoView)
        informationView.sendSubviewToBack(infoView)
        let lineView1 = UIView()
        lineView1.frame = CGRectMake((self.view.frame.size.width-16)/3+8, infoView.frame.size.height/6+3, 0.5, infoView.frame.size.height*3/6)
        lineView1.backgroundColor = UIColor.whiteColor()
        informationView.addSubview(lineView1)
        let lineView2 = UIView()
        lineView2.frame = CGRectMake((self.view.frame.size.width-16)/3*2+8, infoView.frame.size.height/6+3, 0.5, infoView.frame.size.height*3/6)
        lineView2.backgroundColor = UIColor.whiteColor()
        informationView.addSubview(lineView2)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TodayTableViewController.appBecomeActive), name: UIApplicationWillEnterForegroundNotification, object: nil )
    }
    func appBecomeActive() {
        //call viewDidAppear when the app becomes active
        viewDidAppear(true)
    }
    override func viewDidAppear(animated: Bool) {
        searchForCards()
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