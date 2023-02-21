//
//  WeatherModel.swift
//  Map Search App
//
//  Created by Константин Малков on 20.02.2023.
//

import Foundation

struct WeatherDataAPI: Decodable {
    let location: Location
    let current: Current
   
    
    private enum CodingKeys: String, CodingKey {
        case location = "location", current = "current"
    }
    
}

struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    
    
    private enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
    }
    
}

struct Current: Decodable {
    let temp_c: Double
    let condition: Condition
    let last_updated: String
    let wind_kph: Double
    let wind_degree: Int
    let wind_dir: String
    let feelslike_c: Double
    
    private enum CodingKeys: String, CodingKey {
        case temp_c, condition = "condition", last_updated, wind_kph, wind_degree, wind_dir, feelslike_c
    }
}

struct Condition: Decodable {
    let text: String
    let icon: String
    let code: Int
}



