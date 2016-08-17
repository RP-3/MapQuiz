//
//  Attempt+CoreDataProperties.swift
//  
//
//  Created by Anna Rogers on 8/17/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Attempt {

    @NSManaged var created_at: NSDate?
    @NSManaged var countryToFind: String?
    @NSManaged var countryGuessed: String?
    @NSManaged var revealed: NSNumber?
    @NSManaged var game: Game?

}
