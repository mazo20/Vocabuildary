//
//  DeckStore.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 30.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation

class DeckStore: NSObject{
    var decks = [Deck]()
    let decksArchiveURL: URL = {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("decks.archive")
    }()
    var cards: [Int] {
        var cardType = [0, 0, 0, 0]
        for deck in decks {
            for card in deck.cards {
                switch card.status {
                case .easy, .hard: cardType[1]+=1
                case .new: cardType[2]+=1
                case .learned: cardType[3]+=1
                }
            }
        }
        cardType[0] = cardType[1] + cardType[2] + cardType[3]
        return cardType
    }
    
    override init() {
        if let archivedDecks = NSKeyedUnarchiver.unarchiveObject(withFile: decksArchiveURL.path) as? [Deck] {
            decks += archivedDecks
        } else {
            let onboardingArrayFront = ["Tap „Show answer” to flip the card",
                                        "Based on your answer the app will show the card again just when you will about to forget it.", "Come back everyday to study new cards and repeat previous ones",
                                        "Add your cards to begin studying"]
            let onboardingArrayBack = ["Rate how well did you know the answer",
                                       "The algorithm will adjust itself to maximize the learning efficiency!",
                                       "You can change the number of new daily cards in the settings",
                                       "You can group them in decks"]
            let onboardingDeck = Deck(name: "Welcome to Vocabuildary!")
            for i in 0...3 {
                let card = Card(frontCard: onboardingArrayFront[i], backCard: onboardingArrayBack[i], isReversed: false)
                //card.days.count+=1
                card.days.append(1)
                onboardingDeck.cards.append(card)
            }
            //decks.append(onboardingDeck)
        }
    }
    func saveChanges() -> Bool {
        print("Saving decks to \(decksArchiveURL.path)")
        
        
        
        return NSKeyedArchiver.archiveRootObject(decks, toFile: decksArchiveURL.path)
        
    }
    
    
    func removeDeck(_ deck: Deck) {
        if let index = decks.index(of: deck) {
            decks.remove(at: index)
        }
    }
    
    func moveDeckAtIndex(_ fromIndex: Int, toIndex:Int) {
        guard fromIndex != toIndex else { return }
        let deck = decks[fromIndex]
        decks.remove(at: fromIndex)
        decks.insert(deck, at: toIndex)
    }
}
