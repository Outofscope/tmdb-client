//
//  DetailsController.swift
//  Movies
//
//  Created by Konstantin Medvedenko on 29.11.2020.
//

import UIKit
import Kingfisher

class DetailsController: UIViewController {
    
    var movie: DisplayedMovie?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!

    private var api: ApiClient {
        (UIApplication.shared.delegate as! AppDelegate).api
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateInitial()
        requestDetails()
    }
    
    
    // MARK: -
    
    private func updateInitial() {
        
        runtimeLabel.isHidden = true
        budgetLabel.isHidden = true
        revenueLabel.isHidden = true

        if let movie = movie {
            title = movie.title
            titleLabel.text = movie.title
            overviewLabel.text = movie.overview
            releaseDateLabel.text = movie.releaseDate != nil ? DateHelper.formattedDate(withStr: movie.releaseDate!) : nil
            
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
    
    private func requestDetails() {
        guard let movieId = movie?.id else {
            return
        }
        
        api.requestDetails(movieId: movieId) { [weak self = self] (details, error) in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                if let runtime = details?.runtime, runtime > 0 {
                    self.runtimeLabel.text = "\(runtime) min."
                    self.runtimeLabel.isHidden = false
                }
                
                if let budget = details?.budget, budget > 0 {
                    self.budgetLabel.text = "Budget: $\(budget)"
                    self.budgetLabel.isHidden = false
                }
                
                if let revenue = details?.revenue, revenue > 0 {
                    self.revenueLabel.text = "Revenue: $\(revenue)"
                    self.revenueLabel.isHidden = false
                }
            }
        }
    }
}
