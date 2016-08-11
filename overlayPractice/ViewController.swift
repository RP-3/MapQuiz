//
//  ViewController.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/6/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

//    let continentCodes = [
//        "AF": "Africa",
//        "AN": "Antarctica",
//        "AS": "Asia",
//        "EU": "Europe",
//        "NA": "North America",
//        "OC": "Oceania",
//        "SA": "South America"
//    ]

import UIKit
import MapKit
import CoreData

//todo: not zoom out on delete overlay, better click accurcay,

class ViewController: CoreDataController, MKMapViewDelegate {

    @IBOutlet weak var worldMap: MKMapView!
    
    var continent: String?
    
    var countriesInRegion: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let land = app.landAreas
        let fetchRequest = NSFetchRequest(entityName: "LandArea")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: land.context, sectionNameKeyPath: nil, cacheName: nil)
        let entities = fetchedResultsController!.fetchedObjects as! [LandArea]
        print("entities", entities.count)
        
        
        //make an array of country models - loop through core data for all with desired continent code and make to model
        for entity in entities {
            if (entity.continent == continent) {
                let country = Country(name: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!)
                countriesInRegion.append(country)
            }
        }
        worldMap.mapType = .SatelliteFlyover
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer)
        // Do any additional setup after loading the view, typically from a nib.
        addBoundary(countriesInRegion, resetZoom: true)
    }
    
    var polys = [MKPolygon]()
    var countriesIntersected = [String]()
    
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let newCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        
        let point = MKMapPointForCoordinate(newCoordinates)
        let mapRect = MKMapRectMake(point.x, point.y, 0.000000000000001, 0.0000000000001);
        
//        for polygon in worldMap.overlays as! [MKPolygon] {
//            if polygon.intersectsMapRect(mapRect) {
//                print("found intersection")
//            }
//        }
        //loop through the countries in continent
        for country in countriesInRegion {
            //loop through all innner polygons for continent
            for polygon in country.polygons! {
                
                if polygon.intersectsMapRect(mapRect) {
                    polys.append(polygon)
                    countriesIntersected.append(country.country)
                }
            }
            
        }
        
        if polys.count > 1 {
            //then need to find the nearest country found
            print("foudn multiple matches!")
            var closest: CLLocationDistance = 0
            var matchedCountry: String = ""
            for p in 0..<polys.count {
                let center = MKMapPointForCoordinate(polys[p].coordinate)
                let distance = MKMetersBetweenMapPoints(center, point)
                if distance > closest {
                    closest = distance
                    matchedCountry = countriesIntersected[p]
                } else if distance == closest {
                    print("SAME DISTAnCE!")
                }
            }
            print("matched polygon", matchedCountry)
            //now want to change the appearance of this polygon
            for c in 0..<countriesInRegion.count-1 {
                if countriesInRegion[c].country == matchedCountry {
                    countriesInRegion.removeAtIndex(c)
                    //remove all overlays from the map and then add them from the countriesInRegion array
                    deleteMapOverlays()
                }
            }
            polys.removeAll()
            countriesIntersected.removeAll()
        } else if polys.count == 1 {
            //then only one country found
            print("found one match!", countriesIntersected[0])
            for c in 0..<countriesInRegion.count-1 {
                if countriesInRegion[c].country == countriesIntersected[0] {
                    countriesInRegion.removeAtIndex(c)
                    deleteMapOverlays()
                }
            }
            polys.removeAll()
            countriesIntersected.removeAll()
        }
        
    }
    
    func deleteMapOverlays() {
        for overlay: MKOverlay in worldMap.overlays {
            worldMap.removeOverlay(overlay)
        }
        //add extra argument so not reset the region on the screen
        addBoundary(countriesInRegion, resetZoom: false)
    }

    func addBoundary(countries: [Country], resetZoom: Bool) {
        for country in countries {
            if country.geojsonFormat == "MultiPolygon" {
                var polygons = [MKPolygon]()
                //then need to loop through each boundary and make each a polygon and calculate the number of points
                for var landArea in country.multiBoundary {
                    let multiPolygon = MKPolygon(coordinates: &landArea, count: landArea.count)
                    polygons.append(multiPolygon)
                    worldMap.addOverlay(multiPolygon)
                }
                country.polygons = polygons
            } else {
                let polygon = MKPolygon(coordinates: &country.boundary, count: country.boundaryPointsCount)
                country.polygons = [polygon]
                worldMap.addOverlay(polygon)
            }
            
        }
        
        if resetZoom {
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

    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.lineWidth = 0.75
            polygonView.strokeColor = UIColor.whiteColor()
            polygonView.fillColor = UIColor.orangeColor()
            return polygonView
        }
        return MKOverlayRenderer()
    }

}


