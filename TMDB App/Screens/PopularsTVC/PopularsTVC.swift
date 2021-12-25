//
//  MoviesTableViewController.swift
//  TMDB App
//
//  Created by Eden Chen on 10/12/2021.
//

import UIKit

class PopularsTVC: UITableViewController {
    
    let getPopularRoot = "popular?api_key="
    
    var selectedMovie: MovieModel?
    var movies: [MovieModel] = []
    
    let viewModel = TableViewModels()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        navigationItem.title = "Populars"
        viewModel.setTableView(tableView: tableView)
        
        viewModel.getMoviesToView(methodRoot: getPopularRoot, tableView: tableView)
        movies = viewModel.movies
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.movies.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieTableViewCell
        
        cell.titleLabel?.text = viewModel.movies[indexPath.row].title
        let urlString = NetworkManager.shared.posterRootURL + viewModel.movies[indexPath.row].posterPath
        NetworkManager.shared.downloadImages(from: urlString, indexPath: indexPath, tableView: tableView)
        
        let image = NetworkManager.shared.image
        cell.movieImage?.image = image
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovie = viewModel.movies[indexPath.row]
        if selectedMovie != nil {
            let detailsVC = DetailsViewController()
            detailsVC.selectedMovie = selectedMovie!
            self.navigationController!.pushViewController(detailsVC, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Something went wrong", message: "Something went wrong please try again later", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okButton)
            present(alert, animated: true)
        }
    }
        
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            if viewModel.isLoading == false {
                viewModel.startLoading(view: tableView)
                tableView.isUserInteractionEnabled = false
                NetworkManager.shared.page += 1
                viewModel.getNextPageOfMovies(methodRoot: getPopularRoot, tableView: tableView)
                movies += viewModel.movies
                
                DispatchQueue.main.async { [self] in
                    viewModel.stopLoading()
                    tableView.isUserInteractionEnabled = false
                    tableView.reloadData()
                }
            }
        }
    }
    
}
