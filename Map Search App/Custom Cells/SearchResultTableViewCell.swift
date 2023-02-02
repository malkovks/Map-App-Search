//
//  SearchResultTableViewController.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//

import Foundation
import UIKit
import MapKit

class SearchResultTableViewCell: UITableViewCell {
 
    static let identifier = "SearchResultTableViewCell"
    private let geocoder = CLGeocoder()
    private let coredata = PlaceEntityStack.instance
    
    var coordinatesForSaving: CLLocationCoordinate2D?
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.contentMode = .topLeft
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "Place name and other"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.contentMode = .topLeft
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.text = "Place name and other"
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.contentMode = .left
        label.font = .systemFont(ofSize: 14,weight: .light)
        label.text = "0.0 m."
        return label
    }()
    
    let detailButtonOnCell: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .black
        button.showsMenuAsPrimaryAction = true
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(detailButtonOnCell)
        detailButtonOnCell.addTarget(self, action: #selector(didTapCellDetailButtonTest), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 5, y: 5, width: contentView.frame.size.width-75, height: 20)
        subtitleLabel.frame = CGRect(x: 5, y: 25, width: contentView.frame.size.width-45, height: 45)
        distanceLabel.frame = CGRect(x: contentView.frame.size.width-50, y: 5, width: 45, height: 20)
        detailButtonOnCell.frame = CGRect(x: contentView.frame.size.width-40, y: 5, width: 40, height: 60)
    }
    
    @objc private func didTapCellDetailButtonTest(){
        let tag = detailButtonOnCell.tag
        let menu = UIMenu(title: "",options: .displayInline,children: [
            UIAction(title: "Delete",image: UIImage(systemName: "trash"),attributes: .destructive, handler: { _ in
                
            }),
            UIAction(title: "Add To Favourite",image: UIImage(systemName: "star.fill"), handler: { _ in
                let date = DateClass.dateConverter()
                if let location = self.coordinatesForSaving {
                    self.coredata.saveData(lat: location.latitude, lon: location.longitude, date: date, name: "Second Test")
                }
                
            }),
            UIAction(title: "Show on map",image: UIImage(systemName: "mappin.square.fill"), handler: { _ in
                
            })
        ])
        detailButtonOnCell.menu = menu
        print(tag)
    }
    

    
    private func alternativeParseData(customMark: MKPlacemark) -> String {
        
        let addressLine = "\(customMark.thoroughfare ?? ""), \(customMark.subThoroughfare ?? "")\n\(customMark.administrativeArea ?? "Название города отсутствует"),  \(customMark.country ?? "")"
        return addressLine
    }
    
    func configureCell(placemark: MKPlacemark){
        distanceLabel.isHidden = true
        let subtitleInfo = alternativeParseData(customMark: placemark)
        titleLabel.text = placemark.name
        subtitleLabel.text = subtitleInfo
    }
    
    func configureDistanceForCell(distance: String?) {
        distanceLabel.isHidden = false
        distanceLabel.text = distance
    }
    
    func configureCell(with model: SearchHistory){
        distanceLabel.isHidden = true
        let location = CLLocation(latitude: model.langitude, longitude: model.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemark, error in
            guard let placemark = placemark?.first else { return }
            let mkplacemark = MKPlacemark(placemark: placemark)
            let subtitle = self?.alternativeParseData(customMark: mkplacemark)
            DispatchQueue.main.async {
                self?.titleLabel.text = model.nameCategory ?? "🛑"
                self?.subtitleLabel.text = subtitle
            }
        }
    }
}

