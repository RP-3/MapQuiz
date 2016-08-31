//
//  WorldRankViewController.swift
//  MapQuiz
//
//  Created by Anna Rogers on 8/31/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit

class WorldRankViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in ranking page")
    }
    
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}
