//
//  BlackjackModel.swift
//  Blackjack Buddy
//
//  Created by MTSS on 11/9/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import Foundation
import GameplayKit

struct cardInfo : Codable {
    var name : String
    var image : String
    var value : Int
}

struct statisticsInfo : Codable {
    var title : String
    var value : Int
    
    enum CodingKeys : String, CodingKey {
        case title = "title"
        case value = "value"
    }
    
    init(title : String, value : Int){
        self.title = title
        self.value = value
    }
}

typealias Stats = [statisticsInfo]

typealias Cards = [cardInfo]

class Hand {
    var cards : Cards
    var hasMultipleTotals : Bool
    
    init(cards : Cards, hasMultipleTotals : Bool){
        self.cards = cards
        self.hasMultipleTotals = hasMultipleTotals
    }
    
    func totalCount() -> Int{
        var total = 0
        
        for card in cards {
            total += card.value
        }
        
        return total
    }
    
    func hasAce() -> Bool {
        for card in cards {
            if card.value == 11{
                return true
            }
        }
        return false
    }
    
    func numberOfAces() -> Int {
        var numberOfAces = 0
        for card in cards {
            if card.value == 11 {
                numberOfAces += 1
            }
        }
        
        return numberOfAces
    }
    
    func hasBlackJack() -> Bool {
        if(totalCount() == 21){
            return true
        }
        
        return false
    }
    
    func clear() {
        cards = [cardInfo]()
    }
    
    func canSplit() -> Bool {
        if(((cards[0].value == cards[1].value) || (cards[0].name.contains("Ace") && cards[1].name.contains("Ace"))) && cards.count == 2){
            return true
        }
        
        return false
    }
    
    func canDouble() -> Bool {
        if(cards.count > 2){
            return false
        }
        
        return true
    }
}

class Model {
    fileprivate let Deck : Cards
    fileprivate var currentDeck : Cards
    fileprivate let stand = "You should stand."
    fileprivate let hit = "You should hit."
    fileprivate let double = "You should double down."
    fileprivate let split = "You should split."
    fileprivate var stats : Stats
    
    var numberOfDecks : Int
    var runningCount = 0
    var trueCount = 0
    var totalMoney = 0
    var totalBet = 0
    var currentHand = Hand.init(cards: [cardInfo](), hasMultipleTotals : false)
    var dealerHand = Hand.init(cards: [cardInfo](), hasMultipleTotals : false)
    var splitHands = [Hand]()
    var appJustOpened = true
    
    let destinationURL : URL
    
    static let sharedInstance = Model()
    
    fileprivate init() {
        let mainBundle = Bundle.main
        
        let filename = "statistics"
        
        let fileManager = FileManager.default
        let statisticsURL = mainBundle.url(forResource: filename, withExtension: "json")
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        destinationURL = documentURL.appendingPathExtension(filename + ".json")
        
        let fileexists = fileManager.fileExists(atPath: destinationURL.path)
        
        if(!fileexists){
            do {
                try fileManager.copyItem(at: statisticsURL!, to: destinationURL)
            }
            catch {
                print(error)
            }
        }
        
        do {
            let data = try Data(contentsOf: destinationURL)
            let decoder = JSONDecoder()
            stats = try decoder.decode(Stats.self, from: data)
        }
        catch {
            print(error)
            stats = []
        }
        
        let cardsURL = mainBundle.url(forResource: "Cards", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: cardsURL!)
            let decoder = PropertyListDecoder()
            Deck = try decoder.decode(Cards.self, from: data)
        }
        catch {
            print(error)
            Deck = []
        }
        
        
        currentDeck = Deck
        
        let prefs = UserDefaults.standard
        numberOfDecks = prefs.integer(forKey: UserDefaultsKeys.numberOfDecks)
        
    }
    
    var numberOfHandsWon : Int {return stats[0].value}
    var numberOfHandsPlayed : Int {return stats[1].value}
    var numberOfBlackjacks : Int {return stats[2].value}
    var numberOfSplits : Int {return stats[3].value}
    var numberOfDoubleDowns : Int {return stats[4].value}
    var biggestWin : Int {return stats[5].value}
    var totalGain : Int {return stats[6].value}
    
    func addHandWon() {
        stats[0].value += 1
        encodeStats()
    }
    
    func addHandPlayed() {
        stats[1].value += 1
        encodeStats()
    }
    
    func addBlackjack() {
        stats[2].value += 1
        encodeStats()
    }
    
    func addSplit() {
        stats[3].value += 1
        encodeStats()
    }
    
    func addDoubleDown() {
        stats[4].value += 1
        encodeStats()
    }
    
    func addGain(for amount : Int) {
        stats[6].value += amount
        if(amount > stats[5].value){
            stats[5].value = amount
        }
        encodeStats()
    }
    
    func encodeStats() {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(stats)
            try data.write(to: destinationURL)
        }
        catch {
            print(error)
        }
    }
    
    func shuffleDeck() {
        
        currentDeck = Deck
        
        for _ in 1..<numberOfDecks {
            currentDeck.append(contentsOf: Deck)
        }
        
        currentDeck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: currentDeck) as! Cards
        
        runningCount = 0
        trueCount = 0
    }
    
    func removeMoney(_ amount : Int){
        totalMoney -= amount
    }
    
    func addMoney(_ amount : Int){
        totalMoney += amount
    }
    
    func addBet(_ amount : Int){
        totalBet += amount
    }
    
    func removeFromBet(_ amount : Int){
        totalBet -= amount
    }
    
    func clearBet(){
        totalBet = 0
    }
    
    func nextCardImage(for hand : Hand) -> String {
        let nextCard = currentDeck[0]
        currentDeck.remove(at: 0)
        
        if(!currentDeck.isEmpty){
            updateRunningCount(for: nextCard)
            updateTrueCount(for: nextCard)
        }
        
        else{
            shuffleDeck()
        }
        
        hand.cards.append(nextCard)
        
        return nextCard.image
    }
    
    func nextDealerCardImage() -> String {

        let nextCard = currentDeck[0]
        currentDeck.remove(at: 0)
        
        if(dealerHand.cards.count > 0 && !currentDeck.isEmpty){
            updateRunningCount(for: nextCard)
            updateTrueCount(for: nextCard)
        }
        

        
        if(currentDeck.isEmpty){
            shuffleDeck()
        }
        
        dealerHand.cards.append(nextCard)
        
        return nextCard.image
    }
    
    func handCount(for hand : Hand) -> String {
        
        let totalAces = hand.numberOfAces()
        
        if(hand.hasAce()){
            var oneTotal = totalAces
            for card in hand.cards {
                if card.value != 11 {
                    oneTotal += card.value
                }
            }
            
            if(totalAces > 1) {
                var aceCount = 0
                for i in 0..<hand.cards.count {
                    if hand.cards[i].value == 11 {
                        aceCount += 1
                        if(aceCount != totalAces){
                            hand.cards[i].value = 1
                        }
                    }
                }
            }
            
            if(hand.totalCount() > 21){
                for i in 0..<hand.cards.count {
                    //var card = card
                    if hand.cards[i].value == 11 {
                        hand.cards[i].value = 1
                    }
                }
                hand.hasMultipleTotals = false
                return "\(hand.totalCount())"
            }
            
            else{
                hand.hasMultipleTotals = true
                return "\(oneTotal)/\(hand.totalCount())"
            }
        }
        
        else{
            hand.hasMultipleTotals = false
            return "\(hand.totalCount())"
        }
    }
    
    func clearHands() {
        currentHand.clear()
        dealerHand.clear()
    }
    
    func firstDealerCardImage() -> String {
        updateRunningCount(for: dealerHand.cards[0])
        updateTrueCount(for: dealerHand.cards[0])
        return dealerHand.cards[0].image
    }
    
    func splitDeck(for handNumber : Int){
        let splitHand1 = Hand.init(cards: [cardInfo](), hasMultipleTotals : false)
        let splitHand2 = Hand.init(cards: [cardInfo](), hasMultipleTotals : false)
        
        if(splitHands.isEmpty){
            
            for i in 0..<currentHand.cards.count {
                if currentHand.cards[i].value == 1 {
                    currentHand.cards[i].value = 11
                }
            }
            
            splitHand1.cards.append(currentHand.cards[0])
            splitHand2.cards.append(currentHand.cards[1])
            
            splitHands.append(splitHand1)
            splitHands.append(splitHand2)
            
        }
        
        else {
            for hand in splitHands{
                for i in 0..<hand.cards.count {
                    if hand.cards[i].value == 1 {
                        hand.cards[i].value = 11
                    }
                }
            }
            
            splitHand1.cards.append(splitHands[handNumber].cards[0])
            splitHand2.cards.append(splitHands[handNumber].cards[1])
            
            splitHands.remove(at: handNumber)
            
            splitHands.insert(splitHand1, at: handNumber)
            
            //If the end hand is being split
            if((handNumber + 1) > (splitHands.count - 1)){
                splitHands.append(splitHand2)
            }
            else {
                splitHands.insert(splitHand2, at: handNumber + 1)
            }
        }
    }
    
    func resetHands() {
        currentHand.cards.removeAll()
        dealerHand.cards.removeAll()
        splitHands.removeAll()
    }
    
    func changeNumberOfDecks(to number : Int) {
        numberOfDecks = number
    }
    
    func totalCardsInDeck() -> Int {
        return currentDeck.count
    }
    
    func updateRunningCount(for card : cardInfo){
        if(card.value >= 2 && card.value <= 6){
            runningCount += 1
        }
        else if(card.value >= 10 || card.value == 1){
            runningCount -= 1
        }
        
    }
    
    func updateTrueCount(for card : cardInfo) {
        let cardsInDeck = currentDeck.count
        
        let percentageOfCardsLeft = Double(cardsInDeck)/Double(numberOfDecks * Deck.count)
        let numberOfRemainingDecks = Double(numberOfDecks) * percentageOfCardsLeft
        
        trueCount = Int(round(Double(runningCount)/numberOfRemainingDecks))
        
    }
    
    func hintResponse(for handNumber : Int) -> String {
        
        let dealerUpCard = dealerHand.cards[1].value
        let hand : Hand
        
        if(splitHands.isEmpty){
            hand = currentHand
            
        }
        else {
            hand = splitHands[handNumber]
        }
        
        let currentTotal = hand.totalCount()
        
        if (hand.hasAce() && hand.hasMultipleTotals){
            
            if(hand.canSplit()){
                return split
            }
            
            else{
            
                if(currentTotal >= 18){
                    return stand
                }
                
                else {
                    if(dealerUpCard >= 7){
                        if(currentTotal == 18){
                            if(dealerUpCard == 7 || dealerUpCard == 8){
                                return stand
                            }
                            
                            return hit
                        }
                        
                        return hit
                    }
                    
                    else {
                        if(currentTotal == 13 || currentTotal == 14){
                            if(dealerUpCard >= 5 && hand.canDouble()){
                                return double
                            }

                            return hit
                        }
                        
                        else if(currentTotal == 15 || currentTotal == 16){
                            if(dealerUpCard >= 4 && hand.canDouble()){
                                return double
                            }
                            
                            return hit
                        }
                        
                        else {
                            if(currentTotal == 17){
                                if(dealerUpCard >= 3 && hand.canDouble()){
                                    return double
                                }
                                
                                return hit
                            }
                            
                            else {
                                if(dealerUpCard >= 3 && hand.canDouble()){
                                    return double
                                }
                                
                                return stand
                            }
                        }
                    }
                }
            }
        }
        
        else {
            
            if(hand.canSplit()){
                if(currentTotal == 20){
                    return stand
                }
                
                else if(currentTotal == 16){
                    return split
                }
                
                else if(currentTotal == 18){
                    if(dealerUpCard == 7 || dealerUpCard >= 10){
                        return stand
                    }
                    
                    return split
                }
                
                else if(currentTotal == 10){
                    if(dealerUpCard >= 10){
                        return hit
                    }
                    
                    return double
                }
                
                else if(currentTotal == 8){
                    if(dealerUpCard == 5 || dealerUpCard == 6){
                        return split
                    }
                    
                    return hit
                }
                    
                else if(currentTotal == 12){
                    if(dealerUpCard >= 7){
                        return hit
                    }
                    
                    return split
                }
                
                else {
                    if(dealerUpCard >= 8){
                        return hit
                    }
                    
                    return split
                    
                }
            }
            
            else {
                if(currentTotal >= 17){
                    return stand
                }
                
                else if(currentTotal <= 8) {
                    return hit
                }
                    
                else if(currentTotal == 10){
                    if(dealerUpCard <= 9 && hand.canDouble()){
                        return double
                    }
                    else {
                        return hit
                    }
                }
                    
                else if(currentTotal == 11){
                    
                    if(hand.canDouble()){
                        return double
                    }
                    
                    return hit
                }
                
                else {
                    if(dealerUpCard <= 6){
                        if(currentTotal <= 16 && currentTotal >= 12){
                            if(currentTotal == 12 && dealerUpCard <= 3){
                                return hit
                            }
                            
                            else {
                                return stand
                            }
                        }
      
                        else{
                            if(dealerUpCard <= 6 && dealerUpCard >= 3 && hand.canDouble()){
                                return double
                            }
                            
                            else {
                                return hit
                            }
                        }
                    }
                    
                    else {
                        return hit
                    }
                }
            }

        }
    }

}
