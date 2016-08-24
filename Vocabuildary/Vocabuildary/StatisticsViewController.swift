//
//  StatisticsViewController.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 08.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, SendDataDelegate {
    
    var deckStore: DeckStore!
    var deckToShowStatistics = -1
    
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
    
    func sendData(data: Int) {
        deckToShowStatistics = data
        if deckToShowStatistics != -1 {
            chartView.deck = deckStore.deckStore[deckToShowStatistics]
            chartView1.deck = deckStore.deckStore[deckToShowStatistics]
            chartView2.deck = deckStore.deckStore[deckToShowStatistics]
            self.title = deckStore.deckStore[deckToShowStatistics].name
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
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        chartView.numberOfLines = numberOfLines
        chartView.setNeedsDisplay()
        chartView1.numberOfLines = numberOfLines
        chartView1.setNeedsDisplay()
        chartView2.numberOfLines = numberOfLines
        chartView2.setNeedsDisplay()
    }
    
    func drawChart() {
        let x:CGFloat = self.view.bounds.size.width-16
        let y:CGFloat = (self.view.bounds.size.width-16)/self.view.bounds.size.height*self.view.bounds.size.width
        let frame = CGRectMake(0, 0, x, y)
        chartView.frame = frame
        chartView.layer.cornerRadius = 7
        chartView.chartType = .Cards
        chartView.deckStore = deckStore
        chartView.center = self.view.center
        chartView.center.y = self.view.frame.origin.y + y/2 + 5
        chartView.numberOfLines = numberOfLines
        chartView1.frame = frame
        chartView1.layer.cornerRadius = 7
        chartView1.chartType = .Time
        chartView1.deckStore = deckStore
        chartView1.center = self.view.center
        chartView1.center.y = self.view.frame.origin.y + y/2*3 + 10
        chartView1.numberOfLines = numberOfLines
        chartView2.frame = frame
        chartView2.layer.cornerRadius = 7
        chartView2.chartType = .Answers
        chartView2.deckStore = deckStore
        chartView2.center = self.view.center
        chartView2.center.y = self.view.frame.origin.y + y/2*5 + 15
        chartView2.numberOfLines = numberOfLines
        
        scrollView.addSubview(chartView)
        scrollView.addSubview(chartView1)
        scrollView.addSubview(chartView2)
    }
    
    override func viewDidLoad() {
        let rect = CGRectMake(0, segmentedControll.frame.size.height + 16, view.frame.size.width, view.frame.size.height-segmentedControll.frame.size.height-16)
        scrollView = UIScrollView(frame: rect)
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.contentSize = CGSizeMake(self.view.frame.width, ((self.view.bounds.size.width-16)/self.view.bounds.size.height*self.view.bounds.size.width)*3 + 20 + self.tabBarController!.tabBar.bounds.size.height)
        scrollView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
        view.addSubview(scrollView)
        
        let tabBar = self.tabBarController as! TabBarController
        self.deckStore = tabBar.deckStore
        
        let lineView = UIView(frame: CGRectMake(0,(self.navigationController?.navigationBar.frame.size.height)!,self.view.frame.size.width,1))
        lineView.backgroundColor = UIColor(red: 0, green: 0.6, blue: 1, alpha: 1)
        self.navigationController?.navigationBar.addSubview(lineView)
        
        drawChart()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navController = segue.destinationViewController as! UINavigationController
        let viewController = navController.topViewController as! StatisticsDeckViewController
        viewController.deckStore = self.deckStore
        viewController.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        if deckToShowStatistics != -1 {
            chartView.deck = deckStore.deckStore[deckToShowStatistics]
            chartView1.deck = deckStore.deckStore[deckToShowStatistics]
            chartView2.deck = deckStore.deckStore[deckToShowStatistics]
            self.title = deckStore.deckStore[deckToShowStatistics].name
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
