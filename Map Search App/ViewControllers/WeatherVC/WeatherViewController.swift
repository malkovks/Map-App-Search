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
    
    var userLocationManager = CLLocationManager() 
    
    let services = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        title = "Погода"
        setupView()
        getWeather(user: userLocationManager)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    func getUserLocation(){
        
    }
    
    func getWeather(user location: CLLocationManager){
        guard let location = location.location else { return }
        Task {
            do {
                let result = try await services.weather(for: location)
                print(String(describing: result.currentWeather))
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func setupView(){
        
    }
    
}
