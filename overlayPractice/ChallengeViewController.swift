//
//  ChallengeViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/16/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ChallengeViewController: CoreDataController {
    
    var continent:String!
    
    @IBOutlet weak var worldMap: MKMapView!
    @IBOutlet weak var displayTimeLabel: UIBarButtonItem!
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    
    var totalCountries: Int = 0
    
    var game = [
        "guessed": [String:String](),
        "toPlay": [String:String](),
        "revealed": [String: String]()
    ]
    var misses = 0
    
    var toFind = ""
    //question label
    let label = UILabel()
    
    //dictionary keyed by country name with the values as an array of all the polygons for that country
    var createdPolygonOverlays = [String: [MKPolygon]]()
    //dictionary keyed by country name with values of the coordinates of each country (for the contains method to use to check if clicked point is within one of the overlays)
    var coordinates = [ String: [[CLLocationCoordinate2D]] ]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertController = UIAlertController(title: "Ready?", message: "Press go to start the clock ticking!", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "Go!", style: .Default) { (action:UIAlertAction!) in
            //start the timer!
            
            let aSelector : Selector = #selector(MapViewController.updateTime)
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            self.startTime = NSDate.timeIntervalSinceReferenceDate()
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion:nil)
        
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        let entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities", entities.count)
        
        //make an array of country models - loop through core data for all with desired continent code and make to model
        for entity in entities {
            if (entity.continent == continent) {
                let country = Country(name: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!)
                game["toPlay"]![entity.name!] = entity.name
                addBoundary(country)
                setZoomForContinent()
            }
        }
        totalCountries = createdPolygonOverlays.count
        self.title = String("0 / \(totalCountries)")
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer)
        
        //start the game
        //make label to show the user and pick random index to grab country name with
        makeQuestionLabel()
        worldMap.mapType = .Satellite
    }
    
    func makeQuestionLabel () {
        let index: Int = Int(arc4random_uniform(UInt32(game["toPlay"]!.count)))
        let countryToFind = Array(game["toPlay"]!.values)[index]
        toFind = countryToFind
        let screenSize = UIScreen.mainScreen().bounds.size
        label.frame = CGRectMake(0, 0 + 44, (screenSize.width + 5), 35)
        
        label.textAlignment = NSTextAlignment.Center
        label.text = "Find: \(countryToFind)"
        label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        label.textColor = UIColor.whiteColor()
        view.frame.origin.y = 44 * (-1)
        worldMap.addSubview(label)
    }
    
    func addBoundary(countryShape: Country) {
        
        var polygons = [MKPolygon]()
        //then need to loop through each boundary and make each a polygon and calculate the number of points
        for var landArea in (countryShape.boundary) {
            let multiPolygon = MKPolygon(coordinates: &landArea, count: landArea.count)
            multiPolygon.title = countryShape.country
            //let overlay = customPolygon(countryName: country.country, alphaValue: 1.0, polygon: multiPolygon)
            polygons.append(multiPolygon)
            worldMap.addOverlay(multiPolygon)
            polygons.append(multiPolygon)
        }
        createdPolygonOverlays[countryShape.country] = polygons
        coordinates[countryShape.country] = countryShape.boundary
        
    }
    
    func setZoomForContinent () {
        // dictionary of points and zooms for the continents
        var midPoints = [
            "EU": ["lat": 50.9630, "long": 10.1875, "scale": 70.0],
            "AF": ["lat": 2.897318, "long": 18.105618, "scale": 110.0],
            "OC": ["lat": -29.962515, "long": 172.562187, "scale": 130.0],
            "AS": ["lat": 20.4507, "long": 85.8319, "scale": 130.0],
            "NA": ["lat": 55.856794, "long":  -101.585755, "scale": 130.0],
            "SA": ["lat": -25.643226, "long": -57.442726, "scale": 80.0]
        ]
        
        let latDelta:CLLocationDegrees = midPoints[continent!]!["scale"]!
        let longDelta:CLLocationDegrees = midPoints[continent!]!["scale"]!
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(midPoints[continent!]!["lat"]!, midPoints[continent!]!["long"]!)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        worldMap.setRegion(region, animated: true)
    }
    
    
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
//        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
//        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        displayTimeLabel.title = "\(strMinutes):\(strSeconds)"
    }

    
}
