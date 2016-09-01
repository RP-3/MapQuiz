//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Anna Rogers on 9/1/16.
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
    @NSManaged var lives_left: NSNumber?
    @NSManaged var match_length: NSNumber?
    @NSManaged var mode: String?
    @NSManaged var game_id: String?
    @NSManaged var rank: NSNumber?
    @NSManaged var attempt: NSSet?

}
