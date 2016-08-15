//
//  ScoreViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/13/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import UIKit

class ScoreViewController: CoreDataController {
    
    var score: Int!
    var scoreTotal: Int!
    var revealed: Int!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let returnButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.home))
        self.navigationItem.rightBarButtonItem = returnButton
        scoreLabel.text = "\(score)/\(scoreTotal)"
    }
    
    //if the mode was practice then give a lowdown of the scores - 
    // revealed
    // guessed
    // lost
    
    
    
    func home () {
        navigationController?.popToRootViewControllerAnimated(true)
    }

}