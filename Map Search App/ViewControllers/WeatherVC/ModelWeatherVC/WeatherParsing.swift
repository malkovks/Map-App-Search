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
        let latitude = Int(coordinate.latitude)
        let longitude = Int(coordinate.longitude)
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=e7b2054dc37b1f464d912c00dd309595&units=Metric") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode(WeatherDataAPI.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
