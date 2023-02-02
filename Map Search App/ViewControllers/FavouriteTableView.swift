//
//  FavouriteTableViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//

import UIKit
import CoreLocation
import MapKit
import SPAlert

protocol FavouritePlaceDelegate: AnyObject{
    func passCoordinates(coordinates: CLLocationCoordinate2D,name: String?)
}

class FavouriteTableViewController: UIViewController, UIGestureRecognizerDelegate{

    private let coredata = PlaceEntityStack.instance
    
    private let geocoder = CLGeocoder()
    
    weak var delegate: FavouritePlaceDelegate?
    
    let tableview: UITableView = {
        let table = UITableView()
        table.register(FavouriteTableViewCell.self, forCellReuseIdentifier: FavouriteTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        coredata.loadData()
        setupViewController()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
    
    @objc func didTapCancel(){
        dismiss(animated: true)
    }
    
    @objc private func didTapEditCell(sender: AnyObject){
        let cellIndex = sender
    }
    
    @objc private func didTapLongGesture(gesture: UILongPressGestureRecognizer){
        if gesture.state == .ended {
            let p = gesture.location(in: tableview)
            if let indexPath = tableview.indexPathForRow(at: p) {
                let place = coredata.vaultData[indexPath.row]
                let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                let vc = DetailViewController()
                vc.coordinatesForPlotInfo = coordinate
                let navVC = UINavigationController(rootViewController: vc)
                present(navVC, animated: true)
            }
        }
    }
    func setupNavigationController(){
        title = "Favourite Places"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func setupViewController(){
        view.addSubview(tableview)
        view.backgroundColor = .systemBackground
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didTapLongGesture(gesture: )))
        gesture.minimumPressDuration = 1.0
        gesture.delegate = self
        gesture.delaysTouchesBegan = true
        tableview.addGestureRecognizer(gesture)
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    func setupAlert(){
        let alert = SPAlertView(title: "Deleted from library", preset: .done)
        alert.duration = 5
        alert.dismissByTap = true
        alert.present()
    }
    // MARK: - Table view data source
}
extension FavouriteTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coredata.vaultData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteTableViewCell.identifier, for: indexPath) as! FavouriteTableViewCell
        let place = coredata.vaultData[indexPath.row]
        cell.configureCell(with: place)
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(didTapEditCell), for: .touchUpInside)
        button.tag = indexPath.row
        button.contentMode = .scaleAspectFit
        cell.accessoryView = button as UIView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let place = coredata.vaultData[indexPath.row]
        let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        
        delegate?.passCoordinates(coordinates: coordinate,name: place.place)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let data = coredata.vaultData[indexPath.row]
            coredata.vaultData.remove(at: indexPath.row)
            PlaceEntityStack().deleteData(data: data)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }



}
