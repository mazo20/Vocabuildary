//
//  StatisticsViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 08.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, SendDeckDelegate {
    
    var deckStore: DeckStore!
    var deck: Deck?
    
    var range: timeRange {
        switch segmentedControll.selectedSegmentIndex {
        case 0:
            return .week
        case 1:
            return .month
        default:
            return .year
        }
    }
    
    let chartView = ChartView()
    let chartView1 = ChartView()
    let chartView2 = ChartView()
    
    @IBOutlet var segmentedControll: UISegmentedControl!
    var scrollView: UIScrollView!
    
    var numberOfLines: Int {
        switch segmentedControll.selectedSegmentIndex {
        case 0:
            return 7
        case 1:
            return 31
        default:
            return 12
        }
    }
    
    func sendDeck(_ deck: Deck?) {
        self.deck = deck
        if let deck = deck {
            chartView.deck = deck
            chartView1.deck = deck
            chartView2.deck = deck
            self.title = deck.name
        } else {
            chartView.deck = nil
            chartView1.deck = nil
            chartView2.deck = nil
            self.title = "All decks"
        }
        chartView.setNeedsDisplay()
        chartView1.setNeedsDisplay()
        chartView2.setNeedsDisplay()
    }
    
    @IBAction func segmentedControlChanged(_ sender: AnyObject) {
        chartView.range = range
        chartView.setNeedsDisplay()
        chartView1.range = range
        chartView1.setNeedsDisplay()
        chartView2.range = range
        chartView2.setNeedsDisplay()
    }
    
    func drawChart() {
        let x:CGFloat = self.view.bounds.size.width-16
        let y:CGFloat = (self.view.bounds.size.width-16)/self.view.bounds.size.height*self.view.bounds.size.width
        let frame = CGRect(x: 0, y: 0, width: x, height: y)
        chartView.frame = frame
        chartView.layer.cornerRadius = 7
        chartView.chartType = .cards
        chartView.deckStore = deckStore
        chartView.center = self.view.center
        chartView.center.y = self.view.frame.origin.y + y/2 + 5
        chartView.range = range
        chartView1.frame = frame
        chartView1.layer.cornerRadius = 7
        chartView1.chartType = .time
        chartView1.deckStore = deckStore
        chartView1.center = self.view.center
        chartView1.center.y = self.view.frame.origin.y + y/2*3 + 10
        chartView1.range = range
        chartView2.frame = frame
        chartView2.layer.cornerRadius = 7
        chartView2.chartType = .answers
        chartView2.deckStore = deckStore
        chartView2.center = self.view.center
        chartView2.center.y = self.view.frame.origin.y + y/2*5 + 15
        chartView2.range = range
        
        scrollView.addSubview(chartView)
        scrollView.addSubview(chartView1)
        scrollView.addSubview(chartView2)
    }
    
    override func viewDidLoad() {
        let rect = CGRect(x: 0, y: segmentedControll.frame.size.height + 16, width: view.frame.size.width, height: view.frame.size.height-segmentedControll.frame.size.height-16)
        scrollView = UIScrollView(frame: rect)
        scrollView.backgroundColor = UIColor.white
        let width = self.view.frame.width
        scrollView.contentSize = CGSize(width: width, height: ((width-16)/self.view.bounds.size.height*width)*3 + 20 + self.tabBarController!.tabBar.bounds.size.height)
        scrollView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        view.addSubview(scrollView)
        
        let tabBar = self.tabBarController as! TabBarController
        self.deckStore = tabBar.deckStore
        
        drawChart()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let viewController = navController.topViewController as! StatisticsDeckViewController
        viewController.deckStore = self.deckStore
        viewController.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        if let deck = deck {
            chartView.deck = deck
            chartView1.deck = deck
            chartView2.deck = deck
            self.title = deck.name
        } else {
            chartView.deck = nil
            chartView1.deck = nil
            chartView2.deck = nil
            self.title = "All decks"
        }
        chartView.setNeedsDisplay()
        chartView1.setNeedsDisplay()
        chartView2.setNeedsDisplay()
    }
}
