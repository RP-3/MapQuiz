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
    var activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.center = view.center
    }

    @IBAction func challengeClicked(sender: AnyObject) {
        activitySpinner.startAnimating()
        view.addSubview(activitySpinner)
        performSegueWithIdentifier("showChallenge", sender: nil)
    }
    
    
    @IBAction func practiceClicked(sender: AnyObject) {
        activitySpinner.startAnimating()
        view.addSubview(activitySpinner)
        performSegueWithIdentifier("showPractice", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showPractice" {
            let controller = segue.destinationViewController as! MapViewController
            controller.continent = continent
        } else if segue.identifier == "showChallenge" {
            let controller = segue.destinationViewController as! ChallengeViewController
            controller.continent = continent
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
    
    override func viewWillDisappear(animated: Bool) {
        activitySpinner.stopAnimating()
        view.willRemoveSubview(activitySpinner)
    }
    
}