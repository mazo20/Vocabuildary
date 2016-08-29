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
    
    var cardsLeftToLearn: [Int]!
    var i = 0
    let layer = CAShapeLayer()
    let layer1 = CAShapeLayer()
    
    @IBAction func repeatAnswerButton(sender: AnyObject) {
        deckHistory.answers[0]+=1
        answerGiven(0)
    }
    @IBAction func hardAnswerButton(sender: AnyObject) {
        deckHistory.answers[1]+=1
        answerGiven(1)
    }
    @IBAction func easyAnswetButton(sender: AnyObject) {
        deckHistory.answers[2]+=1
        answerGiven(2)
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
        if deck.deck[i].numberOfViews == 0 {
            hardButton.hidden = true
        }
        UIView.animateWithDuration(0.2, animations: {
            self.backCardLabel.hidden = false
        })
    }
    func answerGiven(answer: Int) {
        hardButton.hidden = false
        layer.hidden = true
        layer1.hidden = true
        stackView.hidden = false
        secondStackView.hidden = true
        backCardLabel.hidden = true
        
        spacedRepetitionAlgorithm(answer)
        i+=1
        
        if i < deck.deck.count {
            if deck.deck[i].isReversed && arc4random_uniform(2) == 0 {
                frontCardLabel.text = deck.deck[i].backCard
                backCardLabel.text = deck.deck[i].frontCard
            } else {
                frontCardLabel.text = deck.deck[i].frontCard
                backCardLabel.text = deck.deck[i].backCard
            }
        } else {
            self.performSegueWithIdentifier("exit", sender: self)
        }
    }
    func spacedRepetitionAlgorithm(answer: Int) {
        let card = deck.deck[i]
        
        if card.Q < 1.5 {
            cardsLeftToLearn[2]-=1
        } else if card.numberOfViews == 0 {
            cardsLeftToLearn[0]-=1
        } else {
            cardsLeftToLearn[1]-=1
        }
        
        let a = Double(2-answer)
        if deckInDeckStore.priority == 0 {
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
        
        if answer == 0 || card.numberOfViews == 0 {
            let deckSize = deck.deck.count
            var random = Int(arc4random_uniform(UInt32(deckSize-i)))
            if random < 2 && i+random+3 < deckSize {
                random+=2
            }
            if card.Q < 1.5 {
                cardsLeftToLearn[2]+=1
            } else {
                cardsLeftToLearn[1]+=1
            }
            deck.deck.insert(card, atIndex: i+random+1)
            if answer != 0 {
                deckInDeckStore.newCardsToday+=1
                card.numberOfViews+=1
                card.days.append(1)
            }
        } else {
            if card.days[card.numberOfViews-1] > 1000 {
                card.days[card.numberOfViews-1] = 1000
            }
            var nextDay = Int(Double(card.days[card.numberOfViews-1])*card.Q)
            if nextDay == card.days[card.numberOfViews-1] {
                nextDay+=1
            }
            card.date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: nextDay - card.days[card.numberOfViews-1], toDate: card.date, options: NSCalendarOptions.init(rawValue: 0))!
            
            card.days.append(nextDay)
            card.numberOfViews+=1
            deckHistory.numberOfCards+=1
        }
        newCards.text = String(cardsLeftToLearn[0])
        repeatingCards.text = String(cardsLeftToLearn[1])
        problematicCards.text = String(cardsLeftToLearn[2])
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
        if let history = deckInDeckStore.historyForDate(stringFromDate(NSDate())) {
            deckHistory = history
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
        super.viewDidLoad()
        
        cardsLeftToLearn = deck.whatCards
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(LearnViewController.timerDidEnd(_:)), userInfo: nil, repeats: true)
        newCards.text = String(cardsLeftToLearn[0])
        repeatingCards.text = String(cardsLeftToLearn[1])
        problematicCards.text = String(cardsLeftToLearn[2])
        if deck.name != "Welcome to Vocabuildary!" {
            deck.shuffle()
        }
        drawLine()
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
}
