//
//  CardViewController.swift
//  M19
//
//  Created by Александра Угольнова on 02.10.2023.
//

import Foundation
import UIKit
import SnapKit
import CoreData

protocol CardViewControllerDelegate: AnyObject {
    func didSaveFilmData()
}

class CardViewController: UIViewController{
    
    
    
    weak var delegate: CardViewControllerDelegate?
    var context: NSManagedObjectContext?
    var film: SavedFilms?
    
    
    var movieDetail: MovieDetail?



    
    private lazy var nameRussia : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui20Semi
        return label
    }()
    private lazy var nameOr : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui20Reg
        return label
    }()
    private lazy var ratingKino : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui16Reg
        return label
    }()
    private lazy var Kino : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui16Reg
        label.text = "Кинопоиск"
        return label
    }()
    private lazy var ratingIm : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui16Reg
        return label
    }()
    private lazy var IMD: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui16Reg
        label.text = "IMDB"
        return label
    }()
    private lazy var labelYear : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui16Light
        return label
    }()
    private lazy var labelYearText : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.greyDark
        label.font = Constants.Fonts.ui16Light
        label.text = "Год производства"
        return label
    }()
    private lazy var labelfilmLength : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui16Light
        return label
    }()
    private lazy var labelLengthText : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.greyDark
        label.font = Constants.Fonts.ui16Light
        label.text = "Продолжительность"
        return label
    }()

    private lazy var labelDescription : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.Colors.Title
        label.font = Constants.Fonts.ui16Light
        label.numberOfLines = 0
        return label
    }()
    
    

    private lazy var filmImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Constants.Colors.greyLight
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUpViews()
        setUpConstraints()
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        
        let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores { storeDescription, error in
                if let error = error {
                    fatalError("Не удалось загрузить хранилище данных: \(error)")
                }
        }
        let context = container.viewContext
        self.context = context

    }
    
    @objc func saveButtonTapped() {
        
        guard let context = context else {
               print("Ошибка: context равен nil.")
               return
           }
        
        let uniqueIdentifier = "\(nameRussia.text ?? "")_\(labelYear.text ?? "")"
        let request: NSFetchRequest<SavedFilms> = SavedFilms.fetchRequest()
            request.predicate = NSPredicate(format: "uniqueIdentifier == %@", uniqueIdentifier)
            do {
                let existingFilms = try context.fetch(request)
                
                if existingFilms.first != nil {
                    let alertController = UIAlertController(title: "Ошибка", message: "Фильм уже сохранен", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                    return
                }
            } catch {
                print("Ошибка при проверке существующего фильма: \(error.localizedDescription)")
            }
            
        if film == nil {
            film = SavedFilms(context: context)
        }
        film?.length = labelfilmLength.text
        film?.nameOr = nameOr.text
        film?.nameRU = nameRussia.text
        film?.descript = labelDescription.text
        film?.ratIMBD = ratingIm.text
        film?.ratKino = ratingKino.text
        film?.image = movieDetail?.posterUrl
        film?.uniqueIdentifier = uniqueIdentifier
        
        do {
            try film?.managedObjectContext?.save()
            print("Данные успешно сохранены")
            delegate?.didSaveFilmData()
            let alertController = UIAlertController(title: "Успешно", message: "Фильм сохранен", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } catch {
            print("Ошибка сохранения данных: \(error.localizedDescription)")
        }
        navigationController?.popViewController(animated: true)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func loadMovieDetails(link: String) {
        guard let baseURL = URL(string: link) else {
            return
        }
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        request.setValue("7261c4f1-a382-44a7-9ba2-466323962811", forHTTPHeaderField: "X-API-KEY")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let movieDetail = try decoder.decode(MovieDetail.self, from: data)
                    
                    self.movieDetail = movieDetail
                    
                    DispatchQueue.main.async {
                        self.updateUIWithMovieDetail()
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }

    private func updateUIWithMovieDetail() {
        guard let movieDetail=self.movieDetail else {
            return
        }
        
        nameRussia.text = movieDetail.nameRu
        nameOr.text = movieDetail.nameOriginal
        ratingKino.text = "\(movieDetail.ratingKinopoisk)"
        ratingIm.text = "\(movieDetail.ratingImdb)"
        labelYear.text = "\(movieDetail.year)"
        labelfilmLength.text = "\(movieDetail.filmLength) мин"
        labelDescription.text = movieDetail.description
        
        if let imageUrl = URL(string: movieDetail.posterUrl) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.filmImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
    
    private func setUpConstraints() {
        
        filmImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo((view.frame.width - 60) / 2)
            make.height.equalTo(300)
        }

        
        Kino.snp.makeConstraints { make in
            make.top.equalTo(filmImage.snp.top).offset(20)
            make.leading.equalTo(filmImage.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        ratingKino.snp.makeConstraints { make in
            make.top.equalTo(Kino.snp.bottom).offset(20)
            make.leading.equalTo(filmImage.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        IMD.snp.makeConstraints { make in
            make.top.equalTo(ratingKino.snp.bottom).offset(30)
            make.leading.equalTo(filmImage.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        ratingIm.snp.makeConstraints { make in
            make.top.equalTo(IMD.snp.bottom).offset(16)
            make.leading.equalTo(filmImage.snp.trailing).offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        nameRussia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(filmImage.snp.bottom).offset(10)
        }
        
        nameOr.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameRussia.snp.bottom).offset(5)
        }
        
        labelDescription.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(nameOr.snp.bottom).offset(20)
        }
        
        labelYearText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(labelDescription.snp.bottom).offset(20)
        }
        
        labelYear.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(labelYearText.snp.bottom).offset(5)
        }
        
        labelLengthText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(labelYear.snp.bottom).offset(20)
        }
        
        labelfilmLength.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(labelLengthText.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
    }


    
    private func setUpViews(){
        view.addSubview(labelYear)
        view.addSubview(filmImage)
        view.addSubview(labelfilmLength)
        view.addSubview(nameRussia)
        view.addSubview(nameOr)
        view.addSubview(ratingIm)
        view.addSubview(ratingKino)
        view.addSubview(labelDescription)
        view.addSubview(Kino)
        view.addSubview(IMD)
        view.addSubview(labelYearText)
        view.addSubview(labelLengthText)
    }
    
   
}
