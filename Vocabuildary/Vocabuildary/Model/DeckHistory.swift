//
//  CardHistory.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 23.05.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import UIKit

class DeckHistory: NSObject, NSCoding {
    var date = stringFromDate(NSDate().today)
    var answers = [0, 0, 0]
    var numberOfCards = 0
    var time = NSTimeInterval()
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeInteger(numberOfCards, forKey: "numberOfCards")
        for i in 0...2 {
            aCoder.encodeInteger(answers[i], forKey: "answers\(i)")
        }
        aCoder.encodeObject(time, forKey: "time")
    }
    override init() {
        date = stringFromDate(NSDate().today)
        //print(date)
        answers = [0, 0, 0]
        numberOfCards = 0
        
    }
    required init(coder aDecoder: NSCoder) {
        date = aDecoder.decodeObjectForKey("date") as! String
        numberOfCards = aDecoder.decodeIntegerForKey("numberOfCards")
        for i in 0...2 {
            answers[i] = aDecoder.decodeIntegerForKey("answers\(i)")
        }
        time = aDecoder.decodeObjectForKey("time") as! NSTimeInterval
    }
}
