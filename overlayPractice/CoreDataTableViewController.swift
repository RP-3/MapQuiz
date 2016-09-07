//
//  CoreDataTableViewController.swift
//  MapQuiz
//
//  Created by Anna Rogers on 8/28/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController {
    
    
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            executeSearch()
        }
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }
    
    let continents = [
        "NA":"North America",
        "SA":"South America",
        "AF":"Africa",
        "AS":"Asia",
        "OC":"Oceania",
        "EU":"Europe"
    ]
    
}

//Table Data Source
extension CoreDataTableViewController{
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let fc = fetchedResultsController{
            return (fc.sections?.count)!;
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            // limit number of scores show to the user to three
            if fc.sections![section].numberOfObjects < 3 {
                return fc.sections![section].numberOfObjects
            } else {
                return 3
            }
            
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sectionForSectionIndexTitle(title, atIndex: index)
        }else{
            return 0
        }
    }
    
    // add custom table cell
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let fc = fetchedResultsController{
            let shortHand = fc.sections![section].name
            let title = continents[shortHand]
            let headerView = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
            headerView.titleOfSection.text = title
            return headerView
        }else{
            return nil
        }
    }
    
}


