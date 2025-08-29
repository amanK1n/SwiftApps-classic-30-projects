//
//  SearchViewController.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet public var searchTextField: UITextField?
    @IBOutlet public var searchResultTableView: UITableView?
    @IBOutlet public var customBackgroundView: UIView?
    @IBOutlet public var tableViewHeightConst: NSLayoutConstraint?
    private var searchMovieViewModel: SearchMovieViewModel?
    var searchResultsArray: [MovieDataUIModel]? = []
    private var pendingRequestWorkItem: DispatchWorkItem?
    let screenHeight = UIScreen.main.bounds.height
    var bookmarkedMovies: [MovieItemDataUIModel]?
    
    @IBOutlet var backBtnImgView: UIImageView?
    override func viewDidAppear(_ animated: Bool) {
        searchTextField?.becomeFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchMovieViewModel = SearchMovieViewModel(delegate: self)
        setupUI()
        searchTextField?.delegate = self
    }
    
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.backgroundColor = UIColor(red: 6/255.0, green: 4/255.0, blue: 31/255.0, alpha: 1.0)
        customBackgroundView?.backgroundColor = UIColor(red: 6/255.0, green: 4/255.0, blue: 31/255.0, alpha: 1.0)
        tableViewHeightConst?.constant = CGFloat(screenHeight * 0.80)
        searchResultTableView?.backgroundColor = .clear
        searchResultTableView?.separatorStyle = .none
        searchTextField?.backgroundColor = .clear
        searchTextField?.textColor = .white
        searchTextField?.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        searchTextField?.layer.borderColor = UIColor(red: 36/255.0, green: 34/255.0, blue: 58/255.0, alpha: 1.0).cgColor
        searchTextField?.layer.borderWidth = 1.0
        searchTextField?.layer.cornerRadius = 6.0
        
        registerCells()
    }
    func registerCells() {
        searchResultTableView?.register(UINib(nibName: "SavedMovieTableViewCell", bundle: nil), forCellReuseIdentifier: "SavedMovieTableViewCell")
        searchResultTableView?.dataSource = self
        searchResultTableView?.delegate = self
        searchResultTableView?.allowsSelection = true
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //bookmarkedMovie?.count ?? 0
        return searchResultsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedMovieTableViewCell", for: indexPath) as? SavedMovieTableViewCell
        cell?.movieTitle?.text = searchResultsArray?[indexPath.row].title ?? ""
        cell?.unsaveButton?.isHidden = true
        let genreIds: [Int] = searchResultsArray?[indexPath.row].genreIds ?? []
        let genreNamesArr: [String] = Utility.getGenreNames(for: genreIds)
        let genres: String = genreNamesArr.joined(separator: ", ")
        cell?.movieGenreLabel?.text = genres
        
        let posterPath = searchResultsArray?[indexPath.row].posterPath ?? ""
        let posterFullPath = "https://image.tmdb.org/t/p/w500" + posterPath
        let posterURL = URL(string: posterFullPath)
        cell?.movieImgView?.loadImage(from: posterURL)

        
        return cell ?? UITableViewCell()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped on row: \(indexPath.row)")
        print("movie: ", searchResultsArray?[indexPath.row].id ?? "")
        let selectedMovieID = searchResultsArray?[indexPath.row].id ?? 0
        let isBookmarked = bookmarkedMovies?.contains(where: { obj in
             obj.id == selectedMovieID
        })
        let vc = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        vc.selectedMovieId = selectedMovieID
        vc.isBookmarked = isBookmarked ?? false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension SearchViewController: UITextFieldDelegate, SearchMovieFlowDelegate {
    func actionSearchMovieSuccessful(data: TrendingMoviesDataUIModel) {
        print("Search Success:")
        dump(data)
        searchResultsArray = []
        searchResultsArray = data.results
        DispatchQueue.main.async { [weak self] in
            self?.searchResultTableView?.reloadData()
        }
    }
    
    func actionSearchMovieFailed(error: TrendingMoviesErrorUIModel) {
        print("Search Failed:")
        dump(error)
        searchResultsArray = []
        DispatchQueue.main.async { [weak self] in
            self?.searchResultTableView?.reloadData()
        }
        if error.statusCode == "NO_INTERNET" {
            DispatchQueue.main.async { [weak self] in
                self?.showToast(message: "No Internet Connection")
            }
        }
    }
    
    func search(query: String) {
        pendingRequestWorkItem?.cancel()
        guard query.count >= 1 else { return }
        let requestWorkItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: query)
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: requestWorkItem)
    }
    private func performSearch(query: String) {
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let endpoint = "/search/movie?query=\(encodedQuery)&include_adult=false&language=en-US&page=1"
        
        self.searchMovieViewModel?.searchMovies(endpoint: endpoint)
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text as? NSString ?? "" as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
      //  print("Search Text: \(newString)")
        if newString == "" {
            searchResultsArray = []
            DispatchQueue.main.async { [weak self] in
                self?.searchResultTableView?.reloadData()
            }
        }
        search(query: newString as String)
        
        return true
    }
}
