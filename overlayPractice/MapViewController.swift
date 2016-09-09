//
//  MapViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/6/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//


import UIKit
import MapKit
import CoreData
import AVFoundation

class MapViewController: CoreDataController {

    @IBOutlet weak var worldMap: MKMapView!
    @IBOutlet weak var revealButton: UIBarButtonItem!
    @IBOutlet weak var showAllButton: UIBarButtonItem!
    @IBOutlet weak var stepper: UIStepper!
    
    let Helpers = HelperFunctions.sharedInstance
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var currentGame: Game!
    var restoreOccur: Bool?
    
    //question label to ask user to find a country
    var label:UILabel?
        
    var mapDelegate = MapViewDelegate()
    //entities from core data for the current continent
    var entities: [LandArea]!
    var gestureRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add a skip button to the nav bar
        let skipButton: UIBarButtonItem = UIBarButtonItem(title: "Skip", style: .Plain, target: self, action: #selector(self.skip))
        navigationItem.rightBarButtonItem = skipButton
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Helpers.labelFont], forState: .Normal)
        
        worldMap.delegate = mapDelegate
        // add tap recogniser to allow user to select country
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer!)
        // set map type
        worldMap.mapType = .Satellite
        
        //set fonts
        revealButton.setTitleTextAttributes([NSFontAttributeName: Helpers.labelFont], forState: .Normal)
        showAllButton.setTitleTextAttributes([NSFontAttributeName: Helpers.labelFont], forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //if if the contient is not set throw error - for view restore
        if  Helpers.continent == nil {
            let alertController = UIAlertController(title: "Alert", message: "You left the game for too long. Please return to the menu to start again.", preferredStyle: UIAlertControllerStyle.Alert)
            let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            alertController.addAction(Action)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.presentViewController(alertController, animated: true, completion:nil)
            }
        }
        
        //get the needed entities out of core data for the chosen continent
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let pred = NSPredicate(format: "continent = %@", Helpers.continent)
        fetchRequest.predicate = pred
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: app.landAreas.context, sectionNameKeyPath: nil, cacheName: nil)
        entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities in view did load: ", entities.count)
        
        //check that there are entities to add to the view
        if entities.count == 0 {
            let alertController = UIAlertController(title: "Alert", message: "There was a problem loading the countries.", preferredStyle: UIAlertControllerStyle.Alert)
            let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                // if none then return the user to the main menu
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            alertController.addAction(Action)
        }
        
        for entity in entities {
            if (entity.continent == Helpers.continent) {
                makeCountryAndAddToMap(entity)
            }
        }
        //set a total value for all the countries in the continent
        Helpers.totalCountries = Helpers.createdPolygonOverlays.count
        // show count of countries got at top of screen
        self.title = String("0 / \(Helpers.totalCountries)")
        
        // if restore then get the existing game else if not restore then make a new game
        if (restoreOccur == true) {
            restoreOccur = false
            print("data is saved go get it")
            // if the game has already been partially played then set up old scores
            if currentGame.attempt?.count > 0 {
                //1. loop through the attempts and adjust overlays and score to match
                for attempt in currentGame.attempt! {
                    if (attempt as! Attempt).countryToFind == (attempt as! Attempt).countryGuessed {
                        Helpers.game["guessed"]![(attempt as! Attempt).countryToFind!] = (attempt as! Attempt).countryToFind
                        Helpers.game["toPlay"]!.removeValueForKey((attempt as! Attempt).countryToFind!)
                        for overlay in worldMap.overlays {
                            if overlay.title! == (attempt as! Attempt).countryToFind {
                                // not remove overlay here just reset so there is an outline and an annotation
                                worldMap.removeOverlay(overlay)
                                (overlay as! CustomPolygon).userGuessed = true
                                worldMap.addOverlay(overlay)
                                worldMap.addAnnotation(Helpers.addCountryLabel(overlay.title!!, overlay: overlay))
                                continue
                            }
                        }
                    } else if (attempt as! Attempt).revealed == true {
                        Helpers.revealed += 1
                        Helpers.game["toPlay"]!.removeValueForKey((attempt as! Attempt).countryToFind!)
                        for overlay in worldMap.overlays {
                            if overlay.title! == (attempt as! Attempt).countryToFind {
                                // not remove overlay here just reset so there is an outline and an annotation
                                worldMap.removeOverlay(overlay)
                                (overlay as! CustomPolygon).userGuessed = true
                                worldMap.addOverlay(overlay)
                                worldMap.addAnnotation(Helpers.addCountryLabel(overlay.title!!, overlay: overlay))
                                continue
                            }
                        }
                    } else if (attempt as! Attempt).countryToFind != (attempt as! Attempt).countryGuessed {
                        Helpers.misses += 1
                    }
                }
            }
        } else {
            //make a new game in core data and set as current
            currentGame = Game(continent: Helpers.continent, mode: "practice", context: fetchedResultsController!.managedObjectContext)
            // use autosave to save it - else on exiting the core data entities are saved
        }
        let region = Helpers.setZoomForContinent(Helpers.continent)
        worldMap.setRegion(region, animated: true)
        print("countries to find --->", Helpers.game["toPlay"]!.count)
        //make label to show the user and pick random index to grab country name with
        label = Helpers.makeQuestionLabel("practice")
        worldMap.addSubview(label!)
    }
    
    //set up games to play in dictionary and make country model
    func makeCountryAndAddToMap (entity: LandArea) {
        let country = Country(title: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!, point: entity.annotation_point!)
        Helpers.game["toPlay"]![entity.name!] = entity.name
        addBoundary(country)
    }
        
    // work out if the click was on a country
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let tappedCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        // loop through the land areas in the current country to find and make sure that the tap was here - else error
        var found = false
        
        for landArea in Helpers.coordinates[Helpers.toFind]! {
            //for the small islands allow tap to not be totally accurate
            if (Helpers.islands[Helpers.toFind] != nil) {
                // check it the tap is within a certain distance of the polygon
                if Helpers.createdPolygonOverlays[Helpers.toFind] != nil {
                    let lat: CLLocationDegrees = tappedCoordinates.latitude
                    let lon: CLLocationDegrees = tappedCoordinates.longitude
                    let locationPoint: CLLocation =  CLLocation(latitude: lat, longitude: lon)
                    let lat2: CLLocationDegrees = (Helpers.createdPolygonOverlays[Helpers.toFind]![0] as! CustomPolygon).annotation_point.latitude
                    let lon2: CLLocationDegrees = (Helpers.createdPolygonOverlays[Helpers.toFind]![0] as! CustomPolygon).annotation_point!.longitude
                    let locationPoint2: CLLocation =  CLLocation(latitude: lat2, longitude: lon2)
                    if locationPoint.distanceFromLocation(locationPoint2)/1000 < 500 {
                        found = true
                    }
                }
            } else if (Helpers.contains(landArea, selectedPoint: tappedCoordinates)) {
                found = true
            }
        }
        //logic for tapped correct/incorrect country
        if found {
            // play correct sound
            let audioPlayer = Helpers.playSound("yep")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            label!.text = "Found!"
            label!.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
            //save the attempt to coredata
            let turn = Attempt(toFind: Helpers.toFind, guessed: Helpers.toFind, revealed: false, context: fetchedResultsController!.managedObjectContext)
            turn.game = currentGame
            currentGame.attempt?.setByAddingObject(turn)
            Helpers.delay(0.7) {
                self.setQuestionLabel()
            }
            updateMapOverlays(Helpers.toFind)
        } else {
            //it was an incorrect guess play nope sound
            let audioPlayer = Helpers.playSound("nope")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            label!.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
            //increase wrong count
            Helpers.misses += 1
            //save attempt to core data
            let turn = Attempt(toFind: Helpers.toFind, guessed: Helpers.toFind, revealed: false, context: fetchedResultsController!.managedObjectContext)
            turn.game = currentGame
            currentGame.attempt?.setByAddingObject(turn)
            Helpers.delay(0.7) {
                self.label!.text = "Find: \(self.Helpers.toFind)"
                self.label!.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
            }
        }
    
    }
    
    //show new country to find
    @IBAction func skip(sender: AnyObject) {
        // play skip sound
        let audioPlayer = Helpers.playSound("skip")
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        setQuestionLabel()
    }
    
    //ask new question
    func setQuestionLabel () {
        if Helpers.game["toPlay"]?.count > 0 {
            let index: Int = Int(arc4random_uniform(UInt32(Helpers.game["toPlay"]!.count)))
            let randomVal = Array(Helpers.game["toPlay"]!.values)[index]
            Helpers.toFind = randomVal
            label!.text = "Find: \(randomVal)"
            label!.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        } else {
            view.removeGestureRecognizer(gestureRecognizer!)
            //nothing left to play - all countries have been guessed
            // save finish date to core data
            currentGame.finished_at = NSDate()
            //send current finished game to the client file to send to server
            if Reachability.isConnectedToNetwork() {
                if NSUserDefaults.standardUserDefaults().objectForKey("user_id") != nil {
                    if NSUserDefaults.standardUserDefaults().objectForKey("user_secret") != nil {
                        Helpers.sendGameToClient(currentGame)
                    } else {
                        throwAlert("The game cannot be saved",message: "There is no user_id regestered with this phone. To save a game, terminate and restart the app in an area with internet.")
                    }
                } else {
                    throwAlert("The game cannot be saved",message: "There is no user_id regestered with this phone. To save a game, terminate and restart the app in an area with internet.")
                }
            } else {
                throwAlert("Alert",message: "There is no internet connection. Please connect to the interenet to view this page.")
            }
            //if the game not saved then alert the user that it was not saved
            Helpers.delay(2.0) {
                self.performSegueWithIdentifier("showScore", sender: nil)
            }
        }
        self.title = String("\(Helpers.game["guessed"]!.count + Helpers.revealed) / \(Helpers.totalCountries)")
    }
    
    func throwAlert (title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
        }
        alertController.addAction(Action)
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alertController, animated: true, completion:nil)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showScore" {
            let controller = segue.destinationViewController as! ScoreViewController
            controller.score = Helpers.game["guessed"]?.count
            controller.scoreTotal = Helpers.totalCountries
            controller.revealed = Helpers.revealed
            controller.incorrect = Helpers.misses
            Helpers.finishGame()
        }
    }
    
    func updateMapOverlays(titleOfPolyToRemove: String) {
        for overlay: MKOverlay in worldMap.overlays {
            if overlay.title! == titleOfPolyToRemove {
                //remove the overlay and then add it again with the the userGuessed property as true (tell render method just to show overlay outline and not the fill)
                worldMap.removeOverlay(overlay)
                (overlay as! CustomPolygon).userGuessed = true
                worldMap.addOverlay(overlay)
                worldMap.addAnnotation(Helpers.addCountryLabel(overlay.title!!, overlay: overlay))
            }
        }
        //update game dictionary
        Helpers.game["guessed"]![Helpers.toFind] = Helpers.toFind
        Helpers.game["toPlay"]!.removeValueForKey(Helpers.toFind)
    }
    
    //add a polygon to a map
    func addBoundary(countryShape: Country) {
        var polygons = [MKPolygon]()
        //then need to loop through each boundary and make each a polygon and calculate the number of points
        for landArea in (countryShape.boundary) {
            let overlay = CustomPolygon(guessed: false, lat_long: countryShape.annotation_point, coords: landArea, numberOfPoints: landArea.count )
            overlay.title = countryShape.name
            polygons.append(overlay)
            worldMap.addOverlay(overlay)
            polygons.append(overlay)
        }
        Helpers.createdPolygonOverlays[countryShape.name] = polygons
        Helpers.coordinates[countryShape.name] = countryShape.boundary
    }

    //show all of the countries and their annotations
    @IBAction func showAll(sender: AnyObject) {
        //TODO: more functionality??
        //delete all overlays off the map
        for overlay in worldMap.overlays {
            //TODO: show name of country
            worldMap.removeOverlay(overlay)
            (overlay as! CustomPolygon).userGuessed = true
            worldMap.addOverlay(overlay)
            worldMap.addAnnotation(Helpers.addCountryLabel(overlay.title!!, overlay: overlay))
        }
        //delete the countries dictionary
        Helpers.createdPolygonOverlays.removeAll()
        label!.removeFromSuperview()
        revealButton.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
        showAllButton.enabled = false
        currentGame.finished_at = NSDate()
        Helpers.finishGame()
    }
    
    
    // this button shows the uncovers the current courty being asked
    @IBAction func reveal(sender: AnyObject) {
        // get the name of the country being asked
        let audioPlayer = Helpers.playSound("reveal")
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        for overlay in worldMap.overlays {
            if overlay.title!! == Helpers.toFind {
                //update the mapview
                worldMap.removeOverlay(overlay)
                (overlay as! CustomPolygon).userGuessed = true
                worldMap.addOverlay(overlay)
                worldMap.addAnnotation(Helpers.addCountryLabel(overlay.title!!, overlay: overlay))
                // center map on revealed point
                let latDelta:CLLocationDegrees = 10.0
                let longDelta:CLLocationDegrees = 10.0
                let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
                let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake((overlay as! CustomPolygon).annotation_point.latitude, (overlay as! CustomPolygon).annotation_point.longitude)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
                worldMap.setRegion(region, animated: true)
                // add reveal to core data
                let turn = Attempt(toFind: Helpers.toFind, guessed: "", revealed: true, context: fetchedResultsController!.managedObjectContext)
                turn.game = currentGame
                currentGame.attempt?.setByAddingObject(turn)
                continue
            }
        }
        Helpers.game["toPlay"]!.removeValueForKey(Helpers.toFind)
        Helpers.revealed += 1
        setQuestionLabel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        currentGame.finished_at = NSDate()
        Helpers.finishGame()
        app.landAreas.save()
    }
    
    
    // functions to deal with the restoring state
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        // save the continent as minimal source of data
        coder.encodeObject(Helpers.continent as AnyObject, forKey: "continent")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        let data = coder.decodeObjectForKey("continent")
        Helpers.continent = String(data!)
        restoreOccur = true
        super.decodeRestorableStateWithCoder(coder)
    }
    
    // once the app has loaded again work out what to show on the screen
    override func applicationFinishedRestoringState() {
        print("finished restoring state map view")
        //grab the unfinished game and set to currrent game
        let moc = app.landAreas.context
        let fetchRequest = NSFetchRequest(entityName: "Game")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: false)]
        
        var entities: [Game]
        do {
            entities = try moc.executeFetchRequest(fetchRequest) as! [Game]
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        // set the current game - if the finish date is nil
        if entities.count > 0 && entities[0].finished_at == nil {
            print("have game to continue")
            currentGame = entities[0]
        } else {
            //show the home page
            navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }
    
    @IBAction func zoom(sender: AnyObject) {
        //find center of the view/map zoom in here
        let viewCenter = worldMap.centerCoordinate
        let latDelta:CLLocationDegrees = 100 - (stepper.value)
        let longDelta:CLLocationDegrees = 100 - (stepper.value)
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(viewCenter, theSpan)
        worldMap.setRegion(region, animated: true)
    }
}






