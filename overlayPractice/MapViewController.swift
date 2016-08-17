//
//  MapViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/6/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//    let continentCodes = [
//        "AF": "Africa",
//        "AN": "Antarctica",
//        "AS": "Asia",
//        "EU": "Europe",
//        "NA": "North America",
//        "OC": "Oceania",
//        "SA": "South America"
//    ]

import UIKit
import MapKit
import CoreData


// starting logic for challenge mode
// timer
// lives
// ending

class MapViewController: CoreDataController {

    @IBOutlet weak var worldMap: MKMapView!
    
    var continent: String!
    
    var currentGame: Game!
    
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
    
    var mapDelegate = MapViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldMap.delegate = mapDelegate
        
        //customize the navigation bar buttons
        self.navigationItem.hidesBackButton = true
        let newBackButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(self.returnToMainMenue))
        self.navigationItem.leftBarButtonItem = newBackButton

        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        let entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities", entities.count)
        
        //make a new game in core data
        currentGame = Game(continent: continent, mode: "practice", context: fetchedResultsController!.managedObjectContext)
        //let autosave save it
        print("THE GAME: ",currentGame)
        
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
    
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let tappedCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        
        //loop through the countries in continent
        for (key, _) in coordinates {
            
            for landArea in coordinates[key]! {
                //each thing is a land area of coordinates
                if (self.contains(landArea, selectedPoint: tappedCoordinates)) {
                    if (toFind == key) {
                        label.text = "Found!"
                        label.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
                        //save the attempt to coredata
                        let turn = Attempt(toFind: toFind, guessed: toFind, revealed: false, context: fetchedResultsController!.managedObjectContext)
                        turn.game = currentGame
                        currentGame.attempt?.setByAddingObject(turn)
                        
                        delay(0.7) {
                            self.setQuestionLabel()
                        }
                        //then we can delete country overlay from map as correct selection
                        updateMapOverlays(key)
                    } else {
                        //it was an incorrect guess, want to currently do nothing/change color/say wrong country on label
                        label.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
                        misses += 1
                        //save attempt to core data
                        let turn = Attempt(toFind: toFind, guessed: key, revealed: false, context: fetchedResultsController!.managedObjectContext)
                        turn.game = currentGame
                        currentGame.attempt?.setByAddingObject(turn)
                        
                        delay(0.7) {
                            self.label.text = "Find: \(self.toFind)"
                            self.label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
                        }
                    }
                }
     
            }

        }
        
    }
    
    @IBAction func skip(sender: AnyObject) {
        setQuestionLabel()
    }
    
    //ask new question
    func setQuestionLabel () {
        if game["toPlay"]?.count > 0 {
            let index: Int = Int(arc4random_uniform(UInt32(game["toPlay"]!.count)))
            let randomVal = Array(game["toPlay"]!.values)[index]
            toFind = randomVal
            label.text = "Find: \(randomVal)"
            label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        } else {
            //nothing left to play - all countries have been guessed
            //push to score screen
            performSegueWithIdentifier("showScore", sender: nil)
            // save finish date to core data
            currentGame.finished_at = NSDate()
        }
        self.title = String("\(game["guessed"]!.count + game["revealed"]!.count) / \(totalCountries)")
    }
    
    // TODO:
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showScore" {
            //let controller = segue.destinationViewController as! ScoreViewController
            //get the id property on the annotation
//            controller.score = game["guessed"]?.count
//            controller.scoreTotal = totalCountries
//            controller.revealed = game["revealed"]?.count
//            controller.misses = misses
            
        }
    }
    
    func updateMapOverlays(titleOfPolyToRemove: String) {
        for overlay: MKOverlay in worldMap.overlays {
            if overlay.title! == titleOfPolyToRemove {
                //remove references to this polygon
                createdPolygonOverlays.removeValueForKey(titleOfPolyToRemove)
                coordinates.removeValueForKey(titleOfPolyToRemove)
                let annotation = MKPointAnnotation()
                annotation.coordinate = overlay.coordinate
                annotation.title = titleOfPolyToRemove
                worldMap.addAnnotation(annotation)
                worldMap.removeOverlay(overlay)
            }
        }
        self.game["guessed"]![self.toFind] = self.toFind
        self.game["toPlay"]!.removeValueForKey(self.toFind)
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

    
    @IBAction func showAll(sender: AnyObject) {
        //TODO: more functionality??
        //delete all overlays off the map
        for overlay: MKOverlay in worldMap.overlays {
            //TODO: show name of country
            worldMap.removeOverlay(overlay)
        }
        //delete the countries dictionary
        createdPolygonOverlays.removeAll()
        setZoomForContinent()
    }
    
    
    // this button shows the uncovers the current courty being asked
    @IBAction func reveal(sender: AnyObject) {
        // get the name of the country being asked
        for overlay in worldMap.overlays {
            if overlay.title!! == toFind {
                //remove reference to it in view
                worldMap.removeOverlay(overlay)
                // add reveal to core data
                let turn = Attempt(toFind: toFind, guessed: "", revealed: true, context: fetchedResultsController!.managedObjectContext)
                turn.game = currentGame
                currentGame.attempt?.setByAddingObject(turn)
                
                continue
            }
        }
        print("polygons: ",createdPolygonOverlays.count)
        print("coordinates: ",coordinates.count)
        game["toPlay"]!.removeValueForKey(toFind)
        game["revealed"]![toFind] = toFind
        createdPolygonOverlays.removeValueForKey(toFind)
        coordinates.removeValueForKey(toFind)
        setQuestionLabel()
        
    }
    
    func returnToMainMenue () {
        navigationController?.popToRootViewControllerAnimated(true)
        currentGame.finished_at = NSDate()
        do {
            try fetchedResultsController!.managedObjectContext.save()
        } catch {
            print("error saving :(", error)
        }
        
    }
    
}

extension MapViewController {
    
    // check if a point is in a polygon
    func contains(polygon: [CLLocationCoordinate2D], selectedPoint: CLLocationCoordinate2D) -> Bool {
        var pJ=polygon.last!
        var contains = false
        for pI in polygon {
            if ( ((pI.latitude >= selectedPoint.latitude) != (pJ.latitude >= selectedPoint.latitude)) &&
                (selectedPoint.longitude <= (pJ.longitude - pI.longitude) * (selectedPoint.latitude - pI.latitude) / (pJ.latitude - pI.latitude) + pI.longitude) ){
                contains = !contains
            }
            pJ=pI
        }
        return contains
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
    
    func delay (delay:Double, closure:()->()) {
        //set the time to dispatch after
        //dispatch_time: creates dispatch time relative to now then this is in a dispatch after this amount of time method
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),
        //then run the closure fn in the main queue when delay over
        dispatch_get_main_queue(), closure)
    }

    
}



