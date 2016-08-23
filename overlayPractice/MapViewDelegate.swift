//
//  MapViewDelegate.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/16/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let custom = (overlay as! customPolygon)
            let polygonView = MKPolygonRenderer(overlay: custom)
            polygonView.lineWidth = 0.75
            polygonView.alpha = 0.9
            polygonView.strokeColor = UIColor.whiteColor()
            if custom.userGuessed == false {
                polygonView.fillColor = UIColor.orangeColor()
            } else {
                polygonView.fillColor = UIColor.clearColor()
            }
            return polygonView
        }
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId: String = "reuseid"
        
        var aView: MKAnnotationView
        
        if let av = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) {
            av.annotation = annotation
            aView = av
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            let lbl = UILabel()
            lbl.backgroundColor = UIColor.whiteColor()
            lbl.layer.masksToBounds = true
            lbl.layer.cornerRadius = 4
            lbl.textAlignment = .Center
            lbl.textColor = UIColor.blackColor()
            
            lbl.tag = 20
            av.addSubview(lbl)
            
            //Following lets the callout still work if you tap on the label...
            av.frame = lbl.frame
            aView = av
        }
        let lbl: UILabel = (aView.viewWithTag(20) as! UILabel)
        lbl.text = annotation.title!
        lbl.font = UIFont.systemFontOfSize(10)
        lbl.sizeToFit()
//        aView.canShowCallout = true
        return aView
    }
    
}
