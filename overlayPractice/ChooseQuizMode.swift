//
//  ChooseQuizMode.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/14/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChooseQuizMode: CoreDataController {
    
    var continent: String!
    
//    @IBAction func challenge(sender: AnyObject) {
//        mode = "challenge"
//    }
//    
//    @IBAction func practice(sender: AnyObject) {
//        mode = "practice"
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPractice" {
            let controller = segue.destinationViewController as! PracticeViewController
            controller.continent = continent
        } else if segue.identifier == "showChallenge" {
            let controller = segue.destinationViewController as! ChallengeViewController
            controller.continent = continent
        }
    }
    
}
