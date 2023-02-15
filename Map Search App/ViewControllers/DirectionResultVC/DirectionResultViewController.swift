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
    
    private let directionTable = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupView()
        setupTableView()
    }
    
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        testLabel.frame = CGRect(x: 10, y: 50, width: view.frame.size.width-20, height: 55)
        directionTable.frame = CGRect(x: 10, y: view.safeAreaInsets.top+10, width: view.frame.size.width-20, height: 180)
    }
    
    @objc private func didTapStartDirection(){
        
    }
    
    private func setupView(){
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(directionTable)
    }
    
    private func setupNavigationBar(){
        title = "Result of directions"
    }
    
    private func setupTableView(){
        directionTable.register(UITableViewCell.self, forCellReuseIdentifier: "cellDistanceResult")
        directionTable.delegate = self
        directionTable.dataSource = self
        directionTable.backgroundColor = .systemBackground
        directionTable.separatorStyle = .none
        directionTable.layer.cornerRadius = 8
        directionTable.scrollsToTop = false
        directionTable.isScrollEnabled = false
    }
    
    private func getDistance(data: DirectionResultStruct) -> String{
        var text = String()
       if let route = data.responseDirection.routes.first {
            let text = mapTools.getDistanceBetweenPoints(route: route)
            testLabel.text = text
       }
        return text
    }
    
}

extension DirectionResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    //сделать кастомную строку для отображения лейбла, доплейбла и кнопки
    //на каждую строку сделать массив с дистанцией, временем и плейсмарком, чтобы для выбора конкретной строки пользователь мог выбрать наиболее короткий или удобный маршрут
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellDistanceResult",for: indexPath)
    
        cell.imageView?.image = UIImage(systemName: "arrow.triangle.turn.up.right.diamond")
        cell.textLabel?.text = "Check label"
        cell.detailTextLabel?.text = "Check detail label"
//        cell.textLabel?.text = getDistance(data: routeData!)
//        cell.textLabel?.font = .systemFont(ofSize: 16,weight: .heavy)
//        cell.detailTextLabel?.text = "Displaying distance"
//        let button = UIButton(type: .system)
//        button.backgroundColor = .systemGreen
//        button.titleLabel?.text = "Начать"
//        button.layer.cornerRadius = 8
//        button.tag = indexPath.row
////        button.titleLabel?.font = .systemFont(ofSize: 12,weight: .medium)
//        button.frame = CGRect(x: cell.frame.size.width-60, y: 10, width: 40, height: 40)
//        button.addTarget(self, action: #selector(didTapStartDirection), for: .touchUpInside)
//        cell.accessoryView = button as UIView
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
