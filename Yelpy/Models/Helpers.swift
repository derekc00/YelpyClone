//
//  Helpers.swift
//  Yelpy
//
//  Created by Derek Chang on 8/1/20.
//  Copyright © 2020 Derek Chang. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

func degreeToRadian(angle:CLLocationDegrees) -> Double{
    return (  (Double(angle)) / 180.0 * .pi  )
}

//        /** Radians to Degrees **/
func radianToDegree(radian:Double) -> CLLocationDegrees {
    return CLLocationDegrees(  radian * Double(180.0 / .pi)  )
}

func geographicMidpoint(betweenCoordinates coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {

    guard coordinates.count > 1 else {
        return coordinates.first ?? // return the only coordinate
            CLLocationCoordinate2D(latitude: 0, longitude: 0) // return null island if no coordinates were given
    }

    var x = Double(0)
    var y = Double(0)
    var z = Double(0)

    for coordinate in coordinates {
        let lat = degreeToRadian(angle: coordinate.latitude)
        let lon = degreeToRadian(angle: coordinate.longitude)
        x += Double(cos(lat) * cos(lon))
        y += Double(cos(lat) * sin(lon))
        z += Double(sin(lat))
    }

    x /= Double(coordinates.count)
    y /= Double(coordinates.count)
    z /= Double(coordinates.count)

    let lon = atan2(y, x)
    let hyp = sqrt(x * x + y * y)
    let lat = atan2(z, hyp)

    return CLLocationCoordinate2D(latitude: radianToDegree(radian: lat), longitude: radianToDegree(radian: lon))
}

//Returns distnance from user to the coords of a restuarant
//if no user location is present, default is San Francisco coords. See Restaurant.swift for constructor of "coordinates" property
func getDistance(coordinates: CLLocationCoordinate2D, locationManager: CLLocationManager) -> Measurement<UnitLength>{
    //extract lat and long
    let restaurantCoords = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    //declare var to store distance between two coordinates (me and the restaurant)
    var distance_from_current_location: Measurement<UnitLength>
    //Check to see if locationManager has a location. This will be nil if user decline to share location
    if let current_location = locationManager.location {
        distance_from_current_location = Measurement(value: current_location.distance(from: restaurantCoords), unit: UnitLength.meters)
    } else{ //if declined to share location, use 10,000 meters
        distance_from_current_location = Measurement(value: 10000, unit: UnitLength.meters)
    }
    //convert meters to miles and truncate to 1 decimal place
    return distance_from_current_location

}
func formatPhoneNumber(number: String) -> String{
    
    let areaCode: String = String(number.prefix(3))
    let nextThree: String = String(number.dropLast(4).suffix(3))
    let nextFour: String = String(number.suffix(4))
    return "(\(areaCode)) \(nextThree)-\(nextFour)"
}
