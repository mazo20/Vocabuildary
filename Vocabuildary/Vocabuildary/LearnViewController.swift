//
//  LearningViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 04.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class LearnViewController: UIViewController {
    
    var deck: Deck!
    var deckInDeckStore: Deck!
    var answer = 0
    var deckHistory = DeckHistory()
    var timer = NSTimer()
    
    @IBOutlet var checkButton: UIButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var secondStackView: UIStackView!
    @IBOutlet var backCardLabel: UILabel!
    @IBOutlet var frontCardLabel: UILabel!
    @IBOutlet var hardButton: UIButton!
    @IBOutlet var repeatButton: UIButton!
    @IBOutlet var easyButton: UIButton!
    @IBOutlet var line: UIView!
    
    @IBOutlet var problematicCards: UILabel!
    @IBOutlet var repeatingCards: UILabel!
    @IBOutlet var newCards: UILabel!
    
    var cards = [0,0,0]
    var i = 0
    let layer = CAShapeLayer()
    let layer1 = CAShapeLayer()
    
    @IBAction func repeatAnswerButton(sender: AnyObject) {
        answer = 0
        deckHistory.answers[0]+=1
        answerGiven()
    }
    @IBAction func hardAnswerButton(sender: AnyObject) {
        answer = 1
        deckHistory.answers[1]+=1
        answerGiven()
    }
    @IBAction func easyAnswetButton(sender: AnyObject) {
        answer = 2
        deckHistory.answers[2]+=1
        answerGiven()
    }
    @IBAction func showAnswerButton(sender: AnyObject) {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.18
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        layer.hidden = false
        layer1.hidden = false
        layer.addAnimation(pathAnimation, forKey: "strokeEnd")
        layer1.addAnimation(pathAnimation, forKey: "strokeEnd")
        stackView.hidden = true
        secondStackView.hidden = false
        if deck.deck[i].n == 0 {
            hardButton.hidden = true
        }
        UIView.animateWithDuration(0.2, animations: {
            self.backCardLabel.hidden = false
        })
    }
    func answerGiven() {
        hardButton.hidden = false
        layer.hidden = true
        layer1.hidden = true
        stackView.hidden = false
        secondStackView.hidden = true
        backCardLabel.hidden = true
        
        if i < deck.deck.count {    //i = number of card in the deck array
            spacedRepetitionAlgorithm(answer)    //calls the algorithm to determine whether to repeat the card or calculate next date
            i+=1    //card already shown and calculated, time to show next card
            if i < deck.deck.count {  //checks if there is next card to show; the algorithm might have added new card to appear
                if deck.deck[i].reversed {
                    let random = arc4random_uniform(2)
                    if random == 0 {    //randomizes between front and back cards if user opted for it in the settings
                        frontCardLabel.text = deck.deck[i].frontCard
                        backCardLabel.text = deck.deck[i].backCard
                    } else {
                        frontCardLabel.text = deck.deck[i].backCard
                        backCardLabel.text = deck.deck[i].frontCard
                    }
                } else {
                    frontCardLabel.text = deck.deck[i].frontCard
                    backCardLabel.text = deck.deck[i].backCard
                }
            }
        }
        if i >= deck.deck.count {   //if there are no cards to show, perform unwind segue
            self.performSegueWithIdentifier("exit", sender: self)
        }
    }
    func spacedRepetitionAlgorithm(answer: Int) {
        let card = deck.deck[i]
        if card.n == 0 {
            if card.Q < 1.5 {
                cards[2]-=1
            } else {
                cards[0]-=1
            }
        } else if card.Q < 1.5 {
            cards[2]-=1
        } else {
            cards[1]-=1
        }
        
        let a = Double(2-answer)
        if deck.priority == 0 {
            card.Q += (0.1 - a * (0.3 + a * 0.1))
            if card.Q < 1.3 {
                card.Q = 1.3
            }
        } else {
            card.Q += (0.05 - a * (0.4 + a * 0.1))
            if card.Q < 1.2 {
                card.Q = 1.2
            }
        }
        
        card.date = NSDate().today
        
        if answer == 0 {    // if user forgot the card show it again in a few minutes
            let d = deck.deck.count
            var random = Int(arc4random_uniform(UInt32(d-i)))
            if random < 2 && i+random+3 < d {
                random+=2
            }
            if card.Q < 1.5 {
                cards[2]+=1
            } else {
                cards[1]+=1
            }
            deck.deck.insert(card, atIndex: i+random+1)
        } else if card.n == 0 {     //if the card was shown for the first time repeat it in a few minutes to improve remembering
            deckInDeckStore.newCardsToday+=1
            let d = deck.deck.count
            var random = Int(arc4random_uniform(UInt32(d-i)))
            if random < 2 && i+random+3 < d {
                random+=2
            }
            if card.Q < 1.5 {
                cards[2]+=1
            } else {
                cards[1]+=1
            }
            deck.deck.insert(card, atIndex: i+Int(random)+1)
            card.n+=1   //increases the number of times the card was shown
            card.days.append(1)     //adds next day == 1 to ensure that the next day can be calculated
        } else {    //calculates the next date
            
            if card.days[card.n-1] > 1000 {
                card.days[card.n-1] = 1000
            }
            var nextDay = Int(Double(card.days[card.n-1])*card.Q)     //next day to show the card
            if nextDay == card.days[card.n-1] {   //make sure the next day increased at least by 1
                nextDay+=1
            }
            if NSDate().compare(card.date) != .OrderedAscending {
                let nextDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: nextDay - card.days[card.n-1], toDate: card.date, options: NSCalendarOptions.init(rawValue: 0))   //increases the date
                card.date = nextDate!
            } else {
                let nextDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: nextDay - card.days[card.n-1], toDate: NSDate().today, options: NSCalendarOptions.init(rawValue: 0))   //increases the date
                card.date = nextDate!
            }
            
            card.days.append(nextDay) //adds that date to the array
            card.n+=1   //increases the number of times the card was shown
            deckHistory.numberOfCards+=1
        }
        newCards.text = String(cards[0])
        repeatingCards.text = String(cards[1])
        problematicCards.text = String(cards[2])
        
    }
    func drawLine() {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(self.view.center.x, 2))
        path.addLineToPoint(CGPointMake(10, 2))
        let path1 = UIBezierPath()
        path1.moveToPoint(CGPointMake(self.view.center.x, 2))
        path1.addLineToPoint(CGPointMake(self.view.bounds.width-26, 2))
        
        layer.frame = line.bounds
        layer.path = path.CGPath
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.lineWidth = 3
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinBevel
        line.layer.insertSublayer(layer, atIndex: 1)
        
        layer1.frame = line.bounds
        layer1.path = path1.CGPath
        layer1.strokeColor = UIColor.blackColor().CGColor
        layer1.lineWidth = 3
        layer1.lineCap = kCALineCapRound
        layer1.lineJoin = kCALineJoinBevel
        line.layer.insertSublayer(layer1, atIndex: 1)
        
        layer.hidden = true
        layer1.hidden = true
    }
    @IBAction func unwindSegue(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("exit", sender: self)
    }
    override func viewWillAppear(animated: Bool) {
        //Hide the tab bar controller
        self.tabBarController?.tabBar.hidden = true
        
        stackView.hidden = false
        secondStackView.hidden = true
        backCardLabel.hidden = true
        
        self.navigationController?.navigationBar.hidden = false
        checkButton.layer.cornerRadius = 5
        hardButton.layer.cornerRadius = 5
        repeatButton.layer.cornerRadius = 5
        easyButton.layer.cornerRadius = 5
        
        UIView.animateWithDuration(0.2, animations: {
            var center = button.center
            center.y += 100
            button.center = center
            button.alpha = 0
        })
    }
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        
        var hasHistory = false
        if deckInDeckStore.history.count > 0 {
            let date = deckInDeckStore.history[deckInDeckStore.history.count-1].date
            if date == stringFromDate(NSDate()) {
                deckHistory = deckInDeckStore.history[deckInDeckStore.history.count-1]
            } else {
                let dateComponents = date.componentsSeparatedByString("-")
                let todayComponents = stringFromDate(NSDate().today).componentsSeparatedByString("-")
                if todayComponents[0] > dateComponents[0] {
                    deckInDeckStore.history.append(deckHistory)
                    hasHistory = true
                } else if todayComponents[0] == dateComponents[0] && todayComponents[1] > dateComponents[1] {
                    deckInDeckStore.history.append(deckHistory)
                    hasHistory = true
                } else if todayComponents[0] == dateComponents[0] && todayComponents[1] == dateComponents[1] && todayComponents[2] > dateComponents[2] {
                    deckInDeckStore.history.append(deckHistory)
                    hasHistory = true
                }
                if !hasHistory {
                    if let history = deckInDeckStore.historyForDate(stringFromDate(NSDate())) {
                        deckHistory = history
                    } else {
                        for history in deckInDeckStore.history {
                            if todayComponents[0] < dateComponents[0] {
                                let index = deckInDeckStore.history.indexOf(history)!
                                deckInDeckStore.history.insert(deckHistory, atIndex: index)
                            } else if todayComponents[0] == dateComponents[0] && todayComponents[1] < dateComponents[1] {
                                let index = deckInDeckStore.history.indexOf(history)!
                                deckInDeckStore.history.insert(deckHistory, atIndex: index)
                            } else if todayComponents[0] == dateComponents[0] && todayComponents[1] == dateComponents[1] && todayComponents[2] < dateComponents[2] {
                                let index = deckInDeckStore.history.indexOf(history)!
                                deckInDeckStore.history.insert(deckHistory, atIndex: index)
                            }
                        }
                    }
                }
            }
        } else {
            deckInDeckStore.history.append(deckHistory)
        }
    }
    override func viewWillDisappear(animated: Bool) {
        //Show again the view controller when leaving
        self.tabBarController?.tabBar.hidden = false
        
        UIView.animateWithDuration(0.2, animations: {
            var center = button.center
            center.y -= 100
            button.center = center
            button.alpha = 1
        })
        self.view.layoutIfNeeded()
        timer.invalidate()
        if deckHistory.numberOfCards == 0 {
            let index = deckInDeckStore.history.indexOf(deckHistory)
            deckInDeckStore.history.removeAtIndex(index!)
        }
    }
    override func viewDidLoad() {
        for card in deck.deck {
            whatCard(card)
        }
        dump(deck)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(LearnViewController.timerDidEnd(_:)), userInfo: nil, repeats: true)
        newCards.text = String(cards[0])
        repeatingCards.text = String(cards[1])
        problematicCards.text = String(cards[2])
        if deck.name != "Welcome to Vocabuildary!" {
            deck.shuffle()
        }
        drawLine()
        super.viewDidLoad()
        self.title = deck.name
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(LearnViewController.unwindSegue(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        frontCardLabel.text = deck.deck[0].frontCard
        backCardLabel.text = deck.deck[0].backCard
    }
    func timerDidEnd(timer: NSTimer) {
        deckHistory.time+=1
    }
    func whatCard(card: Card) {
        if card.n == 0 {
            cards[0]+=1
        } else if card.Q < 1.5 {
            cards[2]+=1
        } else {
            cards[1]+=1
        }
    }
}
