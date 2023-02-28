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
    let forecast: Forecast
   
    
    private enum CodingKeys: String, CodingKey {
        case location = "location", current = "current", forecast = "forecast"
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

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
    
    private enum CodingKeys: String, CodingKey {
        case forecastday = "forecastday"
    }
}

struct ForecastDay: Decodable {
    let date: String
    let date_epoch: Int
    let day: Day
    let astro: Astro
    
    private enum CodingKeys: String, CodingKey {
        case date, date_epoch, day = "day", astro = "astro"
    }
}

struct Day: Decodable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let avgtemp_c: Double
    let maxwind_kph: Double
    let daily_chance_of_rain: Int
    let daily_will_it_rain: Int
    let daily_chance_of_snow: Int
    let daily_will_it_snow: Int
    let condition: Condition

}

struct Astro: Decodable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
    let moon_phase: String
    let moon_illumination: String
    let is_moon_up: Int
    let is_sun_up: Int
}



