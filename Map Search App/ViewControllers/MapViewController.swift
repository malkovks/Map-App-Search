//
//  MapViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//

import UIKit
import MapKit
import CoreLocationUI
import SPAlert

protocol HandleMapSearch {
    func dropPin(placemark: MKPlacemark,requestName: String?)
    func dropCoordinate(coordinate: CLLocationCoordinate2D, requestName: String)
    func dropSomeAnnotations(items: [MKMapItem])
}

class MapViewController: UIViewController {

    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let annotationCustom = MKPointAnnotation()
    
    
    private let geocoder = CLGeocoder()
    var selectedCoordination: CLLocationCoordinate2D?
    var previosLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    var savedLocationToShowDirection: CLLocationCoordinate2D?
    var savedNameLocation: String?
    var previousMainName: String?
    var coordinateSpanValue = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    var currentLocation = CLLocationCoordinate2D()
    private let coredata = PlaceEntityStack.instance
    
    
    private let favouriteButton: UIButton = {
        let button = UIButton()
         button.layer.cornerRadius = 8
         button.backgroundColor = .secondarySystemFill
         button.setImage(UIImage(systemName: "bookmark",
                                 withConfiguration: UIImage.SymbolConfiguration(
                                 pointSize: 32,
                                 weight: .medium)),
                                 for: .normal)
         button.tintColor = .black
         return button
     }()
    
    private let locationButton: CLLocationButton = {
        let locationButton = CLLocationButton()
        locationButton.icon = .arrowOutline
        locationButton.isHighlighted = true
        locationButton.cornerRadius = 20
        locationButton.backgroundColor = .black
        return locationButton
    }()
    
    private let clearMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(
                                    pointSize: 32,
                                    weight: .medium)),
                        for: .normal)
        button.layer.cornerRadius = 8

        button.tintColor = .black
        return button
    }()
    
    private let stepper: UIStepper = {
       let stepper = UIStepper()
        stepper.minimumValue = 0.005
        stepper.maximumValue = 2
        stepper.stepValue = 0.05
        stepper.value = 0.02
        return stepper
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.setImage(UIImage(systemName: "list.dash"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.backgroundColor = .systemFill
        button.tintColor = .black
        button.subtitleLabel?.text = "Menu"
        return button
    }()
    
    var searchController: UISearchController = {
        let search = UISearchController()
        search.searchBar.searchBarStyle = .prominent
        search.searchBar.placeholder = "Print Request"
        search.searchBar.backgroundColor = .systemBackground
        search.showsSearchResultsController = true
        search.automaticallyShowsCancelButton = true
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.sizeToFit()
        return search
    }()
    //MARK: - Main View Loadings Methods
    override func viewDidAppear(_ animated: Bool) {
        setupDelegates()
        super.viewDidAppear(animated)
        if let location = savedLocationToShowDirection,let name = savedNameLocation {
            setChoosenLocation(coordinates: location, requestName: name)
            savedLocationToShowDirection = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTrackingUserLocation()
        setupWeather()
    }
    //key func for collecting all funcs for working and showing first necessary information
    private func startTrackingUserLocation(){
        setupSubviews()
        setupLocationManager()
        setupViewsTargetsAndDelegates()
        setupSearchAndTable()
        setupDelegates()
        previosLocation = getCenterLocation(for: mapView) //collect last data with latitude and longitude
    }

    //MARK: - Layout setup
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let navVC = navigationController?.navigationBar.frame.size.height else { return }
        mapView.frame = view.bounds
        locationButton.frame = CGRect(x: view.frame.size.width-40, y:view.safeAreaInsets.top+navVC+locationButton.frame.size.height+40 , width: 40, height: 40)
        clearMapButton.frame = CGRect(x: view.frame.size.width-40, y: view.safeAreaInsets.top+navVC+40+locationButton.frame.size.height+40, width: 40, height: 40)
        clearMapButton.layer.cornerRadius = 0.5 * clearMapButton.bounds.size.width
        stepper.frame = CGRect(x: view.frame.size.width-120, y: view.frame.size.height-view.safeAreaInsets.top, width: 100, height: 100)
        menuButton.frame = CGRect(x: 15, y: view.frame.size.height-view.safeAreaInsets.top, width: 40, height: 40)
        menuButton.layer.cornerRadius = 0.5 * menuButton.bounds.size.width
    }
    //MARK: - Objc methods
    //func for getting user location when user press on location button
    @objc private func didTapLocation(){
        setupLocationManager()
    }
    //method for menu Button and displaying UIMenu
    //сделать меню для отображения части данных, редактирование окна, показа избранного и пр.
    @objc private func didTapMenu(){
        let menu = UIMenu(title: "",options: .displayInline,children:
                            
                            [
                                UIAction(title: "Clear map",image: UIImage(systemName: "xmark.circle.fill"),attributes: .destructive, handler: { _ in
                                    self.didTapClearDirection()
                                }),
                                UIAction(title: "Тип карты",image: UIImage(systemName: "map.fill"), handler: { _ in
                                switch self.mapView.mapType {
                                case .standard:
                                    self.mapView.mapType = .satellite
                                case .satellite:
                                    self.mapView.mapType = .hybrid
                                default:
                                    self.mapView.mapType = .standard
                                    }
                                }),
                                UIAction(title: "Трафик",image: UIImage(systemName: "car.fill"), handler: { _ in
                                switch self.mapView.showsTraffic {
                                case false:
                                    self.mapView.showsTraffic = true
                                default:
                                    self.mapView.showsTraffic = false
                                    }
                                }),
                                UIAction(title: "Поделиться геопозицией",image: UIImage(systemName: "square.and.arrow.up.fill"), handler: { _ in
                                   if let lat = self.locationManager.location?.coordinate.latitude,
                                      let long = self.locationManager.location?.coordinate.longitude {
                                       if let url = URL(string: "https://maps.apple.com?ll=\(lat),\(long)") {
                                           let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                           activity.popoverPresentationController?.permittedArrowDirections = .up
                                           self.present(activity,animated: true)
                                       }
                                   }
                                }),
                                UIAction(title: "Добавить геопозицию в избранное",image: UIImage(systemName: "suit.heart.fill"), handler: { _ in
                                   let dateC = DateClass.dateConverter()
                                   let location = self.locationManager.location?.coordinate
                                   if let location = location {
                                       self.coredata.saveData(lat: location.latitude, lon: location.longitude, date: dateC, name: "Test")
                                   }
                                }),
                                UIAction(title: "Избранное",image: UIImage(systemName: "bookmark.fill"), handler: { _ in
                                   self.didTapToFavourite()
                                }),
                                UIAction(title: "Информация о приложении",image: UIImage(systemName: "info.circle.fill"), handler: { _ in
                                    let vc = DeveloperViewController()
                                    let nav = UINavigationController(rootViewController: vc)
                                    nav.modalPresentationStyle = .pageSheet
                                    nav.sheetPresentationController?.detents = [.custom(resolver: { _ in
                                        650
                                    })]
                                    nav.sheetPresentationController?.preferredCornerRadius = 8
                                    nav.isNavigationBarHidden = false
                                    nav.sheetPresentationController?.prefersGrabberVisible = true
                                    self.present(nav,animated: true)
                                })
                        ])
        self.menuButton.menu = menu
        self.menuButton.showsMenuAsPrimaryAction = true
    }
    //method for stepper
    @objc private func updateStepper(_ sender: UIStepper){
        var value: Double?
        if stepper.value <= 0.07 {
            stepper.stepValue = 0.01
            value = sender.value
        } else if stepper.value > 0.07 && stepper.value < 0.2 {
            stepper.stepValue = 0.07
            value = sender.value
        } else {
            stepper.stepValue = 0.1
            value = sender.value
        }
        
        coordinateSpanValue = MKCoordinateSpan(latitudeDelta: value!, longitudeDelta: value!)
        let coordinate = currentLocation
        let region = MKCoordinateRegion(center: coordinate, span: coordinateSpanValue)
        self.mapView.setRegion(region, animated: true)
    }
    //segue to Favourite View Contr
    @objc private func didTapToFavourite(){
        let vc = FavouriteTableViewController()
        vc.delegate = self
        let secVC = DetailViewController()
        secVC.delegate = self
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        present(navVc, animated: true)
    }
    
    @objc private func didTapSearch(){
        let vc = SearchViewController()
        guard let loc = locationManager.location else { return displayError() }
        vc.handleMapSearchDelegate = self
        vc.searchValue = SearchData(someLocation: loc, indicatorOfView: false,mapView: mapView,tagView: 10)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.detents = [.large(),.custom(resolver: { context in return 500.0 })]
        nav.sheetPresentationController?.prefersGrabberVisible = false
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    //created new branch
    
    //add annotation on map and open detail view
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer){
        print("pressed")
        
        if gesture.state == .ended{
            guard let destination = gestureLocation(for: gesture), let userCoord = locationManager.location?.coordinate else {
                return displayError()
            }
            mapView.removeAnnotation(annotationCustom)
            mapView.removeAnnotations(mapView.annotations)
            let vc = SetDirectionViewController()
            vc.delegate = self
            let vcSec = SearchViewController()
            vcSec.secondDelegate = self
            vc.directionData = SetDirectionData(userCoordinate: userCoord, userAddress: "", userPlacemark: nil, mapViewDirection: mapView, destinationCoordinate: destination, destinationAddress: "", destinationPlacemark: nil)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.sheetPresentationController?.detents = [.custom(resolver: { context in return 500 }),.large()]
            nav.sheetPresentationController?.prefersGrabberVisible = true
            nav.isNavigationBarHidden = false
            present(nav,animated: true)
//            if streetName(location: gesture) != nil{
//            }
        }
    }
    //func of cleaning view from directions and pins
    @objc private func didTapClearDirection(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeAnnotation(annotationCustom)
    }
    //подумать нужна или нет
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: mapView)
            let location = mapView.convert(point, toCoordinateFrom: mapView)
            selectedCoordination = location
        }
    }
    
    //function of lift up view
    @objc func keyboardWillShow(notification: NSNotification){
        if let keyboardsize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardsize.height
            }
        }
    }
    //func of lift down view after using search bar
    @objc func keyboardWillHide(notification: NSNotification){
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    //MARK: - setup visual elements
    //weather test
    func setupWeather(){
        //импортировать кит с погодой
    }
    func displayError(){
        SPAlert.present(title: "Turn on your location in settings", preset: .error, haptic: .error)
    }
    //проверить нужна ли эта функция ???
    func setupSearchAndTable(){
        let tableDelegate = SearchViewController()
        searchController = UISearchController(searchResultsController: tableDelegate)
        searchController.searchResultsUpdater = tableDelegate
        tableDelegate.mapView = mapView
        tableDelegate.handleMapSearchDelegate = self
        definesPresentationContext = true
        //КОНТРОЛЛЕР убран из вью!!!!
//        navigationItem.searchController = searchController
        //
    }
    func setupSubviews(){
        view.addSubview(mapView)
        view.addSubview(locationButton)
        view.addSubview(clearMapButton)
        view.addSubview(stepper)
        view.addSubview(menuButton)
    }
    //add views in subview,targets and delegates
    func setupViewsTargetsAndDelegates(){
        //targets
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        clearMapButton.addTarget(self, action: #selector(didTapClearDirection), for: .touchUpInside)
        stepper.addTarget(self, action: #selector(updateStepper), for: .valueChanged)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        //below two funcs which setup showing and hiding keyboard
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //nav item set up
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(didTapToFavourite))
        navigationItem.rightBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy)), style: .done, target: self, action: #selector(didTapSearch))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        //delegates and secondary setups
        longGesture.minimumPressDuration = 0.5
        definesPresentationContext = true
        
        mapView.showsCompass = false
        mapView.userTrackingMode = .followWithHeading
        mapView.addGestureRecognizer(longGesture)
        mapView.selectableMapFeatures = [.pointsOfInterest]
        let mapConfig = MKStandardMapConfiguration()
        mapConfig.pointOfInterestFilter = .includingAll
        mapConfig.showsTraffic = true
        mapView.preferredConfiguration = mapConfig
    }
    //location manager settings
    func setupLocationManager(){
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if let location = locationManager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func distanceFunction(coordinate: CLLocationCoordinate2D) -> Double {
        let user = locationManager.location
        let convert = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let dist = user?.distance(from: convert) else { return 0.0 }
        return dist
    }
    
    private func setupDelegates(){
        let vc = DetailViewController()
        vc.delegate = self
        let sec = FavouriteTableViewController()
        sec.delegate = self
        locationManager.delegate = self
        mapView.delegate = self
        searchController.delegate = self
        let destVC = SetDirectionViewController()
        destVC.delegate = self
        let searchVC = SearchViewController()
        searchVC.secondDelegate = self
    }
    //MARK: - Setups for displaying direction, converter methods and getters of address
    public func setChoosenLocation(coordinates: CLLocationCoordinate2D,requestName: String?) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        mapView.removeAnnotation(annotationCustom)
        mapView.removeAnnotations(mapView.annotations)
//        let geocoderStart = GeocoderReturn
        geocoder.reverseGeocodeLocation(location) { placemark, error in
            guard let placemark = placemark?.first else { return }
            let streetName = placemark.thoroughfare ?? ""
            let appartmentNumber = placemark.subThoroughfare ?? ""
            let areaOfinterest = placemark.areasOfInterest?.first ?? "\(streetName), дом \(appartmentNumber)"
            DispatchQueue.main.async {
                self.annotationCustom.title = requestName ?? areaOfinterest
                self.annotationCustom.subtitle = "\(streetName), дом \(appartmentNumber)"
                self.annotationCustom.coordinate = coordinates
                self.mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)),  animated: true)
                self.mapView.addAnnotation(self.annotationCustom)
                let dist = self.distanceFunction(coordinate: coordinates)
                
                let vc = DetailViewController()
                vc.pointOfInterest = requestName
                vc.distanceBetweenUserAndAnnotation = dist
                vc.coordinatesForPlotInfo = placemark.location?.coordinate
                vc.delegate = self
                vc.modalPresentationStyle = .pageSheet
                vc.sheetPresentationController?.detents = [.medium(),.large(),.custom(resolver: { context in
                    return 175.0
                })]
                vc.sheetPresentationController?.prefersGrabberVisible = true
                self.present(vc, animated: true)
                
            }
        }
    }
    //func for getting user's location data
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
           let latitude = mapView.centerCoordinate.latitude
           let longitude = mapView.centerCoordinate.longitude
           return CLLocation(latitude: latitude, longitude: longitude)
    }
    //func for gesture location and for output locations data
    func gestureLocation(for gesture: UILongPressGestureRecognizer) -> CLLocationCoordinate2D? {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        annotationCustom.coordinate = coordinate
        self.mapView.addAnnotation(annotationCustom)
        return coordinate
    }
    //func for  getting street name and number of buildings
    func streetName(location gesture: UILongPressGestureRecognizer) -> CLPlacemark? {
        let center = gestureLocation(for: gesture)
        var returnPlacemark: CLPlacemark?
        guard let center = center else {
            return nil
        }
        let locationData = CLLocation(latitude: center.latitude, longitude: center.longitude)
        geocoder.reverseGeocodeLocation(locationData) { [weak self] placemark, error in
            guard let placemark = placemark?.first else {
                return
            }
            guard let self = self else {
                return
            }
            returnPlacemark = placemark
            let street = placemark.thoroughfare ?? ""
            let streetNum = placemark.subThoroughfare ?? ""
            DispatchQueue.main.async {
                let dist = self.distanceFunction(coordinate: center)
                let vc = DetailViewController()
                vc.coordinatesForPlotInfo = center
                vc.distanceBetweenUserAndAnnotation = dist
                vc.delegate = self
                vc.modalPresentationStyle = .pageSheet
                vc.sheetPresentationController?.detents = [.medium(),.large(),.custom(resolver: { context in
                    return 175.0
                })]
                vc.sheetPresentationController?.prefersGrabberVisible = true
                self.present(vc, animated: true)
                self.annotationCustom.title = "\(street), \(streetNum)"
            }
        }
        return returnPlacemark
    }
    //MARK: - Direction Settings
    //func for starting showing direction. Func input user location and return polyline on map
    func getDirection(locationDirection: CLLocationCoordinate2D?){
        guard let checkLoc = locationDirection else {
            return
        }
        let request = createDirectionRequest(from: checkLoc)
        let directions = MKDirections(request: request)
        resetMap(withNew: directions)
        directions.calculate { [unowned self] response, error in
            //output alert if error
            guard let response = response, error == nil else {
                return
            }
            for route in response.routes {
                _ = route.steps
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    //функция для отображения ДЛИННЫ МАРШРУТА
//    private func getRouteDistance(coordinate: CLLocationCoordinate2D){
//        let request = MKDirections.Request()
//        let user = locationManager.location?.coordinate
//        let destination = MKPlacemark(coordinate: coordinate)
//        let userMark = MKPlacemark(coordinate: user)
//        request.source = MKMapItem(placemark: userMark)
//        request.destination = MKMapItem(placemark: destination)
//    }
    
    //main setups for direction display. Input user location and output result of request by start and end location
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = coordinate //endpoint coordinates
        let startingLocation      = MKPlacemark(coordinate: locationManager.location!.coordinate)//checking for active user location
        let destination           = MKPlacemark(coordinate: destinationCoordinate) //checking for having endpoint coordinates
        let request               = MKDirections.Request()
        request.source                       = MKMapItem(placemark: startingLocation)
        request.destination                  = MKMapItem(placemark: destination)
        request.transportType                = .walking
        request.requestsAlternateRoutes     = false
        
        annotationCustom.coordinate = destinationCoordinate
        return request
    }
    //func for clean direction
    func resetMap(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    

   
    //MARK: - Error debagging and if statements

    //check for error
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            setupLocationManager()
            previosLocation = getCenterLocation(for: mapView)
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
            //show alert
        case .denied:
            break
            //show alert
        @unknown default:
            fatalError()
        }
    }
}
//MARK: - Extensions for Delegates
extension MapViewController: SetPinSearchDelegate {
    func isFuncAvailable(boolean: Bool) {
        if boolean == true {
            print("Boolean true")
        }
    }
    
    
}

extension MapViewController: FavouritePlaceDelegate{
    func passCoordinates(coordinates: CLLocationCoordinate2D,name: String?) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeAnnotation(annotationCustom)
        savedLocationToShowDirection = coordinates
        savedNameLocation = name
    }
}

extension MapViewController:  PlotInfoDelegate {
    func deleteAnnotations(boolean: Bool) {
        if boolean == true {
            if let search = searchController.searchBar.text, !search.isEmpty {
                mapView.removeAnnotation(annotationCustom)
                mapView.removeAnnotations(mapView.annotations)
                searchController.searchBar.text = ""
            }
            mapView.removeAnnotation(annotationCustom)
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    func passAddressNavigation(location: CLLocationCoordinate2D) {
        
        let locationData = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(locationData) { [weak self] placemark, error in
            guard let placemark = placemark?.first else {
                return
            }
            guard let self = self else {
                return
            }
            let streetName = placemark.thoroughfare ?? ""
            let streetNumber = placemark.subThoroughfare ?? ""
            let city = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            let areaInterests = placemark.areasOfInterest ?? []
            DispatchQueue.main.async {
                    if areaInterests == [] {
                        self.annotationCustom.coordinate = location
                        self.annotationCustom.title = "\(streetName), дом \(streetNumber)"
                        self.annotationCustom.subtitle = "\(city), \(country)"
                        self.mapView.addAnnotation(self.annotationCustom)
                        self.getDirection(locationDirection: location)
                    } else if areaInterests != [] {
                        self.annotationCustom.coordinate = location
                        self.annotationCustom.title = areaInterests.first
                        self.annotationCustom.subtitle = "г. \(city) "
                        self.mapView.addAnnotation(self.annotationCustom)
                        self.getDirection(locationDirection: location)
                }
            }
        }
    }
}
extension MapViewController: SetDirectionProtocol {
    func getDataForDirection(user coordinate: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D, direction type: String) {
        
    }
    
    
}


extension MapViewController: HandleMapSearch {
    func dropCoordinate(coordinate: CLLocationCoordinate2D, requestName: String) {
        setChoosenLocation(coordinates: coordinate, requestName: requestName)
        
    }
    func dropSomeAnnotations(items: [MKMapItem]) {
        
        let annotations = items.map { location -> MKAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = location.placemark.name
            annotation.subtitle = location.placemark.title
            annotation.coordinate = location.placemark.coordinate
            return annotation
        }
        setupLocationManager()
        mapView.addAnnotations(annotations)
        
    }
    //не используется
    func dropPin(placemark: MKPlacemark,requestName: String?) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeAnnotation(annotationCustom)
        annotationCustom.coordinate = placemark.coordinate
        annotationCustom.title = placemark.name
        print("Delegate successfully")
        if let city = placemark.locality, let street = placemark.thoroughfare, let appartment = placemark.subThoroughfare {
            annotationCustom.subtitle = "\(city), \(street), дом \(appartment)"
        }
        mapView.addAnnotation(annotationCustom)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        let dist = distanceFunction(coordinate: annotationCustom.coordinate)
        
        let vc = DetailViewController()
        vc.pointOfInterest = requestName ?? placemark.areasOfInterest?.first
        vc.coordinatesForPlotInfo = placemark.coordinate
        vc.distanceBetweenUserAndAnnotation = dist
        vc.delegate = self
        
        vc.modalPresentationStyle = .pageSheet
        vc.sheetPresentationController?.detents = [.medium(),.large(),.custom(resolver: { context in
            return 175.0
        })]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        present(vc, animated: true)
    }
}
//MARK: - Extensions Data Source
extension MapViewController: UISearchBarDelegate, UISearchControllerDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let nav = UINavigationController(rootViewController: SearchViewController())
        self.present(nav,animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locations = locations.first else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: locations.coordinate.latitude, longitude: locations.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        self.currentLocation = center
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        annotationView.markerTintColor = .systemPurple
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if view.annotation != nil {
//            mapView.removeAnnotation(annotationCustom)
//        }
        mapView.removeAnnotation(annotationCustom)
        guard let annotation = (view.annotation?.coordinate) else { return }
        
        let dist = distanceFunction(coordinate: annotation)
        let vc = DetailViewController()
        vc.pointOfInterest = view.annotation?.title ?? "No title"
        vc.coordinatesForPlotInfo = view.annotation?.coordinate
        vc.distanceBetweenUserAndAnnotation = dist
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        vc.sheetPresentationController?.detents = [.medium(),.large(),.custom(resolver: { context in
            return 175.0
        })]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        present(vc, animated: true)
   }
    //polyline setups
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemIndigo
        return renderer
    }
}
