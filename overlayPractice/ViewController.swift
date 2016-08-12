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

//todo: better click accurcay
// add label to country on delete

class ViewController: CoreDataController, MKMapViewDelegate {

    @IBOutlet weak var worldMap: MKMapView!
    
    var continent: String?
    
    var score: Int = 0
    
    var countriesInContinent = [String: Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        score = countriesInContinent.count
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
                countriesInContinent[country.country] = country
            }
        }
        self.title = String("\(score) / \(countriesInContinent.count)")
        print("----->", countriesInContinent.count)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.overlaySelected))
        view.addGestureRecognizer(gestureRecognizer)
        addBoundary(countriesInContinent, resetZoom: true)
    }
    
    var polys = [MKPolygon]()
    var previousMatch: String = ""
    
    func overlaySelected (gestureRecognizer: UIGestureRecognizer) {
        let pointTapped = gestureRecognizer.locationInView(worldMap)
        let newCoordinates = worldMap.convertPoint(pointTapped, toCoordinateFromView: worldMap)
        
        let point = MKMapPointForCoordinate(newCoordinates)
        let mapRect = MKMapRectMake(point.x, point.y, 0.000000000000001, 0.0000000000001);
       
        //empty out arrays of data
        polys.removeAll()
        
         //loop through the countries in continent
        for (key, value) in countriesInContinent {
            
            //loop through all innner polygons for continent
            for polygon in countriesInContinent[key]!.polygons! {
                if polygon.intersectsMapRect(mapRect) {
                    polys.append(polygon)
                }
            }
        }
        
        if polys.count > 1 {
            //then need to find the nearest country found
            print("foudn multiple matches!")
            var closest: CLLocationDistance = 0
            var matchedCountry = MKPolygon()
            for p in 0..<polys.count {
                let center = MKMapPointForCoordinate(polys[p].coordinate)
                let distance = MKMetersBetweenMapPoints(center, point)
                if distance > closest {
                    closest = distance
                    matchedCountry = polys[p]
                } else if distance == closest {
                    print("SAME DISTAnCE!--- PROBLEM!")
                }
            }
            print("matched polygon", matchedCountry.title)
            //now want to change the appearance of this polygon
            for (key, value) in countriesInContinent {
                //if this country has been tapped last then we want to delete it else we make it transparent
                if countriesInContinent[key]!.country == matchedCountry && previousMatch != matchedCountry {
                    countriesInContinent[key]!.alpha = "0.8"
                    previousMatch = matchedCountry.title!
                    //need a way to update just oe polygons alpha
                    
                } else if countriesInContinent[key]!.country == matchedCountry && previousMatch == matchedCountry {
                    //countriesInContinent.removeAtIndex(index)
                    updateMapOverlays(matchedCountry.title!)
                } else {
                    countriesInContinent[key]!.alpha = "1.0"
                }
            }
        } else if polys.count == 1 {
            //then only one country found
            print("found one match!", countriesInContinent.count)
            for (key, value) in countriesInContinent {
                //if this country has been tapped last then we want to delete it else we make it transparent
                if countriesInContinent[key]!.country == polys[0].title! && previousMatch != polys[0].title! {
                    //countriesInContinent[key]!.alpha = "0.8"
                    previousMatch = polys[0].title!
                    //need a way to update just the one polygon
                    
                    
                } else if countriesInContinent[key]!.country == polys[0].title! && previousMatch == polys[0].title! {
                    updateMapOverlays(polys[0].title!)
                } else {
                    countriesInContinent[key]!.alpha = "1.0"
                }
            }
        }
        
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId: String = "reuseid"
        
        var aView: MKAnnotationView
        
        if let av = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) {
            av.annotation = annotation
            aView = av
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let lbl = UILabel(frame: CGRectMake(0, 0, 40, 15))
            lbl.adjustsFontSizeToFitWidth = true
            lbl.backgroundColor = UIColor.blackColor()
            lbl.textColor = UIColor.whiteColor()
            lbl.alpha = 0.5
            lbl.tag = 42
            lbl.numberOfLines = 0
            av.addSubview(lbl)
            //Following lets the callout still work if you tap on the label...
            av.canShowCallout = true
            av.frame = lbl.frame
            aView = av
        }
        let lbl: UILabel = (aView.viewWithTag(42) as! UILabel)
        lbl.text = annotation.title!
        return aView
    }
    
    func updateMapOverlays(titleOfPolyToRemove: String) {
        for overlay: MKOverlay in worldMap.overlays {
            //worldMap.removeOverlay(overlay)
            if overlay.title! == titleOfPolyToRemove {
                countriesInContinent.removeValueForKey(titleOfPolyToRemove)
                let annotation = MKPointAnnotation()
                annotation.coordinate = overlay.coordinate
                annotation.title = titleOfPolyToRemove
                worldMap.addAnnotation(annotation)
                worldMap.removeOverlay(overlay)
            }
        }
        score += 1
        self.title = String("\(score) / \(countriesInContinent.count)")
    }

    func addBoundary(countries: [String: Country], resetZoom: Bool) {
        for (key, value) in countries {
            if countries[key]?.geojsonFormat == "MultiPolygon" {
                var polygons = [MKPolygon]()
                //then need to loop through each boundary and make each a polygon and calculate the number of points
                for var landArea in (countries[key]?.multiBoundary)! {
                    let multiPolygon = MKPolygon(coordinates: &landArea, count: landArea.count)
                    multiPolygon.title = countries[key]?.country
                    multiPolygon.subtitle = countries[key]?.alpha
                    //let overlay = customPolygon(countryName: country.country, alphaValue: 1.0, polygon: multiPolygon)
                    polygons.append(multiPolygon)
                    worldMap.addOverlay(multiPolygon)
                }
                countries[key]?.polygons = polygons
            } else {
                let polygon = MKPolygon(coordinates: &countries[key]!.boundary, count: (countries[key]?.boundaryPointsCount)!)
                polygon.title = countries[key]?.country
                polygon.subtitle = countries[key]?.alpha
                //let overlay = customPolygon(countryName: country.country, alphaValue: 1.0, polygon: polygon)
                countries[key]?.polygons = [polygon]
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
            if let n = NSNumberFormatter().numberFromString(overlay.subtitle!!) {
                polygonView.alpha = CGFloat(n)
            }
            return polygonView
        }
        return MKOverlayRenderer()
    }

}

//class customPolygon: MKPolygon {
//    var alpha: CGFloat
//    var country: String
//    var polygonShape: MKPolygon
//    
//    init(countryName: String, alphaValue: CGFloat, polygon: MKPolygon) {
//        country = countryName
//        alpha = alphaValue
//        polygonShape = polygon
//    }
//}


