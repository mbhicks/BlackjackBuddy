//
//  ViewExtension.swift
//  Blackjack Buddy
//
//  Created by MTSS on 11/27/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import Foundation
import UIKit

let model = Model.sharedInstance

extension UIView {
    
    
    func fadeIn() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
        }
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0.0
        }
    }
    
    func addLabel(for card : Int, with text : String, _ handNumber : Int, _ result : handResult) {
        
        let firstCard = self.subviews[card]
        let lastCard : UIView
        if(model.splitHands.isEmpty){
            lastCard = self.subviews[self.subviews.count - 1]
        }
        else{
            let lastCardNumber = card + (model.splitHands[handNumber].cards.count - 1)
            lastCard = self.subviews[lastCardNumber]
        }
        
        let x : CGFloat = firstCard.frame.origin.x
        let y = firstCard.frame.height/2.0
        let height : CGFloat = 40.0
        let width = (lastCard.frame.origin.x - x) + lastCard.frame.width
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let label = UITextView(frame: frame)
        label.textAlignment = .center
        label.text = text
        label.font = UIFont(descriptor: label.font!.fontDescriptor, size: 24.0)
        if(text.contains("BLACKJACK")){
            label.font = UIFont(descriptor: label.font!.fontDescriptor, size: 18.0)
        }
        
        label.sizeToFit()
        label.frame.size.width = width
        
        switch result {
        case .lose:
            label.textColor = UIColor.red
        case .win:
            label.textColor = UIColor.green
        case .push:
            label.textColor = UIColor.white
        default:
            label.textColor = UIColor.white
        }
        label.backgroundColor = UIColor.init(white: 0.0, alpha: 0.75)
        self.addSubview(label)
        
    }
}
