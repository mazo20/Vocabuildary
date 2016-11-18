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
    var cards = [Card]()
    var timer = Timer()
    var cardTimeInterval: TimeInterval = 0
    
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
    
    var cardsLeftToLearn = [Int]()
    var i = 0
    let layer = CAShapeLayer()
    let layer1 = CAShapeLayer()
    
    @IBAction func repeatAnswerButton(_ sender: AnyObject) {
        answerGiven(0)
    }
    @IBAction func hardAnswerButton(_ sender: AnyObject) {
        answerGiven(1)
    }
    @IBAction func easyAnswetButton(_ sender: AnyObject) {
        answerGiven(2)
    }
    @IBAction func showAnswerButton(_ sender: AnyObject) {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.18
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        layer.isHidden = false
        layer1.isHidden = false
        layer.add(pathAnimation, forKey: "strokeEnd")
        layer1.add(pathAnimation, forKey: "strokeEnd")
        stackView.isHidden = true
        secondStackView.isHidden = false
        if deck.cards[i].days.count == 0 { hardButton.isHidden = true }
        UIView.animate(withDuration: 0.2, animations: {
            self.backCardLabel.isHidden = false
        })
    }
    func answerGiven(_ answer: Int) {
        hardButton.isHidden = false
        layer.isHidden = true
        layer1.isHidden = true
        stackView.isHidden = false
        secondStackView.isHidden = true
        backCardLabel.isHidden = true
        
        let card = cards[0]
        if answer == 0 || card.status == .new {
            let deckSize = cards.count
            var random = Int(arc4random_uniform(UInt32(deckSize)))
            if random < 2 && random+3 < deckSize {
                random+=2
            }
            cards.insert(card, at: random+1)
            if card.status == .new { deck.newCardsToday+=1 }
        }
        
        let cardAnswer = Answer(answer: answer, time: cardTimeInterval, date: Date())
        card.answerGiven(answer: cardAnswer)
        cardTimeInterval = 0
        cards.remove(at: 0)
        
        cardsLeftToLearn = deck.whatCards(cards)
        newCards.text = String(cardsLeftToLearn[0])
        repeatingCards.text = String(cardsLeftToLearn[1])
        problematicCards.text = String(cardsLeftToLearn[2])
        
        
        if i < cards.count {
            if deck.cards[0].isReversed && arc4random_uniform(2) == 0 {
                frontCardLabel.text = cards[0].backCard
                backCardLabel.text = cards[0].frontCard
            } else {
                frontCardLabel.text = cards[0].frontCard
                backCardLabel.text = cards[0].backCard
            }
        } else {
            self.performSegue(withIdentifier: "exit", sender: self)
        }
    }
    
    func timerDidEnd(_ timer: Timer) {
        cardTimeInterval+=1
    }
    
    @IBAction func unwindSegue(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide the tab bar controller
        self.tabBarController?.tabBar.isHidden = true
        
        stackView.isHidden = false
        secondStackView.isHidden = true
        backCardLabel.isHidden = true
        
        self.navigationController?.navigationBar.isHidden = false
        checkButton.layer.cornerRadius = 5
        hardButton.layer.cornerRadius = 5
        repeatButton.layer.cornerRadius = 5
        easyButton.layer.cornerRadius = 5
        
        UIView.animate(withDuration: 0.2, animations: {
            var center = button.center
            center.y += 100
            button.center = center
            button.alpha = 0
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            var center = button.center
            center.y -= 100
            button.center = center
            button.alpha = 1
        })
        self.view.layoutIfNeeded()
        timer.invalidate()
        deck.extraCards = [Card]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cards = deck.extraCards.count > 0 ? deck.extraCards : deck.cardsForToday
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LearnViewController.timerDidEnd(_:)), userInfo: nil, repeats: true)
        
        cardsLeftToLearn = deck.whatCards(cards)
        newCards.text = String(cardsLeftToLearn[0])
        repeatingCards.text = String(cardsLeftToLearn[1])
        problematicCards.text = String(cardsLeftToLearn[2])
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.view.center.x, y: 2))
        path.addLine(to: CGPoint(x: 10, y: 2))
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: self.view.center.x, y: 2))
        path1.addLine(to: CGPoint(x: self.view.bounds.width-26, y: 2))
        
        layer.frame = line.bounds
        layer.path = path.cgPath
        layer.strokeColor = UIColor.black.cgColor
        layer.lineWidth = 3
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinBevel
        line.layer.insertSublayer(layer, at: 1)
        
        layer1.frame = line.bounds
        layer1.path = path1.cgPath
        layer1.strokeColor = UIColor.black.cgColor
        layer1.lineWidth = 3
        layer1.lineCap = kCALineCapRound
        layer1.lineJoin = kCALineJoinBevel
        line.layer.insertSublayer(layer1, at: 1)
        
        layer.isHidden = true
        layer1.isHidden = true
        
        self.title = deck.name
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(LearnViewController.unwindSegue(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        frontCardLabel.text = cards[0].frontCard
        backCardLabel.text = cards[0].backCard
        frontCardLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        backCardLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
}
