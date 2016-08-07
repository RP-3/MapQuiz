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
    
    init (name: String, points: String, coordType: String) {
        
        country = name
        print("coord------", coordType)
        let data: NSData = points.dataUsingEncoding(NSUTF8StringEncoding)!
        let json = JSON(data: data)
        
        boundary = []
        let boundaryPoints =  json
        
        boundaryPointsCount = json.count
        
//        for coords in json {
//            if (coordType == "Polygon") {
//                let shapeData = overlaysFromPolygons(json as! AnyObject as! [AnyObject], id: name)
//                boundary += shapeData
//            }
//            else if (coordType == "MultiPolygon") {
//                for polygonData in json {
//                    let shapeCoords = overlaysFromPolygons(polygonData as! AnyObject as! [AnyObject], id: name)
//                    boundary += shapeCoords
//                }
//            }
//            else {
//                print("Unsupported type: \(coordType)")
//            }
//        }

        
        //add logic here to ask if the 0th array is > 1 and keep going to deepest nesting
        if coordType == "Polygon" {
            //take json loop through and make polygon points
            for i in 0...json.count-1 {
                //need another loop here??
                boundaryPointsCount = json[i].count
                for element in json[i] {
                    let lat = String(element.1[1])
                    let long = String(element.1[0])
                    //print("lat long", lat, long)
                    boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)]
                }
            }
        } else if coordType == "MultiPolygon" {
            //loop through json and for each one inside this loop through
            for item in 1...json.count-1 {
                for element in json[item] {
                    boundaryPointsCount = element.1.count
                    for coord in element.1 {
                        let lat = String(coord.1[1])
                        let long = String(coord.1[0])
                        boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(lat)!, CLLocationDegrees(long)!)]
                    }
                }
            }
            
        }
        //print("count---->", boundaryPointsCount)
        
    }
    
    func overlaysFromPolygons(polygons: [AnyObject], id title: String) -> [CLLocationCoordinate2D] {
        //make array with capacity for all the items in polygons
        var interiorPolygons = [CLLocationCoordinate2D]()
        //loop through polygons
        for i in 1..<polygons.count {
            //add to our created array return from next fn
            interiorPolygons += (polygonFromPoints(polygons[i] as! [AnyObject], interiorPolygons: []))
        }
        //use the first thing in the array as the title??!
        //var overlayPolygon: MKPolygon = polygonFromPoints(polygons[0] as! [AnyObject], interiorPolygons: interiorPolygons)
        //overlayPolygon.title = title
        return interiorPolygons
    }
    
    
    func polygonFromPoints(points: [AnyObject], interiorPolygons polygons: [AnyObject]) -> [CLLocationCoordinate2D] {
        //count of contents of points
        //var numberOfCoordinates: Int = points.count
        //make empty array to hold points
        var polygonPoints = [CLLocationCoordinate2D]() //what this line do? size of array to be made?
        //loop through points and make a coordinate object
        var index: Int = 0
        for pointArray in points {
            polygonPoints[index] = CLLocationCoordinate2DMake(Double(pointArray[1] as! Int), Double(pointArray[0] as! Int))
            index += 1
        }
//        var polygon: MKPolygon
//        if polygons.count > 0 {
//            polygon = MKPolygon.polygonWithCoordinates(polygonPoints, count: numberOfCoordinates, interiorPolygons: polygons)
//        } else {
//            polygon = MKPolygon.polygonWithCoordinates(polygonPoints, count: numberOfCoordinates)
//        }
        //free(polygonPoints)
        return polygonPoints
    }
    
}
