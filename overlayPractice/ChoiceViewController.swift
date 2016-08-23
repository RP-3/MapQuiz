//
//  ChoiceViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/8/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChoiceViewController: CoreDataController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var senderTag = [
        1: "AS",
        2: "OC",
        3: "AF",
        4: "EU",
        5: "NA",
        6: "SA"
    ]
    
    var continentChoice: String = ""
    
    @IBAction func asiaButton(sender: AnyObject) {
        continentChoice = senderTag[sender.tag]!
        performSegueWithIdentifier("pickGame", sender: nil)
    }

    @IBAction func ocianiaButton(sender: AnyObject) {
        continentChoice = senderTag[sender.tag]!
        performSegueWithIdentifier("pickGame", sender: nil)
    }

    @IBAction func africaButton(sender: AnyObject) {
        continentChoice = senderTag[sender.tag]!
        performSegueWithIdentifier("pickGame", sender: nil)
    }

    @IBAction func europeButton(sender: AnyObject) {
        continentChoice = senderTag[sender.tag]!
        performSegueWithIdentifier("pickGame", sender: nil)
    }
    
    @IBAction func northAmericaButton(sender: AnyObject) {
        continentChoice = senderTag[sender.tag]!
        performSegueWithIdentifier("pickGame", sender: nil)
    }
    
    @IBAction func southAmericaButton(sender: AnyObject) {
        continentChoice = senderTag[sender.tag]!
        performSegueWithIdentifier("pickGame", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pickGame" {
            let controller = segue.destinationViewController as! ChooseQuizModeViewController
            controller.continent = continentChoice
        }
    }


}