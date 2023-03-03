//
//  WeatherViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
/*
 This class inherit data from API WeatherAPI.com
 Basic displaying data in labels for current day and for next 7 days of week in table
 */


import Foundation
import UIKit
import WeatherKit
import CoreLocation
import SPAlert

class WeatherDisplayViewController: UIViewController {
    
    var weatherData: WeatherDataAPI?
    
    var userLocationManager = CLLocationManager() 
    
    let services = WeatherService()
    
    private let cityLabel = UILabel()
    private let currentTemperatureLabel = UILabel()
    private let minMaxLabel = UILabel()
    
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
        cityLabel.frame = CGRect(x: 10, y: 0, width: view.frame.size.width-20, height: 60)
        currentTemperatureLabel.frame = CGRect(x: 10, y: cityLabel.frame.size.height+10, width: view.frame.size.width-20, height: 80)
        minMaxLabel.frame = CGRect(x: 10, y: cityLabel.frame.size.height+currentTemperatureLabel.frame.size.height+20, width: view.frame.size.width-20, height: 80)
        weatherTableView.frame = CGRect(x: 10, y: cityLabel.frame.size.height+currentTemperatureLabel.frame.size.height+minMaxLabel.frame.size.height+30, width: view.frame.size.width-20, height: 620)
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
        weatherTableView.backgroundColor = .secondarySystemBackground
        
    }
    
    private func setupNavigationBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .black
        title = "Погода"
    }

    private func setupLabel(){
        cityLabel.backgroundColor = .secondarySystemBackground
        cityLabel.textAlignment = .center
        cityLabel.font = .systemFont(ofSize: 24,weight: .bold)
        
        currentTemperatureLabel.font = .systemFont(ofSize: 30 ,weight: .medium)
        currentTemperatureLabel.backgroundColor = .secondarySystemBackground
        currentTemperatureLabel.textAlignment = .center
        currentTemperatureLabel.numberOfLines = 1
        
        minMaxLabel.backgroundColor = .secondarySystemBackground
        minMaxLabel.textAlignment = .center
        minMaxLabel.numberOfLines = 2
        minMaxLabel.font = .systemFont(ofSize: 20,weight: .medium)
    }
    
    private func setupScrollView(){
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 1000)
        scrollView.addSubview(cityLabel)
        scrollView.addSubview(currentTemperatureLabel)
        scrollView.addSubview(minMaxLabel)
        scrollView.addSubview(weatherTableView)
        scrollView.backgroundColor = .secondarySystemBackground
    }
    
    private func setupView(){
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(scrollView)
        guard let location = userLocationManager.location?.coordinate else { return }
        getCallerAPI(location: location)
    }

    
    private func getCallerAPI(location: CLLocationCoordinate2D){
        WeatherModel.shared.requestWeatherAPI(coordinate: location) { [weak self] result in
            switch result {
            case .success(let data):
                let temp = Int(data.current.temp_c)
                let minTemp = Int(data.forecast.forecastday[0].day.mintemp_c)
                let maxTemp = Int(data.forecast.forecastday[0].day.maxtemp_c)
                self?.weatherData = data
                self?.cityLabel.text = data.location.region
                self?.currentTemperatureLabel.text = "\(temp)"+" °"
                self?.minMaxLabel.text = "\(data.current.condition.text)"+"\nМакс.: \(maxTemp) °, мин.: \(minTemp) °"
                
                DispatchQueue.main.async {
                    self?.weatherTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension WeatherDisplayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "weatherCell")
        cell.selectionStyle = .none
        cell.backgroundColor = .secondarySystemBackground
        if let data = weatherData {

            let day = data.forecast.forecastday[indexPath.row].date
            let dayOfWeek = WeatherModel.shared.getWeekdayFromDay(date: day)
            let mintemp = String(describing: Int(data.forecast.forecastday[indexPath.row].day.mintemp_c))
            let maxtemp = String(describing: Int(data.forecast.forecastday[indexPath.row].day.maxtemp_c))
            let conditionText = data.forecast.forecastday[indexPath.row].day.condition.text
            let code = data.forecast.forecastday[indexPath.row].day.condition.code
            let avgTemp = Int(data.forecast.forecastday[indexPath.row].day.avgtemp_c)
            cell.textLabel?.text = dayOfWeek + "   : " + mintemp + "  →   " +  maxtemp
            cell.detailTextLabel?.text = conditionText + ", Сред.: " + "\(avgTemp)" + " °"
            cell.imageView?.image = WeatherModel.shared.setupImageCategory(image: code)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Погода на неделю"
    }
    
    
}



