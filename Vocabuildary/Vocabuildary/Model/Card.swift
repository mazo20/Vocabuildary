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
    var n = 0
    var date: NSDate
    var days = [Int]()
    var reversed: Bool
    
    init(frontCard: String, backCard: String) {
        
        self.frontCard = frontCard
        self.backCard = backCard
        self.date = NSDate()
        self.n = 0
        self.Q = 2.0
        self.days = [Int]()
        self.reversed = true
        
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(frontCard, forKey: "frontCard")
        aCoder.encodeObject(backCard, forKey: "backCard")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeDouble(Q, forKey: "Q")
        aCoder.encodeInteger(n, forKey: "n")
        aCoder.encodeBool(reversed, forKey: "reversed")
        for i in 0..<n {
            aCoder.encodeInteger(days[i], forKey: "int\(i)")
        }
    }
    required init(coder aDecoder: NSCoder) {
        frontCard = aDecoder.decodeObjectForKey("frontCard") as! String
        backCard = aDecoder.decodeObjectForKey("backCard") as! String
        date = aDecoder.decodeObjectForKey("date") as! NSDate
        Q = aDecoder.decodeDoubleForKey("Q")
        n = aDecoder.decodeIntegerForKey("n")
        reversed = aDecoder.decodeBoolForKey("reversed")
        
        for i in 0..<n {
            days.append(aDecoder.decodeIntegerForKey("int\(i)"))
        }
        n = days.count
    }
}
