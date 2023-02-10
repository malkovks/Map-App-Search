//
//  DirectionResultViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 08.02.2023.
//
//контроллер для отображения данных после установления маршрута
//возможно следует использовать Floating Panel для удобства работы с двумя вью одновременно
//или почитать про то, как добавлять два вью на один
import UIKit
import MapKit

protocol ReturnResultOfDirection: AnyObject {
    func passChoise(data: DirectionResultStruct, boolean: Bool,count choosenPolyline: Int)
}

struct DirectionResultStruct {
    let startCoordinate: CLLocationCoordinate2D
    let finalCoordinate: CLLocationCoordinate2D
    let responseDirection: MKDirections.Response
    let typeOfDirection: String
}

class DirectionResultViewController: UIViewController {

    weak var delegate: ReturnResultOfDirection?
    
    var routeData: DirectionResultStruct?
    
    private let converter = MapDataConverter.instance
    private let mapTools = MapIntruments.instance
    
    private let testLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 30,weight: .bold)
        label.text = ""
        label.textColor = .systemRed
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        testLabel.frame = CGRect(x: 10, y: 50, width: view.frame.size.width-20, height: 55)
    }
    
    private func setupView(){
        view.backgroundColor = .systemGray3
        view.addSubview(testLabel)
        guard let route = routeData?.responseDirection.routes.first else { return }
        let text = mapTools.getDistanceBetweenPoints(route: route)
        testLabel.text = text
    }
    
    private func setupNavigationBar(){
        title = "Result of directions"
    }



}
