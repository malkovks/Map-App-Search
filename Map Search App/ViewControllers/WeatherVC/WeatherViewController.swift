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
    
    private func setupImageDisplay(image code: Int) -> UIImage{
        print(code)
        switch code {
            
        case 1000:
            return UIImage(systemName: "sun.max")!
        case 1003:
            return UIImage(systemName: "cloud")!
        case 1006:
            print("cloudy")
            return UIImage(systemName: "cloud")!
        case 1009:
            print("overcast")
            return UIImage(systemName: "cloud")!
        case 1030:
            return UIImage(systemName: "sun.max")!
        case 1063:
            return UIImage(systemName: "sun.max")!
        case 1066:
            return UIImage(systemName: "sun.max")!
        case 1069:
            return UIImage(systemName: "sun.max")!
        case 1072:
            return UIImage(systemName: "sun.max")!
        case 1087:
            return UIImage(systemName: "sun.max")!
        case 1114:
            return UIImage(systemName: "sun.max")!
        case 1117:
            return UIImage(systemName: "wind.snow")!
        case 1135:
            return UIImage(systemName: "sun.max")!
        case 1147:
            return UIImage(systemName: "sun.max")!
        case 1150:
            return UIImage(systemName: "sun.max")!
        case 1153:
            return UIImage(systemName: "sun.max")!
        case 1168:
            return UIImage(systemName: "sun.max")!
        case 1171:
            return UIImage(systemName: "sun.max")!
        case 1180:
            return UIImage(systemName: "sun.max")!
        case 1183:
            return UIImage(systemName: "sun.max")!
        case 1186:
            return UIImage(systemName: "sun.max")!
        default:
            print("switch func is working")
            return UIImage(systemName: "thermometer.sun")!
            
        }
    }
    
    private func setupBackgroundColor(temp: Int) {
        switch temp {
        case 1...10 :
            scrollView.backgroundColor = .systemYellow
        case -10...0:
            scrollView.backgroundColor = .systemBlue
        case -40 ... -11:
            scrollView.backgroundColor = .darkGray
        case 11...60 :
            scrollView.backgroundColor = .systemOrange
        default:
            scrollView.backgroundColor = .systemBackground
        }
    }
    
    private func getWeekdayFromDay(date: String) -> String {
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
    
    private func getCallerAPI(location: CLLocationCoordinate2D){
        WeatherModel.shared.requestWeatherAPI(coordinate: location) { [weak self] result in
            switch result {
            case .success(let data):
                let temp = Int(data.current.temp_c)
                let feelsLikeTemp = Int(data.current.feelslike_c)
                let minTemp = Int(data.forecast.forecastday[0].day.mintemp_c)
                let maxTemp = Int(data.forecast.forecastday[0].day.maxtemp_c)
                self?.setupBackgroundColor(temp: temp)
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
            let dayOfWeek = getWeekdayFromDay(date: day)
            let mintemp = String(describing: Int(data.forecast.forecastday[indexPath.row].day.mintemp_c))
            let maxtemp = String(describing: Int(data.forecast.forecastday[indexPath.row].day.maxtemp_c))
            cell.textLabel?.text = dayOfWeek + mintemp + "....." +  maxtemp
            cell.detailTextLabel?.text = data.forecast.forecastday[indexPath.row].day.condition.text + " " + "\(Int(data.forecast.forecastday[indexPath.row].day.avgtemp_c))" + " °"
            cell.imageView?.image = setupImageDisplay(image: data.forecast.forecastday[indexPath.row].day.condition.code)
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



