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
    
    var continent: String!
    
    @IBOutlet weak var displayTimerLabel: MKMapView!
    @IBOutlet weak var worldMap: MKMapView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lifeThree: UILabel!
    @IBOutlet weak var lifeTwo: UILabel!
    @IBOutlet weak var lifeOne: UILabel!
    
    let Helpers = HelperFunctions.sharedInstance
    
    var totalCountries: Int = 0
    var currentGame: Game!
    var restoreOccur: Bool?
    
    var game = [
        "guessed": [String:String](),
        "toPlay": [String:String]()
    ]
    var revealed = 0
    var misses = 0
    
    var lives = 3
    
    var toFind = ""
    //question label
    let label = UILabel()
    
    var stopwatch = 50
    var timerScheduler: NSTimer!
    
    //dictionary keyed by country name with the values as an array of all the polygons for that country
    var createdPolygonOverlays = [String: [MKPolygon]]()
    //dictionary keyed by country name with values of the coordinates of each country (for the contains method to use to check if clicked point is within one of the overlays)
    var coordinates = [ String: [[CLLocationCoordinate2D]] ]()
    var entities: [LandArea]!
    
    var mapDelegate = MapViewDelegate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        worldMap.delegate = mapDelegate
        let alertController = UIAlertController(title: "Ready?", message: "Hit go to start the game", preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "GO", style: .Default) { (action:UIAlertAction!) in
            print("start the timer")
            self.timerScheduler = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ChallengeViewController.updateTime), userInfo: nil, repeats: true)
            
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion:nil)
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities", entities.count)
        //make an array of country models - loop through core data for all with desired continent code and make to model
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer)
        // set map
        worldMap.mapType = .Satellite
    }
    
    
    override func viewWillAppear(animated: Bool) {
        for entity in entities {
            if (entity.continent == continent) {
                let country = Country(title: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!, point: entity.annotation_point!)
                game["toPlay"]![entity.name!] = entity.name
                addBoundary(country)
            }
        }
        totalCountries = createdPolygonOverlays.count
        // show countries guessed count to user
        self.title = String("0 / \(totalCountries)")
        print("<><><><><>",game["toPlay"]!.count)
        // 2. if restore then get the existing game else if not restore then make a new game
        if (restoreOccur == true) {
            restoreOccur = false
            print("data is saved go get it")
            // if the game has already been partially played then set up old scores
            if currentGame.attempt?.count > 0 {
                //1. loop through the attempts and adjust overlays and score to match
                for attempt in currentGame.attempt! {
                    if (attempt as! Attempt).countryToFind == (attempt as! Attempt).countryGuessed {
                        game["guessed"]![(attempt as! Attempt).countryToFind!] = (attempt as! Attempt).countryToFind
                        game["toPlay"]!.removeValueForKey((attempt as! Attempt).countryToFind!)
                        for overlay in worldMap.overlays {
                            if overlay.title! == (attempt as! Attempt).countryToFind {
                                worldMap.removeOverlay(overlay)
                                continue
                            }
                        }
                    } else if (attempt as! Attempt).revealed == true {
                        revealed += 1
                        game["toPlay"]!.removeValueForKey((attempt as! Attempt).countryToFind!)
                        for overlay in worldMap.overlays {
                            if overlay.title! == (attempt as! Attempt).countryToFind {
                                worldMap.removeOverlay(overlay)
                                continue
                            }
                        }
                    } else if (attempt as! Attempt).countryToFind != (attempt as! Attempt).countryGuessed {
                        misses += 1
                    }
                }
            }
        } else {
            //make a new game in core data and set as current
            currentGame = Game(continent: continent, mode: "challenge", context: fetchedResultsController!.managedObjectContext)
            let region = Helpers.setZoomForContinent(continent)
            worldMap.setRegion(region, animated: true)
        }
        print("countries to play --->", game["toPlay"]!.count)
        //make label to show the user and pick random index to grab country name with
        makeQuestionLabel()
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
        for landArea in (countryShape.boundary) {
            // make custom polygon to be able to edit properties 
            let overlay = CustomPolygon(guessed: false, lat_long: countryShape.annotation_point, coords: landArea, numberOfPoints: landArea.count)
            overlay.title = countryShape.name
            polygons.append(overlay)
            worldMap.addOverlay(overlay)
            polygons.append(overlay)
        }
        createdPolygonOverlays[countryShape.name] = polygons
        coordinates[countryShape.name] = countryShape.boundary
    }
    
     // work out if the click was on a country
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let tappedCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        // loop through the land areas in the current country to find and make sure that the tap was here - else error
        var found = false
        for landArea in coordinates[toFind]! {
            //call function to retrun true or false, depending if the tap is in one of the land areas
            if (Helpers.contains(landArea, selectedPoint: tappedCoordinates)) {
                found = true
            }
        }
        if found {
            label.text = "Found!"
            label.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
            //save the attempt to coredata
            let turn = Attempt(toFind: toFind, guessed: toFind, revealed: false, context: fetchedResultsController!.managedObjectContext)
            turn.game = currentGame
            currentGame.attempt?.setByAddingObject(turn)
            Helpers.delay(0.7) {
                self.setQuestionLabel()
            }
            updateMapOverlays(toFind)
        } else {
            //it was an incorrect guess
            label.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
            misses += 1
            //save attempt to core data
            let turn = Attempt(toFind: toFind, guessed: toFind, revealed: false, context: fetchedResultsController!.managedObjectContext)
            turn.game = currentGame
            currentGame.attempt?.setByAddingObject(turn)
            Helpers.delay(0.7) {
                self.label.text = "Find: \(self.toFind)"
                self.label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
            }
            lives -= 1
            // remove a life and fade out in UI
            if lifeThree.enabled {
                lifeThree.enabled = false
            } else if lifeTwo.enabled {
                lifeTwo.enabled = false
            } else if lifeOne.enabled {
                lifeOne.enabled = false
                // all lives gone
                currentGame.finished_at = NSDate()
                performSegueWithIdentifier("showChallengeScore", sender: nil)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // pass the lives and total score and total countries and time
        let controller = segue.destinationViewController as! ChallengeScoreViewController
        controller.lives = lives
        controller.correct = game["guessed"]!.count
        controller.time = stopwatch
        controller.totalCountriesInContinent = totalCountries
    }
    
    //ask new question
    func setQuestionLabel () {
        self.title = String("\(game["guessed"]!.count + revealed) / \(totalCountries)")
        if game["toPlay"]?.count > 0 {
            let index: Int = Int(arc4random_uniform(UInt32(game["toPlay"]!.count)))
            let randomVal = Array(game["toPlay"]!.values)[index]
            toFind = randomVal
            label.text = "Find: \(randomVal)"
            label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        } else {
            //push to score screen
            currentGame.finished_at = NSDate()
            performSegueWithIdentifier("showChallengeScore", sender: nil)
        }
    }
    
    
    func updateMapOverlays(titleOfPolyToRemove: String) {
        for overlay: MKOverlay in worldMap.overlays {
            if overlay.title! == titleOfPolyToRemove {
                //update the polygon so it just has a white outline
                worldMap.removeOverlay(overlay)
                (overlay as! CustomPolygon).userGuessed = true
                worldMap.addOverlay(overlay)
                worldMap.addAnnotation(Helpers.addCountryLabel(overlay.title!!, overlay: overlay))
            }
        }
        self.game["guessed"]![self.toFind] = self.toFind
        self.game["toPlay"]!.removeValueForKey(self.toFind)
    }
    
    func updateTime () {
        if(stopwatch > 0){
            let minutes = String(stopwatch / 60)
            var seconds = String(stopwatch % 60)
            if String(seconds).characters.count == 1 {
                seconds = seconds + String("0")
            }
            timerLabel.text = minutes + ":" + seconds
            stopwatch -= 1
        } else {
            // stop this function from being called after this condition has been met
            timerScheduler.invalidate()
            currentGame.finished_at = NSDate()
            performSegueWithIdentifier("showChallengeScore", sender: nil)
        }
    }
    
    
    // functions to deal with the restoring state
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        // save the continent as minimal source of data
        coder.encodeObject(continent as AnyObject, forKey: "continent")
        coder.encodeInteger(stopwatch, forKey: "stoppedTime")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        let data = coder.decodeObjectForKey("continent")
        continent = String(data!)
        stopwatch = coder.decodeIntegerForKey("stoppedTime")
        restoreOccur = true
        super.decodeRestorableStateWithCoder(coder)
    }
    
    // once the app has loaded again work out what to show on the screen
    override func applicationFinishedRestoringState() {
        //grab the unfinished game and set to currrent game
        let moc = fetchedResultsController!.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
        
        var entities: [Game]
        do {
            entities = try moc.executeFetchRequest(fetchRequest) as! [Game]
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        // set the current game if needed else return to main menu
        if entities[0].finished_at != nil {
            print("have game to continue")
            currentGame = entities[0]
        } else {
            //show the home page
            print("return home")
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
}
