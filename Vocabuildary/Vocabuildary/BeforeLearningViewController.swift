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
    var numberOfScheduledCardsTypes = [0, 0, 0]
    var numberOfExtraCards = [0, 0]
    var newCardsLabel = UILabel()
    var repeatCardsLabel = UILabel()
    var totalTimeSpentInDeck: NSTimeInterval = 0
    var averageTimeSpentPerDay: NSTimeInterval = 0
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
        //If "Study" button was pressed when first tab was selected perform segue with already chosen cards
        if segmentedControl.selectedSegmentIndex == 0 {
            self.performSegueWithIdentifier("ShowLearnViewController", sender: self)
        //Otherwise find requested number of new cards and repeats and fetch them to new View Controller
        } else {
            //If no extra cards were picked just return
            guard numberOfExtraCards[0] > 0 || numberOfExtraCards[1] > 0 else {return}
            //Shuffle a deck to randomize the cards
            let deckCopy = deckInDeckStore
            deckCopy.shuffle()
            deck = Deck(name: deckInDeckStore.name)
            var newCardsToLearn = 0
            var cardsToRepeat = 0
            for card in deckCopy.deck {
                if newCardsToLearn < numberOfExtraCards[0] && card.n == 0{
                    deck.addCard(card)
                    newCardsToLearn+=1
                } else if cardsToRepeat < numberOfExtraCards[1] && card.n != 0 {
                    deck.addCard(card)
                    cardsToRepeat+=1
                }
                //If exact number of cards was found break the loop
                if newCardsToLearn == numberOfExtraCards[0] && cardsToRepeat == numberOfExtraCards[1] {
                    break
                }
            }
            self.performSegueWithIdentifier("ShowLearnViewController", sender: self)
        }
    }
    @IBAction func segmentedControlUpdateView(sender: AnyObject) {
        //Reload the data when tabs change
        tableView.reloadData()
        chartView.setNeedsDisplay()
    }
    
    //MARK: - TableView methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("numberOfCardsCell", forIndexPath: indexPath) as! CardsNumberCell
                cell.newCards.text = String(numberOfScheduledCardsTypes[0])
                cell.repeatingCards.text = String(numberOfScheduledCardsTypes[1])
                cell.problematicCards.text = String(numberOfScheduledCardsTypes[2])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("chartViewCell", forIndexPath: indexPath) as! ChartViewCell
                cell.chartView.deck = deckInDeckStore
                cell.chartView.chartType = .Learn
                cell.chartView.numberOfLines = 7
                cell.chartView.cardsToLearn = numberOfScheduledCardsTypes[0] + numberOfScheduledCardsTypes[1] + numberOfScheduledCardsTypes[2]
                chartView = cell.chartView
                return cell
            default:
                var repeats = 0
                for history in deckInDeckStore.history {
                    repeats+=history.numberOfCards
                }
                var expectedTime: NSTimeInterval = 0
                if repeats == 0 || totalTimeSpentInDeck == 0 {
                    expectedTime = Double(numberOfScheduledCardsTypes[0]+numberOfScheduledCardsTypes[1]+numberOfScheduledCardsTypes[2])*10
                } else {
                    expectedTime = totalTimeSpentInDeck/Double(repeats)*Double(numberOfScheduledCardsTypes[0]+numberOfScheduledCardsTypes[1]+numberOfScheduledCardsTypes[2])
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
                    cell.detailTextLabel?.text = timeFormatter(averageTimeSpentPerDay)
                    cell.detailTextLabel?.textColor = UIColor.lightTextColor()
                    return cell
                default:
                    cell.textLabel?.text = "Total time for this deck"
                    cell.textLabel?.textColor = UIColor.whiteColor()
                    cell.detailTextLabel?.text = timeFormatter(totalTimeSpentInDeck)
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
                        numberOfExtraCards[0] = newCards
                        newCardsLabel.text = "\(newCards)"
                    } else {
                        cell.slider.value = Float(new)
                        numberOfExtraCards[0] = new
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
                        numberOfExtraCards[1] = 10
                        repeatCardsLabel.text = "10"
                    } else {
                        cell.slider.value = Float(repeats)
                        numberOfExtraCards[1] = repeats
                        repeatCardsLabel.text = String(repeats)
                    }
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("chartViewCell", forIndexPath: indexPath) as! ChartViewCell
                cell.chartView.deck = deckInDeckStore
                cell.chartView.numberOfLines = 7
                cell.chartView.chartType = .Learn
                cell.chartView.cardsToLearn = numberOfExtraCards[0] + numberOfExtraCards[1]
                chartView = cell.chartView
                return cell
            default:
                var repeats = 0
                for history in deckInDeckStore.history {
                    repeats+=history.numberOfCards
                }
                var expectedTime: NSTimeInterval = 0
                if repeats == 0 || totalTimeSpentInDeck == 0 {
                    expectedTime = Double(numberOfExtraCards[0]+numberOfExtraCards[1])*10
                } else {
                    expectedTime = totalTimeSpentInDeck/Double(repeats)*Double(numberOfExtraCards[0]+numberOfExtraCards[1])
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
                    cell.detailTextLabel?.text = timeFormatter(averageTimeSpentPerDay)
                    return cell
                default:
                    cell.textLabel?.text = "Total time for this deck"
                    cell.detailTextLabel?.text = timeFormatter(totalTimeSpentInDeck)
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
                numberOfExtraCards[0] = Int(sender.value)
                chartView.cardsToLearn = numberOfExtraCards[0] + numberOfExtraCards[1]
                chartView.setNeedsDisplay()
            }
        } else if sender.tag == 2 {
            if repeatCardsLabel.text != String(Int(sender.value)) {
                repeatCardsLabel.text = String(Int(sender.value))
                numberOfExtraCards[1] = Int(sender.value)
                chartView.cardsToLearn = numberOfExtraCards[0] + numberOfExtraCards[1]
                chartView.setNeedsDisplay()
            }
        }
        var repeats = 0
        for history in deckInDeckStore.history {
            repeats+=history.numberOfCards
        }
        var expectedTime: NSTimeInterval = 0
        if repeats == 0 || totalTimeSpentInDeck == 0 {
            expectedTime = Double(numberOfExtraCards[0]+numberOfExtraCards[1])*10
        } else {
            expectedTime = totalTimeSpentInDeck/Double(repeats)*Double(numberOfExtraCards[0]+numberOfExtraCards[1])
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
                numberOfScheduledCardsTypes[0]+=1
            } else if card.Q < 1.5 {
                numberOfScheduledCardsTypes[2]+=1
            } else {
                numberOfScheduledCardsTypes[1]+=1
            }
        }
        
        //If there are no more cards scheduled for today show only second tab in segmentedControl
        if  deck.deck.count == 0 {
            segmentedControl.setEnabled(false, forSegmentAtIndex: 0)
            segmentedControl.selectedSegmentIndex = 1
        }
        totalTimeSpentInDeck = totalTime()
        if deckInDeckStore.history.count != 0 {
            averageTimeSpentPerDay = totalTimeSpentInDeck/NSTimeInterval(deckInDeckStore.history.count)
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