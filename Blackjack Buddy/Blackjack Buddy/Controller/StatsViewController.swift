//
//  StatsViewController.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/8/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var handsWon: UILabel!
    @IBOutlet weak var handsPlayed: UILabel!
    @IBOutlet weak var blackjacks: UILabel!
    @IBOutlet weak var splits: UILabel!
    @IBOutlet weak var doubleDowns: UILabel!
    @IBOutlet weak var biggestWin: UILabel!
    @IBOutlet weak var totalGain: UILabel!
    
    let model = Model.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        handsWon.text = "\(model.numberOfHandsWon)"
        handsPlayed.text = "\(model.numberOfHandsPlayed)"
        blackjacks.text = "\(model.numberOfBlackjacks)"
        splits.text = "\(model.numberOfSplits)"
        doubleDowns.text = "\(model.numberOfDoubleDowns)"
        biggestWin.text = "$\(model.biggestWin)"
        totalGain.text = "$\(model.totalGain)"
    }
    
}
