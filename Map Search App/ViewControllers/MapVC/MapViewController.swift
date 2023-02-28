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
import FloatingPanel

class MapViewController: UIViewController {
    //main attributes
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let annotationCustom = MKPointAnnotation()
    
    //instance constants
    private let converter = LocationDataConverter()
    private let mapTools = DirectionTools()
    private let panel = FloatingPanelController()
    private let coredata = PlaceEntityStack.instance
    private let geocoder = CLGeocoder()
    
    //variables with data
    var polylineIndex: Int = 1
    var selectedCoordination: CLLocationCoordinate2D?
    var previosLocation: CLLocation?
    var directionsArray: [MKDirections] = []
    var coordinateSpanValue = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    var currentLocation = CLLocationCoordinate2D()
    
    
    //UI elements
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
    
    private let weatherLabelButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Temp"
        button.titleLabel?.numberOfLines = 1
        button.layer.cornerRadius = 12
        button.configuration?.imagePlacement = .leading
        button.titleLabel?.textColor = .black
        button.configuration?.imagePadding = 2
        button.configuration?.baseBackgroundColor = .black
        button.configuration?.baseForegroundColor = .black
        return button
    }()
    
    //MARK: - Main View Loadings Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Core.shared.isNewUser() {
            let vc = OnboardingViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.sheetPresentationController?.detents = [.large()]
            nav.sheetPresentationController?.prefersGrabberVisible = true
            nav.isNavigationBarHidden = true
            present(nav, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTrackingUserLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let location = locationManager.location?.coordinate else { return displayError(title: "Ошибка получения геолокации для погоды\nПопробуйте позже")}
        setupWeatherButtonTemp(location: location)
    }
    
    //key func for collecting all funcs for working and showing first necessary information
    private func startTrackingUserLocation(){
        setupSubviews()
        setupLocationManager()
        setupViewsTargetsAndDelegates()
        setupDelegates()
        previosLocation = converter.getCenterLocation(for: mapView) //collect last data with latitude and longitude
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let navVC = navigationController?.navigationBar.frame.size.height else { return }
        mapView.frame = view.bounds
        weatherLabelButton.frame = CGRect(x: 10, y: view.safeAreaInsets.top+navVC, width: 80, height: 30)
        locationButton.frame = CGRect(x: view.frame.size.width-40, y:view.safeAreaInsets.top+navVC+locationButton.frame.size.height+40 , width: 40, height: 40)
        clearMapButton.frame = CGRect(x: view.frame.size.width-40, y: view.safeAreaInsets.top+navVC+40+locationButton.frame.size.height+40, width: 40, height: 40)
        clearMapButton.layer.cornerRadius = 0.5 * clearMapButton.bounds.size.width
        stepper.frame = CGRect(x: view.frame.size.width-120, y: view.frame.size.height-view.safeAreaInsets.top, width: 100, height: 100)
        menuButton.frame = CGRect(x: 15, y: view.frame.size.height-view.safeAreaInsets.top, width: 40, height: 40)
        menuButton.layer.cornerRadius = 0.5 * menuButton.bounds.size.width
    }
    
    func setupSubviews(){
        view.addSubview(mapView)
        view.addSubview(weatherLabelButton)
        view.addSubview(locationButton)
        view.addSubview(clearMapButton)
        view.addSubview(stepper)
        view.addSubview(menuButton)
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
                                UIAction(title: "Тип карты",image: UIImage(systemName: "map.fill"),attributes: .keepsMenuPresented, handler: { [self] _ in
                                switch self.mapView.mapType {
                                case .standard:
                                    mapView.mapType = .satellite
                                    
                                    navigationItem.leftBarButtonItem?.tintColor = .systemBackground
                                    navigationItem.rightBarButtonItem?.tintColor = .systemBackground
                                    clearMapButton.tintColor = .systemBackground
                                    menuButton.tintColor = .systemBackground
                                case .satellite:
                                    mapView.mapType = .hybrid
                                    
                                default:
                                    mapView.mapType = .standard
                                    
                                    navigationItem.leftBarButtonItem?.tintColor = .black
                                    navigationItem.rightBarButtonItem?.tintColor = .black
                                    clearMapButton.tintColor = .black
                                    menuButton.tintColor = .black
                                    }
                                }),
                                UIAction(title: "Трафик",image: UIImage(systemName: "car.fill"),attributes: .keepsMenuPresented, handler: { _ in
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
                                        else {
                                            self.displayError(title: "Ошибка функцией поделиться\nПопробуйте позже!")
                                        }
                                        
                                    }
                                    
                                }),
                                UIAction(title: "Построить маршрут",image: UIImage(systemName: "arrow.triangle.turn.up.right.diamond"), handler: { _ in
                                    guard let userLoc = self.locationManager.location?.coordinate else {
                                        return self.displayError(title: "Ошибка построения маршрута\nПопробуйте включить геолокацию")
                                    }
                                    
                                    let vc = SetDirectionViewController()
                                    vc.delegate = self
                                    vc.directionData = SetDirectionData(userCoordinate: userLoc, mapViewDirection: self.mapView, destinationCoordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
                                    let nav = UINavigationController(rootViewController: vc)
                                    nav.modalPresentationStyle = .pageSheet
                                    nav.sheetPresentationController?.detents = [.medium(),.large()]
                                    nav.sheetPresentationController?.prefersGrabberVisible = true
                                    nav.isNavigationBarHidden = false
                                    self.present(nav, animated: true)
                                }),
                                UIAction(title: "Добавить геопозицию в избранное",image: UIImage(systemName: "suit.heart.fill"), handler: { _ in
                                   let dateC = DateClass.dateConverter()
                                   let location = self.locationManager.location?.coordinate
                                   if let location = location {
                                       self.coredata.saveData(lat: location.latitude, lon: location.longitude, date: dateC, name: "Test")
                                   }
                                }),
                                UIAction(title: "Показать избранные места на карте", image: UIImage(systemName: "mappin"), handler: { _ in
                                    self.coredata.loadData()
                                    let vault = self.coredata.vaultData
                                    let annotations = vault.map { data in
                                        let annotation = MKPointAnnotation()
                                        annotation.title = data.place
                                        annotation.coordinate = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
                                        return annotation
                                    }
                                    self.mapView.addAnnotations(annotations)
                                }),
                                UIAction(title: "Погода",image: UIImage(systemName: "thermometer.sun.fill"), handler: { _ in
                                    self.didTapToWeather()
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
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        present(navVc, animated: true)
    }
    //segue method to Search VC
    @objc private func didTapSearch(){
        let vc = SearchViewController()
        guard let loc = locationManager.location else {
            return displayError(title: "Ошибка получения геолокации\nПопробуйте выключить и включить геолокацию.")
        }
        vc.handleMapSearchDelegate = self
        vc.searchValue = SearchData(someLocation: loc, indicatorOfView: false,mapView: mapView,tagView: 10)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.detents = [.large(),.custom(resolver: { context in return 500.0 })]
        nav.sheetPresentationController?.prefersGrabberVisible = false
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    //add annotation on map and open detail view
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == .ended{
            guard let destination = converter.gestureLocation(for: gesture, mapView: mapView, annotationCustom: annotationCustom),
                  let userCoord = locationManager.location?.coordinate else {
                return displayError(title: "Ошибка получения геолокации или данных о выбранной точке.")
            }
            mapView.removeAnnotation(annotationCustom)
            mapView.removeAnnotations(mapView.annotations)
            let vc = SetDirectionViewController()
            vc.delegate = self
            vc.detailDelegate = self
            vc.directionData = SetDirectionData(userCoordinate: userCoord, userAddress: "", userPlacemark: nil, mapViewDirection: mapView, destinationCoordinate: destination, destinationAddress: "", destinationPlacemark: nil)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.sheetPresentationController?.detents = [.large()]
            nav.sheetPresentationController?.prefersGrabberVisible = true
            nav.isNavigationBarHidden = false
            present(nav,animated: true)
        }
    }
    //func of cleaning view from directions and pins
    @objc private func didTapClearDirection(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeAnnotation(annotationCustom)
    }
    
    @objc private func didTapToWeather(){
        setupWeather(user: locationManager) 
    }
    //MARK: - setup visual elements
    //weather test
    func setupWeather(user coordinates: CLLocationManager){
        let vc = WeatherDisplayViewController()
        vc.userLocationManager = coordinates
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.modalTransitionStyle = .coverVertical
        nav.sheetPresentationController?.detents = [.large()]
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    func displayError(title: String?){
        SPAlert.present(title: title ?? "Fatal failure!\nPlease try again", preset: .error, haptic: .error)
    }
 
    //add views in subview,targets and delegates
    func setupViewsTargetsAndDelegates(){
        //targets
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        clearMapButton.addTarget(self, action: #selector(didTapClearDirection), for: .touchUpInside)
        stepper.addTarget(self, action: #selector(updateStepper), for: .valueChanged)
        menuButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
        weatherLabelButton.addTarget(self, action: #selector(didTapToWeather), for: .touchUpInside)

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
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        let mapConfig = MKStandardMapConfiguration()
        mapConfig.pointOfInterestFilter = .includingAll
        mapConfig.showsTraffic = true
        mapView.preferredConfiguration = mapConfig
    }
    //location manager settings
    func setupLocationManager(){
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        if let location = locationManager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            let region = MKCoordinateRegion(center: center, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
    //all delegates in one method
    private func setupDelegates(){
        let vc = DetailViewController()
        vc.delegate = self
        let sec = FavouriteTableViewController()
        sec.delegate = self
        locationManager.delegate = self
        mapView.delegate = self
        let destVC = SetDirectionViewController()
        destVC.delegate = self
        destVC.detailDelegate = self
        let destResult = DirectionResultViewController()
        destResult.delegate = self
    }
    
    private func setupWeatherButtonTemp(location: CLLocationCoordinate2D){
        WeatherModel.shared.requestWeatherAPI(coordinate: location) { [weak self] result in
            switch result {
            case .success(let data):
                let temp = Int(data.current.temp_c)
                let imageCode = data.current.condition.code
                let image = WeatherModel.shared.setupImageCategory(image: imageCode)
                self?.weatherLabelButton.configuration?.image = image
                self?.weatherLabelButton.configuration?.title = "\(temp)" + " °"
            case .failure(_):
                self?.displayError(title: "Ошибка загрузки данных.\nПопробуйте позже")
            }
        }
    }
    //MARK: - methods for adding annotation, open detail VC and setting up direction
    //method segue for displaying full detail info about coordinate place
    public func setChoosenLocation(coordinates: CLLocationCoordinate2D,name title: String?) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geocoder.reverseGeocodeLocation(location) { [self] placemark, error in
            guard let placemark = placemark?.first else { return }
            let streetName = placemark.thoroughfare ?? ""
            let appartmentNumber = placemark.subThoroughfare ?? ""
            let placeName = title ?? placemark.areasOfInterest?.first ??  streetName + " " + appartmentNumber
            annotationCustom.title = placeName
            annotationCustom.subtitle = streetName + " " + appartmentNumber
            annotationCustom.coordinate = placemark.location!.coordinate
            mapView.addAnnotation(annotationCustom)
            DispatchQueue.main.async {
                self.mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)),  animated: true)
                let vc = DetailViewController()
                guard let coordinate = placemark.location?.coordinate else {
                    return self.displayError(title: "Ошибка передачи данных.\nПопробуйте включить геолокацию в настройках")
                }
                vc.gettingData = DetailsData(userLocation: self.locationManager,
                                             placePoint: coordinate,
                                             pointOfInterestName: placeName,
                                             distanceRoute: "Distance is not avaliable..",
                                             placemark: placemark)
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
    //MARK: - Direction Settings
    //func for starting showing direction. Func input user location and return polyline on map
    func getDirection(start location: CLLocationCoordinate2D?,final destination: CLLocationCoordinate2D,type: String?,index: Int){
        let request = DirectionTools().createDirectionRequest(user: locationManager,
                                                             from: location,
                                                             to: destination,
                                                             type: type)
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] response, error in
            guard let response = response, error == nil else {
                return self.displayError(title: "Ошибка построения маршрута\nПопробуйте позже.")
            }
            self.didTapClearDirection()
            for route in response.routes {
                _ = route.steps
                mapTools.plotPolyline(route: route, mapView: mapView, choosenCount: index)
                
                let annotationOne = MKPointAnnotation()
                annotationOne.title = "Начало маршрута"
                mapView.addAnnotation(annotationOne)
                annotationOne.coordinate = location ?? locationManager.location!.coordinate
                let annotationTwo = MKPointAnnotation()
                annotationTwo.title = "Конец маршрута"
                annotationTwo.coordinate = destination
                mapView.addAnnotation(annotationTwo)
            }
            DispatchQueue.main.async {
                let startLoc = location ?? self.locationManager.location?.coordinate
                let vc = DirectionResultViewController()
                vc.delegate = self
                vc.routeData = DirectionResultStruct(startCoordinate: startLoc!, finalCoordinate: destination, responseDirection: response, typeOfDirection: type ?? "")
                self.panel.set(contentViewController: vc)
                self.panel.addPanel(toParent: self)
                self.panel.move(to: .tip, animated: true)
            }
        }
    }
    //MARK: - some helpful methods
    //getting direction and drawing polylines
    private func setDirectionRoute(data: DirectionResultStruct,index: Int) {
        let response = data.responseDirection
        for route in response.routes {
            _ = route.steps
            mapTools.plotPolyline(route: route, mapView: mapView, choosenCount: index)
        }
    }

    //func for clean direction
    func resetMap(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        directionsArray.map { $0.cancel() }
    }
    //MARK: - Error debagging and if statements

    //check for error
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            setupLocationManager()
            previosLocation = converter.getCenterLocation(for: mapView)
        case .authorizedAlways:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            displayError(title: "")
            break
            
        case .denied:
            displayError(title: "")
            break
        @unknown default:
            fatalError()
        }
    }
}
//MARK: - Extensions for Delegates
//delegate method from Set Direction VC
extension MapViewController: ReturnResultOfDirection{
    func dismissContoller(isDismissed: Bool) {
        if isDismissed == true {
            didTapClearDirection()
        }
    }
    //changing routes after choosing
    func passChoise(data: DirectionResultStruct, boolean: Bool, count choosenPolyline: Int) {
        setDirectionRoute(data: data, index: choosenPolyline)
    }
}
//Drop pin and open detail vc from favourite vc
extension MapViewController: FavouritePlaceDelegate{
    func passCoordinates(coordinates: CLLocationCoordinate2D,name: String?){
        setChoosenLocation(coordinates: coordinates, name: name)
    }
}
//delete all annotations if detail vc was closed
extension MapViewController:  DetailDelegate {
    func deleteAnnotations(boolean: Bool) {
        if boolean == true {
            mapView.removeAnnotation(annotationCustom)
            mapView.removeAnnotations(mapView.annotations)
        }
    }
//drawing routes after choosing set direction button
    func passAddressNavigation(location: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.location?.coordinate else { return displayError(title: "Ошибка получения данных геолокации.\nПопробуйте позже")}
        getDirection(start: userLocation, final: location, type: "Автомобиль", index: 1)
    }
}

extension MapViewController: SetDirectionProtocol {
    func getDataForDirection(user coordinate: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, type: String,route index: Int) {
        getDirection(start: coordinate, final: destination, type: type,index: index)
    }
}
//delegation data from search vc after searching some data
extension MapViewController: HandleMapSearch {
    func dropCoordinate(coordinate: CLLocationCoordinate2D, requestName: String) {
        setChoosenLocation(coordinates: coordinate, name: requestName)
    }
    //summary drop places from search
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
}
//MARK: - Extensions Data Source
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
        var annView: MKAnnotationView?
        let annotationViewCustom = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")

        if annView != nil {
            annotationViewCustom.markerTintColor = .systemYellow
            annView = annotationViewCustom
        }
        return annView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.removeAnnotation(annotationCustom)
        if let coord = view.annotation?.coordinate ,
           let title = view.annotation?.title{
            setChoosenLocation(coordinates: coord, name: title)
        }
   }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyline = MKPolylineRenderer(overlay: overlay)
        let index = polylineIndex
        if overlay is MKPolyline {
            if mapView.overlays.count == index {
                polyline.strokeColor = .systemIndigo.withAlphaComponent(1)
                polyline.lineWidth = 10
            } else {
                polyline.strokeColor = .systemBlue.withAlphaComponent(0.4)
                polyline.lineWidth = 5
            }
        }
        return polyline
    }
}

//below two funcs which setup showing and hiding keyboard
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//MARK: - Methods for search ,hiding and showing keyboard
//override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    for touch in touches {
//        let point = touch.location(in: mapView)
//        let location = mapView.convert(point, toCoordinateFrom: mapView)
//        selectedCoordination = location
//    }
//}
//
////function of lift up view
//@objc func keyboardWillShow(notification: NSNotification){
//    if let keyboardsize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//        if self.view.frame.origin.y == 0 {
//            self.view.frame.origin.y -= keyboardsize.height
//        }
//    }
//}
////func of lift down view after using search bar
//@objc func keyboardWillHide(notification: NSNotification){
//    if self.view.frame.origin.y != 0 {
//        self.view.frame.origin.y = 0
//    }
//}
