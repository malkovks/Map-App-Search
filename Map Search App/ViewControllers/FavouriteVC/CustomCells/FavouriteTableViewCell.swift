//
//  FavouriteTableViewCell.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//  

//MARK: - UNUSING

import Foundation
import UIKit
import MapKit

class FavouriteTableViewCell: UITableViewCell {
    static let identifier = "FavouriteTableViewCell"
    private let geocoder = CLGeocoder()
    
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
    
    private let detailButton : UIButton = {
       let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .systemGray4
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(detailButton)
//        detailButton.addTarget(self, action: #selector(didTapDetail), for: .touchUpInside)
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 5, y: 5, width: contentView.frame.size.width-30, height: 20)
        subtitleLabel.frame = CGRect(x: 5, y: 25, width: contentView.frame.size.width-30, height: 45)
    }
    //затестить и понять почему не работае класс наследования
    func configureCell(with model: PlaceEntity){
        let location = CLLocation(latitude: model.latitude, longitude: model.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemark, error in
            guard let placemark = placemark?.first else { return }
            let streetName = placemark.thoroughfare ?? "\n"
            let appNumber = placemark.subThoroughfare ?? ""
            let city = placemark.administrativeArea ?? ""
            let country = placemark.country ?? ""
            let areaOfInterest = String(describing: model.place!)
            DispatchQueue.main.async {
                if areaOfInterest.isEmpty {
                    self?.titleLabel.text = "\(streetName), д. \(appNumber)"
                    self?.subtitleLabel.text = "Регион: \(city), \(country).\nСохранено: \(model.date ?? "Ошибка")"
                } else {
                    self?.titleLabel.text = " \"\(areaOfInterest)\", улица: \(streetName), д. \(appNumber)"
                    self?.subtitleLabel.text = "Регион: \(city), \(country).\nСохранено: \(model.date ?? "Ошибка")"
                }
            }
        }
    }
}
