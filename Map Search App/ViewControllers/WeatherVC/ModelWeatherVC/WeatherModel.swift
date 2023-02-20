//
//  WeatherModel.swift
//  Map Search App
//
//  Created by Константин Малков on 20.02.2023.
//

import Foundation

struct WeatherDataAPI: Codable {
    let location: Location
    let current: Current
   
    
    private enum CodingKeys: String, CodingKey {
        case location = "location", current = "current"
    }
    
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    
    private enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
    }
    
}

struct Current: Codable {
    let temp_c: Double//или double
    let temp_f: Double
    
    private enum CodingKeys: String, CodingKey {
        case temp_c, temp_f
    }
}



