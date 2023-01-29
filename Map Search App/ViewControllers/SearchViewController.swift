//
//  SearchViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//


import UIKit
import MapKit

class SearchViewController: UIViewController {
    
    static let identifier = "SearchViewController"
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView?
    var testValueForSecondTable: [String] = []
    var lastRequest: [LastChoosenRequest] = []
    var userLocation: CLLocation?
    private let geocoder = CLGeocoder()
    private let coreData = SearchHistoryStack.instance
    
    var handleMapSearchDelegate: HandleMapSearch? = nil

    let imageDictionary = ["Аэропорт": UIImage(systemName: "airplane.arrival"),
                           "Рестораны":UIImage(systemName: "fork.knife"),
                           "Магазины":UIImage(systemName: "basket"),
                           "Аптеки":UIImage(systemName: "cross.case"),
                           "Отели":UIImage(systemName: "bed.double"),
                           "АЗС":UIImage(systemName: "fuelpump"),
                           "Кинотеатры":UIImage(systemName: "popcorn"),
                           "Фитнес":UIImage(systemName: "dumbbell"),
                           "ТЦ":UIImage(systemName: "handbag"),
                           "Салоны красоты": UIImage(systemName: "scissors"),
                           "Банкоматы":UIImage(systemName: "banknote"),
                           "Бары": UIImage(systemName: "wineglass"),
                           "Интересные места":UIImage(systemName: "star"),
                           "Пункты выдачи":UIImage(systemName: "shippingbox"),
                           "Кофейни": UIImage(systemName: "mug"),
                           "Больницы":UIImage(systemName: "cross.circle")
                        ]
    
    let table: UITableView = {
       let table = UITableView()
        table.backgroundColor = .secondarySystemBackground
        return table
    }()
    
    private var categoryCollectionView: UICollectionView!
    
    
    
    private let previosRequests = UITableView(frame: .zero, style: .plain)
    
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
        search.hidesNavigationBarDuringPresentation = true
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
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.isHidden = true
        button.backgroundColor = .systemBackground
        
        return button
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationAndView()
        newSetupSearchController()
        setupTable()
        setupSearchBarConstraints()
    }

    
    override func viewDidLayoutSubviews(){
        let safeArea = view.safeAreaInsets.top
        closeButton.frame = CGRect(x: view.frame.size.width-40, y: safeArea+10, width: 30, height: 30)
        closeButton.layer.cornerRadius = 0.5 * closeButton.bounds.width
        searchImage.frame = CGRect(x: 10, y: safeArea+10, width: 30, height: 30)
        searchImage.layer.cornerRadius = 0.5 * searchImage.bounds.width
        clearHistoryButton.frame = CGRect(x: view.frame.size.width-50, y: safeArea+65, width: 30, height: 40)
        segmentalButtons.frame = CGRect(x: 55, y: safeArea+65, width: view.frame.size.width-110, height: 40)
        table.frame = CGRect(x: 0, y: safeArea+110, width: view.frame.size.width, height: view.frame.size.height-90)
        table.layer.cornerRadius = 8
        categoryCollectionView.frame = CGRect(x: 0, y: safeArea+110, width: view.frame.size.width, height: view.frame.size.height-100)
    }
    
    @objc private func didTapDismiss(){
        resultSearchController.searchBar.text = ""
        resultSearchController.dismiss(animated: true)
        matchingItems = []
        self.dismiss(animated: true)
    }
    
    @objc private func didTapClearHistory(){
        let alert = UIAlertController(title: "Warning!", message: "Do you want to clear your history of request?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { _ in
            let data = self.coreData.historyVault
            self.coreData.deleteHistoryData(data: data)
            self.coreData.historyVault.removeAll()
            self.table.reloadData()
            self.clearHistoryButton.isEnabled = false
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert,animated: true)
    }
    
    @objc private func didTapDetailButton(sender: AnyObject){
        print(sender.tag as Any)
    }
    
    @objc private func didTapToChangeSegment(){
        //для перехода от одного вью к другому
        switch segmentalButtons.selectedSegmentIndex {
        case 0:
            resultSearchController.searchBar.isHidden = false
            clearHistoryButton.isHidden = true
            categoryCollectionView.isHidden = false
            segmentalButtons.frame = CGRect(x: 55, y: view.safeAreaInsets.top+65, width: view.frame.size.width-110, height: 40)
            table.reloadData()
            matchingItems = []
        default:
            table.reloadData()
            coreData.loadHistoryData()
            resultSearchController.searchBar.text = ""
            matchingItems = []
            resultSearchController.searchBar.isHidden = true
            clearHistoryButton.isHidden = false
            categoryCollectionView.isHidden = true
            segmentalButtons.frame = CGRect(x: 55, y: view.safeAreaInsets.top+15, width: view.frame.size.width-110, height: 40)
        }
    }
    
    private func setupSearchBarConstraints(){
        let bar = resultSearchController.searchBar
        bar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor,constant: 10),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -50),
            bar.heightAnchor.constraint(equalToConstant: 55),
            bar.widthAnchor.constraint(equalToConstant: view.frame.size.width-100)
        ])
    }
    
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
        if coreData.historyVault.count != 0 {
            clearHistoryButton.isEnabled = true
            clearHistoryButton.tintColor = .systemRed
        } else {
            clearHistoryButton.isEnabled = false
            clearHistoryButton.tintColor = .black
        }
        
    }
    
    private func setupNavigationAndView(){
        view.addSubview(table)
        view.addSubview(resultSearchController.searchBar)
        view.addSubview(closeButton)
        view.addSubview(searchImage)
        view.addSubview(segmentalButtons)
        view.addSubview(categoryCollectionView)
        view.addSubview(clearHistoryButton)
        view.backgroundColor = .systemBackground
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        view.inputViewController?.edgesForExtendedLayout = .all
        
        segmentalButtons.addTarget(self, action: #selector(didTapToChangeSegment), for: .valueChanged)
        clearHistoryButton.addTarget(self, action: #selector(didTapClearHistory), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
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
    
    //не работает тк неудачно конвертирует координаты в placemark
    //необходимо отредактировать функцию!!!
    private func convertLocInPlacemark(location:CLLocationCoordinate2D) -> CLPlacemark? {
        let coordinate = CLLocation(latitude: location.latitude, longitude: location.longitude)
        var returnPlacemark: CLPlacemark?
        geocoder.reverseGeocodeLocation(coordinate) { placemark, error in
        
            returnPlacemark = placemark?.first
        }
        return returnPlacemark
    }
    
    private func alternativeParseData(customMark: MKPlacemark) -> String {
        
        let addressLine = "\(customMark.thoroughfare ?? "Адрес отсутствует"), \(customMark.subThoroughfare ?? "Дом остутствует"), \(customMark.subLocality ?? "Название района отсутствует"), \(customMark.administrativeArea ?? "Название города отсутствует"),  \(customMark.country ?? "")"
        return addressLine
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let mapView = mapView, let text = searchController.searchBar.text else {
            return
        }
        if text != "" {
            categoryCollectionView.isHidden = true
            self.table.isHidden = false
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = text
            request.region = mapView.region
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                self.matchingItems = response.mapItems
                self.table.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultSearchController.searchBar.resignFirstResponder()
        if let text = searchBar.text, !text.isEmpty {
                    let data = matchingItems
                    self.handleMapSearchDelegate?.dropSomeAnnotations(items: data)
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            DispatchQueue.main.asyncAfter(deadline: .now()+2){
                self.matchingItems = []
                self.table.reloadData()
                self.resultSearchController.dismiss(animated: true)
                self.categoryCollectionView.isHidden = false
                self.table.isHidden = true
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text ,!text.isEmpty {
            searchBar.text = ""
            matchingItems = []
            table.reloadData()
            categoryCollectionView.isHidden = false
            table.isHidden = true
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
            if let location = self.userLocation {
                let placeDistance = convertDistance(user: location, annotation: selectedItems.coordinate)
                cell.configureDistanceForCell(distance: placeDistance)
            }
        } else {
            //доделать placemark
            let convertData = coreData.historyVault.reversed()[indexPath.row]
            cell.configureCell(with: convertData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if segmentalButtons.selectedSegmentIndex == 0 {
            let selectedItem = matchingItems[indexPath.row].placemark
            handleMapSearchDelegate?.dropCoordinate(coordinate: selectedItem.coordinate, requestName: selectedItem.name!)
            self.matchingItems = []
            if let name = selectedItem.name{
                let coordinate = selectedItem.coordinate
                coreData.saveHistoryDataElement(name: name, lan: coordinate.latitude, lon: coordinate.longitude)
                self.resultSearchController.searchBar.endEditing(true)
                self.resultSearchController.searchBar.text = ""
                self.resultSearchController.dismiss(animated: true)
                self.table.reloadData()
            }
            self.dismiss(animated: true)
        } else {
            let data = coreData.historyVault.reversed()[indexPath.row]
            guard let name = data.nameCategory else { return }
            let location = CLLocationCoordinate2D(latitude: data.langitude, longitude: data.longitude)
            handleMapSearchDelegate?.dropCoordinate(coordinate: location, requestName: name)
            self.dismiss(animated: true)
        }
    }
}
