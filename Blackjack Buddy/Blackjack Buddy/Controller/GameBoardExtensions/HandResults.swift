//
//  HandResults.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/9/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import Foundation
import UIKit

extension GameBoardViewController {
    func push(for chips : [UIButton]){
        cancelButton.isHidden = false
        
        UIView.animate(withDuration: kAnimationDuration, animations: {
            for chip in chips {
                chip.transform = chip.transform.scaledBy(x: 2.0, y: 2.0)
                chip.transform = chip.transform.scaledBy(x: 0.5, y: 0.5)
            }
        }) { (finished) in
            
            if(!self.lastSplit && !self.model.splitHands.isEmpty){
                self.currentHandNumber += 1
                self.handResults()
            }
            if(self.lastSplit){
                self.resetBoard()
            }
        }
    }
    
    func lose(for chips : [UIButton]){
        
        view.bringSubviewToFront(betView)
        
        UIView.animate(withDuration: 2*kAnimationDuration, animations: {
            for chip in chips {
                chip.frame.origin.y = -(chip.frame.height) - self.betView.frame.origin.y
            }
        }) { (finished) in
            
            
            for chip in chips{
                chip.removeFromSuperview()
                self.model.removeFromBet(chip.tag)
            }
            
            let prefs = UserDefaults.standard
            prefs.set(self.model.totalBet, forKey: UserDefaultsKeys.totalBet)
            
            self.totalBet.text = "$\(self.model.totalBet)"
            
            if(!self.lastSplit && !self.model.splitHands.isEmpty){
                self.currentHandNumber += 1
                self.handResults()
            }
                
            else if(self.lastSplit){
                self.resetBoard()
            }
        }
    }
    
    func win(for chips : [UIButton]){
        
        model.addHandWon()
        cancelButton.isHidden = false
        
        var totalWin = 0
        
        var newChips = [UIButton]()
        
        for chip in chips {
            let newChip = UIButton(type: .custom)
            let chipImage = chip.imageView!.image!
            
            betView.addSubview(newChip)
            newChip.setImage(chipImage, for: .normal)
            newChip.setImage(chipImage, for: .disabled)
            newChip.addTarget(self, action: #selector(removeChip(_:)), for: .touchUpInside)
            newChip.tag = chip.tag
            
            newChip.frame = chip.frame
            newChip.frame.origin.y = -(newChip.frame.width) - betView.frame.origin.y
            
            newChips.append(newChip)
            
            model.addBet(chip.tag)
            totalWin += chip.tag
        }
        
        model.addGain(for: totalWin)
        
        let prefs = UserDefaults.standard
        prefs.set(model.totalBet, forKey: UserDefaultsKeys.totalBet)
        
        view.bringSubviewToFront(betView)
        UIView.animate(withDuration: kAnimationDuration, animations: {
            for chip in newChips {
                self.placeChip(chip)
            }
        }) { (finished) in
            
            self.totalBet.text = "$\(self.model.totalBet)"
            
            if(!self.lastSplit && !self.model.splitHands.isEmpty){
                self.currentHandNumber += 1
                self.handResults()
            }
            
            if(self.lastSplit){
                self.resetBoard()
            }
        }
    }
    
    func blackjack() {
        
        model.addBlackjack()
        model.addHandWon()
        
        hitButton.isHidden = true
        standButton.isHidden = true
        doubleButton.isHidden = true
        splitButton.isHidden = true
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        let total = betForHands[0].total
        var blackjackTotal = Int(Double(total) * 1.5)
        
        model.addGain(for: blackjackTotal)
        model.addBet(blackjackTotal)
        
        let prefs = UserDefaults.standard
        prefs.set(model.totalBet, forKey: UserDefaultsKeys.totalBet)
        
        view.bringSubviewToFront(betView)
        
        UIView.animate(withDuration: kAnimationDuration, animations: {
            if(blackjackTotal > 100){
                let numberOfChips = blackjackTotal/100
                blackjackTotal -= numberOfChips * 100
                self.addBlackjackChips(for: numberOfChips, of: self.oneHundredChip)
                
            }
            
            if(blackjackTotal > 50){
                let numberOfChips = blackjackTotal/50
                blackjackTotal -= numberOfChips * 50
                self.addBlackjackChips(for: numberOfChips, of: self.fiftyChip)
            }
            
            if(blackjackTotal > 25){
                let numberOfChips = blackjackTotal/25
                blackjackTotal -= numberOfChips * 25
                self.addBlackjackChips(for: numberOfChips, of: self.twentyFiveChip)
            }
            
            if(blackjackTotal > 5){
                let numberOfChips = blackjackTotal/5
                blackjackTotal -= numberOfChips * 5
                self.addBlackjackChips(for: numberOfChips, of: self.fiveChip)
            }
            
            if(blackjackTotal > 1){
                let numberOfChips = blackjackTotal
                blackjackTotal -= numberOfChips
                self.addBlackjackChips(for: numberOfChips, of: self.oneChip)
            }
        }) { (finished) in
            if(blackjackTotal == 0){
                self.totalBet.text = "$\(self.model.totalBet)"
                self.cancelButton.isHidden = false
                self.resetBoard()
            }
        }
    }
    
    func handResults() {
        let hand : Hand
        let dealerTotal = model.dealerHand.totalCount()
        
        if(currentHandNumber == self.model.splitHands.count - 1){
            self.lastSplit = true
        }
        
        if(self.model.splitHands.isEmpty){
            hand = self.model.currentHand
        }
        else{
            hand = self.model.splitHands[currentHandNumber]
        }
        
        if(hand.totalCount() > 21){
            self.result = .lose
            cardView.addLabel(for: firstCardNumber, with: "BUST", currentHandNumber, result)
            let hiddenCard = self.dealerView.subviews[0] as! UIImageView
            let newImageName = self.model.firstDealerCardImage()
            UIView.transition(with: hiddenCard, duration: self.kAnimationDuration, options: .curveEaseInOut, animations: {
                hiddenCard.transform = hiddenCard.transform.scaledBy(x: -1.0, y: 1.0)
                hiddenCard.transform = hiddenCard.transform.scaledBy(x: -1.0, y: 1.0)
            }, completion: { (finished) in
                hiddenCard.image = UIImage(named: newImageName)
                self.runningCount.text = "\(self.model.runningCount)"
                self.trueCount.text = "\(self.model.trueCount)"
                self.runningCount.sizeToFit()
                self.lose(for: self.betForHands[self.currentHandNumber].chips)
            })
            
        }
            
        else if (dealerTotal > 21 || hand.totalCount() > dealerTotal){
            self.result = .win
            cardView.addLabel(for: firstCardNumber, with: "WIN", currentHandNumber, result)
            self.win(for: self.betForHands[currentHandNumber].chips)
        }
            
        else if(dealerTotal == hand.totalCount()){
            self.result = .push
            cardView.addLabel(for: firstCardNumber, with: "PUSH", currentHandNumber, result)
            self.push(for: self.betForHands[currentHandNumber].chips)
        }
        else {
            self.result = .lose
            cardView.addLabel(for: firstCardNumber, with: "LOSE", currentHandNumber, result)
            self.lose(for: self.betForHands[currentHandNumber].chips)
        }
        
        firstCardNumber += hand.cards.count
    }

}

