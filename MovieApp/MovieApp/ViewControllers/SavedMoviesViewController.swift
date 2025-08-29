//
//  SavedMoviesViewController.swift
//  MovieApp
//
//  Created by Sayed on 23/08/25.
//

import UIKit

class SavedMoviesViewController: UIViewController {

    @IBOutlet public var savedMoviesLabel: UILabel?
    @IBOutlet public var savedMoviesTableView: UITableView?
    public var bookmarkedMovie: [MovieItemDataUIModel]?
    private var addRemoveMovieViewModel: AddMovieViewModel?
    private var bookmarkedListViewModel: BookmarkedListViewModel?
    let screenHeight = UIScreen.main.bounds.height
    var selectedMovieId: Int? = -1
    @IBOutlet public var tableHeightConst: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        addRemoveMovieViewModel = AddMovieViewModel(delegate: self, component: self)
        bookmarkedListViewModel = BookmarkedListViewModel(delegate: self)
        setupUI()
    }
    func setupUI() {
        tableHeightConst?.constant = CGFloat(screenHeight * 0.78)
        view.backgroundColor = UIColor(red: 6/255.0, green: 4/255.0, blue: 31/255.0, alpha: 1.0)
        savedMoviesTableView?.backgroundColor = .clear
        savedMoviesLabel?.text = "Saved Movies"
        savedMoviesLabel?.textColor = UIColor.white
        savedMoviesLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        savedMoviesTableView?.backgroundColor = UIColor.clear
        savedMoviesTableView?.separatorStyle = .none
        registerCells()
    }
    
    func registerCells() {
        savedMoviesTableView?.register(UINib(nibName: "SavedMovieTableViewCell", bundle: nil), forCellReuseIdentifier: "SavedMovieTableViewCell")
        savedMoviesTableView?.dataSource = self
        savedMoviesTableView?.delegate = self
    }


}
extension SavedMoviesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookmarkedMovie?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedMovieTableViewCell", for: indexPath) as? SavedMovieTableViewCell
        cell?.movieTitle?.text = bookmarkedMovie?[indexPath.row].title ?? ""
       
        let genreIds: [Int] = bookmarkedMovie?[indexPath.row].genreIds ?? []
        let genreNamesArr: [String] = Utility.getGenreNames(for: genreIds)
        let genres: String = genreNamesArr.joined(separator: ", ")
        cell?.movieGenreLabel?.text = genres
        
        let posterPath = bookmarkedMovie?[indexPath.row].posterPath ?? ""
        let posterFullPath = "https://image.tmdb.org/t/p/w500" + posterPath
        let posterURL = URL(string: posterFullPath)
        
        
        if let savedImage = MoviePersistenceManager.shared.getPosterImage(movieId: bookmarkedMovie?[indexPath.row].id ?? -1) {
            cell?.movieImgView?.image = savedImage
        } else {
            cell?.movieImgView?.loadImage(from: posterURL)
        }
        
        
        cell?.unsaveBtnClosure = { [weak self] in
            Utility.showLoader(on: self?.view ?? UIView())
            self?.selectedMovieId = self?.bookmarkedMovie?[indexPath.row].id
            self?.addRemoveMovieViewModel?.addMovie(endpoint: "/list/8553268/remove_item")
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselected")
    }
    
}
extension SavedMoviesViewController: AddMovieDependency, AddMovieFlowDelegate, BookmarkedListFlowDelegate {
    func actionBookmarkedListSuccessful(data: BookmarkedListDataUIModel) {
        print("list pass")
        self.bookmarkedMovie = data.items
        DispatchQueue.main.async { [weak self] in
            self?.savedMoviesTableView?.reloadData()
        }
        Utility.hideLoader()
    }
    
    func actionBookmarkedListFailed(error: BookmarkedListErrorUIModel) {
        print("list faill")
        Utility.hideLoader()
        if error.statusCode == "NO_INTERNET" {
            DispatchQueue.main.async { [weak self] in
                self?.showToast(message: "No Internet Connection")
            }
        }
    }
    
    func getMovieId() -> Int? {
        return selectedMovieId
    }
    
    func actionAddMovieSuccessful(data: AddMovieDataUIModel) {
        print("Rem succ")
        dump(data)
        if data.statusCode == 13 {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.bookmarkedListViewModel?.fetchBookmarkedList(endpoint: "/list/8553268")
            }
        }
    }
    
    func actionAddMovieFailed(error: AddMovieErrorUIModel) {
        print("Rem faill")
        dump(error)
        Utility.hideLoader()
        if error.statusCode == "NO_INTERNET" {
            DispatchQueue.main.async { [weak self] in
                self?.showToast(message: "No Internet Connection")
            }
        }
    }
    
    
}
