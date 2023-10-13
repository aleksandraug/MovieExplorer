//
//  SavedViewController.swift
//  M19
//
//  Created by Александра Угольнова on 11.10.2023.
//
import UIKit
import SnapKit
import Foundation
import CoreData

class SavedViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {
    
    private var refreshControl = UIRefreshControl()
    let cellViewModel = "cellViewModel"

    var film: SavedFilms?

    private let persistentContainer = NSPersistentContainer(name: "Model")
    
    
    private lazy var fetchedResultController: NSFetchedResultsController<SavedFilms> = {
        
        let fetchRequest: NSFetchRequest<SavedFilms> = SavedFilms.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        do {
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            print("Количество записей в базе данных: \(count)")
        } catch {
            print("Ошибка при выполнении запроса: \(error.localizedDescription)")
        }
        
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self

        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error)
        }

        return fetchedResultController
    }()

    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(cellClass.self , forCellReuseIdentifier: cellViewModel)
        tableView.rowHeight = 200
        tableView.addSubview(refreshControl)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        setUpViews()
        setUpConstraints()
    }
    @objc func refreshData() {
        refreshControl.endRefreshing()
        tableView.reloadData()
        
    }
    
    
    
    private func setUpViews(){
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        persistentContainer.loadPersistentStores{ (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to load")
                print("\(error), \(error.localizedDescription)")
            } else {
                do{
                    try self.fetchedResultController.performFetch()
                } catch{
                    print(error)
                }
            }
            
        }
    }
    
    private func setUpConstraints(){
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
    
    
extension SavedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let film = fetchedResultController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel, for: indexPath) as! cellClass
        cell.labelText.text = film.nameRU
        
        if let imageURLString = film.image, let imageURL = URL(string: imageURLString) {
            let session = URLSession.shared
            let task = session.dataTask(with: imageURL) { data, _, error in
                if let error = error {
                    print("Ошибка при загрузке изображения: \(error)")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.image.image = image
                    }
                }
            }
            task.resume()
        } else {
            DispatchQueue.main.async {
                cell.image.image = UIImage(named: "placeholderImage")
            }
        }
        
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if let sections = fetchedResultController.sections {
              return sections[section].numberOfObjects
          }
          return 0
    }
        
        
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let film = fetchedResultController.object(at: indexPath)
                persistentContainer.viewContext.delete(film)
                try? persistentContainer.viewContext.save()
            }
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let vc = SavedCardViewController()
            vc.context = persistentContainer.viewContext
            vc.film = fetchedResultController.object(at: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
}

extension SavedViewController: NSFetchedResultsControllerDelegate{
    

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

}

extension SavedViewController: CardViewControllerDelegate {
    func didSaveFilmData() {
      print("didSaveMusicData called")
      tableView.reloadData()
    }
}
