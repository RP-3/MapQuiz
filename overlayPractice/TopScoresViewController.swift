//
//  TopScoresViewController.swift
//  MapQuiz
//
//  Created by Anna Rogers on 8/28/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import CoreData

class TopScoresViewController: CoreDataTableViewController {
    
    // this controller is to show the last 5 or 10 gmaes played and show: time, contintnet and lives left
    
    let continents = [
        "NA":"North America",
        "SA":"South America",
        "AF":"Africa",
        "AS":"Asia",
        "OC":"Oceania",
        "EU":"Europe"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated:true)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmaticSC-Bold", size: 24)!], forState: .Normal)
        
        print("loading ......")
        title = "Top Challenge Scores"
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "Game")
        
        // not nil match_length
        // challenge mode
        let timePredicate = NSPredicate(format: "match_length!=nil AND match_length!=0")
        let modePredicate = NSPredicate(format: "mode = %@", "challenge")
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [timePredicate, modePredicate])
        fetchRequest.predicate = andPredicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "match_length", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //countEntities()
    }
    
    //TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Find the right notebook for this indexpath
        let game = fetchedResultsController!.objectAtIndexPath(indexPath) as! Game
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("TopScoreCell", forIndexPath: indexPath)
        
        print("TIME: ", game.match_length!,  convertSecondsToTime(Int(game.match_length!)), "for:", continents[game.continent!])
        //add text to the cell
        cell.textLabel?.text = convertSecondsToTime(Int(game.match_length!))
        cell.textLabel?.font = UIFont(name: "AmaticSC-Bold", size: 20)
        cell.detailTextLabel?.text = continents[game.continent!]
        
        return cell
        
        
        
    }
    
    func convertSecondsToTime (seconds: Int) -> String {
        let minutes = String(seconds / 60)
        var secs = String(seconds % 60)
        if String(secs) == "0" {
            secs = "0" + secs
        }
        // pad with zero
        if String(secs).characters.count == 1 {
            secs = "0" + secs
        }
        let time = minutes + ":"
        return time + secs
    }
    
    @IBAction func done(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
}


