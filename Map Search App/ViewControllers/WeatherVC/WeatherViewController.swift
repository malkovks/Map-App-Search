//
//  WeatherViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//


import Foundation
import UIKit
import WeatherKit
import CoreLocation

class WeatherDisplayViewController: UIViewController {
    
    
    var weatherData: WeatherDataAPI?
    
    var userLocationManager = CLLocationManager() 
    
    let services = WeatherService()
    
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLabel.frame = CGRect(x: 10, y: 100, width: view.frame.size.width-20, height: 55)
        secondLabel.frame = CGRect(x: 10, y: 170, width: view.frame.size.width-20, height: 55)
        thirdLabel.frame = CGRect(x: 10, y: 240, width: view.frame.size.width-20, height: 55)
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    public func requestWeatherAPI(coordinate: CLLocationCoordinate2D){
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        print(latitude)
        print(longitude)
        guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=982e0f449bc841028ee230603231902&q=\(latitude),\(longitude)&aqi=no") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error != nil else { return }
            if !data.isEmpty {
                print("Work ok")
            } else {
                print("Not ok")
            }
            do {
                let result = try JSONDecoder().decode(WeatherDataAPI.self, from: data)
                self.weatherData = result
                print(result.location.region)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func setupView(){
        view.addSubview(firstLabel)
        view.addSubview(secondLabel)
        view.addSubview(thirdLabel)
        view.backgroundColor = .secondarySystemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .black
        title = "Погода"
        firstLabel.backgroundColor = .systemBackground
        secondLabel.backgroundColor = .systemBackground
        firstLabel.text = "Check first label"
        secondLabel.text = "sldlsdlsdlsld"
        guard let loc = userLocationManager.location?.coordinate else { return }
        requestWeatherAPI(coordinate: loc)
        firstLabel.text = "\(weatherData?.current.temp_f)"
        secondLabel.text = "\(weatherData?.current.temp_c)"
    }
    
}
    
//    public func requestWeatherAPI(coordinate: CLLocationCoordinate2D){
//        let latitude = coordinate.latitude
//        let longitude = coordinate.longitude
//        print(latitude)
//        print(longitude)
//        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=e7b2054dc37b1f464d912c00dd309595&units=Metric") else { return }
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error != nil else { return }
//            if !data.isEmpty {
//                print("Work ok")
//            }
//            do {
//                let result = try JSONDecoder().decode(WeatherDataAPI.self, from: data)
//                self.firstLabel.text = String(describing: result.main.feels_like)
//                self.secondLabel.text = String(describing: result.main.temp)
//                self.weatherData = result
//                print(result.main.temp)
//            } catch {
//                print(error)
//            }
//        }.resume()
//    }
    
//    private func getParseData(){
//        guard let location = userLocationManager.location?.coordinate else { return }
//        WeatherModel.shared.requestWeatherAPI(coordinate: location) { [weak self] result in
//            switch result {
//            case .success(let data):
//                self?.firstLabel.text = String(describing: data.main.feels_like)
//                print(data.main.temp)
//                self?.secondLabel.text = String(describing: data.main.temp)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
  //НЕ РАБОТАЕТ////НЕ РАБОТАЕТ////НЕ РАБОТАЕТ////НЕ РАБОТАЕТ//
//    func getWeather(user location: CLLocationManager){
//        guard let location = location.location else { return }
//        Task {
//            do {
//                let result = try await services.weather(for: location)
//                weatherData = WeatherData(tempreture: result.currentWeather.temperature.value,
//                                          confition: result.currentWeather.condition.rawValue,
//                                          symbolName: result.currentWeather.symbolName)
//
//            } catch {
//                print(String(describing: error))
//            }
//        }
//    }
    

