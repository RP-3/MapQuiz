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
        
        //add logic here to ask if the 0th array is > 1 and keep going to deepest nesting
        if json.count > 2 {
            print("ONE")
            boundaryPointsCount = json.count
            for i in 0...boundaryPointsCount-1 {
                let lat = String(boundaryPoints[i][1])
                let long = String(boundaryPoints[i][0])
                boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)]
            }
        } else if json[0].count > 2 {
            print("TWO")
            boundaryPointsCount = json[0].count
            for i in 0...boundaryPointsCount-1 {
                let lat = String(boundaryPoints[i][1])
                let long = String(boundaryPoints[i][0])
                boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)]
            }
        } else if json[0][0].count > 2 {
            print("ONE")
            boundaryPointsCount = json[0][0].count
            for i in 0...boundaryPointsCount-1 {
                let lat = String(boundaryPoints[i][1])
                let long = String(boundaryPoints[i][0])
                boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)]
            }
        }
        print("count---->", boundaryPointsCount)
        
    }
    
}