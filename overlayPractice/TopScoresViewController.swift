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
        print("loading ......")
        //get each game
        //sort by time
        //get top 5 returned
        //display to table
        
//        let app = UIApplication.sharedApplication().delegate as! AppDelegate
//        let land = app.landAreas
//        let fetchRequest = NSFetchRequest(entityName: "Game")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "match_length", ascending: true)]
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
//        let entities = fetchedResultsController!.fetchedObjects as! [Game]
//        print("entities in view did load: ", entities.count)
        
        //take the top 5 entities
        // else if no entities then just show an empty table
        //need title for page
        
    }
    
//    // MARK:  - TableView Data Source
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        
//        // This method must be implemented by our subclass. There's no way
//        // CoreDataTableViewController can know what type of cell we want to
//        // use.
//        
//        
//        // Find the right notebook for this indexpath
//        let nb = fetchedResultsController!.objectAtIndexPath(indexPath) as! Notebook
//        
//        // Create the cell
//        let cell = tableView.dequeueReusableCellWithIdentifier("NotebookCell", forIndexPath: indexPath)
//        
//        // Sync notebook -> cell
//        cell.textLabel?.text = nb.name
//        cell.detailTextLabel?.text = String(format: "%d notes", nb.notes!.count)
//        
//        
//        return cell
//        
//    }
    
    
}


