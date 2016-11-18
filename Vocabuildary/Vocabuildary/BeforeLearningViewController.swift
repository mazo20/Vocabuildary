//
//  LearnViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 03.03.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class BeforeLearningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TimeFormatable {
    
    //MARK: Properties
    
    var deck: Deck!
    var newCardsLabel = UILabel()
    var repeatCardsLabel = UILabel()
    var timeLabel: UILabel!
    
    var numberOfExtraCards = [0, 0]
    var maxExtraCards = [0,0]
    var totalNumberOfExtraCards: Int {
        return numberOfExtraCards[0] + numberOfExtraCards[1]
    }
    
    //MARK: Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var problematicCards: UILabel!
    @IBOutlet var repeatingCards: UILabel!
    @IBOutlet var newCards: UILabel!
    @IBOutlet var chartView: ChartView!
    @IBOutlet var studyButton: UIButton!
    
    //MARK: Time counting
    
    var totalTimeSpentInDeck: TimeInterval {
        var time = TimeInterval()
        for card in deck.cards {
            for answer in card.answers {
                time+=answer.time
            }
        }
        return time
    }
    var averageTimePerAnswer: TimeInterval {
        var answers = 0.0
        for card in deck.cards {
            for _ in card.answers {
                answers+=1
            }
        }
        if answers == 0 { return 0 }
        return totalTimeSpentInDeck/answers
    }
    func expectedTime() -> TimeInterval {
        let time = averageTimePerAnswer == 0 ? 3 : averageTimePerAnswer
        if segmentedControl.selectedSegmentIndex == 0 {
            return time * Double(deck.cardsForToday.count)
        }
        return time * Double(totalNumberOfExtraCards)
    }
    
    
    //MARK: Actions
    
    @IBAction func studyButton(_ sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.performSegue(withIdentifier: "ShowLearnViewController", sender: self)
        } else {
            guard numberOfExtraCards[0] > 0 || numberOfExtraCards[1] > 0 else {return}
            
            var newCardsToLearn = 0
            var cardsToRepeat = 0
            let shuffledDeck = deck.shuffle(array: deck.cards)
            for card in shuffledDeck {
                if newCardsToLearn < numberOfExtraCards[0] && card.status == .new {
                    deck.extraCards.append(card)
                    newCardsToLearn+=1
                } else if cardsToRepeat < numberOfExtraCards[1] && card.status != .new {
                    deck.extraCards.append(card)
                    cardsToRepeat+=1
                }
                if newCardsToLearn == numberOfExtraCards[0] && cardsToRepeat == numberOfExtraCards[1] {
                    break
                }
            }
            self.performSegue(withIdentifier: "ShowLearnViewController", sender: self)
        }
    }
    @IBAction func segmentedControlUpdateView(_ sender: AnyObject) {
        tableView.reloadData()
        chartView.setNeedsDisplay()
    }
    func sliderChanged(_ sender: UISlider) {
        if sender.tag == 1 && newCardsLabel.text != String(Int(sender.value)) {
            newCardsLabel.text = String(Int(sender.value))
            numberOfExtraCards[0] = Int(sender.value)
        } else if sender.tag == 2 && repeatCardsLabel.text != String(Int(sender.value)){
            repeatCardsLabel.text = String(Int(sender.value))
            numberOfExtraCards[1] = Int(sender.value)
        }
        chartView.cardsToLearn = totalNumberOfExtraCards
        chartView.setNeedsDisplay()
        timeLabel.text = timeFormatter(expectedTime())
    }
    
    //MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            if segmentedControl.selectedSegmentIndex == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "numberOfCardsCell", for: indexPath) as! CardsNumberCell
                let scheduledCards = deck.whatCards(deck.cardsForToday)
                cell.newCards.text = String(scheduledCards[0])
                cell.repeatingCards.text = String(scheduledCards[1])
                cell.problematicCards.text = String(scheduledCards[2])
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "numberCell", for: indexPath) as! SliderCell
                cell.numberLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                cell.numberLabel.textColor = UIColor.lightText
                cell.titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
                cell.titleLabel.textColor = UIColor.white
                cell.slider.addTarget(self, action: #selector(BeforeLearningViewController.sliderChanged(_:)), for: .valueChanged)
                cell.slider.minimumValue = 0
                if (indexPath as NSIndexPath).row == 0 {
                    cell.titleLabel?.text = "New cards to learn"
                    newCardsLabel = cell.numberLabel
                    cell.slider.tag = 1
                    cell.slider.maximumValue = Float(maxExtraCards[0])
                    if maxExtraCards[0] == 0 { cell.slider.alpha = 0.7 }
                    cell.slider.value = Float(numberOfExtraCards[0])
                    newCardsLabel.text = String(numberOfExtraCards[0])
                } else {
                    cell.titleLabel?.text = "Cards to repeat"
                    repeatCardsLabel = cell.numberLabel
                    cell.slider.tag = 2
                    cell.slider.maximumValue = Float(maxExtraCards[1])
                    if maxExtraCards[1] == 0 { cell.slider.alpha = 0.7 }
                    cell.slider.value = Float(numberOfExtraCards[1])
                    repeatCardsLabel.text = String(numberOfExtraCards[1])
                }
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "chartViewCell", for: indexPath) as! ChartViewCell
            cell.chartView.deck = deck
            cell.chartView.chartType = .learn
            cell.chartView.range = .week
            cell.chartView.cardsToLearn = segmentedControl.selectedSegmentIndex == 0 ? deck.cardsForToday.count : totalNumberOfExtraCards
            chartView = cell.chartView
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.lightText
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Expected time"
                cell.detailTextLabel?.text = timeFormatter(expectedTime())
                if segmentedControl.selectedSegmentIndex == 1 { timeLabel = cell.detailTextLabel }
            case 1:
                cell.textLabel?.text = "Average time answer"
                cell.detailTextLabel?.text = timeFormatter(averageTimePerAnswer)
            default:
                cell.textLabel?.text = "Total time for this deck"
                cell.detailTextLabel?.text = timeFormatter(totalTimeSpentInDeck)
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return segmentedControl.selectedSegmentIndex == 0 ? 1 : 2
        case 1:
            return 1
        default:
            return 3
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0000001
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return segmentedControl.selectedSegmentIndex == 0 ? 152 : 76
        case 1:
            return 200
        default:
            return 44
        }
    }
    
    //MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLearnViewController" {
            let learnViewController = segue.destination as! LearnViewController
            learnViewController.deck = deck
        }
    }
    
    //MARK: - View customization
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        UIView.animate(withDuration: 0.2, animations: {
            var center = button.center
            center.y += 100
            button.center = center
            button.alpha = 0
        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        //Reseting the navigation controller when leaving this view
        self.tabBarController?.tabBar.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            var center = button.center
            center.y -= 100
            button.center = center
            button.alpha = 1
        })
    }
    override func viewDidLoad() {
        tableView.backgroundColor = UIColor.clear
        self.title = deck.name
        
        maxExtraCards[0] = deck.cards.filter({ $0.status == .new }).count
        maxExtraCards[1] = deck.cards.count-maxExtraCards[0]
        let newCards = UserDefaults.standard.object(forKey: "newCards") as! Int
        numberOfExtraCards[0] = maxExtraCards[0] > newCards ? newCards : maxExtraCards[0]
        numberOfExtraCards[1] = maxExtraCards[1] > 15 ? 15 : maxExtraCards[1]
        
        //If there are no more cards scheduled for today show only second tab in segmentedControl
        if  deck.cardsForToday.count == 0 {
            segmentedControl.setEnabled(false, forSegmentAt: 0)
            segmentedControl.selectedSegmentIndex = 1
        }
        
        let normalBlue = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
        let lighterBlue = UIColor(red: 0, green: 0.8, blue: 1, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.colors = [normalBlue.cgColor, lighterBlue.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.95)
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, at: 0)
        studyButton.layer.cornerRadius = 5
    }
}
