//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Anna Rogers on 8/28/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Game {

    @NSManaged var continent: String?
    @NSManaged var created_at: NSDate?
    @NSManaged var finished_at: NSDate?
    @NSManaged var mode: String?
    @NSManaged var match_length: NSNumber?
    @NSManaged var attempt: NSSet?

}
