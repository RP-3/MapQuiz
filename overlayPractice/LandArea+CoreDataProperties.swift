//
//  LandArea+CoreDataProperties.swift
//  
//
//  Created by Anna Rogers on 8/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LandArea {

    @NSManaged var name: String?
    @NSManaged var continent: String?
    @NSManaged var capital: String?
    @NSManaged var coordinates: String?

}
