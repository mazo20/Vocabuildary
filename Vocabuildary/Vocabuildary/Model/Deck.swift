//
//  Deck.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 28.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation

class Deck: NSObject, NSCoding {
    var name: String = ""
    var deck = [Card]()
    var time = NSTimeInterval()
    var history = [DeckHistory]()
    var newCardsToday = 0
    var priority = 0
    var numberOfRepeats: Int {
        var repeats = 0
        for history in self.history {
            repeats+=history.numberOfCards
        }
        return repeats
    }
    
    func historyForDate(date: String) -> DeckHistory? {
        if history.count == 0 {return nil}
        for deckHistory in history {
            if deckHistory.date == date {
                //printD(deckHistory.date)
                return deckHistory
            }
        }
        return nil
    }
    
    func addCard(card: Card) {
        deck.append(card)
    }
    func removeCard(card: Card) {
        if let index = deck.indexOf(card) {
            deck.removeAtIndex(index)
        }
    }
    init(name: String) {
        self.name = name
        super.init()
    }
    func moveDeckAtIndex(fromIndex: Int, toIndex:Int) {
        if fromIndex == toIndex {
            return
        }
        let card = deck[fromIndex]
        deck.removeAtIndex(fromIndex)
        deck.insert(card, atIndex: toIndex)
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(deck, forKey: "deck")
        aCoder.encodeObject(history, forKey: "history")
        aCoder.encodeObject(newCardsToday, forKey: "newCardsToday")
        aCoder.encodeObject(priority, forKey: "priority")
    }
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        deck = aDecoder.decodeObjectForKey("deck") as! [Card]
        history = aDecoder.decodeObjectForKey("history") as! [DeckHistory]
        if aDecoder.decodeObjectForKey("priority") != nil {
            priority = aDecoder.decodeObjectForKey("priority") as! Int
        } else {
            priority = 0
        }
        newCardsToday = aDecoder.decodeObjectForKey("newCardsToday") as! Int
        super.init()
    }
    func shuffle() {
        let d = deck.count
        if d<2 {return}
        for i in 0..<d-1 {
            let j = Int(arc4random_uniform(UInt32(d-i))) + i
            if i != j {
                swap(&deck[i], &deck[j])
            }
        }
    }
}
