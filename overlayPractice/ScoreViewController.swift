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
    var misses: Int!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var correct: UILabel!
    @IBOutlet weak var uncovered: UILabel!
    @IBOutlet weak var wrong: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let returnButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.home))
        self.navigationItem.rightBarButtonItem = returnButton
        
        titleLabel.text = "Out of \(scoreTotal) countries you got:"
        correct.text = "\(score) correct"
        wrong.text = "\(misses) wrong"
        uncovered.text = "and \(revealed) misses"
        
    }
    
    //if the mode was practice then give a lowdown of the scores - 
    // revealed
    // guessed
    // lost
    // number of wrong guesses
    
    // if quiz mode then:
    // message - "Boom you made it"
    // message - "you lost"
    
    
    func home () {
        navigationController?.popToRootViewControllerAnimated(true)
    }

}