//
//  DeckStore.swift
//  Vocabuildary
//
//  Created by Maciej Kowalski on 30.04.2016.
//  Copyright © 2016 Maciej Kowalski. All rights reserved.
//

import Foundation

class DeckStore: NSObject{
    var deckStore = [Deck]()
    let decksArchiveURL: NSURL = {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent("decks.archive")
    }()
    var cards: [Int] {
        var cards = 0
        var notShown = 0
        var learned = 0
        for deck in deckStore {
            for card in deck.deck {
                let d = card.days.count
                cards+=1
                if card.numberOfViews == 0 {
                    notShown+=1
                }
                if d > 1 {
                    if card.days[d-1]-card.days[d-2] > 60 {
                        learned+=1
                    }
                }
            }
        }
        let toStudy = cards - notShown - learned
        return [cards, toStudy, notShown, learned]
    }
    
    func addDeck(deck: Deck) {
        deckStore.append(deck)
    }
    func deleteDeck(deck: Deck) {
        deckStore.removeAtIndex(deckStore.indexOf(deck)!)
    }
    override init() {
        if let archivedDecks = NSKeyedUnarchiver.unarchiveObjectWithFile(decksArchiveURL.path!) as? [Deck] {
            deckStore += archivedDecks
        } else {
            let onboardingDeck = Deck(name: "Welcome to Vocabuildary!")
            let onboardingCard1 = Card(frontCard: "Tap „Show answer” to flip the card", backCard: "Rate how well did you know the answer")
            let onboardingCard2 = Card(frontCard: "Based on your answer the app will  show the card again just when you will about to forget it.", backCard: "The algorithm will adjust itself to maximize the learning efficiency!")
            let onboardingCard3 = Card(frontCard: "Come back everyday to study new cards and repeat previous ones", backCard: "You can change the number of new daily cards in the settings")
            let onboardingCard4 = Card(frontCard: "Add your cards to begin studying", backCard: "You can group them in decks")
            onboardingCard1.numberOfViews+=1
            onboardingCard2.numberOfViews+=1
            onboardingCard3.numberOfViews+=1
            onboardingCard4.numberOfViews+=1
            onboardingCard2.days.append(1)
            onboardingCard3.days.append(1)
            onboardingCard4.days.append(1)
            onboardingCard1.days.append(1)
            onboardingCard1.isReversed = false
            onboardingCard2.isReversed = false
            onboardingCard3.isReversed = false
            onboardingCard4.isReversed = false
            onboardingDeck.deck.append(onboardingCard1)
            onboardingDeck.deck.append(onboardingCard2)
            onboardingDeck.deck.append(onboardingCard3)
            onboardingDeck.deck.append(onboardingCard4)
            deckStore.append(onboardingDeck)
        }
    }
    func saveChanges() -> Bool {
        print("Saving decks to \(decksArchiveURL.path!)")
        return NSKeyedArchiver.archiveRootObject(deckStore, toFile: decksArchiveURL.path!)
    }
    func deckAtIndex(index: Int) -> Deck {
        return deckStore[index]
    }
    func deckWithName(name: String) -> Deck? {
        for deck in deckStore {
            if deck.name == name {
                return deck
            }
        }
        return nil
    }
    func removeDeck(deck: Deck) {
        if let index = deckStore.indexOf(deck) {
            deckStore.removeAtIndex(index)
        }
    }
    func moveDeckAtIndex(fromIndex: Int, toIndex:Int) {
        if fromIndex == toIndex {
            return
        }
        let deck = deckStore[fromIndex]
        deckStore.removeAtIndex(fromIndex)
        deckStore.insert(deck, atIndex: toIndex)
    }
}
