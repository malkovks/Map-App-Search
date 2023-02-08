//
//  SetDirectionCollectionViewCell.swift
//  Map Search App
//
//  Created by Константин Малков on 04.02.2023.
//

import UIKit

class SetDirectionCollectionViewCell: UICollectionViewCell {
    static let identifier = "SetDirectionCollectionViewCell"
    
    public let imageOfDirection: UIImageView = {
       let image = UIImageView()
        image.contentMode = .center

        image.tintColor = .systemBackground
        return image
    }()
    
    public let typeOfSetDirection: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textAlignment = .center
        label.textColor = .systemBackground
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageOfDirection)
        contentView.addSubview(typeOfSetDirection)
        setupSizeOfItems()
        contentView.backgroundColor = .systemBlue
        contentView.layer.cornerRadius = 24
    }
    
    private func setupSizeOfItems(){
        addSubview(imageOfDirection)
        addSubview(typeOfSetDirection)
        imageOfDirection.frame = CGRect(x: contentView.frame.size.width/6, y: 5, width: contentView.frame.size.width-contentView.frame.size.width/3, height: 30)
        typeOfSetDirection.frame = CGRect(x: contentView.frame.size.width/6, y: 40, width: contentView.frame.size.width-contentView.frame.size.width/3, height: 20)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(title: String,image: UIImage){
        self.typeOfSetDirection.text = title
        self.imageOfDirection.image = image
    
    }
    
}
