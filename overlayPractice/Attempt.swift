//
//  Attempt.swift
//  
//
//  Created by Anna Rogers on 8/17/16.
//
//

import Foundation
import CoreData


class Attempt: NSManagedObject {

    convenience init(toFind: String, guessed: String, revealed: Bool, context : NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Attempt",inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.countryToFind = toFind
            self.countryGuessed = guessed
            self.revealed = revealed
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
