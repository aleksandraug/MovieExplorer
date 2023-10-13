//
//  cellCLass.swift
//  M19
//
//  Created by Александра Угольнова on 02.10.2023.
//

import Foundation
import UIKit

class cellClass: UITableViewCell {
    
     lazy var labelText : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont(name: "Inter-SemiBold", size: 30)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

     lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .gray

        return imageView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(labelText)

        return stackView
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        setupConstraints()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        image.image = nil
    }



    private func setupConstraints(){
       
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        image.heightAnchor.constraint(equalToConstant: 50).isActive = true
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }

}
