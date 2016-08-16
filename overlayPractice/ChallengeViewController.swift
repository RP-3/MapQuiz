//
//  ChallengeViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/16/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ChallengeViewController: CoreDataController, MKMapViewDelegate {
    
    var continent: String!
    var mode: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("here")
    }
}
