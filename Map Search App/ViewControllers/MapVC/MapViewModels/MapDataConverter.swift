//
//  MapViewConverter.swift
//  Map Search App
//
//  Created by Константин Малков on 08.02.2023.
//

import UIKit
import MapKit

class MapDataConverter {
    
    static let instance = MapDataConverter()
    
    func distanceFunction(coordinate: CLLocationCoordinate2D,user locationManager: CLLocationManager) -> Double {
        let user = locationManager.location
        let convert = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let dist = user?.distance(from: convert) else { return 0.0 }
        return dist
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func gestureLocation(for gesture: UILongPressGestureRecognizer,mapView: MKMapView,annotationCustom: MKPointAnnotation) -> CLLocationCoordinate2D? {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        annotationCustom.coordinate = coordinate
        mapView.addAnnotation(annotationCustom)
        return coordinate
    }
    

}
