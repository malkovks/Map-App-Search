//
//  SetDirectionViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 03.02.2023.
//

import Foundation
import UIKit
import MapKit
import SPAlert

protocol SetDirectionProtocol: AnyObject{
    func getDataForDirection(user coordinate: CLLocationCoordinate2D,destination coordinate: CLLocationCoordinate2D,type direction: String)
}

class SetDirectionViewController: UIViewController {
    
    var directionData: SetDirectionData? //сюда сохраняются данные из map view для делегирования их на карту обратно
    
    weak var delegate: SetDirectionProtocol?
    
    private var coreData = PlaceEntityStack.instance
    
    private let geocoder = CLGeocoder()
    
    var detailDelegate: HandleMapSearch? = nil
    
    
    let dictionaryOfType: [String:UIImage] = ["Автомобиль":UIImage(systemName: "car")!
                                              ,"Пешком":UIImage(systemName: "figure.walk")!
                                              ,"Велосипед":UIImage(systemName: "bicycle")!
                                              ,"Транспорт":UIImage(systemName: "bus")!]
    
    private let table: UITableView = {
       let table = UITableView()
        table.backgroundColor = .systemBackground
        table.layer.cornerRadius = 8
        return table
    }()
    
    private let firstTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Отсюда"
        field.text = "Мое местоположение"
        field.font = .systemFont(ofSize: 16,weight: .light)
        field.layer.cornerRadius = 12
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .systemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.tag = 0
        return field
    }()
    
    private let secondTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Сюда"
        field.text = "📍Выбранная геолокация"
        field.font = .systemFont(ofSize: 16,weight: .light)
        field.layer.cornerRadius = 12
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .systemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.tag = 1
        return field
    }()
    
    private let detailsOfPlace: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Что здесь находится?"
        button.configuration?.image = UIImage(systemName: "mappin.and.ellipse")
        button.configuration?.imagePlacement = .top
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.baseForegroundColor = .systemBlue
        return button
    }()
    
    private var directionCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupCollectionView()
        setupView()
        setupNavigationBar()
        setupTableView()
        table.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeArea = view.safeAreaInsets.top
        let sArea = view.safeAreaInsets.top+10+detailsOfPlace.frame.size.height
        let ht = setupHeightForTable()
        detailsOfPlace.frame = CGRect(x: 10, y: 10+safeArea, width: view.frame.size.width-20, height: 55)
        firstTextField.frame = CGRect(x: 10, y: 10+sArea, width: view.frame.size.width-20, height: 55)
        secondTextField.frame = CGRect(x: 10, y: 20+sArea+firstTextField.frame.size.height, width: view.frame.size.width-20, height: 55)
        table.frame = CGRect(x: 10, y: 30+sArea+firstTextField.frame.size.height+secondTextField.frame.size.height, width: view.frame.size.width-20, height: 50+ht)
        directionCollectionView.frame = CGRect(x: 10, y: 40+sArea+firstTextField.frame.size.height+secondTextField.frame.size.height+table.frame.size.height, width: view.frame.size.width-20, height: 100)
    }
    
    private func setupHeightForTable() -> CGFloat{
        var height: CGFloat = 0.0
        let count: CGFloat = CGFloat(coreData.vaultData.count)
        if count <= 5 {
            table.showsVerticalScrollIndicator = false
            table.isScrollEnabled = false
            table.frame.size.height = 40*count
            height = table.frame.size.height
        } else if count > 5 {
            table.showsVerticalScrollIndicator = true
            table.isScrollEnabled = true
            table.frame.size.height = 200
            height = table.frame.size.height
        }
        return height
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    @objc private func didTapShowDetailOfPlace(){
        guard let coordinate = directionData?.destinationCoordinate else { return }
        self.detailDelegate?.dropCoordinate(coordinate: coordinate, requestName: "")
        self.dismiss(animated: true)
    }
    
    private func setupTableView(){
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "directionTable")
        
    }
    
    private func setupView(){
        view.addSubview(detailsOfPlace)
        view.addSubview(firstTextField)
        view.addSubview(secondTextField)
        view.addSubview(table)
        view.addSubview(directionCollectionView)
        
        detailsOfPlace.addTarget(self, action: #selector(didTapShowDetailOfPlace), for: .touchUpInside)
        
        view.backgroundColor = .secondarySystemBackground
        coreData.loadData()
        firstTextField.delegate = self
        secondTextField.delegate = self
        let vc = SearchViewController()
        vc.delegate = self
    }
    
    private func setupNavigationBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.down")!, landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .black
        title = "Настройка маршрута"
    }
    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSizeMake(view.frame.size.width/3, 60)
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        directionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        directionCollectionView.backgroundColor = view.backgroundColor
        directionCollectionView.showsHorizontalScrollIndicator = false
        directionCollectionView.dataSource = self
        directionCollectionView.delegate = self
        directionCollectionView.register(SetDirectionCollectionViewCell.self,
                                         forCellWithReuseIdentifier: SetDirectionCollectionViewCell.identifier)
        directionCollectionView.isUserInteractionEnabled = true
        directionCollectionView.contentInsetAdjustmentBehavior = .automatic
    }
}

extension SetDirectionViewController: SearchControllerDelegate {
    func passSearchResult(coordinates: CLLocationCoordinate2D, placemark: MKPlacemark?,tagView: Int) {
        print(coordinates.latitude)
        print(placemark?.title! as Any)
        print(tagView)
        if let placemark = placemark?.name, !placemark.isEmpty {
            if tagView == 0 {
                firstTextField.text = placemark
                firstTextField.inputViewController?.dismissKeyboard()
                directionData?.userCoordinate = coordinates
                directionData?.userAddress = placemark
            } else if tagView == 1 {
                secondTextField.text = placemark
                secondTextField.inputViewController?.dismissKeyboard()
                directionData?.destinationCoordinate  = coordinates
                directionData?.destinationAddress = placemark
            }
        } else if tagView == 0{
                firstTextField.text = "📍Пользовательская локация "
                directionData?.destinationCoordinate  = coordinates
        }
    }
}

extension SetDirectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        secondTextField.resignFirstResponder()
        if let text = secondTextField.text, !text.isEmpty {
            //метод делегирования данных на главный вью
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let vc = SearchViewController()
        if textField.tag == 0 {
            guard let data = directionData?.userCoordinate else { return }
            let location = CLLocation(latitude: data.latitude, longitude: data.longitude)
            vc.searchValue = SearchData(someLocation: location, indicatorOfView: true,mapView: directionData!.mapViewDirection,tagView: textField.tag)
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .automatic
            nav.sheetPresentationController?.detents = [.custom(resolver: { context in
                return 400
            })]
            nav.sheetPresentationController?.prefersGrabberVisible = false
            nav.isNavigationBarHidden = false
            self.view.endEditing(true)
            present(nav, animated: true)
        } else {
            guard let data = directionData?.destinationCoordinate else { return }
            let location = CLLocation(latitude: data.latitude, longitude: data.longitude)
            vc.searchValue = SearchData(someLocation: location, indicatorOfView: true,mapView: directionData!.mapViewDirection,tagView: textField.tag)
            vc.delegate = self
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            nav.sheetPresentationController?.detents = [.custom(resolver: { context in
                return 400
            })]
            nav.sheetPresentationController?.prefersGrabberVisible = false
            nav.isNavigationBarHidden = false
            self.view.endEditing(true)
            present(nav, animated: true)
            
        }
    }
    
    
}


//коллекции с выбором варианта маршрута
extension SetDirectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dictionaryOfType.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetDirectionCollectionViewCell.identifier, for: indexPath) as! SetDirectionCollectionViewCell
        let key = Array(dictionaryOfType.keys.sorted())[indexPath.row]
        let value = dictionaryOfType[key]
        cell.configureCell(title: key, image: value!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print(indexPath.row)
        let cell = collectionView.cellForItem(at: indexPath) as! SetDirectionCollectionViewCell
        guard let userLoc = directionData?.userCoordinate,
              let destLoc = directionData?.destinationCoordinate,
              let text = cell.typeOfSetDirection.text else {
            return SPAlert.present(message: "Ошибка передачи данных\nПопробуйте еще раз", haptic: .none)
        }
        self.delegate?.getDataForDirection(user: userLoc, destination: destLoc, type: text)
        self.dismiss(animated: true)
        
    }
}

extension SetDirectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coreData.vaultData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Избранные места 🔖"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "directionTable",for: indexPath)
        let data = coreData.vaultData[indexPath.row]
        cell.textLabel?.text = data.place
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = coreData.vaultData[indexPath.row]
        let location = CLLocationCoordinate2D(latitude: cell.latitude, longitude: cell.longitude)
        secondTextField.text = cell.place
        directionData?.destinationCoordinate = location
        directionData?.destinationAddress = cell.place
        print(cell.place)
    }
}
