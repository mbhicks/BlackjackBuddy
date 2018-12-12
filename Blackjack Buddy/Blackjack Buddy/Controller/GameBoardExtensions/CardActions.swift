//
//  CardActions.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/9/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import Foundation
import UIKit

extension GameBoardViewController {
    
    func drawCard(){
        
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        let card = UIImageView(image: topOfDeck.image)
        view.addSubview(card)
        card.frame = topOfDeck.frame
        
        if(isDealer) {
            let cardImageName = model.nextDealerCardImage()
            let cardImage = UIImage(named: cardImageName)
            let numberOfCards = dealerView.subviews.count
            let topOfHand = dealerView.subviews[numberOfCards - 1]
            changeSuperviews(view: card, newSuperview: dealerView)
            
            UIView.transition(with: topOfDeck, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
                card.center.x = topOfHand.center.x + (2*self.xOffset)
                card.center.y = self.dealerView.frame.height/2.0
            }) { (finished) in
                
                self.deckTotal.text = "\(self.model.totalCardsInDeck())"
                self.runningCount.text = "\(self.model.runningCount)"
                self.trueCount.text = "\(self.model.trueCount)"
                self.runningCount.sizeToFit()
                
                self.dealerHandTotal.text = "\(self.model.handCount(for: self.model.dealerHand))"
                self.dealerHandTotal.sizeToFit()
                if(self.model.dealerHand.totalCount() < 17){
                    self.drawCard()
                }
                else {
                    if(!self.model.splitHands.isEmpty){
                        self.lastSplit = false
                    }
                    self.handResults()
                    
                }
                card.image = cardImage
            }
            
        }
            
        else {
            
            let cardImageName : String
            let topOfHand : UIView
            var cardNumber = 0
            var numberOfPreviousCards = 0
            
            if(action == .split){
                cardImageName = model.nextCardImage(for: self.model.splitHands[splitCount])
                
                for i in 0..<splitCount{
                    for _ in model.splitHands[i].cards {
                        numberOfPreviousCards += 1
                    }
                }
                cardNumber = (model.splitHands[splitCount].cards.count - 2) + numberOfPreviousCards//2*(splitCount)
                topOfHand = cardView.subviews[cardNumber]
            }
            else{
                cardImageName = model.nextCardImage(for: self.model.currentHand)
                let numberOfCards = cardView.subviews.count
                topOfHand = cardView.subviews[numberOfCards - 1]
            }
            
            let cardImage = UIImage(named: cardImageName)
            
            changeSuperviews(view: card, newSuperview: cardView)
            
            UIView.transition(with: topOfDeck, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
                card.center.x = topOfHand.center.x + (2*self.xOffset)
                card.center.y = topOfHand.center.y//self.cardView.frame.height/2.0
                if(self.action != .split){
                    card.transform = card.transform.scaledBy(x: 1.5, y: 1.5)
                }
                
            }) { (finished) in
                
                self.deckTotal.text = "\(self.model.totalCardsInDeck())"
                self.runningCount.text = "\(self.model.runningCount)"
                self.trueCount.text = "\(self.model.trueCount)"
                self.runningCount.sizeToFit()
                
                self.handTotal.text = "\(self.model.handCount(for: self.model.currentHand))"
                self.handTotal.sizeToFit()
                card.image = cardImage
                
                switch self.action {
                case .hit:
                    if(self.model.currentHand.totalCount() > 21){
                        self.result = .lose
                        self.cardView.addLabel(for: 0, with: "BUST", 0, self.result)
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
                            self.lose(for: self.betForHands[0].chips)
                        })
                        
                    }
                        
                    else {
                        self.hitButton.isHidden = false
                        self.standButton.isHidden = false
                        self.hintButton.isEnabled = true
                        self.settingsButton.isEnabled = true
                    }
                    
                case .double:
                    if(self.model.currentHand.totalCount() > 21){
                        self.result = .lose
                        self.cardView.addLabel(for: 0, with: "BUST", 0, self.result)
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
                            self.lose(for: self.betForHands[0].chips)
                        })
                    }
                        
                    else {
                        self.revealDealerCards()
                    }
                    
                case .split:
                    
                    var numberOfPreviousCards = 0
                    var numberOfFirstCard = 0
                    
                    for i in 0..<self.splitCount{
                        for _ in 0..<self.model.splitHands[i].cards.count {
                            numberOfPreviousCards += 1
                        }
                        numberOfFirstCard = numberOfPreviousCards
                    }
                    
                    for i in (cardNumber + 2)..<self.cardView.subviews.count{
                        self.cardView.subviews[i].alpha = 0.5
                    }
                    
                    self.handTotal.isHidden = true
                    
                    if(self.splitCount <= (self.splitLabels.count - 1)){
                        let label = self.splitLabels[self.splitCount]
                        let card = self.cardView.subviews[numberOfFirstCard]
                        label.frame.origin.x = card.center.x
                        label.text = self.model.handCount(for: self.model.splitHands[self.splitCount])
                        label.sizeToFit()
                    }
                        
                    else {
                        let card = self.cardView.subviews[numberOfFirstCard]
                        let x = card.center.x
                        let y = card.frame.origin.y + card.frame.height
                        let frame = CGRect(x: x, y: y, width: 0, height: 0)
                        let label = UILabel(frame: frame)
                        self.cardView.addSubview(label)
                        self.changeSuperviews(view: label, newSuperview: self.view)
                        label.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
                        label.textColor = UIColor.white
                        label.text = self.model.handCount(for: self.model.splitHands[self.splitCount])
                        label.sizeToFit()
                        self.splitLabels.append(label)
                    }
                    
                    if(self.model.splitHands[self.splitCount].totalCount() > 21){
                        self.splitLabels[self.splitCount].textColor = UIColor.red
                        if(self.splitCount + 1 < self.model.splitHands.count) {
                            self.nextSplitHand()
                        }
                        else {
                            for card in self.cardView.subviews {
                                card.alpha = 1.0
                            }
                            self.action = .stand
                            self.revealDealerCards()
                        }
                    }
                    
                    if(self.isDouble){
                        self.isDouble = false
                        if(self.splitCount + 1 < self.model.splitHands.count) {
                            self.nextSplitHand()
                        }
                        else{
                            for card in self.cardView.subviews {
                                card.alpha = 1.0
                            }
                            self.action = .double
                            self.revealDealerCards()
                        }
                    }
                        
                    else{
                        self.hitButton.isHidden = false
                        self.standButton.isHidden = false
                        self.hintButton.isEnabled = true
                        self.settingsButton.isEnabled = true
                        
                        if(self.betForHands[self.splitCount].total <= self.model.totalMoney && self.model.splitHands[self.splitCount].cards.count <= 2){
                            self.doubleButton.isHidden = false
                            
                            if(self.model.splitHands[self.splitCount].canSplit() && self.totalSplits < self.maximumSplits){
                                if(self.splitCount == 0 && self.leftSplitTotal < 1) {
                                    self.splitButton.isHidden = false
                                }
                                if(self.splitCount == self.leftSplitTotal + 1 && self.rightSplitTotal < 1){
                                    self.splitButton.isHidden = false
                                }
                            }
                        }
                    }
                    
                default:
                    break
                    
                }
                
            }
            
        }
        
    }
    
    func revealDealerCards() {
        let hiddenCard = dealerView.subviews[0] as! UIImageView
        let dealerTotal = model.dealerHand.totalCount()
        
        hitButton.isHidden = true
        standButton.isHidden = true
        doubleButton.isHidden = true
        splitButton.isHidden = true
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        let newImageName = model.firstDealerCardImage()
        
        UIView.transition(with: hiddenCard, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
            hiddenCard.transform = hiddenCard.transform.scaledBy(x: -1.0, y: 1.0)
            hiddenCard.transform = hiddenCard.transform.scaledBy(x: -1.0, y: 1.0)
            
            
        }) { (finished) in
            hiddenCard.image = UIImage(named: newImageName)
            self.dealerHandTotal.text = "\(self.model.handCount(for: self.model.dealerHand))"
            self.runningCount.text = "\(self.model.runningCount)"
            self.trueCount.text = "\(self.model.trueCount)"
            self.runningCount.sizeToFit()
            self.dealerHandTotal.sizeToFit()
            
            if(self.handTotalIsOn){
                self.dealerHandTotal.isHidden = false
            }
            
            if(dealerTotal < 17){
                self.isDealer = true
                self.drawCard()
                
            }
            else{
                if(!self.model.splitHands.isEmpty){
                    self.lastSplit = false
                }
                self.handResults()
            }
        }
    }
}
