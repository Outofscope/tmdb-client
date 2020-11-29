//
//  PopularController.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 28.11.2020.
//

import UIKit
import CoreData
import Kingfisher

class PopularController: UITableViewController {
    
    lazy var storageManager: StorageManager = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container = appDelegate.persistentContainer
        
        let manager = StorageManager(api: appDelegate.api,
                                     container: container)
        
        return manager
    }()
    
    lazy var fetchResultsController: NSFetchedResultsController<StoredMovie> = {
        
        let request: NSFetchRequest<StoredMovie> = StoredMovie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nsError = error as NSError
            print("Core Data fetch error: \(nsError)")
        }
        
        return controller
    }()
    
    //
    
    private var activityIndicator = UIActivityIndicatorView()
    private var endLabel = UILabel()
    
    private var totalCount: Int {
        let totalCount: Int
        
        if fetchResultsController.sections?.count == 1 {
            totalCount = fetchResultsController.sections![0].numberOfObjects
        } else {
            totalCount = 0
        }
        
        return totalCount
    }

    //

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MovieCell", bundle: nil),
                           forCellReuseIdentifier: MovieCell.cellId)
        
        //
        
        setupActivityIndicator()
        updateActivityIndicator()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailsController, let indexPath = sender as? IndexPath {
            
            let movie = fetchResultsController.object(at: indexPath)
            vc.movie = DisplayedMovie(storedMovie: movie)
        }
    }
        
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = fetchResultsController.sections?[section].numberOfObjects ?? 0
        
        if number == 0 {
            requestNextPageIfNeeded(0)
        }
        
        return number
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        requestNextPageIfNeeded(indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.cellId, for: indexPath)
        
        let movie = fetchResultsController.object(at: indexPath)
        
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.popularity > 0 ? "Popularity: \(movie.popularity)" : nil
        
        if let posterPath = movie.posterPath {
            let url = URL(string: Config.posterSizeThumb + posterPath,
                          relativeTo: Config.imageBaseUrl)
            cell.imageView?.kf.setImage(with: url, completionHandler: { result in
                cell.setNeedsLayout()
            })
        } else {
            cell.imageView?.kf.setImage(with: nil as ImageDataProvider?)
        }
        
        return cell
    }
    
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Details", sender: indexPath)
    }
    
    
    // MARK: -
    
    func alert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    func requestNextPageIfNeeded(_ row: Int) {
        if row >= totalCount - 1 - Config.nextPageThreshold {
            storageManager.fetchNextDiscoverPageIfNeeded()
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.style = .large
        activityIndicator.frame = CGRect(x: 0,
                                         y: 0,
                                         width: Config.activityIndicatorSize,
                                         height: Config.activityIndicatorSize)
                
        //
        
        endLabel.textAlignment = .center
        endLabel.textColor = .secondaryLabel
        endLabel.text = "That's all"
        
        endLabel.frame = activityIndicator.frame
    }
    
    private func updateActivityIndicator() {
        if storageManager.hasMoreDiscoverResults {
            tableView.tableFooterView = activityIndicator
            activityIndicator.startAnimating()
        } else if totalCount > 0 {
            tableView.tableFooterView = endLabel
            activityIndicator.stopAnimating()
        } else {
            tableView.tableFooterView = nil
            activityIndicator.stopAnimating()
        }
    }
}


extension PopularController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateActivityIndicator()
        tableView.reloadData()
    }
}
