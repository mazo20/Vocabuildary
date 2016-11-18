//
//  ChartView.swift
//  Charts
//
//  Created by Maciej Kowalski on 04.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

@IBDesignable class ChartView: UIView, TimeFormatable {
    enum type {
        case cards
        case answers
        case time
        case learn
    }
    var values = [Int]()
    var maxValue = 0
    var deck: Deck?
    var deckStore: DeckStore?
    var cardsToLearn = 0
    var chartType: type!
    var numberOfLines: Int {
        if chartType == .answers { return 3 }
        return range.rawValue
    }
    var range: timeRange!
    
    override func draw(_ rect: CGRect) {
        clearView()
        self.clipsToBounds = true
        
        let color1 = UIColor(red: 0, green: 0.4, blue: 1, alpha: 1)
        let color2 = UIColor(red: 0, green: 0.8, blue: 1, alpha: 1)
        let darkYellow = UIColor(red: 1, green: 0.737, blue: 0, alpha: 1)
        
        let gradient = CAGradientLayer()
        gradient.colors = [color2.cgColor, color1.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = self.bounds
        if chartType != .learn { self.layer.insertSublayer(gradient, at: 0) }
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.size.width/13-15, y: self.frame.size.height-25))
        path.addLine(to: CGPoint(x: self.bounds.size.width/13*12+15, y: self.frame.size.height-25))
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        layer.strokeColor = darkYellow.cgColor
        layer.lineWidth = 1
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinBevel
        self.layer.insertSublayer(layer, at: 1)
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: self.bounds.size.width/13-15, y: self.bounds.origin.y+50))
        path1.addLine(to: CGPoint(x: self.bounds.size.width/13*12+15, y: self.bounds.origin.y+50))
        let layer1 = CAShapeLayer()
        layer1.frame = self.bounds
        layer1.path = path1.cgPath
        layer1.strokeColor = darkYellow.cgColor
        layer1.lineWidth = 1
        layer1.lineCap = kCALineCapRound
        layer1.lineJoin = kCALineJoinBevel
        self.layer.insertSublayer(layer1, at: 1)
        
        
        lines()
        scaleLabels(maxValue)
        
        let nameLabel = UILabel(frame: CGRect(x: self.bounds.size.width/13-15, y: self.bounds.origin.y+10, width: 200, height: 20))
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .left
        let averageLabel = UILabel(frame: CGRect(x: self.bounds.size.width/13-15, y: self.bounds.origin.y+30, width: 150, height: 20))
        averageLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        averageLabel.textColor = UIColor.white
        averageLabel.textAlignment = .left
        let valueLabel = UILabel(frame: CGRect(x: self.bounds.size.width/13*12-185, y: self.bounds.origin.y+10, width: 200, height: 20))
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        valueLabel.textColor = UIColor.white
        valueLabel.textAlignment = .right
        
        //This line adds all elements of a array
        let all = values.reduce(0, +)
        let average = all/numberOfLines
        
        if chartType == .cards {
            nameLabel.text = "Reviews"
            valueLabel.text = "\(all) reviews"
            if numberOfLines == 12 {
                averageLabel.text = "Monthly average: \(average)"
            } else {
                averageLabel.text = "Daily average: \(average)"
            }
        } else if chartType == .answers {
            nameLabel.text = "Answers"
            if all == 0 {
                valueLabel.text = "0% easy"
                averageLabel.text = "0% repeats"
            } else {
                valueLabel.text = "\(Int(Float(values[2])/Float(all)*100))% easy"
                averageLabel.text = "\(Int(Float(values[0])/Float(all)*100))% repeats"
            }
        } else if chartType == .time {
            nameLabel.text = "Time"
            valueLabel.text = timeFormatter(TimeInterval(all))
            averageLabel.text = "Daily average: " + timeFormatter(TimeInterval(average))
            if numberOfLines == 12 {
                averageLabel.text = "Monthly average: " + timeFormatter(TimeInterval(average))
            } else {
                averageLabel.text = "Daily average: " + timeFormatter(TimeInterval(average))
            }
        } else if chartType == .learn {
            nameLabel.text = "Today"
            valueLabel.text = "\(values[numberOfLines-1]+cardsToLearn) cards"
            averageLabel.text = "Daily average: \(average)"
        }
        self.addSubview(nameLabel)
        self.addSubview(averageLabel)
        self.addSubview(valueLabel)
    }
    
    func getAllAnswers() {
        values = chartType == .answers ? [0,0,0] : [Int]()
        var value: [Int]
        let type = numberOfLines != 12 ? NSCalendar.Unit.day : NSCalendar.Unit.month
        let granularity = type == .day ? Calendar.Component.day : Calendar.Component.month
        var date = (Calendar.current as NSCalendar).date(byAdding: type, value: -numberOfLines, to: Date())!
        for _ in 0..<numberOfLines {
            date = (Calendar.current as NSCalendar).date(byAdding: type, value: 1, to: date)!
            if let _ = deck {
                value = deckAnswersForDate(deck: deck!, date: date, type: granularity)
            } else {
                value = allAnswersForDate(deckStore: deckStore!, date: date, type: granularity)
            }
            if chartType == .answers {
                for i in 0..<3 {
                    values[i]+=value[i]
                }
            } else {
                values.append(value[0])
            }
        }
    }
    
    func cardAnswersForDate(card: Card, date: Date, type: Calendar.Component) -> [Int] {
        var numberOfAnswers = chartType == .answers ? [0,0,0] : [0]
        for answer in card.answers {
            if NSCalendar.current.compare(date, to: answer.date, toGranularity: type) == .orderedSame {
                if chartType == .time {
                    numberOfAnswers[0]+=Int(answer.time)
                } else if chartType == .answers {
                    numberOfAnswers[answer.value]+=1
                } else {
                    numberOfAnswers[0]+=1
                    break
                }
            }
        }
        return numberOfAnswers
    }
    
    func deckAnswersForDate(deck: Deck, date: Date, type: Calendar.Component) -> [Int] {
        var numberOfAnswers = chartType == .answers ? [0,0,0] : [0]
        for card in deck.cards {
            for i in 0..<numberOfAnswers.count {
                numberOfAnswers[i]+=cardAnswersForDate(card: card, date: date, type: type)[i]
            }
        }
        return numberOfAnswers
    }
    
    func allAnswersForDate(deckStore: DeckStore, date: Date, type: Calendar.Component) -> [Int] {
        var numberOfAnswers = chartType == .answers ? [0,0,0] : [0]
        for deck in deckStore.decks {
            for i in 0..<numberOfAnswers.count {
                numberOfAnswers[i]+=deckAnswersForDate(deck: deck, date: date, type: type)[i]
            }
        }
        return numberOfAnswers
    }

    func createPath(forLine i: Int, value: Int, maxValue: Int, chartType: type) -> UIBezierPath {
        let path = UIBezierPath()
        var point = CGPoint(x: lineStartPoint(line: i, chartType: chartType), y: self.bounds.size.height-32)
        path.move(to: point)
        point.y-=lineHeight(value: value, maxValue: maxValue)
        path.addLine(to: point)
        return path
    }
    
    func lineStartPoint(line: Int, chartType: type) -> CGFloat {
        let startPoint = self.bounds.size.width/13
        let i = chartType == .answers ? line*2+1 : line
        let max = chartType == .answers ? 6 : numberOfLines-1
        return startPoint + startPoint*10/CGFloat(max)*CGFloat(i)
    }
    
    func lineHeight(value: Int, maxValue: Int) -> CGFloat {
        if maxValue == 0 { return 0 }
        return (self.frame.size.height - self.bounds.origin.y - 100) * CGFloat(value)/CGFloat(maxValue)
    }
    
    func drawLine(forLine line: Int, path: UIBezierPath, color: UIColor, width: CGFloat, atLayer: UInt32) {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        layer.strokeColor = color.cgColor
        layer.lineWidth = width
        layer.lineCap = kCALineCapRound
        layer.lineJoin = kCALineJoinBevel
        self.layer.insertSublayer(layer, at: atLayer)
    }
    
    func addDateLabel(forLine i: Int, chartType: type) {
        let dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        dateLabel.center = CGPoint(x: lineStartPoint(line: i, chartType: chartType), y: self.frame.size.height-15)
        dateLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightLight)
        dateLabel.textColor = UIColor.white
        dateLabel.textAlignment = .center
        if chartType == .answers {
            switch i {
            case 0: dateLabel.text = "Repeat"
            case 1: dateLabel.text = "Hard"
            default: dateLabel.text = "Easy"
            }
            self.addSubview(dateLabel)
        } else if range == .year {
            if i%3==1 {
                let date = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.month, value: -numberOfLines+i+1, to: Date())!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM.yy"
                dateLabel.text = dateFormatter.string(from: date)
                self.addSubview(dateLabel)
            }
        } else if range == .month {
            if i%4==1 {
                let date = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -numberOfLines+i+1, to: Date())!
                let dateFormatter = DateFormatter()
                if Locale.current.languageCode == "en-US" { dateFormatter.dateFormat = "MM/dd" }
                dateFormatter.dateFormat = "dd.MM"
                dateLabel.text = dateFormatter.string(from: date)
                self.addSubview(dateLabel)
            }
        } else {
            let date = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -numberOfLines+i+1, to: Date())!
            let dateFormatter = DateFormatter()
            if Locale.current.languageCode == "en-US" { dateFormatter.dateFormat = "MM/dd" }
            dateFormatter.dateFormat = "dd.MM"
            dateLabel.text = dateFormatter.string(from: date)
            self.addSubview(dateLabel)
        }
        
    }
    
    func lines() {
        getAllAnswers()
        maxValue = values.max()!
        if chartType == .learn {
            let value = values[6]+cardsToLearn
            if value > maxValue { maxValue = value }
            let path = createPath(forLine: 6, value: value, maxValue: maxValue, chartType: chartType)
            drawLine(forLine: 6, path: path, color: UIColor(red: 0, green: 0.6, blue: 0.2, alpha: 1), width: 5, atLayer: 1)
        }
        
        for i in 0..<numberOfLines {
            let path = createPath(forLine: i, value: values[i], maxValue: maxValue, chartType: chartType)
            let color: UIColor
            let dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
            dateLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightLight)
            dateLabel.textColor = UIColor.white
            dateLabel.textAlignment = .center
            dateLabel.center = CGPoint(x: lineStartPoint(line: i, chartType: chartType), y: self.frame.size.height-15)
            
            if chartType == .answers && i == 0 {
                color = UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)
            } else if chartType == .answers && i == 2 {
                color = UIColor(red: 0.3, green: 0.8, blue: 0, alpha: 1)
            } else {
                color = UIColor(red: 1, green: 0.737, blue: 0, alpha: 1)
            }
            let width: CGFloat = chartType == .answers ? 10 : 5
            drawLine(forLine: i, path: path, color: color, width: width, atLayer: 2)
            addDateLabel(forLine: i, chartType: chartType)
        }
    }
    
    func scaleLabels(_ max: Int) {
        var y = self.bounds.origin.y+50
        var text = chartType == .time ? timeFormatter(TimeInterval(max)) : "\(max)"
        addScaleLabel(y: y, text: text)
        
        y = (self.bounds.origin.y+50+self.frame.size.height-45)/2.0
        text = chartType == .time ? timeFormatter(TimeInterval(max/2)) : "\(max/2)"
        addScaleLabel(y: y, text: text)
        
        y = self.frame.size.height-45
        text = "0"
        addScaleLabel(y: y, text: text)
    }
    func addScaleLabel(y: CGFloat, text: String) {
        let label = UILabel(frame: CGRect(x: self.bounds.size.width/13*12-35, y: y, width: 50, height: 20))
        label.text = text
        label.font = UIFont.systemFont(ofSize: 9, weight: UIFontWeightLight)
        label.textColor = UIColor.white
        label.textAlignment = .right
        self.addSubview(label)
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
