//
//  ResultCollectionViewCell.swift
//  Map Search App
//
//  Created by Константин Малков on 29.01.2023.
//

import Foundation
import UIKit

class ResultCollectionViewCell: UICollectionViewCell {
    static let identifier = "FavouriteCollectionViewCell"
    
    private let imageCollection: UIImageView = {
       let image = UIImageView()
        image.sizeToFit()
        image.contentMode = .scaleAspectFit
        image.tintColor = .darkGray
        image.image = UIImage(systemName: "xmark")
        return image
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.textAlignment = .center
        label.contentMode = .top
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageCollection)
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = .systemBackground
        contentView.isUserInteractionEnabled = true
        setupSizeOfItems()
    }
    
    private func setupSizeOfItems(){
        addSubview(titleLabel)
        addSubview(imageCollection)
        titleLabel.frame = CGRect(x: 0, y: 55, width: contentView.frame.size.width, height: 40)
        imageCollection.frame = CGRect(x: 1.5, y: 3, width: contentView.frame.size.width-3, height: contentView.frame.size.height-6-titleLabel.frame.size.height)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(title: String,image: UIImage){

        self.titleLabel.text = title
        self.imageCollection.image = image
    }
}
