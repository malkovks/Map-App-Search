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
import SPAlert

class WeatherDisplayViewController: UIViewController {
    
    
    var weatherData: WeatherDataAPI?
    
    var userLocationManager = CLLocationManager() 
    
    let services = WeatherService()
    
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()
    
    private let weatherTableView = UITableView()
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        setupTableView()
        setupNavigationBar()
        setupScrollView()
        setupView()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height)
        firstLabel.frame = CGRect(x: 10, y: 0, width: view.frame.size.width-20, height: 55)
        secondLabel.frame = CGRect(x: 10, y: 75, width: view.frame.size.width-20, height: 55)
        thirdLabel.frame = CGRect(x: 10, y: 150, width: view.frame.size.width-20, height: 55)
        weatherTableView.frame = CGRect(x: 10, y: 225, width: view.frame.size.width-20, height: 620)
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    private func setupTableView(){
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
        weatherTableView.register(UITableViewCell.self, forCellReuseIdentifier: "weatherCell")
        weatherTableView.isScrollEnabled = false
        weatherTableView.separatorStyle = .none
    }
    
    private func setupNavigationBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .black
        title = "Погода"
    }

    private func setupLabel(){
        firstLabel.backgroundColor = .systemBackground
        firstLabel.textAlignment = .center
        firstLabel.font = .systemFont(ofSize: 24,weight: .bold)
        
        secondLabel.font = .systemFont(ofSize: 24,weight: .semibold)
        secondLabel.backgroundColor = .systemBackground
        secondLabel.textAlignment = .center
        
        thirdLabel.backgroundColor = .systemBackground
        thirdLabel.textAlignment = .center
        thirdLabel.font = .systemFont(ofSize: 20,weight: .medium)
    }
    
    private func setupScrollView(){
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 1000)
        scrollView.addSubview(firstLabel)
        scrollView.addSubview(secondLabel)
        scrollView.addSubview(thirdLabel)
        scrollView.addSubview(weatherTableView)
        scrollView.backgroundColor = .secondarySystemBackground
    }
    
    private func setupView(){
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(scrollView)
        guard let location = userLocationManager.location?.coordinate else { return }
        requestWeatherAPI(coordinate: location)
    }
    
    public func requestWeatherAPI(coordinate: CLLocationCoordinate2D){
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        print(latitude)
        print(longitude)
        guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=982e0f449bc841028ee230603231902&q=\(latitude),\(longitude)&aqi=no") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return  }
            do {
                let result = try JSONDecoder().decode(WeatherDataAPI.self, from: data)
                DispatchQueue.main.async {
                    let temp = "\(result.current.feelslike_c)"
                    self.weatherData = result
                    self.firstLabel.text = self.weatherData?.location.country
                    self.secondLabel.text = self.weatherData?.location.region
                    self.thirdLabel.text = "Ощущается как \(temp) ℃"
                    print(result.location.region)
                }
                
            } catch {
                print("Error catching data from API")
            }
        }.resume()
    }
    
}

extension WeatherDisplayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "weatherCell")
        cell.imageView?.image = UIImage(systemName: "cloud.heavyrain")
        cell.textLabel?.text = "№\(indexPath.row+1) Rain weather"
        cell.detailTextLabel?.numberOfLines = 3
        cell.detailTextLabel?.text = "Today will be very rainy and windy Today will be very rainy and windy Today will be very rainy and windy"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Погода на неделю"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}



