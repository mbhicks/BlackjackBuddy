//
//  ResetBoard.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/9/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import Foundation
import UIKit

extension GameBoardViewController {
    
    func resetBoard() {
        
        UIView.animate(withDuration: kAnimationDuration, animations: {
            for card in self.cardView.subviews {
                card.frame.origin.x = -(card.frame.width) - self.cardView.frame.origin.x
            }
            
            for card in self.dealerView.subviews {
                card.frame.origin.x = -(card.frame.width) - self.dealerView.frame.origin.x
            }
        }) { (finished) in
            
            for bet in self.betForHands {
                for chip in bet.chips {
                    chip.isEnabled = true
                }
            }
            
            if(self.model.totalMoney == 0 && self.model.totalBet == 0){
                let alert = UIAlertController(title: "No More Money", message: "Adding $1000 to bank.", preferredStyle: .alert)
                let confirmation = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                    self.model.addMoney(1000)
                    self.totalMoney.text = "$\(self.model.totalMoney)"
                    self.enableChips()
                })
                alert.addAction(confirmation)
                self.present(alert, animated: true, completion: nil)
            }
            
            self.hitButton.isHidden = true
            self.standButton.isHidden = true
            self.doubleButton.isHidden = true
            self.splitButton.isHidden = true
            self.handTotal.isHidden = true
            self.dealerHandTotal.isHidden = true
            
            self.dealButton.isHidden = false
            if(self.model.totalBet == 0){
                self.totalBet.isHidden = true
                self.dealButton.isEnabled = false
            }
            self.enableChips()
            
            self.action = .noAction
            self.result = .noResult
            self.cardCount = 0
            self.isDealer = false
            self.xOffset = -10
            self.isDouble = false
            self.splitCount = 0
            self.firstSplit = true
            self.isChips = false
            self.totalSplits = 0
            self.leftSplitTotal = 0
            self.rightSplitTotal = 0
            self.firstCardNumber = 0
            self.currentHandNumber = 0
            self.hintButton.isEnabled = true
            self.settingsButton.isEnabled = true
            self.cardsDealt = false
            
            let prefs = UserDefaults.standard
            let deckCount = prefs.integer(forKey: UserDefaultsKeys.numberOfDecks)
            
            if(deckCount != self.model.numberOfDecks){
                self.model.changeNumberOfDecks(to: deckCount)
                self.model.shuffleDeck()
                self.deckTotal.text = "\(self.model.totalCardsInDeck())"
                self.runningCount.text = "\(self.model.runningCount)"
                self.trueCount.text = "\(self.model.trueCount)"
                self.runningCount.sizeToFit()
            }
            
            self.betForHands.removeAll()
            
            for label in self.splitLabels {
                label.removeFromSuperview()
            }
            self.splitLabels.removeAll()
            
            for card in self.cardView.subviews {
                card.removeFromSuperview()
            }
            
            for card in self.dealerView.subviews {
                card.removeFromSuperview()
            }
            
            self.model.resetHands()
        }
    }
}
