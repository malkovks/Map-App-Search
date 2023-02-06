//
//  SetDirectionData.swift
//  Map Search App
//
//  Created by Константин Малков on 04.02.2023.
//

import Foundation
import MapKit

struct SetDirectionData {
   var userCoordinate: CLLocationCoordinate2D
   var userAddress: String?
   var userPlacemark: MKPlacemark?
   var mapViewDirection: MKMapView
   var destinationCoordinate: CLLocationCoordinate2D
   var destinationAddress: String?
   var destinationPlacemark: MKPlacemark?
}
