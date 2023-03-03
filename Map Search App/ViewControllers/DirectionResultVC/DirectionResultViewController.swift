//
//  DirectionResultViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 08.02.2023.
/*
 Class for displaying variations of routes after setting up direction.
 Displaying time and distance of every route
 This view using Floating Panel for displaying map and panel
 */


import UIKit
import MapKit
import FloatingPanel

protocol ReturnResultOfDirection: AnyObject {
    func passChoise(data: DirectionResultStruct, boolean: Bool,count choosenPolyline: Int)
    func dismissContoller(isDismissed: Bool)
}

class DirectionResultViewController: UIViewController {

    weak var delegate: ReturnResultOfDirection?
    
    var routeData: DirectionResultStruct?
    
    private let panel = FloatingPanelController()
    private let converter = LocationDataConverter.instance
    private let mapTools = DirectionTools.instance
    
    private let directionTable = UITableView()
    
    private let closeViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.tintColor = .darkGray
        return button
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Выберите удобный маршрут"
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.textAlignment = .center
        label.contentMode = .center
        label.numberOfLines = 1
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var count = CGFloat(routeData?.responseDirection.routes.count ?? Int(0.0))
        titleLabel.frame = CGRect(x: 50, y: 10, width: view.frame.size.width-100, height: 40)
        closeViewButton.frame = CGRect(x: view.frame.size.width-50, y: 10, width: 40, height: 40)
        directionTable.frame = CGRect(x: 10, y: view.safeAreaInsets.top+10+closeViewButton.frame.size.height+10, width: view.frame.size.width-20, height: 60*count)
    }
    
    @objc private func didTapStartDirection(){
        //unfinished method
    }
    
    @objc private func didTapDismiss(){
        self.delegate?.dismissContoller(isDismissed: true)
        self.dismiss(animated: true)
    }
    //MARK: - setup methods
    private func setupView(){
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(directionTable)
        view.addSubview(titleLabel)
        view.addSubview(closeViewButton)
    }
    
    private func setupNavigationBar(){
        title = "Result of directions"
        closeViewButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
    }
    
    private func setupTableView(){
        directionTable.register(UITableViewCell.self, forCellReuseIdentifier: "cellDistanceResult")
        directionTable.delegate = self
        directionTable.dataSource = self
        directionTable.backgroundColor = .systemBackground
        directionTable.separatorStyle = .none
        directionTable.layer.cornerRadius = 8
        directionTable.scrollsToTop = false
        directionTable.isScrollEnabled = false
    }
    
    func getDistanceInMeters(data: DirectionResultStruct,index: Int) -> String {
        let response = data.responseDirection
        let routes = response.routes
        let distanceRoute = mapTools.getDistanceBetweenPoints(route: routes[index])
        return distanceRoute
    }
    
    func getTimeOfDistance(data: DirectionResultStruct,index: Int) -> String {
        let routes = data.responseDirection.routes
        let time = mapTools.getDistanceTime(route: routes[index])
        return time
    }
}

extension DirectionResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeData?.responseDirection.routes.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellDistanceResult")
        let route = getDistanceInMeters(data: routeData!, index: indexPath.row)
        let routeTime = getTimeOfDistance(data: routeData!, index: indexPath.row)
        cell.imageView?.image = UIImage(systemName: "arrow.triangle.turn.up.right.diamond")
        cell.textLabel?.text = "Дистанция: "+route
        cell.detailTextLabel?.text = "Время маршрута "+routeTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.passChoise(data: routeData!, boolean: true, count: indexPath.row)
    }
}
