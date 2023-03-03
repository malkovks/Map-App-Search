//
//  FavouriteTableViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
/*
 Favourite view using for displaying user's saved places
 Displaying table with main title of place. Give oportunity to show place on map
 */

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
        table.register(UITableViewCell.self
                       , forCellReuseIdentifier: "cellFavourite")
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
    
    func setupNavigationController(){
        title = "Избранные места"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    func setupViewController(){
        view.addSubview(tableview)
        view.backgroundColor = .systemBackground
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    func setupAlert(){
        let alert = SPAlertView(title: "Удалено!", preset: .done)
        alert.duration = 1
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
        let place = coredata.vaultData[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellFavourite")
        let location = CLLocation(latitude: place.latitude, longitude: place.longitude)
        GeocoderController.shared.geocoderReturn(location: location) { result in
            switch result {
            case .success(let data):
                let info = GeocoderController.shared.infoAboutPlace(placemark: data)
                cell.textLabel?.text = place.place
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.text = info.country + ", " + info.city + "\n" + "Сохранено: " + (place.date ?? "Без даты")
                cell.imageView?.image = UIImage(systemName: "heart.fill")
                cell.imageView?.tintColor = .black
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
