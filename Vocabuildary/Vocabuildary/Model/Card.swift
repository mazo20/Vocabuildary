//
//  Card.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 28.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation

enum Status: Int {
    case new = 0
    case hard = 1
    case easy = 2
    case learned = 3
}

class Answer: NSObject, NSCoding {
    
    var value: Int
    var time: TimeInterval
    var date: Date
    
    init(answer: Int, time: TimeInterval, date: Date) {
        self.value = answer
        self.time = time
        self.date = date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: "answer")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(time, forKey: "time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.value = aDecoder.decodeInteger(forKey: "answer")
        self.time = aDecoder.decodeDouble(forKey: "time") 
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
    }
}

class Card: NSObject, NSCoding {
    var frontCard: String
    var backCard: String
    var Q: Double
    var date: Date
    var days: [Int]
    var answers = [Answer]()
    var isReversed: Bool
    var status: Status
    
    init(frontCard: String, backCard: String, isReversed: Bool = true) {
        
        self.frontCard = frontCard
        self.backCard = backCard
        self.date = Date()
        self.Q = 2.0
        self.days = [1]
        self.isReversed = isReversed
        self.status = .new
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(frontCard, forKey: "frontCard")
        aCoder.encode(backCard, forKey: "backCard")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(Q, forKey: "Q")
        aCoder.encode(isReversed, forKey: "isReversed")
        aCoder.encode(days, forKey: "days")
        aCoder.encode(answers, forKey: "answers")
        aCoder.encode(status.rawValue, forKey: "status")
    }
    
    required init(coder aDecoder: NSCoder) {
        frontCard = aDecoder.decodeObject(forKey: "frontCard") as! String
        backCard = aDecoder.decodeObject(forKey: "backCard") as! String
        date = aDecoder.decodeObject(forKey: "date") as! Date
        Q = aDecoder.decodeDouble(forKey: "Q")
        isReversed = aDecoder.decodeBool(forKey: "isReversed")
        days = aDecoder.decodeObject(forKey: "days") as! [Int]
        answers = aDecoder.decodeObject(forKey: "answers") as! [Answer]
        status = Status(rawValue: aDecoder.decodeInteger(forKey: "status"))!
    }
    
    func updateCoefficient(answer: Int) {
        let a = Double(2-answer)
        self.Q += (0.1 - a * (0.3 + a * 0.1))
        if self.Q < 1.3 {
            self.Q = 1.3
        }
    }
    
    func updateStatus() {
        let size = self.days.count
        if self.status != .new && size > 1 {
            if size > 15 || self.days[size-1]-self.days[size-2] > 60 {
                self.status = .learned
                return
            }
        }
        //if status == .new {
        self.status = self.Q < 1.5 ? .hard : .easy
        return
    }
    
    func answerGiven(answer: Answer) {
        self.answers.append(answer)
        updateCoefficient(answer: answer.value)
        if self.status == .new || answer.value == 0 {
            updateStatus()
        } else {
            updateStatus()
            scheduleDate(forAnswer: answer.value)
        }
    }
    
    func scheduleDate(forAnswer answer: Int) {
        if self.status == .learned { return }
        let lastDay = days[days.count-1]
        //TODO: days number exceeds int
        var nextDay = Int(Double(lastDay)*self.Q)
        if nextDay == lastDay {
            nextDay+=1
        }
        days.append(nextDay)
        date = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: nextDay-lastDay, to: Date().today , options: NSCalendar.Options.init(rawValue: 0))!
    }
}
