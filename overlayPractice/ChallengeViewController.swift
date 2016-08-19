//
//  ChallengeViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/16/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//next add in lives
//add in score page
//add in BOMB to finish

import UIKit
import MapKit
import CoreData

class ChallengeViewController: CoreDataController {
    
    var continent: String!
    
    @IBOutlet weak var displayTimerLabel: MKMapView!
    @IBOutlet weak var worldMap: MKMapView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lifeThree: UILabel!
    @IBOutlet weak var lifeTwo: UILabel!
    @IBOutlet weak var lifeOne: UILabel!
    
    let Helpers = HelperFunctions.sharedInstance
    
    var totalCountries: Int = 0
    
    var game = [
        "guessed": [String:String](),
        "toPlay": [String:String](),
        "revealed": [String: String]()
    ]
    var misses = 0
    
    var lives = 3
    
    var toFind = ""
    //question label
    let label = UILabel()
    
    var count = 600
    
    //dictionary keyed by country name with the values as an array of all the polygons for that country
    var createdPolygonOverlays = [String: [MKPolygon]]()
    //dictionary keyed by country name with values of the coordinates of each country (for the contains method to use to check if clicked point is within one of the overlays)
    var coordinates = [ String: [[CLLocationCoordinate2D]] ]()
    
    var mapDelegate = MapViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldMap.delegate = mapDelegate
        
        let alertController = UIAlertController(title: "Ready?", message: "Hit go to start the game", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "GO", style: .Default) { (action:UIAlertAction!) in
            print("start the timer")
            _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ChallengeViewController.updateTime), userInfo: nil, repeats: true)
            
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
        label.frame = CGRectMake(0, 0, (screenSize.width + 5), 35)
        
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
    
    
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let tappedCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        
        //loop through the countries in continent
        for (key, _) in coordinates {
            
            for landArea in coordinates[key]! {
                //each thing is a land area of coordinates
                if (Helpers.contains(landArea, selectedPoint: tappedCoordinates)) {
                    if (toFind == key) {
                        self.label.text = "Found!"
                        label.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
                        Helpers.delay(0.7) {
                            self.setQuestionLabel()
                        }
                        //then we can delete country overlay from map as correct selection
                        updateMapOverlays(key)
                    } else {
                        //it was an incorrect guess, want to currently do nothing/change color/say wrong country on label
                        label.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
                        misses += 1
                        lives -= 1
                        
                        if lives == 2 {
                           lifeThree.enabled = false
                        } else if lives == 1 {
                            lifeTwo.enabled = false
                        } else {
                            lifeOne.enabled = false
                            //BOOM! No more lives segue to score page?
                            print("No more lives!")
                        }
                        
                        Helpers.delay(0.7) {
                            if self.lives == 0 {
                                //segue to score page
                                // show bomb  - present modally?
                                // show time taken and then number correct?
                            } else {
                                //reset the question label
                                self.label.text = "Find: \(self.toFind)"
                                self.label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
                            }
                        }
                    }
                }
                
            }
            
        }
        
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
        }
        self.title = String("\(game["guessed"]!.count + game["revealed"]!.count) / \(totalCountries)")
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
    
}

extension ChallengeViewController {
    
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
    
    func updateTime () {
        if(count > 0){
            let minutes = String(count / 60)
            var seconds = String(count % 60)
            if String(seconds).characters.count == 1 {
                seconds = seconds + String("0")
            }
            timerLabel.text = minutes + ":" + seconds
            count -= 1
        }
    }
    
    
}