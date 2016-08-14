//
//  ChooseQuizMode.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/14/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChooseQuizMode: CoreDataController {
    
    var mode = ""
    var continent: String!
    
    @IBAction func challenge(sender: AnyObject) {
        mode = "challenge"
        performSegueWithIdentifier("showMap", sender: nil)
    }
    
    @IBAction func practice(sender: AnyObject) {
        mode = "practice"
        performSegueWithIdentifier("showMap", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            let controller = segue.destinationViewController as! MapViewController
            controller.mode = mode
        }
    }
    
}
