//
//  DirectionResultStruct.swift
//  Map Search App
//
//  Created by Константин Малков on 28.02.2023.
//

import Foundation
import MapKit

struct DirectionResultStruct {
    let startCoordinate: CLLocationCoordinate2D
    let finalCoordinate: CLLocationCoordinate2D
    let responseDirection: MKDirections.Response
    let typeOfDirection: String
}
