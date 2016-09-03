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
    
    @IBOutlet weak var displayTimerLabel: MKMapView!
    @IBOutlet weak var worldMap: MKMapView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lifeThree: UIImageView!
    @IBOutlet weak var lifeTwo: UIImageView!
    @IBOutlet weak var lifeOne: UIImageView!
    
    let Helpers = HelperFunctions.sharedInstance
    
    var currentGame: Game!
    var restoreOccur: Bool?
    
    var lives = 3
    
    //question label
    var label: UILabel?
    
    //timer
    var stopwatch = 0
    var timerScheduler: NSTimer!
    
    var entities: [LandArea]!
    
    var mapDelegate = MapViewDelegate()
    let app = UIApplication.sharedApplication().delegate as! AppDelegate
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //skip button on the top bar
        let skipButton: UIBarButtonItem = UIBarButtonItem(title: "Skip", style: .Plain, target: self, action: #selector(self.skip))
        navigationItem.rightBarButtonItem = skipButton
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: Helpers.labelFont], forState: .Normal)
        
        worldMap.delegate = mapDelegate
        
        //make an array of country models - loop through core data for all with desired continent code and make to model
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer)
        // set map
        worldMap.mapType = .Satellite
    }

    
    override func viewWillAppear(animated: Bool) {
        
        //if there is no set continent
        if Helpers.continent == nil {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                let alertController = UIAlertController(title: "Alert", message: "You left the game for too long. Please return to the menu to start again.", preferredStyle: UIAlertControllerStyle.Alert)
                let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                alertController.addAction(Action)
            }
        }
        
        // load the contries needed for the continent from core data
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let pred = NSPredicate(format: "continent = %@", Helpers.continent)
        fetchRequest.predicate = pred
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: app.landAreas.context, sectionNameKeyPath: nil, cacheName: nil)
        entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities", entities.count)
        
        //check that there are entities to add to the view
        if entities.count == 0 {
            let alertController = UIAlertController(title: "Alert", message: "There was a problem loading the countries.", preferredStyle: UIAlertControllerStyle.Alert)
            let Action = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                //return the user to the main menu
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            alertController.addAction(Action)
        }
        
        //loop through the loaded data and add to the map and into the game dictionary
        for entity in entities {
            if (entity.continent == Helpers.continent) {
                let country = Country(title: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!, point: entity.annotation_point!)
                Helpers.game["toPlay"]![entity.name!] = entity.name
                addBoundary(country)
            }
        }
        
        Helpers.totalCountries = Helpers.createdPolygonOverlays.count
        //make the this time the number of countries * 10 /60 (10 secs per country)
        stopwatch = Helpers.totalCountries*8
        
        // if restore then get the existing game else if not restore then make a new game
        if (restoreOccur == true) {
            
            restoreOccur = false
            // if the game has already been partially played then set up old scores
            if currentGame.attempt?.count > 0 {
                //1. loop through the attempts and adjust overlays and score to match
                for attempt in currentGame.attempt! {
                    if (attempt as! Attempt).countryToFind == (attempt as! Attempt).countryGuessed {
                        Helpers.game["guessed"]![(attempt as! Attempt).countryToFind!] = (attempt as! Attempt).countryToFind
                        Helpers.game["toPlay"]!.removeValueForKey((attempt as! Attempt).countryToFind!)
                        for overlay in worldMap.overlays {
                            if overlay.title! == (attempt as! Attempt).countryToFind {
                                worldMap.removeOverlay(overlay)
                                continue
                            }
                        }
                    } else if (attempt as! Attempt).countryToFind != (attempt as! Attempt).countryGuessed {
                        Helpers.misses += 1
                    }
                }
            }
            //timerScheduler = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ChallengeViewController.updateTime), userInfo: nil, repeats: true)
            //user message to okay when the user is ready to play
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.timerScheduler = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ChallengeViewController.updateTime), userInfo: nil, repeats: true)
            }
            
        } else {
            //user message to okay when the user is ready to play
            let alertController = UIAlertController(title: "Ready?", message: "Hit go to start the game", preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "GO", style: .Default) { (action:UIAlertAction!) in
                self.timerScheduler = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ChallengeViewController.updateTime), userInfo: nil, repeats: true)
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion:nil)
            //make a new game in core data and set as current
            currentGame = Game(continent: Helpers.continent, mode: "challenge", context: fetchedResultsController!.managedObjectContext)
        }
        self.title = String("\(Helpers.game["guessed"]!.count) / \(Helpers.totalCountries)")
        let region = Helpers.setZoomForContinent(Helpers.continent)
        worldMap.setRegion(region, animated: true)
        print("countries to play --->", Helpers.game["toPlay"]!.count)
        //make label to show the user and pick random index to grab country name with
        label = Helpers.makeQuestionLabel("challenge")
        worldMap.addSubview(label!)
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
        Helpers.createdPolygonOverlays[countryShape.name] = polygons
        Helpers.coordinates[countryShape.name] = countryShape.boundary
    }
    
     // work out if the click was on a country
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let tappedCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        // loop through the land areas in the current country to find and make sure that the tap was here - else error
        var found = false
        
        for landArea in Helpers.coordinates[Helpers.toFind]! {
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
        if found {
            let audioPlayer = Helpers.playSound("yep")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            updateMapOverlays(Helpers.toFind)
            //save the attempt to coredata
            let turn = Attempt(toFind: Helpers.toFind, guessed: Helpers.toFind, revealed: false, context: fetchedResultsController!.managedObjectContext)
            turn.game = currentGame
            currentGame.attempt?.setByAddingObject(turn)
            //set question label after updated overlays - dont bother with green label
            setQuestionLabel()
        } else {
            let audioPlayer = Helpers.playSound("nope")
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            //it was an incorrect guess
            label!.backgroundColor = UIColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 1.0)
            Helpers.misses += 1
            //save attempt to core data
            let turn = Attempt(toFind: Helpers.toFind, guessed: Helpers.toFind, revealed: false, context: fetchedResultsController!.managedObjectContext)
            turn.game = currentGame
            currentGame.attempt?.setByAddingObject(turn)
            Helpers.delay(0.7) {
                self.label!.text = "Find: \(self.Helpers.toFind)"
                self.label!.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
            }
            lives -= 1
            // remove a life and fade out in UI
            if lifeThree.alpha == 1.0 {
                lifeThree.alpha = 0.5
            } else if lifeTwo.alpha == 1.0 {
                lifeTwo.alpha = 0.5
            } else if lifeOne.alpha == 1.0 {
                lifeOne.alpha = 0.5
                // all lives gone
                timerScheduler.invalidate()
                currentGame.finished_at = NSDate()
                performSegueWithIdentifier("showChallengeScore", sender: nil)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // pass the lives and total score and total countries and time
        let controller = segue.destinationViewController as! ChallengeScoreViewController
        controller.lives = lives
        controller.correct = Helpers.game["guessed"]!.count
        let minsTaken = ((Helpers.totalCountries*8) - stopwatch)/60
        var secsTaken = String(((Helpers.totalCountries*8) - stopwatch)%60)
        if String(secsTaken) == "0" {
            secsTaken = "0" + secsTaken
        }
        // pad with zero
        if String(secsTaken).characters.count == 1 {
            secsTaken = "0" + secsTaken
        }
        controller.time = String(minsTaken) + ":" + String(secsTaken)
        controller.totalCountriesInContinent = Helpers.totalCountries
        Helpers.finishGame()
    }
    
    func skip () {
        let audioPlayer = Helpers.playSound("skip")
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        setQuestionLabel()
    }
    
    //ask new question
    func setQuestionLabel () {
        self.title = String("\(Helpers.game["guessed"]!.count) / \(Helpers.totalCountries)")
        if Helpers.game["toPlay"]?.count > 0 {
            let index: Int = Int(arc4random_uniform(UInt32(Helpers.game["toPlay"]!.count)))
            let randomVal = Array(Helpers.game["toPlay"]!.values)[index]
            Helpers.toFind = randomVal
            label!.text = "Find: \(randomVal)"
            label!.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        } else {
            // only set the lives left and match_length for when the user completes the game as these are only used by the top scores table
            currentGame.match_length = (Helpers.totalCountries*8) - stopwatch
            currentGame.lives_left = lives
            currentGame.finished_at = NSDate()            
            timerScheduler.invalidate()
            //save the game on finish
            app.landAreas.save()
            //save the game on finish
            
            //take the game and send it up to the server
            //take all games that have not been saved(due to down time this might occur)
            //and send them up to the server
            //will get back a rank and match_id that can be added to the game core data model
            
            Helpers.delay(1.0) {
                self.performSegueWithIdentifier("showChallengeScore", sender: nil)
            }
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
        Helpers.game["guessed"]![Helpers.toFind] = Helpers.toFind
        Helpers.game["toPlay"]!.removeValueForKey(Helpers.toFind)
    }
    
    func updateTime () {
        if(stopwatch > 0){
            timerLabel.text = getTime()
            stopwatch -= 1
        } else {
            // stop this function from being called after this condition has been met
            timerScheduler.invalidate()
            currentGame.finished_at = NSDate()
            performSegueWithIdentifier("showChallengeScore", sender: nil)
        }
    }
    
    func getTime () -> String {
        let minutes = String(stopwatch / 60)
        var seconds = String(stopwatch % 60)
        if String(seconds) == "0" {
            seconds = "0" + seconds
        }
        if String(seconds).characters.count == 1 {
            seconds = "0" + seconds
        }
        let time = minutes + ":" + seconds
        return time
    }
    
    override func viewWillDisappear(animated: Bool) {
        timerScheduler.invalidate()
        currentGame.finished_at = NSDate()
        Helpers.finishGame()
        //get context and then save
        app.landAreas.save()
    }
    
    // functions to deal with the restoring state
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        // save the continent as minimal source of data
        coder.encodeObject(Helpers.continent as AnyObject, forKey: "continent")
        coder.encodeInteger(stopwatch, forKey: "stoppedTime")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        let data = coder.decodeObjectForKey("continent")
        Helpers.continent = String(data!)
        stopwatch = coder.decodeIntegerForKey("stoppedTime")
        restoreOccur = true
        super.decodeRestorableStateWithCoder(coder)
    }
    
    // once the app has loaded again work out what to show on the screen
    override func applicationFinishedRestoringState() {
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
        
        // set the current game if needed else return to main menu
        if entities.count > 0 && entities[0].finished_at == nil {
            currentGame = entities[0]
        } else {
            //show the home page
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
}

