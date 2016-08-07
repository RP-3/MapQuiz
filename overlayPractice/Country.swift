//
//  Country.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/6/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON

class Country {
    
    var country: String
    var boundary: [CLLocationCoordinate2D]
    var boundaryPointsCount: NSInteger
    
    init (name: String, points: String) {
        
        country = name
        print("name", name)
        let data: NSData = points.dataUsingEncoding(NSUTF8StringEncoding)!
        let json = JSON(data: data)
        
        boundary = []
        let boundaryPoints =  json
        boundaryPointsCount = json.count
        print("----->", boundaryPointsCount)
        
        for i in 0...boundaryPointsCount-1 {
            let lat = String(boundaryPoints[i][1])
            let long = String(boundaryPoints[i][0])
            boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)]
        }

    }
    
//    init () {
//        boundary = []
//
//        var boundaryPoints = [[-6.287505662999905,49.91400788000006],[-6.297271287999934,49.909613348000065],[-6.30915279899989,49.91364166900003],[-6.307443813999896,49.927435614000146],[-6.298817511999886,49.935492255000085],[-6.292225714999916,49.93207428600006],[-6.28416907499988,49.92275625200013],[-6.287505662999905,49.91400788000006]]
//        
//        boundaryPointsCount = boundaryPoints.count
//        for i in 0...boundaryPointsCount-1 {
//            let lat = String(boundaryPoints[i][1])
//            let long = String(boundaryPoints[i][0])
//            boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)]
//        }
//
//    }
    
}