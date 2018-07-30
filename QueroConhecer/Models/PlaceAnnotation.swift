//
//  PlaceAnnotation.swift
//  QueroConhecer
//
//  Created by Caio Cardozo on 12/07/18.
//  Copyright © 2018 Caio Cardozo. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    
    enum PlaceType {
        case place
        case poi
    }
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var adress: String?
    
    init(coordinate: CLLocationCoordinate2D, type: PlaceType) {
        self.coordinate = coordinate
        self.type = type
    }
}
