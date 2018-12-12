//
//  Constants.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/1/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import Foundation
import UIKit

struct UserDefaultsKeys {
    static let totalMoney = "Total Money"
    static let totalBet = "Total Bet"
    static let numberOfDecks = "Number Of Decks"
    static let showHandTotals = "Show Hand Totals"
    static let showCardCounter = "Show Card Counter"
    static let showDeckTotal = "Show Deck Total"
}

enum cardAction {
    case hit
    case double
    case stand
    case split
    case noAction //default
}

enum handResult {
    case win
    case lose
    case push
    case noResult //default
}
