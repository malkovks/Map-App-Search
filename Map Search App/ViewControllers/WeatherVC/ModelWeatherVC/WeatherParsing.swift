//
//  WeatherModel.swift
//  Map Search App
//
//  Created by Константин Малков on 20.02.2023.
//

import Foundation
import UIKit
import MapKit
import SPAlert



final class WeatherModel {
    
    static let shared = WeatherModel()
    
    var structData: WeatherDataAPI?
    
    public func requestWeatherAPI(coordinate: CLLocationCoordinate2D, completion: @escaping (Result<WeatherDataAPI, Error>) -> Void){
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        guard let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=982e0f449bc841028ee230603231902&q=\(latitude),\(longitude)&lang=ru&days=7&aqi=no&alerts=no") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode(WeatherDataAPI.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
