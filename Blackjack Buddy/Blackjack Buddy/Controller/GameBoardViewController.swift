//
//  GameBoardViewController.swift
//  Blackjack Buddy
//
//  Created by MTSS on 11/12/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import UIKit

class Bet {
    var chips : [UIButton]
    var total : Int
    
    init(chips : [UIButton], total : Int){
        self.chips = chips
        self.total = total
    }
}

class GameBoardViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let model = Model.sharedInstance
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var totalMoney: UILabel!
    @IBOutlet weak var betView: UIView!
    @IBOutlet weak var totalBet: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var chipView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var dealerView: UIView!
    @IBOutlet weak var handTotal: UILabel!
    @IBOutlet weak var dealerHandTotal: UILabel!
    
    @IBOutlet weak var oneChip: UIButton!
    @IBOutlet weak var fiveChip: UIButton!
    @IBOutlet weak var twentyFiveChip: UIButton!
    @IBOutlet weak var fiftyChip: UIButton!
    @IBOutlet weak var oneHundredChip: UIButton!
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var standButton: UIButton!
    @IBOutlet weak var doubleButton: UIButton!
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var topOfDeck: UIImageView!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var deckTotal: UILabel!
    @IBOutlet weak var deckTotalImage: UIImageView!
    @IBOutlet weak var runningCount: UILabel!
    @IBOutlet weak var cardCountingView: UIView!
    @IBOutlet weak var trueCount: UILabel!
    
    //MARK: - Helper Variables
    
    var action = cardAction.noAction
    var result = handResult.noResult
    
    var handTotalIsOn = true
    var cardCounterIsOn = false
    var deckTotalIsOn = false
    
    var cardsDealt = false
    
    let kAnimationDuration = 1.0
    let kAnimationDelay = 1.0
    
    var cardCount = 0
    var isDealer = false
    var xOffset : CGFloat = -10.0
    let numberOfPlayers = 1
    let maximumSplits = 3
    var isDouble = false
    var splitCount = 0
    var firstSplit = true
    var isChips = false
    var totalSplits = 0
    var lastSplit = true
    var currentHandNumber = 0
    var firstCardNumber = 0
    var hintToggled = false
    var leftSplitTotal = 0
    var rightSplitTotal = 0
    
    //MARK: - Arrays
    
    var betForHands = [Bet]()
    var currentHand = [String]()
    var dealerHand = [String]()
    var splitLabels = [UILabel]()
    
    //MARK: - View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs = UserDefaults.standard
        
        if(model.appJustOpened){
            let totalBet = prefs.integer(forKey: UserDefaultsKeys.totalBet)
            let totalMoney = prefs.integer(forKey: UserDefaultsKeys.totalMoney)
            
            model.addMoney(totalMoney)
            model.addMoney(totalBet)
            
            model.shuffleDeck()
        }
        
        deckTotal.text = "\(model.totalCardsInDeck())"
        runningCount.text = "\(model.runningCount)"
        trueCount.text = "\(model.trueCount)"
        runningCount.sizeToFit()
        
        model.appJustOpened = false
        
        cancelButton.isHidden = true
        dealButton.isEnabled = false
        handTotal.isHidden = true
        totalBet.isHidden = true
        hitButton.isHidden = true
        standButton.isHidden = true
        doubleButton.isHidden = true
        splitButton.isHidden = true
        dealerHandTotal.isHidden = true
        
        hintLabel.alpha = 0.0
        hintLabel.backgroundColor = UIColor.init(white: 0.0, alpha: 0.65)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameBoardViewController.dismissHint(_:)))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        
        
        model.addMoney(model.totalBet)
        model.clearBet()
        
        model.clearHands()
        
        totalMoney.text = "$\(model.totalMoney)"
        totalMoney.sizeToFit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let prefs = UserDefaults.standard
        
        handTotalIsOn = prefs.bool(forKey: UserDefaultsKeys.showHandTotals)
        cardCounterIsOn = prefs.bool(forKey: UserDefaultsKeys.showCardCounter)
        deckTotalIsOn = prefs.bool(forKey: UserDefaultsKeys.showDeckTotal)
        let deckCount = prefs.integer(forKey: UserDefaultsKeys.numberOfDecks)
        
        if(handTotalIsOn && cardsDealt){
            handTotal.isHidden = false
        }
        else {
            handTotal.isHidden = true
        }
        
        if(cardCounterIsOn){
            cardCountingView.isHidden = false
        }
        else {
            cardCountingView.isHidden = true
        }
        
        if(deckTotalIsOn){
            deckTotal.isHidden = false
            deckTotalImage.isHidden = false
        }
        else {
            deckTotal.isHidden = true
            deckTotalImage.isHidden = true
        }
        
        if(deckCount != model.numberOfDecks && model.currentHand.cards.isEmpty){
            model.changeNumberOfDecks(to: deckCount)
            model.shuffleDeck()
            deckTotal.text = "\(model.totalCardsInDeck())"
            runningCount.text = "\(model.runningCount)"
            trueCount.text = "\(model.trueCount)"
            runningCount.sizeToFit()
        }
    }
    
    //MARK: - Hint Actions
    
    @IBAction func toggleHint(_ sender: UIButton) {
        
        if(!hintToggled){
            
            hintButton.setTitleColor(UIColor.cyan, for: .normal)
            
            
            if(dealButton.isHidden){
                hintLabel.text = model.hintResponse(for: splitCount)
            }
        
            else if(betView.subviews.count <= 2) {
                hintLabel.text = "You should place a bet."
            }
        
            else {
                hintLabel.text = "You should tap DEAL."
            }
        
            view.bringSubviewToFront(hintLabel)
            
            hintLabel.sizeToFit()
            hintLabel.fadeIn()
            hintLabel.layer.cornerRadius = 5
        }
        
        else {
            hintButton.setTitleColor(UIColor.white, for: .normal)
            hintLabel.fadeOut()
        }
        
        hintToggled = !hintToggled
    }
    
    @objc func dismissHint(_ sender : UITapGestureRecognizer){
        if(hintToggled){
            hintButton.setTitleColor(UIColor.white, for: .normal)
            hintLabel.fadeOut()
            hintToggled = !hintToggled
        }
    }
    
    
    //MARK: - Betting Actions
    
    @IBAction func clearBet(_ sender: UIButton) {
        self.cancelButton.isHidden = true
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        var chips = [UIView]()
        self.totalBet.isHidden = true
        for i in 2...(betView.subviews.count - 1) {
            chips.append(betView.subviews[i])
        }
        
        for chip in chips {
            changeSuperviews(view: chip, newSuperview: chipView)
            dealButton.isEnabled = false
            
            UIView.transition(with: chip, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
                chip.center.x = self.chipView.frame.width/2.0
                chip.center.y = self.chipView.frame.height/2.0
            }) { (finished) in
                chip.removeFromSuperview()
                self.model.addMoney(self.model.totalBet)
                self.model.clearBet()
                self.enableChips()
                self.hintButton.isEnabled = true
                self.settingsButton.isEnabled = true
                
                let prefs = UserDefaults.standard
                prefs.set(self.model.totalBet, forKey: UserDefaultsKeys.totalBet)
                prefs.set(self.model.totalMoney, forKey: UserDefaultsKeys.totalMoney)
                
                self.totalMoney.text = "$\(self.model.totalMoney)"
                self.totalMoney.sizeToFit()
            }
            
        }
        
    }
    
    @objc func removeChip(_ sender: UIButton) {
        
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        changeSuperviews(view: sender, newSuperview: chipView)
        
        self.model.addMoney(sender.tag)
        self.model.removeFromBet(sender.tag)
        
        if(model.totalBet == 0){
            cancelButton.isHidden = true
            dealButton.isEnabled = false
            totalBet.isHidden = true
        }
        
        UIView.transition(with: sender, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
            sender.center.x = self.chipView.frame.width/2.0
            sender.center.y = self.chipView.frame.height/2.0
        }) { (finished) in
            sender.removeFromSuperview()
            self.enableChips()
            self.hintButton.isEnabled = true
            self.settingsButton.isEnabled = true
            
            self.totalMoney.text = "$\(self.model.totalMoney)"
            self.totalBet.text = "$\(self.model.totalBet)"
            self.totalMoney.sizeToFit()
            self.totalBet.sizeToFit()
        }
    }
    
    @IBAction func placeBet(_ sender: UIButton) {
        let chipImage = sender.imageView!.image!
        
        let newChip = UIButton(type: .custom)
        chipView.addSubview(newChip)
        newChip.setImage(chipImage, for: UIControl.State.normal)
        newChip.setImage(chipImage, for: UIControl.State.disabled)
        newChip.addTarget(self, action: #selector(removeChip(_:)), for: .touchUpInside)
        newChip.tag = sender.tag
        newChip.frame = sender.frame
        
        changeSuperviews(view: newChip, newSuperview: betView)
        
        model.removeMoney(sender.tag)
        model.addBet(sender.tag)
        disableChips()
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        
        UIView.transition(with: newChip, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
            
            self.placeChip(newChip)

        }) { (finished) in

            
            self.totalBet.text = "$\(self.model.totalBet)"
            self.totalMoney.text = "$\(self.model.totalMoney)"
            self.totalBet.isHidden = false
            self.totalBet.sizeToFit()
            self.totalMoney.sizeToFit()
            self.cancelButton.isHidden = false
            self.dealButton.isEnabled = true
            self.hintButton.isEnabled = true
            self.settingsButton.isEnabled = true
        }
        
    }
    
    @IBAction func deal(_ sender: Any) {
        
        cardsDealt = true
        
        dealButton.isHidden = true
        cancelButton.isHidden = true
        oneChip.isEnabled = false
        fiveChip.isEnabled = false
        twentyFiveChip.isEnabled = false
        fiftyChip.isEnabled = false
        oneHundredChip.isEnabled = false
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        let prefs = UserDefaults.standard
        
        prefs.set(model.totalBet, forKey: UserDefaultsKeys.totalBet)
        prefs.set(model.totalMoney, forKey: UserDefaultsKeys.totalMoney)
        
        let totalCardsToDeal = (numberOfPlayers + 1)*2
        
        var chips = [UIButton]()
        for i in 2...(betView.subviews.count - 1) {
            chips.append(betView.subviews[i] as! UIButton)
        }
        
        for chip in chips {
            chip.isEnabled = false
        }
        
        let bet = Bet.init(chips: chips, total: model.totalBet)
        
        if(self.cardCount == 0) {
            betForHands.append(bet)
        }
        
        let cardImageName : String
        let card = UIImageView(image: topOfDeck.image)
        view.addSubview(card)
        card.frame = topOfDeck.frame
        if(isDealer){
            cardImageName = model.nextDealerCardImage()
            changeSuperviews(view: card, newSuperview: dealerView)
                
        }
        else{
            cardImageName = model.nextCardImage(for: model.currentHand)
            changeSuperviews(view: card, newSuperview: cardView)
        }
            
        let cardImage = UIImage(named: cardImageName)
    
    
        UIView.transition(with: card, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
            if(self.isDealer){
                card.center.x = self.dealerView.frame.width/2.0 + self.xOffset
                card.center.y = self.dealerView.frame.height/2.0
            }
            else{
                card.center.x = self.cardView.frame.width/2.0 + self.xOffset
                card.center.y = self.cardView.frame.height/2.0
                card.transform = card.transform.scaledBy(x: 1.5, y: 1.5)
            }
            
        }) { (finished) in
            
            self.deckTotal.text = "\(self.model.totalCardsInDeck())"
            self.runningCount.text = "\(self.model.runningCount)"
            self.trueCount.text = "\(self.model.trueCount)"
            self.runningCount.sizeToFit()
            
            //Check that card is not first dealer card
            //First dealer card must remain face down
            if(!self.isDealer || self.cardCount > self.numberOfPlayers){
                card.image = cardImage
            }
            
            //Check if the next card is a dealer card
            if((self.cardCount + 2) % (self.numberOfPlayers + 1) == 0){
                self.isDealer = true
            }
            else {
                self.isDealer = false
            }
            
            //Check if the all first cards have been dealt
            //Change offset to location of second cards
            if(self.cardCount == (self.numberOfPlayers)){
                self.xOffset = -self.xOffset
            }
            
            //Check if the last card has been dealt
            if(self.cardCount < (totalCardsToDeal - 1)) {
                self.cardCount += 1
                self.deal(sender)
            }
            else{
                self.model.addHandPlayed()
                self.handTotal.text = self.model.handCount(for: self.model.currentHand)
                if(self.handTotalIsOn){
                    self.handTotal.isHidden = false
                }
                
                self.handTotal.sizeToFit()
                
                if(self.model.currentHand.hasBlackJack()){
                    if(self.model.dealerHand.hasBlackJack()){
                        self.result = .push
                        self.model.addBlackjack()
                        self.cardView.addLabel(for: 0, with: "PUSH", 0, self.result)
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
                            self.push(for: self.betForHands[self.currentHandNumber].chips)
                        })
                    }
                    else{
                        self.result = .win
                        self.cardView.addLabel(for: 0, with: "BLACKJACK", 0, self.result)
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
                            self.blackjack()
                        })
                    }
                }
                
                else if(self.model.dealerHand.hasBlackJack()){
                    self.result = .lose
                    self.cardView.addLabel(for: 0, with: "DEALER BLACKJACK", 0, self.result)
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
                    
                    if(self.model.totalBet <= self.model.totalMoney){
                        self.doubleButton.isHidden = false
                        if(self.model.currentHand.canSplit() && self.totalSplits < self.maximumSplits){
                            if(self.splitCount == 0 && self.leftSplitTotal < 1) {
                                self.splitButton.isHidden = false
                            }
                            if(self.splitCount == self.leftSplitTotal + 1 && self.rightSplitTotal < 1){
                                self.splitButton.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Hand Actions
    
    @IBAction func split(_ sender: UIButton) {
        
        model.addSplit()
        
        hitButton.isHidden = true
        standButton.isHidden = true
        doubleButton.isHidden = true
        splitButton.isHidden = true
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        totalSplits += 1
        if(!firstSplit){
            if(splitCount == 0){
                leftSplitTotal += 1
            }
            
            else{
                rightSplitTotal += 1
            }
        }
        

        let cards = cardView.subviews

        action = .split
        
        let newChips = doubleChips()
        
        model.splitDeck(for: splitCount)
        
        var numberOfPreviousCards = 0
        
        for i in 0..<splitCount{
            for _ in model.splitHands[i].cards {
                numberOfPreviousCards += 1
            }
        }
        let startingCard = (model.splitHands[splitCount].cards.count - 1) + numberOfPreviousCards
        
        UIView.transition(with: cardView, duration: kAnimationDuration, options: .curveEaseInOut, animations: {
            
            for newChip in newChips {
                self.placeChip(newChip)
            }
            
            if(self.splitCount == 0){
                cards[startingCard].frame.origin.x = 0.0
            }
            else {
                cards[startingCard].frame.origin.x = cards[startingCard - 1].frame.origin.x + cards[startingCard - 1].frame.width + 20.0
            }
            
            if((startingCard + 1) == (cards.count - 1)){
                cards[startingCard + 1].frame.origin.x = self.cardView.frame.width - (cards[startingCard + 1].frame.width)
            }
            else {
            cards[startingCard + 1].frame.origin.x = cards[startingCard].frame.origin.x + cards[startingCard].frame.width + 50.0
            }
            
            if(self.firstSplit){
                cards[startingCard].transform = cards[startingCard].transform.scaledBy(x: 0.67, y: 0.67)
                cards[startingCard + 1].transform = cards[startingCard + 1].transform.scaledBy(x: 0.67, y: 0.67)
                self.firstSplit = false
            }
            
        }) { (finished) in
                self.totalBet.text = "$\(self.model.totalBet)"
                self.totalMoney.text = "$\(self.model.totalMoney)"
                self.totalBet.sizeToFit()
                self.totalMoney.sizeToFit()
                self.drawCard()
        }

    }
    
    @IBAction func stand(_ sender: UIButton) {
        
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        if(splitCount + 1 < model.splitHands.count) {
            hitButton.isHidden = true
            standButton.isHidden = true
            doubleButton.isHidden = true
            splitButton.isHidden = true
            nextSplitHand()
        }
        
        else {
            for cards in cardView.subviews {
                cards.alpha = 1.0
            }
            action = .stand
            revealDealerCards()
        }
    }
    
    @IBAction func double(_ sender: UIButton) {
        
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        model.addDoubleDown()
        
        let newChips : [UIButton]
        
        if(action == .split){
            action = .double
            newChips = doubleChips()
            action = .split
        }
        
        else {
            action = .double
            newChips = doubleChips()
        }

        isDouble = true
        
        hitButton.isHidden = true
        standButton.isHidden = true
        doubleButton.isHidden = true
        splitButton.isHidden = true
        
        UIView.animate(withDuration: kAnimationDuration, animations: {
            
            for newChip in newChips {
                self.placeChip(newChip)
            }
            
        }) { (finished) in
            self.totalBet.text = "$\(self.model.totalBet)"
            self.totalMoney.text = "$\(self.model.totalMoney)"
            self.totalBet.sizeToFit()
            self.totalMoney.sizeToFit()
            
            self.isDouble = true
            
            self.drawCard()
        }
        
    }
    
    @IBAction func hit(_ sender: UIButton) {
        
        hintButton.isEnabled = false
        settingsButton.isEnabled = false
        
        if(action != .split){
        
        action = .hit
        
        }
        self.hitButton.isHidden = true
        self.standButton.isHidden = true
        self.doubleButton.isHidden = true
        self.splitButton.isHidden = true
        
        isDealer = false
        drawCard()
    }
    
    
    //MARK: - Helper Functions
    
    func changeSuperviews(view v : UIView, newSuperview s : UIView){
        let newPoint = s.convert(v.frame, from: v.superview)
        var numberOfPreviousCards = 0
        v.removeFromSuperview()
        v.frame = newPoint
        if(action == .split && !isChips){
            
            for i in 0..<splitCount{
                for _ in model.splitHands[i].cards {
                    numberOfPreviousCards += 1
                }
            }
            
            let cardNumber = (model.splitHands[splitCount].cards.count - 2) + numberOfPreviousCards
            s.insertSubview(v, aboveSubview: s.subviews[cardNumber])
        }
        else{
            s.addSubview(v)
        }
        view.bringSubviewToFront(s)
    }
    
    func nextSplitHand() {
        
        self.splitCount += 1
            
        var numberOfPreviousCards = 0
            
        for i in 0..<self.splitCount{
            let numberOfFirstCard = numberOfPreviousCards
            for j in 0..<self.model.splitHands[i].cards.count {
                numberOfPreviousCards += 1
                let cardNumber = j + numberOfFirstCard
                self.cardView.subviews[cardNumber].alpha = 0.5
            }
        }
            
        self.cardView.subviews[numberOfPreviousCards].alpha = 1.0
            
        self.drawCard()
        
    }
    
    //MARK: - Gesture Delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if(touch.view == hintButton){
            return false
        }
        
        return true
    }
    
}
