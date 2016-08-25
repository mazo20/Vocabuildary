//
//  ChartView.swift
//  Charts
//
//  Created by Maciej Kowalski on 04.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

@IBDesignable class ChartView: UIView {
    enum type {
        case Cards
        case Answers
        case Time
        case Learn
    }
    var lineHeights = [Int]()
    var maxValue = 0
    var deck: Deck!
    var deckStore: DeckStore!
    var cardsToLearn = 0
    var chartType: type!
    var numberOfLines: Int!
    
    override func drawRect(rect: CGRect) {
        clearView()
        self.clipsToBounds = true
        
        let color1 = UIColor(red: 0, green: 0.4, blue: 1, alpha: 1)
        let color2 = UIColor(red: 0, green: 0.8, blue: 1, alpha: 1)
        let darkYellow = UIColor(red: 1, green: 0.737, blue: 0, alpha: 1)
        
        let gradient = CAGradientLayer()
        gradient.colors = [color2.CGColor, color1.CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = self.bounds
        if chartType != .Learn {
            self.layer.insertSublayer(gradient, atIndex: 0)
        }
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(self.bounds.size.width/13-15, self.frame.size.height-25))
        path.addLineToPoint(CGPointMake(self.bounds.size.width/13*12+15, self.frame.size.height-25))
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.CGPath
        layer.strokeColor = darkYellow.CGColor
        layer.lineWidth = 1
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinBevel
        self.layer.insertSublayer(layer, atIndex: 1)
        let path1 = UIBezierPath()
        path1.moveToPoint(CGPointMake(self.bounds.size.width/13-15, self.bounds.origin.y+50))
        path1.addLineToPoint(CGPointMake(self.bounds.size.width/13*12+15, self.bounds.origin.y+50))
        let layer1 = CAShapeLayer()
        layer1.frame = self.bounds
        layer1.path = path1.CGPath
        layer1.strokeColor = darkYellow.CGColor
        layer1.lineWidth = 1
        layer1.lineCap = kCALineCapRound
        layer1.lineJoin = kCALineJoinBevel
        self.layer.insertSublayer(layer1, atIndex: 1)
        
        lines()
        scaleLabels(maxValue)
        
        let nameLabel = UILabel(frame: CGRectMake(self.bounds.size.width/13-15, self.bounds.origin.y+10, 200, 20))
        nameLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = .Left
        let averageLabel = UILabel(frame: CGRectMake(self.bounds.size.width/13-15, self.bounds.origin.y+30, 150, 20))
        averageLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        averageLabel.textColor = UIColor.whiteColor()
        averageLabel.textAlignment = .Left
        let valueLabel = UILabel(frame: CGRectMake(self.bounds.size.width/13*12-185, self.bounds.origin.y+10, 200, 20))
        valueLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        valueLabel.textColor = UIColor.whiteColor()
        valueLabel.textAlignment = .Right
        
        var all = 0
        for value in lineHeights {
            all+=value
        }
        let average = all/numberOfLines
        
        if chartType == .Cards {
            nameLabel.text = "Reviews"
            valueLabel.text = "\(all) reviews"
            if numberOfLines == 12 {
                averageLabel.text = "Monthly average: \(average)"
            } else {
                averageLabel.text = "Daily average: \(average)"
            }
        } else if chartType == .Answers {
            nameLabel.text = NSLocalizedString("answers", comment: "answers - title of a chart")
            if all == 0 {
                valueLabel.text = "0% easy"
                averageLabel.text = "0% repeats"
            } else {
                valueLabel.text = "\(Int(Float(lineHeights[2])/Float(all)*100))% easy"
                averageLabel.text = "\(Int(Float(lineHeights[0])/Float(all)*100))% repeats"
            }
        } else if chartType == .Time {
            nameLabel.text = "Time"
            valueLabel.text = timeFormatter(NSTimeInterval(all))
            averageLabel.text = "Daily average: " + timeFormatter(NSTimeInterval(average))
            if numberOfLines == 12 {
                averageLabel.text = "Monthly average: " + timeFormatter(NSTimeInterval(average))
            } else {
                averageLabel.text = "Daily average: " + timeFormatter(NSTimeInterval(average))
            }
        } else if chartType == .Learn {
            nameLabel.text = "Today"
            valueLabel.text = "\(lineHeights[numberOfLines-1]+cardsToLearn) cards"
            averageLabel.text = "Daily average: \(average)"
        }
        self.addSubview(nameLabel)
        self.addSubview(averageLabel)
        self.addSubview(valueLabel)
    }
    func lineHeightsData() {
        lineHeights = [Int]()
        for _ in 0...numberOfLines-1 {
            lineHeights.append(0)
        }
        var date = NSDate()
        if numberOfLines == 12 {
            date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Month, value: -12, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))!
            for i in 0...11 {
                date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Month, value: 1, toDate: date, options: NSCalendarOptions.init(rawValue: 0))!
                var dateString = stringFromDate(date)
                dateString = (dateString as NSString).substringToIndex(7)
                if let deck = deck {
                    for history in deck.history {
                        if history.date.containsString(dateString) {
                            lineValuesForHistory(history, i: i)
                        }
                    }
                } else {
                    for deck in deckStore.deckStore {
                        for history in deck.history {
                            if history.date.containsString(dateString) {
                                lineValuesForHistory(history, i: i)
                            }
                        }
                    }
                }
            }
        } else {
            date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -numberOfLines, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))!
            for i in 0...numberOfLines-1 {
                date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: date, options: NSCalendarOptions.init(rawValue: 0))!
                if let deck = deck {
                    if let history = deck.historyForDate(stringFromDate(date)) {
                        lineValuesForHistory(history, i: i)
                    }
                } else {
                    for deck in deckStore.deckStore {
                        if let history = deck.historyForDate(stringFromDate(date)) {
                            lineValuesForHistory(history, i: i)
                        }
                    }
                }
                
            }
        }
        maxValue = lineHeights.maxElement()!
        if chartType == .Learn {
            if lineHeights[6]+cardsToLearn > maxValue {
                maxValue = lineHeights[6]+cardsToLearn
            }
        }
    }
    func lineValuesForHistory(history: DeckHistory, i: Int) {
        if chartType == .Cards || chartType == .Learn {
            lineHeights[i]+=history.numberOfCards
        } else if chartType == .Time {
            lineHeights[i]+=Int(history.time)
        } else if chartType == .Answers {
            lineHeights[0]+=history.answers[0]
            lineHeights[1]+=history.answers[1]
            lineHeights[2]+=history.answers[2]
        }
    }
    func lines() {
        lineHeightsData()
        if chartType == .Answers {
            for i in 0...6 {
                if i%2==1 {
                    let path = UIBezierPath()
                    var lineHeight:CGFloat = 0.0
                    let startPoint = self.bounds.size.width/13
                    var k: CGFloat
                    lineHeight = 0.0
                    if maxValue != 0 {
                        k = CGFloat(lineHeights[i/2])/CGFloat(maxValue)
                        lineHeight = (self.frame.size.height - self.bounds.origin.y - 100)*k
                    }
                    path.moveToPoint(CGPointMake(startPoint + startPoint*10/CGFloat(6)*CGFloat(i), self.bounds.size.height-32))
                    path.addLineToPoint(CGPointMake(startPoint + startPoint*10/CGFloat(6)*CGFloat(i), self.bounds.size.height-32 - lineHeight))
                    let layer = CAShapeLayer()
                    layer.frame = self.bounds
                    layer.path = path.CGPath
                    let dateLabel = UILabel(frame: CGRectMake(0, 0, 80, 30))
                    layer.lineWidth = 10
                    layer.lineCap = kCALineCapRound
                    layer.lineJoin = kCALineJoinBevel
                    switch i/2 {
                    case 0:
                        layer.strokeColor = UIColor(red: 1, green: 0.2, blue: 0, alpha: 1).CGColor
                        dateLabel.text = "Repeat"
                    case 1:
                        layer.strokeColor = UIColor(red: 1, green: 0.737, blue: 0, alpha: 1).CGColor
                        dateLabel.text = "Hard"
                    default:
                        layer.strokeColor = UIColor(red: 0.3, green: 0.8, blue: 0, alpha: 1).CGColor
                        dateLabel.text = "Easy"
                    }
                    self.layer.insertSublayer(layer, atIndex: 1)
                    let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
                    pathAnimation.duration = 1
                    pathAnimation.fromValue = 0
                    pathAnimation.toValue = 1
                    layer.addAnimation(pathAnimation, forKey: "strokeEnd")
                    dateLabel.font = UIFont.systemFontOfSize(10, weight: UIFontWeightLight)
                    dateLabel.textColor = UIColor.whiteColor()
                    dateLabel.textAlignment = .Center
                    dateLabel.center = CGPointMake(startPoint + startPoint*10/CGFloat(6)*CGFloat(i), self.frame.size.height-15)
                    self.addSubview(dateLabel)
                }
            }
        } else {
            var lastDay = 0
            for i in 0...numberOfLines-1 {
                let path = UIBezierPath()
                var lineHeight:CGFloat = 0.0
                let startPoint = self.bounds.size.width/13
                var k: CGFloat
                var date = NSDate()
                lineHeight = 0.0
                if maxValue != 0 {
                    k = CGFloat(lineHeights[i])/CGFloat(maxValue)
                    lineHeight = (self.frame.size.height - self.bounds.origin.y - 95)*k
                }
                path.moveToPoint(CGPointMake(startPoint + startPoint*10/CGFloat(numberOfLines-1)*CGFloat(i), self.bounds.size.height-30))
                path.addLineToPoint(CGPointMake(startPoint + startPoint*10/CGFloat(numberOfLines-1)*CGFloat(i), self.bounds.size.height-30 - lineHeight))
                let layer = CAShapeLayer()
                layer.frame = self.bounds
                layer.path = path.CGPath
                layer.lineWidth = 5
                layer.strokeColor = UIColor(red: 1, green: 0.737, blue: 0, alpha: 1).CGColor
                layer.lineCap = kCALineCapRound
                layer.lineJoin = kCALineJoinBevel
                self.layer.insertSublayer(layer, atIndex: 1)
                let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
                pathAnimation.duration = 1
                pathAnimation.fromValue = 0
                pathAnimation.toValue = 1
                if chartType != .Learn {
                    layer.addAnimation(pathAnimation, forKey: "strokeEnd")
                }
                let dateLabel = UILabel(frame: CGRectMake(0, 0, 80, 30))
                dateLabel.font = UIFont.systemFontOfSize(10, weight: UIFontWeightLight)
                dateLabel.textColor = UIColor.whiteColor()
                dateLabel.textAlignment = .Center
                dateLabel.center = CGPointMake(startPoint + startPoint*10/CGFloat(numberOfLines-1)*CGFloat(i), self.frame.size.height-15)
                // Adding dates under the chart
                var text = ""
                if numberOfLines == 12 {
                    if i%3==1 {
                        date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Month, value: -11+i, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))!
                        (text, lastDay) = dateShortener(date, valueType: "month", lastDay: lastDay)
                    }
                } else if numberOfLines > 28 {
                    date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -numberOfLines+1+i, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))!
                    if i%4==1 {
                        (text, lastDay) = dateShortener(date, valueType: "day", lastDay: lastDay)
                    }
                } else {
                    date = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -numberOfLines+1+i, toDate: NSDate(), options: NSCalendarOptions.init(rawValue: 0))!
                    (text, lastDay) = dateShortener(date, valueType: "day", lastDay: lastDay)
                }
                dateLabel.text = text
                self.addSubview(dateLabel)
                if chartType == .Learn && i == 6 {
                    let layer2 = CAShapeLayer()
                    let path1 = UIBezierPath()
                    path1.moveToPoint(CGPointMake(startPoint + startPoint*10, self.bounds.size.height-30 - lineHeight))
                    if maxValue != 0 {
                        k = CGFloat(lineHeights[i]+cardsToLearn)/CGFloat(maxValue)
                        lineHeight = (self.frame.size.height - self.bounds.origin.y - 95)*k
                    }
                    path1.addLineToPoint(CGPointMake(startPoint + startPoint*10, self.bounds.size.height-30 - lineHeight))
                    layer2.frame = self.bounds
                    layer2.path = path1.CGPath
                    layer2.strokeColor = UIColor(red: 0, green: 0.6, blue: 0.2, alpha: 1).CGColor
                    layer2.lineWidth = 5
                    layer2.lineCap = kCALineCapRound
                    layer2.lineJoin = kCALineJoinBevel
                    self.layer.insertSublayer(layer2, atIndex: 1)
                }
            }
        }
    }
    func dateShortener(date: NSDate, valueType: String, lastDay: Int) -> (String, Int) {
        let month = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: date).month
        var dateLabel = ""
        var newLastDay = lastDay
        let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String
        if valueType == "day" {
            let day = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date).day
            if day > lastDay {
                dateLabel = dateComponentFormatter(day)
                newLastDay = day
            } else {
                if countryCode == "US" {
                    dateLabel = dateComponentFormatter(month) + "/" + dateComponentFormatter(day)
                } else {
                    dateLabel = dateComponentFormatter(day) + "." + dateComponentFormatter(month)
                }
                newLastDay = 0
            }
        } else {
            let year = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: date).year
            if countryCode == "US" {
                dateLabel = dateComponentFormatter(month) + "/" + dateComponentFormatter(year)
            } else {
                dateLabel = dateComponentFormatter(month) + "." + dateComponentFormatter(year)
            }
        }
        return (dateLabel, newLastDay)
    }
    func scaleLabels(max: Int) {
        let scaleLabel1 = UILabel(frame: CGRectMake(self.bounds.size.width/13*12-35, self.bounds.origin.y+50, 50, 20))
        scaleLabel1.text = "\(max)"
        if chartType == .Time{
            scaleLabel1.text = timeFormatter(NSTimeInterval(max))
        }
        scaleLabel1.font = UIFont.systemFontOfSize(9, weight: UIFontWeightLight)
        scaleLabel1.textColor = UIColor.whiteColor()
        scaleLabel1.textAlignment = .Right
        self.addSubview(scaleLabel1)
        let scaleLabel2 = UILabel(frame: CGRectMake(self.bounds.size.width/13*12-35, (self.bounds.origin.y+50+self.frame.size.height-45)/2, 50, 20))
        scaleLabel2.text = "\(max/2)"
        if chartType == .Time{
            scaleLabel2.text = timeFormatter(NSTimeInterval(max/2))
        }
        scaleLabel2.font = UIFont.systemFontOfSize(9, weight: UIFontWeightLight)
        scaleLabel2.textColor = UIColor.whiteColor()
        scaleLabel2.textAlignment = .Right
        self.addSubview(scaleLabel2)
        let scaleLabel3 = UILabel(frame: CGRectMake(self.bounds.size.width/13*12-35, self.frame.size.height-45, 50, 20))
        scaleLabel3.text = "0"
        scaleLabel3.font = UIFont.systemFontOfSize(9, weight: UIFontWeightLight)
        scaleLabel3.textColor = UIColor.whiteColor()
        scaleLabel3.textAlignment = .Right
        self.addSubview(scaleLabel3)
    }
    func clearView() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        if let sublayers = self.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
    }
}
