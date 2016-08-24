//
//  LearnViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 03.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class BeforeLearningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //MARK: Properties
    
    var deck: Deck!
    var deckInDeckStore: Deck!
    var deckStore: DeckStore!
    var cards = [0, 0, 0]
    var extraCards = [0, 0]
    var newCardsLabel = UILabel()
    var repeatCardsLabel = UILabel()
    var totalDeckTime: NSTimeInterval = 0
    var averageTime: NSTimeInterval = 0
    var timeLabel: UILabel!
    
    //MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var problematicCards: UILabel!
    @IBOutlet var repeatingCards: UILabel!
    @IBOutlet var newCards: UILabel!
    @IBOutlet var chartView: ChartView!
    @IBOutlet var studyButton: UIButton!
    
    //MARK: Actions
    
    @IBAction func studyButton(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.performSegueWithIdentifier("ShowLearnViewController", sender: self)
        } else {
            guard extraCards[0] > 0 || extraCards[1] > 0 else {return}
            deckInDeckStore.shuffle()
            deck = Deck(name: deckInDeckStore.name)
            var newCardsToLearn = 0
            var cardsToRepeat = 0
            for card in deckInDeckStore.deck {
                if newCardsToLearn < extraCards[0] {
                    if card.n == 0 {
                        deck.addCard(card)
                        newCardsToLearn+=1
                    }
                }
                if cardsToRepeat < extraCards[1] {
                    if card.n != 0 {
                        deck.addCard(card)
                        cardsToRepeat+=1
                    }
                }
                if newCardsToLearn == extraCards[0] && cardsToRepeat == extraCards[1] {
                    break
                }
            }
            self.performSegueWithIdentifier("ShowLearnViewController", sender: self)
        }
    }
    @IBAction func segmentedControlUpdateView(sender: AnyObject) {
        tableView.reloadData()
        chartView.setNeedsDisplay()
    }
    
    //MARK: - TableView methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("numberOfCardsCell", forIndexPath: indexPath) as! CardsNumberCell
                cell.newCards.text = String(cards[0])
                cell.repeatingCards.text = String(cards[1])
                cell.problematicCards.text = String(cards[2])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("chartViewCell", forIndexPath: indexPath) as! ChartViewCell
                cell.chartView.deck = deckInDeckStore
                cell.chartView.chartType = .Learn
                cell.chartView.numberOfLines = 7
                cell.chartView.cardsToLearn = cards[0] + cards[1] + cards[2]
                chartView = cell.chartView
                return cell
            default:
                var repeats = 0
                for history in deckInDeckStore.history {
                    repeats+=history.numberOfCards
                }
                var expectedTime: NSTimeInterval = 0
                if repeats == 0 || totalDeckTime == 0 {
                    expectedTime = Double(cards[0]+cards[1]+cards[2])*10
                } else {
                    expectedTime = totalDeckTime/Double(repeats)*Double(cards[0]+cards[1]+cards[2])
                }
                let cell = tableView.dequeueReusableCellWithIdentifier("textCell", forIndexPath: indexPath)
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Expected time"
                    cell.textLabel?.textColor = UIColor.whiteColor()
                    cell.detailTextLabel?.text = timeFormatter(expectedTime)
                    cell.detailTextLabel?.textColor = UIColor.lightTextColor()
                    return cell
                case 1:
                    cell.textLabel?.text = "Average time for this deck"
                    cell.textLabel?.textColor = UIColor.whiteColor()
                    cell.detailTextLabel?.text = timeFormatter(averageTime)
                    cell.detailTextLabel?.textColor = UIColor.lightTextColor()
                    return cell
                default:
                    cell.textLabel?.text = "Total time for this deck"
                    cell.textLabel?.textColor = UIColor.whiteColor()
                    cell.detailTextLabel?.text = timeFormatter(totalDeckTime)
                    cell.detailTextLabel?.textColor = UIColor.lightTextColor()
                    return cell
                }
            }
        } else {
            switch indexPath.section {
            case 0:
                var new = 0
                for card in deckInDeckStore.deck {
                    if card.n == 0 {
                        new+=1
                    }
                }
                let cell = tableView.dequeueReusableCellWithIdentifier("numberCell", forIndexPath: indexPath) as! SliderCell
                cell.titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.numberLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.titleLabel.textColor = UIColor.whiteColor()
                if indexPath.row == 0 {
                    cell.titleLabel?.text = "New cards to learn"
                    cell.slider.addTarget(self, action: #selector(BeforeLearningViewController.sliderChanged(_:)), forControlEvents: .ValueChanged)
                    cell.slider.tag = 1
                    newCardsLabel = cell.numberLabel
                    newCardsLabel.textColor = UIColor.lightTextColor()
                    cell.slider.maximumValue = Float(new)
                    cell.slider.minimumValue = 0
                    let newCards = NSUserDefaults.standardUserDefaults().objectForKey("newCards") as! Int
                    if new == 0 {
                        cell.slider.alpha = 0.7
                        newCardsLabel.text = "0"
                    } else if new >= newCards {
                        cell.slider.value = Float(newCards)
                        extraCards[0] = newCards
                        newCardsLabel.text = "\(newCards)"
                    } else {
                        cell.slider.value = Float(new)
                        extraCards[0] = new
                        newCardsLabel.text = String(new)
                    }
                } else {
                    let repeats = deckInDeckStore.deck.count-new
                    cell.titleLabel?.text = "Cards to repeat"
                    cell.slider.addTarget(self, action: #selector(BeforeLearningViewController.sliderChanged(_:)), forControlEvents: .ValueChanged)
                    cell.slider.tag = 2
                    repeatCardsLabel = cell.numberLabel
                    repeatCardsLabel.textColor = UIColor.lightTextColor()
                    cell.slider.maximumValue = Float(repeats)
                    cell.slider.minimumValue = 0
                    if repeats == 0 {
                        cell.slider.alpha = 0.7
                        repeatCardsLabel.text = "0"
                    } else if repeats >= 10 {
                        cell.slider.value = 10
                        extraCards[1] = 10
                        repeatCardsLabel.text = "10"
                    } else {
                        cell.slider.value = Float(repeats)
                        extraCards[1] = repeats
                        repeatCardsLabel.text = String(repeats)
                    }
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("chartViewCell", forIndexPath: indexPath) as! ChartViewCell
                cell.chartView.deck = deckInDeckStore
                cell.chartView.numberOfLines = 7
                cell.chartView.chartType = .Learn
                cell.chartView.cardsToLearn = extraCards[0] + extraCards[1]
                chartView = cell.chartView
                return cell
            default:
                var repeats = 0
                for history in deckInDeckStore.history {
                    repeats+=history.numberOfCards
                }
                var expectedTime: NSTimeInterval = 0
                if repeats == 0 || totalDeckTime == 0 {
                    expectedTime = Double(extraCards[0]+extraCards[1])*10
                } else {
                    expectedTime = totalDeckTime/Double(repeats)*Double(extraCards[0]+extraCards[1])
                }
                let cell = tableView.dequeueReusableCellWithIdentifier("textCell", forIndexPath: indexPath)
                cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.detailTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.detailTextLabel?.textColor = UIColor.lightTextColor()
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Expected time"
                    cell.detailTextLabel?.text = timeFormatter(expectedTime)
                    timeLabel = cell.detailTextLabel
                    return cell
                case 1:
                    cell.textLabel?.text = "Average time for this deck"
                    cell.detailTextLabel?.text = timeFormatter(averageTime)
                    return cell
                default:
                    cell.textLabel?.text = "Total time for this deck"
                    cell.detailTextLabel?.text = timeFormatter(totalDeckTime)
                    return cell
                }
            }
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            switch section {
            case 0,1:
                return 1
            default:
                return 3
            }
        } else {
            switch section {
            case 0:
                return 2
            case 1:
                return 1
            default:
                return 3
            }
        }
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0000001
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 0 {
            switch indexPath.section {
            case 0:
                return 152
            case 1:
                return 200
            default:
                return 44
            }
        } else {
            switch indexPath.section {
            case 0:
                return 76
            case 1:
                return 200
            default:
                return 44
            }
        }
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowLearnViewController" {
            let learnViewController = segue.destinationViewController as! LearnViewController
            learnViewController.deck = deck
            learnViewController.deckInDeckStore = deckInDeckStore
        }
    }
    func sliderChanged(sender: UISlider) {
        if sender.tag == 1 {
            if newCardsLabel.text != String(Int(sender.value)) {
                newCardsLabel.text = String(Int(sender.value))
                extraCards[0] = Int(sender.value)
                chartView.cardsToLearn = extraCards[0] + extraCards[1]
                chartView.setNeedsDisplay()
            }
        } else if sender.tag == 2 {
            if repeatCardsLabel.text != String(Int(sender.value)) {
                repeatCardsLabel.text = String(Int(sender.value))
                extraCards[1] = Int(sender.value)
                chartView.cardsToLearn = extraCards[0] + extraCards[1]
                chartView.setNeedsDisplay()
            }
        }
        var repeats = 0
        for history in deckInDeckStore.history {
            repeats+=history.numberOfCards
        }
        var expectedTime: NSTimeInterval = 0
        if repeats == 0 || totalDeckTime == 0 {
            expectedTime = Double(extraCards[0]+extraCards[1])*10
        } else {
            expectedTime = totalDeckTime/Double(repeats)*Double(extraCards[0]+extraCards[1])
        }
        timeLabel.text = timeFormatter(expectedTime)
    }
    
    func totalTime() -> NSTimeInterval {
        var time = NSTimeInterval()
        for history in deckInDeckStore.history {
            time+=history.time
        }
        return time
    }
    
    
    //MARK: - View customization
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        UIView.animateWithDuration(0.2, animations: {
            var center = button.center
            center.y += 100
            button.center = center
            button.alpha = 0
        })
    }
    override func viewWillDisappear(animated: Bool) {
        //Reseting the navigation controller when leaving this view
        self.tabBarController?.tabBar.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            var center = button.center
            center.y -= 100
            button.center = center
            button.alpha = 1
        })
    }
    override func viewDidLoad() {
        tableView.reloadData()
        tableView.backgroundColor = UIColor.clearColor()
        self.title = deck.name
        
        for card in deck.deck {
            if card.n == 0 {
                cards[0]+=1
            } else if card.Q < 1.5 {
                cards[2]+=1
            } else {
                cards[1]+=1
            }
        }
        
        //If there are no more cards scheduled for today show only second tab in segmentedControl
        if  deck.deck.count == 0 {
            segmentedControl.setEnabled(false, forSegmentAtIndex: 0)
            segmentedControl.selectedSegmentIndex = 1
        }
        totalDeckTime = totalTime()
        if deckInDeckStore.history.count != 0 {
            averageTime = totalDeckTime/NSTimeInterval(deckInDeckStore.history.count)
        }
        
        let normalBlue = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
        let lighterBlue = UIColor(red: 0, green: 0.8, blue: 1, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.colors = [normalBlue.CGColor, lighterBlue.CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.95)
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        studyButton.layer.cornerRadius = 5
    }
}