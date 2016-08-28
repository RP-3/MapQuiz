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
    var time: String!
    var totalCountriesInContinent: Int!
    
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var scoreImage: UIImageView!
    
    var restored = false
    
    override func viewWillAppear(animated: Bool) {
        print("lines etc: ", lives, correct, time,totalCountriesInContinent)
        if restored == true {
            restored = false
            navigationController?.popToRootViewControllerAnimated(true)
        }
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let returnButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(self.home))
        self.navigationItem.rightBarButtonItem = returnButton
        
        // if the score is the same as the total then WON!
        // if no lives then dead
        // if no time then dead
        if correct == totalCountriesInContinent {
            scoreImage.image = UIImage(named: "mountain")
            scoreText.text = "You made it!! All \(totalCountriesInContinent) countries were guessed in \(time)!"
        } else if time == "0:00" {
            scoreImage.image = UIImage(named: "wrong")
            scoreText.text = "Time up! You got \(correct) countries out of \(totalCountriesInContinent)"
        } else if lives == 0 {
            scoreImage.image = UIImage(named: "wrong")
            scoreText.text = "All your lives are gone! You got \(correct) countries out of \(totalCountriesInContinent) in \(time)"
        }
        
    }
    
    //return to main menu
    func home () {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        restored = true
    }

}