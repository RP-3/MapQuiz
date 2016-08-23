//
//  ChallengeScoreViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChallengeScoreViewController: UIViewController {
    
    var lives: Int!
    var correct: Int!
    var time: Int!
    var totalCountriesInContinent: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let returnButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.home))
        self.navigationItem.rightBarButtonItem = returnButton
        
        // if the score is the same as the total then WON!
        // if no lives then dead
        // if no time then dead
        if correct == totalCountriesInContinent {
            print("won!")
        } else if time == 0 {
            print("no time")
        } else if lives == 0 {
            print("no lives")
        }
        
    }
    
    //return to main menu
    func home () {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
}