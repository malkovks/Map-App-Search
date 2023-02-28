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
    
    public func getWeekdayFromDay(date: String) -> String {
        print(date)
        let dateFormatter = DateFormatter()
        let convertDate = DateFormatter()
        var dayInWeek = String()
        convertDate.dateFormat = "yyyy-mm-dd"
        dateFormatter.dateFormat = "EEEE"
        
        dateFormatter.locale = Locale(identifier: "ru_RU")
        if let finalDate = convertDate.date(from: date) {
            dayInWeek = dateFormatter.string(from: finalDate).capitalized
        } else {
            print("Error converting date")
        }
        return dayInWeek
    }
    
    public func convertStringToDate(date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.month,.day,.year,.hour,.minute], from: date)
        let returnDate = dateFormatter.date(from: date)
        return returnDate
    }
    
    public func setupImageCategory(image code: Int) -> UIImage {
            switch code {
            case 1000:
                return UIImage(systemName: "sun.max")!
            case 1003:
                return UIImage(systemName: "cloud")!
            case 1006:
                return UIImage(systemName: "cloud")!
            case 1009:
                return UIImage(systemName: "cloud")!
            case 1030:
                return UIImage(systemName: "cloud.fog")!
            case 1063:
                return UIImage(systemName: "cloud.rain")!
            case 1066:
                return UIImage(systemName: "cloud.snow")!
            case 1069:
                return UIImage(systemName: "cloud.snow")!
            case 1072:
                return UIImage(systemName: "snowflake")!
            case 1087:
                return UIImage(systemName: "bolt")!
            case 1114:
                return UIImage(systemName: "snowflake")!
            case 1117:
                return UIImage(systemName: "wind.snow")!
            case 1135:
                return UIImage(systemName: "cloud.fog")!
            case 1147:
                return UIImage(systemName: "cloud.snow.fill")!
            case 1150:
                return UIImage(systemName: "cloud.sun.rain")!
            case 1153:
                return UIImage(systemName: "cloud.sun.rain")!
            case 1168:
                return UIImage(systemName: "snowflake")!
            case 1171:
                return UIImage(systemName: "cloud.snow.fill")!
            case 1180:
                return UIImage(systemName: "cloud.rain")!
            case 1183:
                return UIImage(systemName: "cloud.rain")!
            case 1186:
                return UIImage(systemName: "cloud.sun.rain")!
            case 1189:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1192:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1995:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1198:
                return UIImage(systemName: "cloud.rain")!
            case 1201:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1204:
                return UIImage(systemName: "snowflake")!
            case 1207:
                return UIImage(systemName: "snowflake")!
            case 1210:
                return UIImage(systemName: "wind.snow")!
            case 1213:
                return UIImage(systemName: "snowflake")!
            case 1216:
                return UIImage(systemName: "snowflake")!
            case 1219:
                return UIImage(systemName: "snowflake")!
            case 1222:
                return UIImage(systemName: "wind.snow")!
            case 1225:
                return UIImage(systemName: "wind.snow")!
            case 1237:
                return UIImage(systemName: "wind.snow")!
            case 1240:
                return UIImage(systemName: "cloud.sun.rain")!
            case 1243:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1246:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1249:
                return UIImage(systemName: "cloud.sun.rain")!
            case 1252:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1255:
                return UIImage(systemName: "snowflake")!
            case 1258:
                return UIImage(systemName: "snowflake")!
            case 1261:
                return UIImage(systemName: "snowflake")!
            case 1264:
                return UIImage(systemName: "snowflake")!
            case 1273:
                return UIImage(systemName: "cloud.rain")!
            case 1276:
                return UIImage(systemName: "cloud.heavyrain")!
            case 1279:
                return UIImage(systemName: "wind.snow")!
            case 1282:
                return UIImage(systemName: "wind.snow")!
            default:
                return UIImage(systemName: "thermometer.sun")!
        }
    }
}
