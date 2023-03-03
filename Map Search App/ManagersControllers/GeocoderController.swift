//
//  GeocoderController.swift
//  Map Search App
//
//  Created by Константин Малков on 01.03.2023.
//

import UIKit
import MapKit

struct DetailInfoAboutPlace{
    let streetName: String
    let appNumber: String
    let city: String
    let country: String
    let areaOfInterest: String
    let nameOfPlacemark: String
    let postalCode: String
    let placemark: CLPlacemark
}

final class GeocoderController {
    
    static let shared = GeocoderController()
    
    public func geocoderReturn(location: CLLocation,completion: @escaping (Result<CLPlacemark,Error>)-> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemark, error in
            if let placemark = placemark?.first, error == nil {
                DispatchQueue.main.async {
                    completion(.success(placemark))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error!))
                }
            }
        }
    }
    
    public func infoAboutPlace(placemark: CLPlacemark) -> DetailInfoAboutPlace {
        var data: DetailInfoAboutPlace!
        let streetName = placemark.thoroughfare ?? ""
        let appNumber = placemark.subThoroughfare ?? ""
        let city = placemark.administrativeArea ?? ""
        let country = placemark.country ?? ""
        let name = placemark.name ?? "\(streetName),\(appNumber)"
        let postalCode = placemark.postalCode ?? ""
        let areaOfInterest = placemark.areasOfInterest?.first ?? name
        data = DetailInfoAboutPlace(streetName: streetName, appNumber: appNumber, city: city, country: country, areaOfInterest: areaOfInterest, nameOfPlacemark: name, postalCode: postalCode, placemark: placemark)
        return data
    }
}
