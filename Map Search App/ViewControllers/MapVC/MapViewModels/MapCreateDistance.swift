//
//  MapCreateDistance.swift
//  Map Search App
//
//  Created by Константин Малков on 10.02.2023.
//

import UIKit
import MapKit
import SPAlert

class MapIntruments {
    
    static let instance = MapIntruments()
    
    func createDirectionRequest(user locationManager: CLLocationManager?,from location: CLLocationCoordinate2D?,to coordinate: CLLocationCoordinate2D,type transport: String?) -> MKDirections.Request {
        let request = MKDirections.Request()
        if let locationUser = locationManager?.location {
            let startCoordinate = location ?? locationUser.coordinate //start or user point
            let destinationCoordinate = coordinate //endpoint coordinates
            let startingLocation      = MKPlacemark(coordinate: startCoordinate)//checking for active user location
            let destination           = MKPlacemark(coordinate: destinationCoordinate) //checking for having endpoint coordinates
            request.source                       = MKMapItem(placemark: startingLocation)
            request.destination                  = MKMapItem(placemark: destination)
            request.requestsAlternateRoutes      = true
            switch transport {
            case "Автомобиль":
                request.transportType = .automobile
            case "Пешком":
                request.transportType = .walking
            case "Велосипед":
                request.transportType = .any
            case "Транспорт":
                request.transportType = .transit
            default:
                request.transportType = .walking
            }
            return request
        }else {
            SPAlert.present(title: "Turn on user location", preset: .error)
        }
        return request
    }
    
    func getDistanceBetweenPoints(request: MKDirections.Request) -> CLLocationDistance {
        let direction = MKDirections(request: request)
        var distance = CLLocationDistance()
        direction.calculate { response, error in
            guard let response = response, error != nil else { return }
            distance = response.routes[0].distance
        }
        print(distance)
        return distance
    }
    
    func getDistanceBetweenPoints(route: MKRoute) -> String {
        var distance = CLLocationDistance()
        distance = route.distance
        if distance <= 1000 {
            return String(distance) + " м"
        } else {
            distance = distance / 1000
            let str = (String(format: "%.1f", distance))
            return str + " км"
        }
    }
    
    func plotPolyline(route: MKRoute,mapView: MKMapView){
        mapView.addOverlay(route.polyline)
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                                      animated: true)
        } else {
            let polylineRect = mapView.visibleMapRect.union(route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineRect,
                                      edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                                      animated: true)
        }
    }
}
