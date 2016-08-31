//
//  ChooseQuizModeViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/23/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChooseQuizModeViewController: UIViewController {
    
    var continent: String!
    
    let Helpers = HelperFunctions.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPractice" {
            _ = segue.destinationViewController as! MapViewController
            Helpers.continent = continent
        } else if segue.identifier == "showChallenge" {
            _ = segue.destinationViewController as! ChallengeViewController
            Helpers.continent = continent
        }
    }
    
    // functions to deal with the restoring state
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        // save the continent as minimal source of data
        coder.encodeObject(continent as AnyObject, forKey: "continent")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        let data = coder.decodeObjectForKey("continent")
        continent = String(data!)
        super.decodeRestorableStateWithCoder(coder)
    }
    
    // once the app has loaded again work out what to show on the screen
    override func applicationFinishedRestoringState() {
        //grab the unfinished game and set to currrent game
        print("ready to keep going data choose mode")
    }
    
}