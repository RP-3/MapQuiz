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
    var boundary: [[CLLocationCoordinate2D]]
    var boundaryPointsCount: NSInteger
    var geojsonFormat: String
    
    init (name: String, points: String, coordType: String) {
        
        country = name
        geojsonFormat = coordType
        //print("name------", name)
        
        let data: NSData = points.dataUsingEncoding(NSUTF8StringEncoding)!
        let json = JSON(data: data)
        
        boundary = []
        boundaryPointsCount = 0
        
        //add logic here to ask if the 0th array is > 1 and keep going to deepest nesting
        if coordType == "Polygon" {
            //take json loop through and make polygon points
            for i in 0...json.count-1 {
                boundaryPointsCount = json[i].count
                var points = [CLLocationCoordinate2D]()
                for element in json[i] {
                    let lat = String(element.1[1])
                    let long = String(element.1[0])
                    points.append(CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!))
                }
                boundary.append(points)
            }
        } else if coordType == "MultiPolygon" {
            //loop through json and for each one inside this loop through
            for item in 0...json.count-1 {
                for element in json[item] {
                    //make an array of coord arrays and then add this to the bounadary array
                    var shape = [CLLocationCoordinate2D]()
                    for coord in element.1 {
                        let lat = String(coord.1[1])
                        var long = String(coord.1[0])
                        if let numberLong =  Float(long) {
                            if numberLong == -180 {
                                long = String(179.9)
                            } else if numberLong == 180 {
                                long = String(179.9)
                            }
                        }
                        let coords = CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)
                        shape.append(coords)
                    }
                    boundary.append(shape)
                }
            }
            
        }
        
    }
    
}
