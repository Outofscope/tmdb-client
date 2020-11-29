//
//  DetailsController.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 29.11.2020.
//

import UIKit
import Kingfisher

class DetailsController: UIViewController {
    
    var storageManager: StorageManager?
    var movieId: Int64?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateAll()
    }
    
    // MARK: -
    
    private func updateAll() {
        if let movieId = movieId, let movie = storageManager?.storedMovie(forMovieId: movieId) {
            title = movie.title
            titleLabel.text = movie.title
            overviewLabel.text = movie.overview
            releaseDateLabel.text = movie.releaseDate
            
            if let posterPath = movie.posterPath {
                let url = URL(string: Config.posterSizeDetails + posterPath,
                              relativeTo: Config.imageBaseUrl)
                posterImageView.kf.setImage(with: url)
            } else {
                posterImageView.kf.setImage(with: nil as ImageDataProvider?)
            }
        } else {
            title = nil
            titleLabel.text = nil
            overviewLabel.text = nil
            releaseDateLabel.text = nil
            posterImageView.kf.setImage(with: nil as ImageDataProvider?)
        }
    }
}
