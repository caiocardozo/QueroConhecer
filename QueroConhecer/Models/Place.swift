//
//  Place.swift
//  QueroConhecer
//
//  Created by Caio Cardozo on 09/07/18.
//  Copyright © 2018 Caio Cardozo. All rights reserved.
//

import Foundation
import MapKit

struct Place : Codable{
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let adress: String
    
    var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func getFormattedAdress(with placemark: CLPlacemark) -> String{
        var adress = ""
        if let street = placemark.thoroughfare{
            adress += street //Rua
        }
        if let number = placemark.subThoroughfare{
            adress += " \(number)" //Numero
        }
        if let subLocality = placemark.subLocality{
            adress += ", \(subLocality)"  //Bairro
        }
        if let city = placemark.locality{
            adress += "\n\(city)"
        }
        if let state = placemark.administrativeArea{
            adress += " - \(state)"
        }
        if let postalCode = placemark.postalCode{
            adress += "\nCEP: \(postalCode)"
        }
        if let country = placemark.country{
            adress += "\n\(country)"
        }
        return adress
    }

}

extension Place: Equatable{
    static func ==(lhs: Place, rhs: Place) -> Bool{
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
