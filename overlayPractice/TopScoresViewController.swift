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
        
        print("loading ......")
        title = "Top Challenge Scores"
        //get each game
        //sort by time
        //get top 5 returned
        //display to table
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "match_length", ascending: true)]
        
        let predicate = NSPredicate(format: "mode = %@", "challenge")
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Find the right notebook for this indexpath
        let game = fetchedResultsController!.objectAtIndexPath(indexPath) as! Game
        let cell = tableView.dequeueReusableCellWithIdentifier("TopScoreCell", forIndexPath: indexPath)
        if game.match_length != nil && Int(game.match_length!) > 0 {
            // Create the cell
            
            print("TIME: ", game.match_length!,  convertSecondsToTime(Int(game.match_length!)), "for:", continents[game.continent!])
            //add text to the cell
            cell.textLabel?.text = continents[game.continent!]
            cell.detailTextLabel?.text = convertSecondsToTime(Int(game.match_length!))
            
            return cell
        } else {
           cell.textLabel?.text = "BAD"
            cell.detailTextLabel?.text = convertSecondsToTime(Int(game.match_length!))
            return cell
        }
        
        
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


