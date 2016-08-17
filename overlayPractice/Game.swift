//
//  Game.swift
//  
//
//  Created by Anna Rogers on 8/17/16.
//
//

import Foundation
import CoreData


class Game: NSManagedObject {

    convenience init(continent: String, mode: String, context : NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Game",inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.continent = continent
            self.mode = mode
            self.created_at = NSDate()
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
    
    var humanReadableAge : String{
        let fmt = NSDateFormatter()
        fmt.timeStyle = .NoStyle
        fmt.dateStyle = .ShortStyle
        fmt.doesRelativeDateFormatting = true
        fmt.locale = NSLocale.currentLocale()
        return fmt.stringFromDate(created_at!)
    }

}
