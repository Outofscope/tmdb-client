//
//  SearchResultsController.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 29.11.2020.
//

import UIKit
import Kingfisher

class SearchResultsController: UITableViewController {
        
    private var activityIndicator = UIActivityIndicatorView()
    private var endLabel = UILabel()

    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var debouncedSearch: () -> Void = {
        debounce(interval: Config.searchDebounceInterval,
                 queue: .main) { [weak self = self] in
            
            guard let self = self else {
                return
            }
            
            self.searchManager.search(self.searchController.searchBar.text ?? "") { error in
                
            }
        }
    }()
    
    lazy var searchManager: SearchManager = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let manager = SearchManager(api: appDelegate.api)
        manager.delegate = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MovieCell", bundle: nil),
                           forCellReuseIdentifier: MovieCell.cellId)
        
        setupActivityIndicator()
        setupSearchController()
        
        updateActivityIndicator()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailsController, let indexPath = sender as? IndexPath {
            
            let movie = searchManager.movie(atIndex: indexPath.row)
            vc.movie = DisplayedMovie(movie: movie)
        }
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchManager.movieCount
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        requestNextPageIfNeeded(indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.cellId, for: indexPath)

        let movie = searchManager.movie(atIndex: indexPath.row)
        
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = (movie.popularity ?? 0) > 0 ? "Popularity: \(movie.popularity!)" : nil
        
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
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        activityIndicator.style = .large
        activityIndicator.frame = CGRect(x: 0,
                                         y: 0,
                                         width: UIScreen.main.bounds.width,
                                         height: Config.activityIndicatorSize)
                
        //
        
        endLabel.textAlignment = .center
        endLabel.textColor = .secondaryLabel
        endLabel.text = "That's all"
        
        endLabel.frame = activityIndicator.frame
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    private func requestNextPageIfNeeded(_ row: Int) {
        if row >= searchManager.movieCount - 1 - Config.nextPageThreshold {
            searchManager.fetchNextPageIfNeeded { _ in 
                
            }
        }
    }
    
    private func debounce(interval: TimeInterval,
                          queue: DispatchQueue,
                          action: @escaping (() -> Void)) -> () -> Void {
        
        var lastFireTime = DispatchTime.now()
        let dispatchDelay = DispatchTimeInterval.milliseconds(Int(interval * 1000))

        return {
            lastFireTime = DispatchTime.now()
            let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay

            queue.asyncAfter(deadline: dispatchTime) {
                let when: DispatchTime = lastFireTime + dispatchDelay
                let now = DispatchTime.now()
                if now.rawValue >= when.rawValue {
                    action()
                }
            }
        }
    }
    
    private func updateActivityIndicator() {
        if searchManager.hasMoreResults {
            tableView.tableFooterView = activityIndicator
            activityIndicator.startAnimating()
        } else {
            tableView.tableFooterView = endLabel
            activityIndicator.stopAnimating()
        }
    }
}


extension SearchResultsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        debouncedSearch()
    }
}


extension SearchResultsController: SearchManagerDelegate {
    func searchManagerDidUpdateResults() {
        updateActivityIndicator()
        tableView.reloadData()
    }
}
