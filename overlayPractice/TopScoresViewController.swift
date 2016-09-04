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
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let Client = GameAPIClient.sharedInstance
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshRanks()
        self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        doneButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AmaticSC-Bold", size: 24)!], forState: .Normal)
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "Game")
        
        // not nil match_length and mode is challenge
        let timePredicate = NSPredicate(format: "match_length!=nil AND match_length!=0")
        let modePredicate = NSPredicate(format: "mode = %@", "challenge")
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [timePredicate, modePredicate])
        fetchRequest.predicate = andPredicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "match_length", ascending: true)]
        
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
        cell.rankLabel.text = "rank: \(String(game.rank!))"
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
    
    @IBAction func refresh(sender: AnyObject) {
        refreshRanks()
    }
    
    func refreshRanks () {
        Client.getLatestRanking() { (data,error) in
            if error == nil {
                print("no error",data)
                //returns all game ids and their ranks
//                let newData = Array(arrayLiteral:data)
                //make array of data into hash of data
                
                var matches:[String:AnyObject] = [:]
                
                for datum in data! {
                    matches[String(datum!["identifier"])] = datum!["identifier"]
                    matches[String(datum!["rank"])] = datum!["rank"]
                }
                
                //get all games from core data and update the ranks for all of them where the id matches
                let moc = self.app.landAreas.context
                let fetchRequest = NSFetchRequest(entityName: "Game")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
                let timePredicate = NSPredicate(format: "match_length!=nil AND match_length!=0")
                let modePredicate = NSPredicate(format: "mode = %@", "challenge")
                let andPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [timePredicate, modePredicate])
                fetchRequest.predicate = andPredicate
                
                var entities: [Game]
                do {
                    entities = try moc.executeFetchRequest(fetchRequest) as! [Game]
                } catch {
                    fatalError("Failed to fetch employees: \(error)")
                }
                
                //loop through the entities and update
                for entity in entities {
                    print("ENTITY pre",entity)
                    if (matches[entity.identifier!] != nil) {
                        entity.rank = Int(matches["identifier"] as! String)
                    }
                    print("ENTITY post",entity)
                }

                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}


