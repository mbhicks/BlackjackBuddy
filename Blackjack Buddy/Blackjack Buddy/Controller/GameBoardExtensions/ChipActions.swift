//
//  ChipActions.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/9/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import Foundation
import UIKit

extension GameBoardViewController {
    
    func enableChips() {
        switch self.model.totalMoney {
        case 1...4:
            self.oneChip.isEnabled = true
        case 5...24:
            self.oneChip.isEnabled = true
            self.fiveChip.isEnabled = true
        case 25...49:
            self.oneChip.isEnabled = true
            self.fiveChip.isEnabled = true
            self.twentyFiveChip.isEnabled = true
        case 50...99:
            self.oneChip.isEnabled = true
            self.fiveChip.isEnabled = true
            self.twentyFiveChip.isEnabled = true
            self.fiftyChip.isEnabled = true
        case 100...Int.max:
            self.oneChip.isEnabled = true
            self.fiveChip.isEnabled = true
            self.twentyFiveChip.isEnabled = true
            self.fiftyChip.isEnabled = true
            self.oneHundredChip.isEnabled = true
        default:
            break
        }
    }
    
    func disableChips() {
        switch self.model.totalMoney {
        case ..<1:
            self.oneChip.isEnabled = false
            self.fiveChip.isEnabled = false
            self.twentyFiveChip.isEnabled = false
            self.fiftyChip.isEnabled = false
            self.oneHundredChip.isEnabled = false
        case ..<5:
            self.fiveChip.isEnabled = false
            self.twentyFiveChip.isEnabled = false
            self.fiftyChip.isEnabled = false
            self.oneHundredChip.isEnabled = false
        case ..<25:
            self.twentyFiveChip.isEnabled = false
            self.fiftyChip.isEnabled = false
            self.oneHundredChip.isEnabled = false
        case ..<50:
            self.fiftyChip.isEnabled = false
            self.oneHundredChip.isEnabled = false
        case ..<100:
            self.oneHundredChip.isEnabled = false
        default:
            break
        }
    }
    
    func placeChip(_ chip : UIButton){
        // Find the button's width and height
        let chipWidth = chip.frame.width
        let chipHeight = chip.frame.height
        
        // Find the width and height of the enclosing view
        let viewWidth = betView.frame.width
        let viewHeight = betView.frame.height
        
        // Compute width and height of the area to contain the button's center
        let xwidth = viewWidth - chipWidth
        let yheight = viewHeight - chipHeight
        
        var isIntersecting = true
        chip.isHidden = false
        
        while(isIntersecting){
            
            // Generate a random x and y offset
            let xoffset = CGFloat(arc4random_uniform(UInt32(xwidth)))
            let yoffset = CGFloat(arc4random_uniform(UInt32(yheight)))
            
            chip.center.x = xoffset + chipWidth / 2
            chip.center.y = yoffset + chipHeight / 2
            
            isIntersecting = false
            
            if(chip.frame.intersects(cancelButton.frame) || chip.frame.intersects(totalBet.frame)){
                isIntersecting = true
            }
            
        }
    }
    
    func doubleChips() -> [UIButton] {
        
        isChips = true
        
        var newChips = [UIButton]()
        
        for chip in betForHands[splitCount].chips{
            let newChip = UIButton(type: .custom)
            let chipImage = chip.imageView!.image!
            
            chipView.addSubview(newChip)
            newChip.setImage(chipImage, for: .normal)
            newChip.setImage(chipImage, for: .disabled)
            newChip.addTarget(self, action: #selector(removeChip(_:)), for: .touchUpInside)
            newChip.isEnabled = false
            newChip.isHidden = true
            newChip.tag = chip.tag
            
            newChip.frame = twentyFiveChip.frame
            
            changeSuperviews(view: newChip, newSuperview: betView)
            
            newChips.append(newChip)
            
            model.removeMoney(chip.tag)
            model.addBet(chip.tag)
        }
        
        let prefs = UserDefaults.standard
        prefs.set(model.totalBet, forKey: UserDefaultsKeys.totalBet)
        prefs.set(model.totalMoney, forKey: UserDefaultsKeys.totalMoney)
        
        isChips = false
        
        let bet = Bet.init(chips: newChips, total: betForHands[splitCount].total)
        
        if(action == .split){
            if(splitCount > betForHands.count - 1){
                betForHands.append(bet)
            }
            else{
                betForHands.insert(bet, at: splitCount + 1)
            }
        }
        else {
            for chip in newChips{
                betForHands[splitCount].chips.append(chip)
            }
        }
        return newChips
    }
    
    func addBlackjackChips(for numberOfChips : Int, of type : UIButton) {
        for _ in 0..<numberOfChips{
            let newChip = UIButton(frame: type.frame)
            betView.addSubview(newChip)
            newChip.setImage(type.imageView!.image!, for: UIControl.State.normal)
            newChip.setImage(type.imageView!.image!, for: UIControl.State.disabled)
            newChip.addTarget(self, action: #selector(removeChip(_:)), for: .touchUpInside)
            newChip.tag = type.tag
            newChip.frame.origin.y = -(newChip.frame.height) - betView.frame.origin.y
            
            UIView.animate(withDuration: kAnimationDuration) {
                self.placeChip(newChip)
            }
            
        }
    }
}
