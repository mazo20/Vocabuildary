//
//  Card.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 28.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation

class Card: NSObject, NSCoding {
    var frontCard: String = ""
    var backCard: String = ""
    var Q = 2.0
    var numberOfViews = 0
    var date: NSDate
    var days = [Int]()
    var isReversed: Bool
    
    init(frontCard: String, backCard: String) {
        
        self.frontCard = frontCard
        self.backCard = backCard
        self.date = NSDate()
        self.numberOfViews = 0
        self.Q = 2.0
        self.days = [Int]()
        self.isReversed = true
        
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(frontCard, forKey: "frontCard")
        aCoder.encodeObject(backCard, forKey: "backCard")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeDouble(Q, forKey: "Q")
        aCoder.encodeInteger(numberOfViews, forKey: "numberOfViews")
        aCoder.encodeBool(isReversed, forKey: "isReversed")
        for i in 0..<numberOfViews {
            aCoder.encodeInteger(days[i], forKey: "int\(i)")
        }
    }
    required init(coder aDecoder: NSCoder) {
        frontCard = aDecoder.decodeObjectForKey("frontCard") as! String
        backCard = aDecoder.decodeObjectForKey("backCard") as! String
        date = aDecoder.decodeObjectForKey("date") as! NSDate
        Q = aDecoder.decodeDoubleForKey("Q")
        numberOfViews = aDecoder.decodeIntegerForKey("numberOfViews")
        isReversed = aDecoder.decodeBoolForKey("isReversed")
        
        for i in 0..<numberOfViews {
            days.append(aDecoder.decodeIntegerForKey("int\(i)"))
        }
        numberOfViews = days.count
    }
}
