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
                request.transportType = .automobile
            }
            return request
        }else {
            SPAlert.present(title: "Turn on user location", preset: .error)
        }
        return request
    }
    
    func getDistanceTime(route: MKRoute) -> String{
        let time = Int(route.expectedTravelTime)
        let (h,m,s) = secondsToHoursMinutesSeconds(time: time)
        if h == 0 {
            return "\(m) минут"
        } else {
            return "\(h) часов, \(m) минут."
        }
        
    }
    
    func secondsToHoursMinutesSeconds(time: Int) -> (Int, Int, Int) {
        return (time / 3600, (time % 3600) / 60, (time % 3600) % 60)
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
    
    
    
    func plotPolyline(route: MKRoute,mapView: MKMapView,choosenCount: Int){
        mapView.addOverlay(route.polyline)
        if mapView.overlays.count == choosenCount {
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
