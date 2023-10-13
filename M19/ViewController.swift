//
//  ViewController.swift
//  M19
//
//  Created by Александра Угольнова on 02.10.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    
    private lazy var kinoLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Киношки"
        label.font = .systemFont(ofSize: 42, weight: .bold)
        return label
    }()
    
    private let Button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Начать", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        return button
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        view.addSubview(Button)
        view.addSubview(kinoLabel)
        Button.addTarget(self,
                         action: #selector(didTapButton),
                         for: .touchUpInside)
        setupConstraints()
    }
    
    private func setupConstraints() {
        kinoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
        }
        
        Button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
    }
    
  
    
    @objc func didTapButton(){
        let tabBarVC = UITabBarController()
        
        let vc1 = UINavigationController(rootViewController: FilmsViewController())
      
        let vc2 = UINavigationController(rootViewController: SavedViewController())
      
    
        
        tabBarVC.setViewControllers([vc1, vc2], animated: false)
        tabBarVC.tabBar.backgroundColor = .orange
        tabBarVC.tabBar.tintColor = nil
        
        guard let items = tabBarVC.tabBar.items else{
            return
        }
        let images = ["film.stack", "heart"]
        
        for x in 0..<items.count{
            items[x].image=UIImage(systemName: images[x])
        }
        
        
        tabBarVC.modalPresentationStyle = .fullScreen
        
        present(tabBarVC, animated: true)
    }
 
    


}
