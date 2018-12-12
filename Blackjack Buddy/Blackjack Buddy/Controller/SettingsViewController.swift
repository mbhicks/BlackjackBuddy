//
//  SettingsViewController.swift
//  Blackjack Buddy
//
//  Created by MTSS on 12/2/18.
//  Copyright © 2018 Mary. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var numberOfDecks: UILabel!
    @IBOutlet weak var numberOfDecksControl: UISegmentedControl!
    @IBOutlet weak var handTotalsSwitch: UISwitch!
    @IBOutlet weak var cardCounterSwitch: UISwitch!
    @IBOutlet weak var deckTotalSwitch: UISwitch!
    
    let model = Model.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs = UserDefaults.standard
        
        let deckNumber = prefs.integer(forKey: UserDefaultsKeys.numberOfDecks)
        numberOfDecksControl.selectedSegmentIndex = deckNumber/2
        
        handTotalsSwitch.isOn = prefs.bool(forKey: UserDefaultsKeys.showHandTotals)
        cardCounterSwitch.isOn = prefs.bool(forKey: UserDefaultsKeys.showCardCounter)
        deckTotalSwitch.isOn = prefs.bool(forKey: UserDefaultsKeys.showDeckTotal)
    }

    @IBAction func numberOfDecksDidChange(_ sender: UISegmentedControl) {
        
        let prefs = UserDefaults.standard
        
        let indexNumber = sender.selectedSegmentIndex
        
        if(indexNumber == 0){
            prefs.set(1, forKey: UserDefaultsKeys.numberOfDecks)
        }
        
        else {
            prefs.set(indexNumber*2, forKey: UserDefaultsKeys.numberOfDecks)
        }
        
    }

    @IBAction func toggleHandTotals(_ sender: UISwitch) {
        
        let prefs = UserDefaults.standard
        prefs.set(sender.isOn, forKey: UserDefaultsKeys.showHandTotals)
    }
    
    @IBAction func toggleCardCounter(_ sender: UISwitch) {
        
        let prefs = UserDefaults.standard
        prefs.set(sender.isOn, forKey: UserDefaultsKeys.showCardCounter)
        
        if(sender.isOn){
            let alert = UIAlertController(title: "Card Counting Tutorial", message: "Would you like to learn more about card counting?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.performSegue(withIdentifier: "cardCountingTutorial", sender: self)
            }
            
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func toggleDeckTotal(_ sender: UISwitch) {
        
        let prefs = UserDefaults.standard
        prefs.set(sender.isOn, forKey: UserDefaultsKeys.showDeckTotal)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "cardCountingTutorial":
            break
        default:
            assert(false, "Unhandled Segue")
        }
    }
    

}
