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
        if soundType == "yep" {
            soundFile = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("right", ofType: "wav")!)
        } else if soundType == "nope" {
            soundFile = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("wrong", ofType: "wav")!)
        } else if soundType == "skip" {
            soundFile = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bounce", ofType: "wav")!)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("error",error)
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error",error)
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: soundFile)
        } catch {
            print("error",error)
            //throw alert? or silently not work?
        }
        
        return audioPlayer
    }
    
}
