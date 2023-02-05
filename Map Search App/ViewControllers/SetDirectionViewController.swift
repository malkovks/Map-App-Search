//
//  SetDirectionViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 03.02.2023.
//

import Foundation
import UIKit
import MapKit

protocol SetDirectionProtocol: AnyObject{
    func getDataForDirection(user coordinate: CLLocationCoordinate2D,_ destination: CLLocationCoordinate2D,direction type: String)
}

class SetDirectionViewController: UIViewController {
    
    var directionData: SetDirectionData? //сюда сохраняются данные из map view для делегирования их на карту обратно
    
    weak var delegate: SetDirectionProtocol?
    
    private let geocoder = CLGeocoder()
    
    let dictionaryOfType: [String:UIImage] = ["Автомобиль":UIImage(systemName: "car")!
                                              ,"Пешком":UIImage(systemName: "figure.walk")!
                                              ,"Велосипед":UIImage(systemName: "bicycle")!
                                              ,"Транспорт":UIImage(systemName: "bus")!]
    
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
    
    private var directionCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigationBar()
        setupView()
        guard let location = directionData?.destinationCoordinate else { return }
        guard let user = directionData?.userCoordinate else { return }
        setupTextFields(first: user, second: location)
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sArea = view.safeAreaInsets.top
        firstTextField.frame = CGRect(x: 10, y: 10+sArea, width: view.frame.size.width-20, height: 55)
        secondTextField.frame = CGRect(x: 10, y: 20+sArea+firstTextField.frame.size.height, width: view.frame.size.width-20, height: 55)
        directionCollectionView.frame = CGRect(x: 10, y: 30+sArea+firstTextField.frame.size.height+secondTextField.frame.size.height, width: view.frame.size.width-20, height: 100)
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    private func setupView(){
        view.addSubview(firstTextField)
        view.addSubview(secondTextField)
        view.addSubview(directionCollectionView)
        view.backgroundColor = .secondarySystemBackground
        firstTextField.delegate = self
        secondTextField.delegate = self
        let vc = SearchViewController()
        vc.delegate = self

//        GeocoderReturn.shared.convertFromGeocode(coordinate: location) { place in
//            self.firstTextField.text = place.streetName+" "+place.appNumber
//        }
    }
    
    private func setupTextFields(first: CLLocationCoordinate2D,second: CLLocationCoordinate2D){
        let firstLoc = CLLocation(latitude: first.latitude, longitude: first.longitude)
        let secLod = CLLocation(latitude: second.latitude, longitude: second.longitude)
        guard let firstMark = parseGeolocation(location: firstLoc) else { return }
        guard let secondMark = parseGeolocation(location: secLod) else { return }
        firstTextField.text = firstMark.thoroughfare ?? "" + " " + (firstMark.subThoroughfare ?? "")
        secondTextField.text = secondMark.thoroughfare ?? "" + " " + (secondMark.subThoroughfare ?? "")
    }
    
    private func parseGeolocation(location: CLLocation) -> CLPlacemark?{
        var returnPlacemark: CLPlacemark?
//        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemark, error in
            guard let placemark = placemark?.first, error != nil else { return }
        }
        print(returnPlacemark?.thoroughfare)
        return returnPlacemark
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
        directionCollectionView.register(SetDirectionCollectionViewCell.self, forCellWithReuseIdentifier: SetDirectionCollectionViewCell.identifier)
        directionCollectionView.isUserInteractionEnabled = true
        directionCollectionView.contentInsetAdjustmentBehavior = .automatic
    }
}

extension SetDirectionViewController: SearchControllerDelegate {
    func passSearchResult(coordinates: CLLocationCoordinate2D, placemark: MKPlacemark,tagView: Int) {
        
        if !placemark.name!.isEmpty {
            print("Delegate work fine")
            if tagView == 0 {
                firstTextField.text = placemark.name
            } else if tagView == 1 {
                secondTextField.text = placemark.name
            }
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
            present(nav, animated: true)
        }
    }
    
    
}



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
        let cell = collectionView.cellForItem(at: indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        
        
//        var transport = TypeOfDirection.Car
//        switch transport {
//        case .Car :
//            print("car")
//        case .Bysicle:
//            print("bisycle")
//        case .Walking:
//            print("walking")
//        }
    }
}

enum TypeOfDirection {
    case Car
    case Walking
    case Bysicle
}
