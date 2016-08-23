//
//  CustomPolygon.swift
//  overlayPractice
//
//  Created by Anna Rogers on 8/23/16.
//  Copyright © 2016 Anna Rogers. All rights reserved.
//

import MapKit

class CustomPolygon: MKPolygon {
    var userGuessed: Bool!
    var annotation_point: CLLocationCoordinate2D!
    convenience init(guessed: Bool, lat_long: CLLocationCoordinate2D, coords: [CLLocationCoordinate2D], numberOfPoints: Int) {
        self.init()
        var coords = coords
        self.init(coordinates: &coords, count: numberOfPoints)
        userGuessed = guessed
        annotation_point = lat_long
    }
}
