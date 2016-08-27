//
//  HelperFunctions.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation


class HelperFunctions {
    
    var continent:String!
    var totalCountries: Int = 0
    var game = [
        "guessed": [String:String](),
        "toPlay": [String:String]()
    ]
    var revealed = 0
    var misses = 0
    var toFind = ""
    //dictionary keyed by country name with the values as an array of all the polygons for that country
    var createdPolygonOverlays = [String: [MKPolygon]]()
    //dictionary keyed by country name with values of the coordinates of each country (for the contains method to use to check if clicked point is within one of the overlays)
    var coordinates = [ String: [[CLLocationCoordinate2D]] ]()
    
    let labelFont = UIFont(name: "AmaticSC-Bold", size: 28)!
    
    var audioPlayer = AVAudioPlayer()

    let islands = [
        "Marshall Islands": "Marshall Islands",
        "Kiribati": "Kiribati",
        "Maldives": "Maldives",
        "Tonga": "Tonga",
        "Micronesia": "Micronesia",
        "Niue": "Niue",
        "Nauru": "Nauru",
        "Tuvalu": "Tuvalu",
        "Samoa": "Samoa",
        "Cook Islands": "Cook Islands",
        "Palau": "Palau",
        "Mauritius": "Mauritius",
        "Comoros": "Comoros",
        "Seychelles": "Seychelles"
    ]
    
    static let sharedInstance = HelperFunctions()
    private init() {}
    
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
    
    func delay (delay:Double, closure:()->()) {
        //set the time to dispatch after
        //dispatch_time: creates dispatch time relative to now then this is in a dispatch after this amount of time method
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),
                       //then run the closure fn in the main queue when delay over
            dispatch_get_main_queue(), closure)
    }
    
    func setZoomForContinent (continent: String) -> MKCoordinateRegion {
        // dictionary of points and zooms for the continents
        var midPoints = [
            "EU": ["lat": 60, "long": 10, "scale": 70.0],
            "AF": ["lat": 10, "long": 22, "scale": 98.0],
            "OC": ["lat": -14, "long": 160, "scale": 160.0],
            "AS": ["lat": 35, "long": 85, "scale": 170.0],
            "NA": ["lat": 55, "long":  -101, "scale": 170.0],
            "SA": ["lat": -19, "long": -60, "scale": 90.0]
        ]
        
        let latDelta:CLLocationDegrees = midPoints[continent]!["scale"]!
        let longDelta:CLLocationDegrees = midPoints[continent]!["scale"]!
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(midPoints[continent]!["lat"]!, midPoints[continent]!["long"]!)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        return region
    }
    
    // add country name label
    func addCountryLabel (countryTitle: String, overlay: MKOverlay) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = (overlay as! CustomPolygon).annotation_point
        annotation.title = overlay.title!
        return annotation
    }
    
    func playSound (soundType: String) -> AVAudioPlayer {
        
        var soundFile: NSURL!
        
        var sounds = [
            "yep":NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("right", ofType: "wav")!),
            "nope":NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wrong", ofType: "wav")!),
            "skip":NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bounce", ofType: "wav")!),
            "reveal":NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("plop", ofType: "wav")!)
        ]
        
        soundFile = sounds[soundType]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("error",error)
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error",error)
            //silently not work as not a be all or end all for the app to work
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: soundFile)
        } catch {
            print("error",error)
            //silently not work as not a be all or end all for the app to work
        }
        
        return audioPlayer
    }
    
    func makeQuestionLabel (sender: String) -> UILabel {
        let index: Int = Int(arc4random_uniform(UInt32(game["toPlay"]!.count)))
        let countryToFind = Array(game["toPlay"]!.values)[index]
        toFind = countryToFind
        let label = UILabel()
        let screenSize = UIScreen.mainScreen().bounds.size
        if sender == "challenge" {
            label.frame = CGRectMake(0, 0, (screenSize.width + 5), 35)
        } else {
            label.frame = CGRectMake(0, 0 + 44, (screenSize.width + 5), 35)
        }
        label.textAlignment = NSTextAlignment.Center
        label.text = "Find: \(countryToFind)"
        label.font = UIFont(name: "AmaticSC-Bold", size: 28)
        label.backgroundColor = UIColor(red: 0.3,green: 0.5,blue: 1,alpha: 1)
        label.textColor = UIColor.whiteColor()
        return label
    }
    
    func finishGame () {
        continent = nil
        totalCountries = 0
        game["guessed"]?.removeAll()
        game["toPlay"]?.removeAll()
        revealed = 0
        misses = 0
        toFind = ""
        createdPolygonOverlays.removeAll()
        coordinates.removeAll()
    }

    
}
