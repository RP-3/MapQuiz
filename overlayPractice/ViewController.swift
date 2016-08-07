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


class ViewController: CoreDataController, MKMapViewDelegate {

    @IBOutlet weak var worldMap: MKMapView!
    
//    let continentCodes = [
//        "AF": "Africa",
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
            if (entity.continent == "NA") {
                let country = Country(name: entity.name!, points: entity.coordinates!, coordType: entity.coordinate_type!)
                countriesInRegion.append(country)
            }
        }

        // Do any additional setup after loading the view, typically from a nib.
        addBoundary(countriesInRegion)
    }

    func addBoundary(countries: [Country]) {
        for country in countries {
            let polygon = MKPolygon(coordinates: &country.boundary, count: country.boundaryPointsCount)
            worldMap.addOverlay(polygon)
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        //let overlayView: MKOverlayRenderer?
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.magentaColor()
            polygonView.fillColor = UIColor.greenColor()
            polygonView.alpha = 0.5
            return polygonView
        }
        return MKOverlayRenderer()
    }

}


