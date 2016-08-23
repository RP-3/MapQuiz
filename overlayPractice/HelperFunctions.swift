//
//  HelperFunctions.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/19/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit



class HelperFunctions {
    
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
        "Palau": "Palau"
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
            "EU": ["lat": 50.9630, "long": 10.1875, "scale": 70.0],
            "AF": ["lat": 2.897318, "long": 18.105618, "scale": 110.0],
            "OC": ["lat": -29.962515, "long": 172.562187, "scale": 130.0],
            "AS": ["lat": 20.4507, "long": 85.8319, "scale": 130.0],
            "NA": ["lat": 55.856794, "long":  -101.585755, "scale": 130.0],
            "SA": ["lat": -25.643226, "long": -57.442726, "scale": 80.0]
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
    
}
