//
//  StudentCallOut.swift
//  On The Map
//
//  Created by Ryan Berry on 12/23/17.
//  Copyright © 2017 Ryan Berry. All rights reserved.
//
import MapKit
import UIKit

class StudentCallOut: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    let title: String?
    let mediaURL: String
    init(coordinate: CLLocationCoordinate2D, title: String, mediaURL: String){
        self.coordinate = coordinate
        self.title = title
        self.mediaURL = mediaURL
        super.init()
    }
    var subtitle: String?{
        return mediaURL
    }
}
