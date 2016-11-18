//
//  Deck.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 28.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation

class Deck: NSObject, NSCoding {
    var name: String
    var cards = [Card]()
    var cardsForToday = [Card]()
    var extraCards = [Card]()
    var newCardsToday: Int
    var lastDate: Date
    //var priority = 0
    
    init(name: String) {
        self.name = name
        self.newCardsToday = 0
        self.lastDate = Date()
        super.init()
    }
    
    
    func cardsInDeckForToday() {
        if !NSCalendar.current.isDate(Date(), inSameDayAs: lastDate) {
            lastDate = Date()
            newCardsToday = 0
        }
        let newCardsLimit = UserDefaults.standard.object(forKey: "newCards") as! Int
        cardsForToday = [Card]()
        var cardsForTodayLeft = newCardsLimit-newCardsToday
        for card in self.cards {
            if card.status == .new && cardsForTodayLeft>0 {
                cardsForToday.append(card)
                cardsForTodayLeft-=1
            } else if card.status != .new && NSCalendar.current.compare(Date(), to: card.date, toGranularity: .day) != .orderedAscending {
                self.cardsForToday.append(card)
            }
        }
        cardsForToday = shuffle(array: cardsForToday)
    }
    
    func whatCards(_ cards: [Card]) -> [Int] {
        var array = [0,0,0]
        for card in cards {
            switch card.status {
            case .new: array[0]+=1
            case .easy: array[1]+=1
            case .hard: array[2]+=1
            default: print("learned card cannot be counted")
            }
        }
        return array
    }
    
    func removeCard(_ card: Card) {
        if let index = cards.index(of: card) {
            cards.remove(at: index)
        }
    }
    
    func moveCardAtIndex(_ fromIndex: Int, toIndex:Int) {
        guard fromIndex != toIndex else {return}
        let card = cards[fromIndex]
        cards.remove(at: fromIndex)
        cards.insert(card, at: toIndex)
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(cards, forKey: "deck")
        aCoder.encode(cardsForToday, forKey: "cardsForToday")
        aCoder.encode(newCardsToday, forKey: "newCardsToday")
        aCoder.encode(lastDate, forKey: "lastDate")
        //aCoder.encode(priority, forKey: "priority")
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        cards = aDecoder.decodeObject(forKey: "deck") as! [Card]
        //priority = aDecoder.decodeObject(forKey: "priority") as! Int
        newCardsToday = aDecoder.decodeInteger(forKey: "newCardsToday")
        cardsForToday = aDecoder.decodeObject(forKey: "cardsForToday") as! [Card]
        lastDate = aDecoder.decodeObject(forKey: "lastDate") as! Date
        super.init()
    }
    
    func shuffle<T>(array: [T]) -> [T] {
        let size = array.count
        guard size>1 else {return array}
        var copy = [T]()
        array.forEach({ copy.append($0) })
        for i in 0..<size-1 {
            let j = Int(arc4random_uniform(UInt32(size-i))) + i
            if i != j {
                swap(&copy[i], &copy[j])
            }
        }
        return copy
    }
}
