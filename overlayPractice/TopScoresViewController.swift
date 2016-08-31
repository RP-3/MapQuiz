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
    
    // this controller is to show the top 3 scores for each continent
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);

        navigationItem.setHidesBackButton(true, animated:true)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmaticSC-Bold", size: 24)!], forState: .Normal)
        
        title = "Top Challenge Scores"
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "Game")
        
        // not nil match_length and mode is challenge
        let timePredicate = NSPredicate(format: "match_length!=nil AND match_length!=0")
        let modePredicate = NSPredicate(format: "mode = %@", "challenge")
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [timePredicate, modePredicate])
        fetchRequest.predicate = andPredicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "continent", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: "continent", cacheName: nil)
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        
    }

    
    //TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Find the right notebook for this indexpath
        let game = fetchedResultsController!.objectAtIndexPath(indexPath) as! Game
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("TopScoreCell") as! CustomTableCell
        
        //add text to the cell
        cell.timeLabel?.text = convertSecondsToTime(Int(game.match_length!))
        //make this the number of lives left/number wrong
        if game.lives_left! == 2 {
            cell.liftThree.alpha = 0.5
        } else if game.lives_left! == 1 {
            cell.liftThree.alpha = 0.5
            cell.lifeTwo.alpha = 0.5
        }
        
        return cell  
    }
    
    func convertSecondsToTime (seconds: Int) -> String {
        let minutes = String(seconds / 60)
        var secs = String(seconds % 60)
        // pad with zero
        if String(secs) == "0" {
            secs = "0" + secs
        }
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


