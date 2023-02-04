//
//  SetDirectionData.swift
//  Map Search App
//
//  Created by Константин Малков on 04.02.2023.
//

import Foundation
import MapKit

struct SetDirectionData {
    let userCoordinate: CLLocationCoordinate2D
    let userAddress: String?
    let userPlacemark: MKPlacemark?
    let destinationCoordinate: CLLocationCoordinate2D
    let destinationAddress: String?
    let destinationPlacemark: MKPlacemark?
}
