//
//  RulesViewController.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/9/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {

    @IBOutlet weak var rulesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        rulesTextView.setContentOffset(.zero, animated: false)
    }

}
