//
//  ChoiceViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/8/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class ChoiceViewController: UIViewController {
    
    
    @IBOutlet weak var NorthAmericaBtn: UIButton!
    @IBOutlet weak var SouthAmericaBtn: UIButton!
    @IBOutlet weak var AfricaBtn: UIButton!
    @IBOutlet weak var AsiaBtn: UIButton!
    @IBOutlet weak var EuropeBtn: UIButton!
    @IBOutlet weak var OceaniaBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AmaticSC-Bold", size: 24)!]
        self.title = "Pick a continent"
        
        let topScoreButton: UIBarButtonItem = UIBarButtonItem(title: "Top Scores", style: .Plain, target: self, action: #selector(self.topScores))
        navigationItem.rightBarButtonItem = topScoreButton
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmaticSC-Bold", size: 24)!], forState: .Normal)
        
        NorthAmericaBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        SouthAmericaBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        AfricaBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        AsiaBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        EuropeBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        OceaniaBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
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
    
    func topScores () {
        performSegueWithIdentifier("topScores", sender: nil)
    }
    
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