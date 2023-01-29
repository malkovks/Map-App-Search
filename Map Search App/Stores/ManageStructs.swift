//
//  ManageStructs.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//

import Foundation
import UIKit
import MapKit

struct FullAdress {
    let street: String
    let appartmentNumber: String
    let city: String
    let country: String
    let postIndex: String
    let latitude: Double
    let longitude: Double
}

struct LastChoosenRequest{
    var placemark: MKPlacemark
    var titleRequest: String
}

struct CollectionImages{
    var imagesCategory = ["Airport":UIImage(systemName: "airplane.arrival"),
                          "Food places":UIImage(systemName: "fork.knife"),
                          "Market":UIImage(systemName: "basket"),
                          "Pharmacy":UIImage(systemName: "cross.case"),
                          "Hotels":UIImage(systemName: "bed.double"),
                          "Petrol Station":UIImage(systemName: "fuelpump"),
                          "Cinema":UIImage(systemName: "popcorn"),
                          "Fitness":UIImage(systemName: "dumbbell")
    ]
}
