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
        
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AmaticSC-Bold", size: 28)!]
        title = "Pick a continent"
        
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
    
    @IBAction func showScorePage(sender: AnyObject) {
        //check there is internet - if there is then show the page else show alert that there is no internet connection
        if Reachability.isConnectedToNetwork() {
            //if the user_id and user_secret is stored
            if NSUserDefaults.standardUserDefaults().objectForKey("user_id") !== nil {
                if NSUserDefaults.standardUserDefaults().objectForKey("user_secret") !== nil {
                    performSegueWithIdentifier("TopScores", sender: nil)
                } else {
                    throwAlert("There is no user_id regestered with this phone. To view this page, terminate and restart the app in an area with internet.")
                }
            } else {
                throwAlert("There is no user_id regestered with this phone. To view this page, terminate and restart the app in an area with internet.")
            }
        } else {
            //throw alert that the interenet is not connected
            throwAlert("There is no internet connection. Please connect to the interenet to view this page.")
        }
        
    }
    
    func throwAlert (message:String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
        }
        alertController.addAction(Action)
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alertController, animated: true, completion:nil)
        }
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

