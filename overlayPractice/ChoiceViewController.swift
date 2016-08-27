//
//  ChoiceViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/8/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChoiceViewController: CoreDataController {
    
    
    @IBOutlet weak var NorthAmericaBtn: UIButton!
    @IBOutlet weak var SouthAmericaBtn: UIButton!
    @IBOutlet weak var AfricaBtn: UIButton!
    @IBOutlet weak var AsiaBtn: UIButton!
    @IBOutlet weak var EuropeBtn: UIButton!
    @IBOutlet weak var OceaniaBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AmaticSC-Bold", size: 28)!]
        title = "Pick a continent"
    }
    
    var senderTag = [
        1: "NA",
        2: "SA",
        3: "AF",
        4: "AS",
        5: "OC",
        6: "EU"
    ]
    
    var continentChoice: String = ""
    
    @IBAction func asiaButton(sender: AnyObject) {
        continentChoice = senderTag[sender.tag]!
        performSegueWithIdentifier("pickGame", sender: nil)
    }

    @IBAction func oceaniaButton(sender: AnyObject) {
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