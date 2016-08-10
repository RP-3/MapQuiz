//
//  ViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/6/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import UIKit
import MapKit
import CoreData

//TODO: BUG in displaying the countries: Russia, Fiji, Kyrgyzstan

class ViewController: CoreDataController, MKMapViewDelegate {

    @IBOutlet weak var worldMap: MKMapView!
    
    var continent: String?
    
//    let continentCodes = [
//        "AF": "Africa",
//        "AN": "Antarctica",
//        "AS": "Asia",
//        "EU": "Europe",
//        "NA": "North America",
//        "OC": "Oceania",
//        "SA": "South America"
//    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        let entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities", entities.count)
        
        var countriesInRegion: [Country] = []
        //make an array of country models - loop through core data for all with desired continent code and make to model
        for entity in entities {
            if (entity.continent == continent) {
                let country = Country(name: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!)
                countriesInRegion.append(country)
            }
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
        addBoundary(countriesInRegion)
    }
    
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        let point: CGPoint = gestureRecognizer.locationInView(worldMap)
        print("tapped",point)
        //now want to locate in which polygon this point was .. if in any
    }

    func addBoundary(countries: [Country]) {
        for country in countries {
            if country.geojsonFormat == "MultiPolygon" {
                //then need to loop through each boundary and make each a polygon and calculate the number of points
                for var landArea in country.multiBoundary {
                    let multiPolygon = MKPolygon(coordinates: &landArea, count: landArea.count)
                    worldMap.addOverlay(multiPolygon)
                }
            } else {
                let polygon = MKPolygon(coordinates: &country.boundary, count: country.boundaryPointsCount)
                worldMap.addOverlay(polygon)
            }
            
        }
        
        
        //I could find the max and min lat and long but as there are only 6/7 continents this feels ugly and I would rather have a dictionary of all the coordinates and a scale to use
        var midPoints = [
            "EU": ["lat": 50.9630, "long": 10.1875, "scale": 70.0],
            "AF": ["lat": 2.897318, "long": 18.105618, "scale": 110.0],
            "OC": ["lat": -29.962515, "long": 172.562187, "scale": 130.0],
            "AS": ["lat": 20.4507, "long": 85.8319, "scale": 130.0],
            "NA": ["lat": 55.856794, "long":  -101.585755, "scale": 130.0],
            "SA": ["lat": -25.643226, "long": -57.442726, "scale": 80.0]
        ]
        
        let latDelta:CLLocationDegrees = midPoints[continent!]!["scale"]!
        let longDelta:CLLocationDegrees = midPoints[continent!]!["scale"]!
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(midPoints[continent!]!["lat"]!, midPoints[continent!]!["long"]!)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        worldMap.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.lineWidth = 0.75
            polygonView.strokeColor = UIColor.orangeColor()
            polygonView.fillColor = UIColor.blueColor()
            polygonView.alpha = 0.5
            return polygonView
        }
        return MKOverlayRenderer()
    }
    
//    func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
//        print("")
//        if sender.state != UIGestureRecognizerState.Began { return }
//        let touchLocation = sender.locationInView(worldMap)
//        let locationCoordinate = worldMap.convertPoint(touchLocation, toCoordinateFromView: worldMap)
//        var point = MKMapPointForCoordinate(locationCoordinate)
//        var mapRect = MKMapRectMake(point.x, point.y, 0, 0);
//        
//        print("------->", point, mapRect)
////        for polygon in protectedMapView.overlays as! [MKPolygon] {
////            if polygon.intersectsMapRect(mapRect) {
////                println("found")
////            }
////        }
//    }

}


