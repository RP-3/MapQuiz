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
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        let entities = fetchedResultsController!.fetchedObjects as! [Game]
        print("entities in view did load: ", entities.count)
        //take the top 5 entities
        // else if no entities then just show an empty table
        //need title for page
    }
    
    override func viewWillAppear(animated: Bool) {
        print("appearing...")
        
    }
    
    //TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Find the right notebook for this indexpath
        let game = fetchedResultsController!.objectAtIndexPath(indexPath) as! Game
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("TopScoreCell") as! CustomRowViewController

        //add text to the cell
        cell.cellImage.image = UIImage(named: "asia")
        cell.cellLabel?.text = game.continent! + " - " + convertSecondsToTime(Int(game.match_length!))
        
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


