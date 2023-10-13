//
//  FilmsViewController.swift
//  M19
//
//  Created by Александра Угольнова on 11.10.2023.
//

import UIKit
import SnapKit
import Foundation
import CoreData

class FilmsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, CardViewControllerDelegate {
    func didSaveFilmData() {
        print("didSaveMusicData called")
    }
    
    
    var context: NSManagedObjectContext?
    
    private var refreshControl = UIRefreshControl()

    private var apiResponse: APIResponse?
    private var newApiResponse: NewAPIResponse?
    
    private var apiResponseData: [Film] = []
    private var newApiResponseData: [NewFilm] = []
    private let persistentContainer = NSPersistentContainer(name: "Model")
    
    let cellViewModel = "cellViewModel"
    
    struct NewAPIResponse: Codable {
        let pagesCount: Int
        let films: [NewFilm]
    }

    struct NewFilm: Codable {
        let filmId: Int
        let nameRu: String
        let type: String?
        let year: String?
        let filmLength: String?
        let countries: [NewCountry]
        let genres: [NewGenre]
        let rating: String
        let ratingVoteCount: Int
        let posterUrl: String
        let posterUrlPreview: String?
        let ratingChange: String?
        let isRatingUp: String?
        let isAfisha: Int?
    }
    
    struct NewCountry: Codable {
        let countryName: String?
    }

    struct NewGenre: Codable {
        let genreName: String?
    }

    
    struct APIResponse: Codable {
        let keyword: String
        let pagesCount: Int
        let films: [Film]
        let searchFilmsCountResult: Int
    }

    struct Film: Codable {
        let filmID: Int?
        let nameRu: String?
        let nameEn: String?
        let type: String?
        let year: String?
        let description: String?
        let filmLength: String?
        let countries: [Country]
        let genres: [Genre]
        let rating: String
        let ratingVoteCount: Int
        let posterURL: String
        let posterURLPreview: String

        enum CodingKeys: String, CodingKey {
            case filmID = "filmId"
            case nameRu, nameEn, type, year, description, filmLength, countries, genres, rating, ratingVoteCount
            case posterURL = "posterUrl"
            case posterURLPreview = "posterUrlPreview"
        }
    }

    struct Country: Codable {
        let countryName: String?
    }

    struct Genre: Codable {
        let genreName: String?
    }

    private lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 40))
        textField.placeholder = "Введите запрос"
        textField.delegate = self
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var searchFilm: UIButton = {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 40)
            button.setTitle("Поиск фильма", for: .normal)
            button.tintColor = .white
            button.backgroundColor = .orange
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(searchURLButton), for: .touchUpInside)
            return button
    }()
        
    private lazy var popularFilm: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Популярные фильмы", for: .normal)
            button.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 40)
            button.backgroundColor = .orange
            button.tintColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(searchButton), for: .touchUpInside)
            return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    @objc func searchURLButton(){
        view.endEditing(true)
        print("Search button pressed")
        textField.text = textField.text?.lowercased()
        guard let searchText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty,
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("Search Text is empty or couldn't be encoded.")
                return
        }
        makeAPIRequest(link: "https://kinopoiskapiunofficial.tech/api/v2.1/films/search-by-keyword", keyword: searchText)
        popularFilm.isSelected = false
    }
    
    @objc func searchButton(){
        view.endEditing(true)
        print("Popular Films button pressed")
        newAPIRequest(link: "https://kinopoiskapiunofficial.tech/api/v2.2/films/top", keyword: "TOP_250_BEST_FILMS")
        popularFilm.isSelected = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(cellClass.self , forCellReuseIdentifier: cellViewModel)
        tableView.rowHeight = 200
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
        
        setUpViews()
        setUpConstraints()
    }
    

    
    @objc func refreshData(_ sender: UIRefreshControl) {
        if popularFilm.isSelected {
            newAPIRequest(link: "https://kinopoiskapiunofficial.tech/api/v2.2/films/top", keyword: "TOP_100_POPULAR_FILMS")
        } else {
            if let searchText = textField.text {
                makeAPIRequest(link: "https://kinopoiskapiunofficial.tech/api/v2.1/films/search-by-keyword", keyword: searchText)
            }
        }
        
        sender.endRefreshing()
    }
    
    private func setUpViews(){
        view.backgroundColor = UIColor.white
        view.addSubview(textField)
        view.addSubview(searchFilm)
        view.addSubview(popularFilm)
        view.addSubview(tableView)
    }
    
    private func setUpConstraints(){
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        searchFilm.snp.makeConstraints { make in
               make.top.equalTo(textField.snp.bottom).offset(20)
               make.leading.equalToSuperview().offset(20)
               make.width.equalTo((view.frame.width - 60) / 2)
               make.height.equalTo(40)
        }
           
        popularFilm.snp.makeConstraints { make in
               make.top.equalTo(textField.snp.bottom).offset(20)
               make.leading.equalTo(searchFilm.snp.trailing).offset(20)
               make.trailing.equalToSuperview().offset(-20)
               make.height.equalTo(40)
        }
        tableView.snp.makeConstraints { make in
               make.top.equalTo(searchFilm.snp.bottom).offset(20)
               make.leading.trailing.bottom.equalToSuperview() // Растянуть таблицу на всю доступную высоту
        }
    }
    
    private func makeAPIRequest(link: String, keyword: String) {
        
        
        guard let baseURL = URL(string: link) else {
            return
        }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "keyword", value: keyword)
        ]
        guard let url = components?.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("7261c4f1-a382-44a7-9ba2-466323962811", forHTTPHeaderField: "X-API-KEY")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }

            if let data = data {
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print(jsonString)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                let apiResponse = try decoder.decode(APIResponse.self, from: data)
                                self.apiResponse = apiResponse
                                self.apiResponseData = apiResponse.films
                                print("API Response: \(apiResponse)")
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            } catch {
                                print("Error decoding JSON: \(error)")
                            }
                        }else {
                            print("Что-то не так")
                        }
                     
            }
        }
        task.resume()
    }
    
    private func newAPIRequest(link: String, keyword: String) {
        
        
        guard let baseURL = URL(string: link) else {
            return
        }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "keyword", value: keyword)
        ]
        guard let url = components?.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("7261c4f1-a382-44a7-9ba2-466323962811", forHTTPHeaderField: "X-API-KEY")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }

            if let data = data {
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print(jsonString)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                            do {
                                let decoder = JSONDecoder()
                                let newApiResponse = try decoder.decode(NewAPIResponse.self, from: data)
                                self.newApiResponse = newApiResponse
                                self.newApiResponseData = newApiResponse.films
                                print("API Response: \(newApiResponse)")
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            } catch {
                                print("Error decoding JSON: \(error)")
                            }


                        }else {
                            print("Что-то не так")
                        }
                     
            }
        }
        task.resume()
    }
    
    


}

extension FilmsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if popularFilm.isSelected {
            return newApiResponseData.count
        } else {
            return apiResponseData.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel, for: indexPath) as! cellClass

        if popularFilm.isSelected {
            let film = newApiResponseData[indexPath.row]
            cell.labelText.text = film.nameRu
            if let url = URL(string: film.posterUrl) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.image.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        } else {
            let film = apiResponseData[indexPath.row]
            cell.labelText.text = film.nameRu
            if let url = URL(string: film.posterURL) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.image.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let CardVC = CardViewController()

        CardVC.delegate = self
        CardVC.context = persistentContainer.viewContext
          
        var filmID: Int
          
          if popularFilm.isSelected {
              filmID = newApiResponseData[indexPath.row].filmId
          } else {
              filmID = apiResponseData[indexPath.row].filmID ?? 0
          }
          
          let newLink = "https://kinopoiskapiunofficial.tech/api/v2.2/films/\(filmID)"
          
          CardVC.loadMovieDetails(link: newLink)
          
          navigationController?.pushViewController(CardVC, animated: true)
    }

}

