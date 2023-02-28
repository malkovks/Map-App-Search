//
//  SearchViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//


import UIKit
import MapKit
import SPAlert

protocol SearchControllerDelegate: AnyObject {
    func passSearchResult(coordinates: CLLocationCoordinate2D,placemark: MKPlacemark?,tagView: Int)
}

protocol HandleMapSearch: AnyObject {
    func dropCoordinate(coordinate: CLLocationCoordinate2D, requestName: String)
    func dropSomeAnnotations(items: [MKMapItem])
}



class SearchViewController: UIViewController {
    
    static let identifier = "SearchViewController"
    
    private let coreData = SearchHistoryStack.instance
    private let favouriteCoreData = PlaceEntityStack.instance
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    var searchValue: SearchData?
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    weak var delegate: SearchControllerDelegate?

    
    let imageDictionary = ["Аэропорт"       :UIImage(systemName: "airplane.arrival"),
                           "Рестораны"      :UIImage(systemName: "fork.knife"),
                           "Магазины"       :UIImage(systemName: "basket"),
                           "Аптеки"         :UIImage(systemName: "cross.case"),
                           "Отели"          :UIImage(systemName: "bed.double"),
                           "АЗС"            :UIImage(systemName: "fuelpump"),
                           "Кинотеатры"     :UIImage(systemName: "popcorn"),
                           "Фитнес"         :UIImage(systemName: "dumbbell"),
                           "ТЦ"             :UIImage(systemName: "handbag"),
                           "Салоны красоты" :UIImage(systemName: "scissors"),
                           "Банкоматы"      :UIImage(systemName: "banknote"),
                           "Бары"           :UIImage(systemName: "wineglass"),
                           "Интересные места":UIImage(systemName: "star"),
                           "Пункты выдачи"  :UIImage(systemName: "shippingbox"),
                           "Кофейни"        :UIImage(systemName: "mug"),
                           "Больницы"       :UIImage(systemName: "cross.circle")
                        ]
    
    let table: UITableView = {
       let table = UITableView()
        table.backgroundColor = .systemBackground
        table.layer.cornerRadius = 8
        return table
    }()
    
    private var categoryCollectionView: UICollectionView!
    
    private var resultSearchController: UISearchController = {
        var search = UISearchController()
        search.searchBar.searchBarStyle = .minimal
        search.searchBar.isTranslucent = false
        search.searchBar.placeholder = "Найти"
        search.searchBar.showsScopeBar = false
        search.searchBar.backgroundColor = .systemBackground
        search.searchBar.returnKeyType = .search
        search.scopeBarActivation = .onTextEntry
        search.showsSearchResultsController = true
        search.automaticallyShowsCancelButton = true
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    private let closeButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .systemGray5
        return button
    }()
    
    private let searchImage: UIImageView = {
       let image = UIImageView()
        image.image = UIImage(systemName: "magnifyingglass")
        image.tintColor = .darkGray
        image.sizeToFit()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let segmentalButtons: UISegmentedControl = {
       let button = UISegmentedControl(items: ["Категории","История поиска"])
        button.tintColor = .systemBackground
        button.selectedSegmentIndex = 0
        button.backgroundColor = .systemGray5
        return button
    }()
    
    private let clearHistoryButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Очистить историю поиска"
        button.configuration?.image = UIImage(systemName: "trash")
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.baseForegroundColor = .systemRed
        return button
    }()
    
    private let setPinOnMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Указать точку на карте"
        button.configuration?.image = UIImage(systemName: "pin")
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.baseForegroundColor = .systemBlue
        return button
    }()
    
    private let getUserLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Мое местоположение"
        button.configuration?.image = UIImage(systemName: "location")
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .black
        button.configuration?.baseForegroundColor = .black
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationAndView()
        newSetupSearchController()
        setupTable()
    }

    
    override func viewDidLayoutSubviews(){
        guard let safeArea = navigationController?.navigationBar.frame.size.height else { return }
        segmentalButtons.frame = CGRect(x: 10, y: safeArea, width: view.frame.size.width-20, height: 40)
        categoryCollectionView.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: view.frame.size.height)
        setPinOnMapButton.frame = CGRect(x: 10, y: safeArea, width: view.frame.size.width-20, height: 55)
        getUserLocationButton.frame = CGRect(x: 10, y: safeArea+10+setPinOnMapButton.frame.size.height, width: view.frame.size.width-20, height: 55)
        if searchValue?.indicatorOfView == false {
            table.frame = CGRect(x: 0, y: 100, width: view.frame.size.width, height: view.frame.size.height)
        } else {
            table.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-60)
            table.layer.cornerRadius = 0
        }
        
    }
    
    @objc private func didTapDismiss(){
        resultSearchController.searchBar.text = ""
        resultSearchController.dismiss(animated: true)
        matchingItems = []
        self.dismiss(animated: true)
    }
    
    @objc private func didTapClearHistory(){
        if !coreData.historyVault.isEmpty {
            let alert = UIAlertController(title: "Внимание!", message: "Вы действительно хотите очистить историю?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive,handler: { _ in
                let data = self.coreData.historyVault
                self.coreData.deleteHistoryData(data: data)
                self.coreData.historyVault.removeAll()
                self.table.reloadData()
                self.clearHistoryButton.isEnabled = false
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            present(alert,animated: true)
        }
    }
    
    @objc private func didTapDetailButton(sender: AnyObject){
        print(sender.tag as Any)
    }
    
    @objc private func didTapToChangeSegment(){
        
        switch segmentalButtons.selectedSegmentIndex {
        case 0://search table
            navigationItem.titleView = resultSearchController.searchBar
            resultSearchController.searchBar.isHidden = false
            clearHistoryButton.isHidden = true
            categoryCollectionView.isHidden = false
            table.reloadData()
            matchingItems = []
            navigationItem.centerItemGroups = []
        default://history table
            self.navigationItem.titleView = clearHistoryButton
            clearHistoryButton.isHidden = false
            table.reloadData()
            coreData.loadHistoryData()
            resultSearchController.searchBar.text = ""
            matchingItems = []
            resultSearchController.searchBar.isHidden = true
            categoryCollectionView.isHidden = true
        }
    }
    
    @objc private func setPinOnMap(){
        SPAlert.present(message: "This func in test project", haptic: .warning)
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @objc private func didDelegateUserLocation(){
        guard let loc = searchValue?.someLocation else { return }
        let location = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        delegate?.passSearchResult(coordinates: location, placemark: nil, tagView: 0)
        self.dismiss(animated: true)
    }
    //MARK: - Setup Methods
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSizeMake(80, 90)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(ResultCollectionViewCell.self, forCellWithReuseIdentifier: ResultCollectionViewCell.identifier)
        categoryCollectionView.backgroundColor = .systemBackground
        categoryCollectionView.isUserInteractionEnabled = true
        categoryCollectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func newSetupSearchController(){
        resultSearchController.searchResultsUpdater = self
        definesPresentationContext = true
        resultSearchController.searchBar.delegate = self
    }
    
    private func setupTable(){
        coreData.loadHistoryData()
        table.keyboardDismissMode = .onDrag
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemBackground
        table.contentInsetAdjustmentBehavior = .always
        table.reloadData()
        table.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        if !coreData.historyVault.isEmpty {
            clearHistoryButton.configuration?.baseBackgroundColor = .systemRed
            clearHistoryButton.configuration?.baseForegroundColor = .systemRed
        } else {
            clearHistoryButton.configuration?.baseBackgroundColor = .systemGray3
            clearHistoryButton.configuration?.baseForegroundColor = .systemGray3
        }
    }
    
    private func setupNavigationAndView(){
        segmentalButtons.addTarget(self, action: #selector(didTapToChangeSegment), for: .valueChanged)
        clearHistoryButton.addTarget(self, action: #selector(didTapClearHistory), for: .touchUpInside)
        setPinOnMapButton.addTarget(self, action: #selector(setPinOnMap), for: .touchUpInside)
        getUserLocationButton.addTarget(self, action: #selector(didDelegateUserLocation), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), landscapeImagePhone: nil, style: .done, target: self, action: nil)
        navigationItem.titleView = resultSearchController.searchBar
        navigationItem.rightBarButtonItem?.tintColor = .darkGray
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
        navigationItem.leftBarButtonItem?.isSelected = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.largeTitleDisplayMode = .never
        if searchValue?.indicatorOfView == true {
            view.addSubview(table)
            view.backgroundColor = .systemBackground
            view.addSubview(setPinOnMapButton)
            view.addSubview(getUserLocationButton)
            table.backgroundColor = .systemBackground
            navigationController?.navigationBar.backgroundColor = .systemBackground
            resultSearchController.searchBar.returnKeyType = .done
            if searchValue?.tagView == 1 {
                getUserLocationButton.isHidden = true
            } else {
                getUserLocationButton.isHidden = false
            }
        } else {
            view.addSubview(table)
            view.addSubview(segmentalButtons)
            view.addSubview(categoryCollectionView)
            view.addSubview(clearHistoryButton)
            view.backgroundColor = .systemBackground
        }
    }
    
    private func convertDistance(user: CLLocation,annotation: CLLocationCoordinate2D) -> String? {
        var output = ""
        let coordinateAnn = CLLocation(latitude: annotation.latitude, longitude: annotation.longitude)
        let dist = user.distance(from: coordinateAnn)
        if dist >= 1000 {
            let km = dist / 1000.00
            output = String(Double(round(10 * km) / 10 )) + " км"
        } else {
            let m = dist
            output = String(Int(m)) + " м"
        }
        return output
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let mapView = searchValue?.mapView, let text = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        if searchValue?.indicatorOfView == false {
            if !text.isEmpty {
                categoryCollectionView.isHidden = true
                self.table.isHidden = false
                search.start { response, _ in
                    guard let response = response else {
                        return
                    }
                    self.matchingItems = response.mapItems
                    self.table.reloadData()
                }
            }
        } else {
            if !text.isEmpty {
                setPinOnMapButton.isHidden = true
                getUserLocationButton.isHidden = true
                self.table.isHidden = false
                search.start { response, _ in
                    guard let response = response else {
                        return
                    }
                    self.matchingItems = response.mapItems
                    self.table.reloadData()
                }
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultSearchController.searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty, searchValue?.indicatorOfView == false {
                    let data = matchingItems
                    self.handleMapSearchDelegate?.dropSomeAnnotations(items: data)
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == ""{
            if searchValue?.indicatorOfView == false {
             DispatchQueue.main.asyncAfter(deadline: .now()+2){
                 self.matchingItems = []
                 self.table.reloadData()
                 self.resultSearchController.dismiss(animated: true)
                 self.categoryCollectionView.isHidden = false
                 self.table.isHidden = true
             }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()+2){
                    self.matchingItems = []
                    self.table.reloadData()
                    self.resultSearchController.dismiss(animated: true)
                    self.setPinOnMapButton.isHidden = false
                    self.getUserLocationButton.isHidden = false
                    self.table.isHidden = true
                }
            }
        } else if !searchBar.text!.isEmpty {
            self.table.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text ,!text.isEmpty {
            if searchValue?.indicatorOfView == false {
                searchBar.text = ""
                matchingItems = []
                table.reloadData()
                categoryCollectionView.isHidden = false
                table.isHidden = true
            } else {
                searchBar.text = ""
                matchingItems = []
                table.reloadData()
                setPinOnMapButton.isHidden = false
                getUserLocationButton.isHidden = false
                table.isHidden = true
            }
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageDictionary.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResultCollectionViewCell.identifier, for: indexPath) as! ResultCollectionViewCell
        let keys = Array(imageDictionary.keys.sorted())[indexPath.row]
        let values = imageDictionary[keys]
        cell.configureCell(title: keys, image: values!!)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = Array(imageDictionary.keys.sorted())[indexPath.row]
        resultSearchController.searchBar.text = cell
    }
}

extension SearchViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.table && segmentalButtons.selectedSegmentIndex == 0{
            return matchingItems.count
        } else {
            return coreData.historyVault.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as! SearchResultTableViewCell
        if segmentalButtons.selectedSegmentIndex == 0 {
            let selectedItems = matchingItems[indexPath.row].placemark
            cell.configureCell(placemark: selectedItems)
            if let location = self.searchValue?.someLocation {
                let placeDistance = convertDistance(user: location, annotation: selectedItems.coordinate)
                cell.configureDistanceForCell(distance: placeDistance)
            }
        } else {
            let convertData = coreData.historyVault.reversed()[indexPath.row]
            let location = CLLocationCoordinate2D(latitude: convertData.langitude, longitude: convertData.longitude)
            cell.configureCell(with: convertData)
            cell.coordinatesForSaving = location
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if searchValue?.indicatorOfView == false, segmentalButtons.selectedSegmentIndex == 0 {
            let placemark = matchingItems[indexPath.row].placemark
            handleMapSearchDelegate?.dropCoordinate(coordinate: placemark.coordinate, requestName: placemark.name!)
            self.matchingItems = []
            if let name = placemark.name{
                let coordinate = placemark.coordinate
                coreData.saveHistoryDataElement(name: name, lan: coordinate.latitude, lon: coordinate.longitude)
                self.resultSearchController.searchBar.endEditing(true)
                self.resultSearchController.searchBar.text = ""
                self.resultSearchController.dismiss(animated: true)
                self.table.reloadData()
            }
            self.dismiss(animated: true)
            
        } else if segmentalButtons.selectedSegmentIndex == 1{
            let data = coreData.historyVault.reversed()[indexPath.row]
            guard let name = data.nameCategory else { return }
            let location = CLLocationCoordinate2D(latitude: data.langitude, longitude: data.longitude)
            handleMapSearchDelegate?.dropCoordinate(coordinate: location, requestName: name)
            self.dismiss(animated: true)
            //condition for set direction after choosing one of textfields
        } else if searchValue?.indicatorOfView == true {
            let placemark = matchingItems[indexPath.row].placemark
            guard let value = searchValue?.tagView else { return }
            delegate?.passSearchResult(coordinates: placemark.coordinate, placemark: placemark,tagView: value)
            self.resultSearchController.dismiss(animated: true)
            self.dismiss(animated: true)
        }
    }
}
