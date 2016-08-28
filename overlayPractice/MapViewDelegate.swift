//
//  MapViewDelegate.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/16/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    let beigeColor = UIColor(red: 0.99, green: 0.93, blue: 0.9, alpha: 1.0)
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let custom = (overlay as! CustomPolygon)
            let polygonView = MKPolygonRenderer(overlay: custom)
            polygonView.lineWidth = 0.75
            polygonView.alpha = 0.9
            polygonView.strokeColor = UIColor(red: 0.15, green: 0.1, blue: 0.01, alpha: 1.0)
            if custom.userGuessed == false {
                polygonView.fillColor = beigeColor
            } else {
                polygonView.fillColor = UIColor.clearColor()
            }
            return polygonView
        }
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId: String = "countryAnnotation"
        var aView: MKAnnotationView
        if let av = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) {
            av.annotation = annotation
            aView = av
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let lbl = UILabel()
            lbl.tag = 20
            av.addSubview(lbl)
            aView = av
        }
        let lbl: UILabel = (aView.viewWithTag(20) as! UILabel)
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 4
        lbl.textAlignment = .Center
        lbl.text = " " + annotation.title!! + "  "
        lbl.font = UIFont(name: "AmaticSC-Regular", size: 16)
        lbl.backgroundColor = beigeColor
        lbl.sizeToFit()
        return aView
    }
    
}
