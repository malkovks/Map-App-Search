//
//  DetailViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//

import UIKit
import CoreLocation
import MapKit
import SPAlert


protocol PlotInfoDelegate: AnyObject {
    func passAddressNavigation(location: CLLocationCoordinate2D)
    func deleteAnnotations(boolean: Bool)
}

class DetailViewController: UIViewController {
    
    private let coreData = PlaceEntityStack.instance
    
    var selectedLocationOnMap = CLLocationCoordinate2D()
    var selectedPlacemark: MKPlacemark?

    
    var coordinatesForPlotInfo: CLLocationCoordinate2D?
    var pointOfInterest: String?
    var distanceBetweenUserAndAnnotation: Double = 0.0
    
    
    private var annotation: MKAnnotation?
    private let geocoder = CLGeocoder()
    private var dataStruct: FullAdress!
    private var cellData: String?
    
    weak var delegate: PlotInfoDelegate?

    //MARK: UI elements
    var mainTitlePlotView: UILabel = {
        let label = UILabel()
        label.text = "Main title is loading..."
        label.numberOfLines = 2
        label.backgroundColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    let shareButtonPlotView: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.imageView?.tintColor = .systemGray
        button.backgroundColor = .systemGray5
        return button
    }()
    
    let removeAddressButtonPlotView: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.tintColor = .systemGray
        button.backgroundColor = .systemGray5
        return button
    }()
    
     let distanceLabelPlotView: UILabel = {
        let label = UILabel()
        label.text = "Distance between user and place is loading.."
        label.backgroundColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 17, weight: .thin)
        return label
    }()
    
    let directionButtonPlotView: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle(" Directions", for: .normal)
        button.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.diamond"), for: .normal)
        button.imageView?.tintColor = .systemBackground
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 8
        return button
    }()
    
    let moreInfoButtonPlotView: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray5
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(" More", for: .normal)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.imageView?.tintColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
     let plotInfoPlotView: UILabel = {
        let label = UILabel()
        label.text = "Details"
        label.backgroundColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    let addressTableViewPlotView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let tableDirectionButtonPlotView: UIButton = {
        let button = UIButton(type: .custom)
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "arrow.triangle.turn.up.right.diamond"), for: .normal)
        button.backgroundColor = .systemGray5
        button.imageView?.tintColor = .systemBlue
        return button
    }()
    
    let addToFavouriteCellPlotView: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle("Add to Favourite", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.textAlignment = .justified
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    let deleteMarkPlotView: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
        button.titleLabel?.textAlignment = .justified
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.imageView?.tintColor = .systemRed
        button.layer.cornerRadius = 8
        return button
    }()
    
    //MARK: - Main Setup view
    override func viewDidLoad() {
        if let coordinate = coordinatesForPlotInfo {
            setPlotInfoByCoordinates(coordinates: coordinate,pointOfInterest: pointOfInterest)
        }
        super.viewDidLoad()
        
        
//        addressTableViewPlotView.delegate = self
//        addressTableViewPlotView.dataSource = self
        
        setupPlotSubview()
        setupFirstTableView()
        buttonTargets()
        mainTitlePlotView.text = "Check label text in label"
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let const = view.safeAreaInsets.top+10
        mainTitlePlotView.frame = CGRect(x: 10, y: const, width: view.frame.size.width-100, height: 60)
        shareButtonPlotView.frame = CGRect(x: view.frame.size.width-shareButtonPlotView.frame.size.width*3, y: const+10, width: 30, height: 30)
        removeAddressButtonPlotView.frame = CGRect(x: view.frame.size.width-removeAddressButtonPlotView.frame.size.width*1.5, y: const+10, width: 30, height: 30)
        shareButtonPlotView.layer.cornerRadius = 0.5 * shareButtonPlotView.bounds.size.width
        removeAddressButtonPlotView.layer.cornerRadius = 0.5 * removeAddressButtonPlotView.bounds.size.width
        distanceLabelPlotView.frame = CGRect(x: 10, y: const+20+mainTitlePlotView.frame.size.height, width: view.frame.size.width/1.5, height: 30)
        directionButtonPlotView.frame = CGRect(x: 10, y: const + 30+mainTitlePlotView.frame.size.height+distanceLabelPlotView.frame.size.height, width: view.frame.size.width/2, height: 60)
        moreInfoButtonPlotView.frame = CGRect(x: 15+directionButtonPlotView.frame.size.width, y: const +  30+mainTitlePlotView.frame.size.height+distanceLabelPlotView.frame.size.height, width: view.frame.size.width/2-20, height: 60)
        plotInfoPlotView.frame = CGRect(x: 10, y:const +  15+mainTitlePlotView.frame.size.height+distanceLabelPlotView.frame.size.height*2+directionButtonPlotView.frame.size.height, width: view.frame.size.width/2, height: 30)
        addressTableViewPlotView.frame = CGRect(x: 10, y:const +  mainTitlePlotView.frame.size.height*2+directionButtonPlotView.frame.size.height*2, width: view.frame.size.width-20, height: 320)
        tableDirectionButtonPlotView.frame = CGRect(x: addressTableViewPlotView.frame.size.width-30, y:const +  mainTitlePlotView.frame.size.height*4+10, width: 30, height: 30)
        tableDirectionButtonPlotView.layer.cornerRadius = 0.5 * tableDirectionButtonPlotView.bounds.size.width
        addToFavouriteCellPlotView.frame = CGRect(x: 10, y:const +  addressTableViewPlotView.frame.size.height*2+addToFavouriteCellPlotView.frame.size.height/2-90, width: view.frame.size.width-20, height: 50)
        deleteMarkPlotView.frame = CGRect(x: 10, y:const +  addressTableViewPlotView.frame.size.height*2+addToFavouriteCellPlotView.frame.size.height*2-100, width: view.frame.size.width-20, height: 50)
    }
    
    //MARK: - Target Methods
    @objc private func didTapClose(){
        dismiss(animated: true)
    }
    
    @objc private func didTapSetDirection(){
        if let coordinates = coordinatesForPlotInfo {
            delegate?.passAddressNavigation(location: coordinates)
            self.view.window?.rootViewController?.dismiss(animated: true)
        } else {
            SPAlert.present(preset: .error)
        }
    }
    
    @objc private func didTapAddToFavourite(){
        let date = DateClass.dateConverter()
        if let coordinate = self.coordinatesForPlotInfo {
            self.coreData.saveData(lat: coordinate.latitude, lon: coordinate.longitude, date: date,name: pointOfInterest ?? "No Name")
        }
    }
    
    @objc private func didTapToDelete(){
        delegate?.deleteAnnotations(boolean: true)
        dismiss(animated: true)
    }
    
    @objc private func didTapToDetails(){
        let menu = UIMenu(title: "",options: .displayInline,children:
                            [UIAction(title: "Close window",image: UIImage(systemName: "trash"),attributes: .destructive, handler: { _ in
                                self.dismiss(animated: true)
                             }),
                             UIAction(title: "Set Direction",image: UIImage(systemName: "arrow.triangle.turn.up.right.diamond"), handler: { _ in
                                if let coordinates = self.coordinatesForPlotInfo {
                                    self.delegate?.passAddressNavigation(location: coordinates)
                                    self.view.window?.rootViewController?.dismiss(animated: true)
                                }
                             }),
                             UIAction(title: "Share location",image: UIImage(systemName: "square.and.arrow.up"), handler: { _ in
                                self.didTapToShare()
                             }),
                             UIAction(title: "Add to Favourite",image: UIImage(systemName: "star"), handler: { _ in
                                self.didTapAddToFavourite()
                             })
                        ])
        moreInfoButtonPlotView.showsMenuAsPrimaryAction = true
        moreInfoButtonPlotView.menu = menu
        
        
    }
    
    @objc private func didTapToShare(){
        if let lat = self.coordinatesForPlotInfo?.latitude, let long = self.coordinatesForPlotInfo?.longitude {
            if let url = URL(string: "https://maps.apple.com?ll=\(lat),\(long)") {
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activity.popoverPresentationController?.permittedArrowDirections = .up
                self.present(activity,animated: true)
            }
        }
    }
    //MARK: - convert and setting view methods
//    private func dateConverter() -> String{
//        let date = Date()
//        let format = DateFormatter()
//        format.dateFormat = "HH:mm:ss"
//        format.timeStyle = .medium
//        format.dateStyle = .long
//        format.timeZone = TimeZone(abbreviation: "UTC")
//        let stringFormat = format.string(from: date)
//        return stringFormat
//    }
    
    private func convertDistance(distance: Double) -> String {
        var km = 0.0
        var output = ""
        if distance >= 1000 {
            km = distance / 1000.00
            output = String(Double(round(100 * km) / 100 )) + " км"
        } else {
            km = distance
            output = String(Int(km)) + " метров"
        }
        return output
    }
    
    public func setPlotInfoByCoordinates(coordinates: CLLocationCoordinate2D,pointOfInterest: String?){
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemark, error in
            guard let placemark = placemark?.first else {
                return
            }
            guard let self = self else { return }
            let streetName = placemark.thoroughfare ?? "No str.name"
            let streetSubname = placemark.subThoroughfare ?? "No num."
            let city = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            let postIndex = placemark.postalCode ?? ""
            let meter = self.distanceBetweenUserAndAnnotation
            let distance = self.convertDistance(distance: meter)
            DispatchQueue.main.async {
                if let point = pointOfInterest {
                    self.mainTitlePlotView.text = point
                    self.distanceLabelPlotView.text = distance
                    self.cellData = "\(streetName), \(streetSubname)\n\(city)\n\(country)\n\(postIndex)"
                    self.dataStruct = FullAdress(street: streetName, appartmentNumber: streetSubname, city: city, country: country, postIndex: postIndex, latitude: coordinates.latitude, longitude: coordinates.longitude)
                    self.addressTableViewPlotView.reloadData()
                } else {
                    self.mainTitlePlotView.text = streetName
                    self.distanceLabelPlotView.text = distance
                    self.cellData = "\(streetName), \(streetSubname)\n\(city)\n\(country)\n\(postIndex)"
                    self.dataStruct = FullAdress(street: streetName, appartmentNumber: streetSubname, city: city, country: country, postIndex: postIndex, latitude: coordinates.latitude, longitude: coordinates.longitude)
                    self.addressTableViewPlotView.reloadData()
                }
            }
        }
    }
    
//    private func convertDataToPlacemark(coordinates: CLLocationCoordinate2D) -> CLPlacemark {
//        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
//        var placemark: CLPlacemark?
//        geocoder.reverseGeocodeLocation(location) { placemarkFirst, error in
//            guard let placemarkLast = placemarkFirst?.first else {
//                return
//            }
//            placemark = placemarkLast
//        }
//        return placemark!
//    }

    //MARK: - setups methods
    private func setupFirstTableView(){
        addressTableViewPlotView.separatorStyle = .none
        addressTableViewPlotView.layer.cornerRadius = 10
        addressTableViewPlotView.alwaysBounceVertical = false
        addressTableViewPlotView.delegate = self
        addressTableViewPlotView.dataSource = self
        title = "Pin Details"
        view.backgroundColor = .secondarySystemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(didTapClose))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    private func buttonTargets(){
        tableDirectionButtonPlotView.addTarget(self, action: #selector(didTapSetDirection), for: .touchUpInside)
        directionButtonPlotView.addTarget(MapViewController(), action: #selector(didTapSetDirection), for: .touchUpInside)
        addToFavouriteCellPlotView.addTarget(self, action: #selector(didTapAddToFavourite), for: .touchUpInside)
        deleteMarkPlotView.addTarget(self, action: #selector(didTapToDelete), for: .touchUpInside)
        removeAddressButtonPlotView.addTarget(self, action: #selector(didTapToDelete), for: .touchUpInside)
        moreInfoButtonPlotView.addTarget(self, action: #selector(didTapToDetails), for: .touchUpInside)
        shareButtonPlotView.addTarget(self, action: #selector(didTapToShare), for: .touchUpInside)
    }

    private func setupPlotSubview(){
        view.addSubview(mainTitlePlotView)
        view.addSubview(shareButtonPlotView)
        view.addSubview(removeAddressButtonPlotView)
        view.addSubview(distanceLabelPlotView)
        view.addSubview(directionButtonPlotView)
        view.addSubview(moreInfoButtonPlotView)
        view.addSubview(plotInfoPlotView)
        view.addSubview(addressTableViewPlotView)
        view.addSubview(tableDirectionButtonPlotView)
        view.addSubview(addToFavouriteCellPlotView)
        view.addSubview(deleteMarkPlotView)
    }
}
//MARK: - Extensions delegate
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows: [Int] = [1,1]
        var rows = 0
        if section < numberOfRows.count{
            rows = numberOfRows[section]
        }
        return rows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section{
        case 0:
            sectionName = NSLocalizedString("Address", comment: "Address")
        case 1:
            sectionName = NSLocalizedString("Coordinate", comment: "Coordinate")
        default:
            sectionName = " "
        }
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.numberOfLines = 4
            cell.textLabel?.font = .systemFont(ofSize: 24,weight: .regular)
            cell.textLabel?.text = cellData
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let lat = coordinatesForPlotInfo?.latitude
            let long = coordinatesForPlotInfo?.longitude
            cell.textLabel?.text = "Longitude: \(Double(lat ?? 0))\nLangitude: \(Double(long ?? 0))"
            cell.textLabel?.font = .systemFont(ofSize: 20,weight: .light)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if let coordinates = coordinatesForPlotInfo {
                self.delegate?.passAddressNavigation(location: coordinates)
                self.view.window?.rootViewController?.dismiss(animated: true)
            }
        }
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 130
        }
        return 60
    }
}
