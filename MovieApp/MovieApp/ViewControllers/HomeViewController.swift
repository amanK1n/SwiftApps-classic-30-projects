//
//  ViewController.swift
//  MovieApp
//
//  Created by Sayed on 21/08/25.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet public var movieScrollView: UIScrollView?
    @IBOutlet public var backgroundView: UIView?
    @IBOutlet public var searchLabel: UILabel?
    @IBOutlet public var hintLabel: UILabel?
    @IBOutlet public var separatorLine: UIView?
    @IBOutlet public var searchView: UIView?
    var hintArray: [String] = ["Movie, Actors, Directors...", "Genres, Release year, Ratings...", "Action, Comedy, Drama, Sci-Fi...", "Upcoming, Now playing, Trending..."]
    var timer: Timer?
    var trendingtimer: Timer?
    var currentIndex: Int = 0
    @IBOutlet public var trendingLabel: UILabel?
    @IBOutlet public var trendingMoviesCollectionView: UICollectionView?
    @IBOutlet public var nowPlayingLabel: UILabel?
    @IBOutlet public var nowPlayingCollectionView: UICollectionView?
    @IBOutlet public var tabBarView: UIView?
    
    @IBOutlet public var homeView: UIView?
    @IBOutlet public var homeIcon: UIImageView?
    
    @IBOutlet public var searchTabView: UIView?
    
    @IBOutlet public var searchIcon: UIImageView?
    
    @IBOutlet public var saveView: UIView?
    
    @IBOutlet public var saveIcon: UIImageView?
    
    @IBOutlet public var scrollHeightConstraint: NSLayoutConstraint?
    var screeHeightY: CGFloat = UIScreen.main.bounds.height
    var isMovieScrollEnabled: Bool = true
    private var currentVC: UIViewController?
    private var trendingMovieViewModel: TrendingMoviesViewModel?
    private var nowPlayingViewModel: TrendingMoviesViewModel?
    private var bookmarkedListViewModel: BookmarkedListViewModel?
   
    var allTrendingMovies: [MovieDataUIModel]?
    var nowPlayingMovies: [MovieDataUIModel]?
    var bookmarkedMovies: [MovieItemDataUIModel]?
    let group = DispatchGroup()
    enum TabItems { case home, search, save }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        bookmarkedListViewModel = BookmarkedListViewModel(delegate: self)
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.bookmarkedListViewModel?.fetchBookmarkedList(endpoint: "/list/8553268")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callTrendingMovieAPI()
        setupNavigationBar()
        setupUI()
        setupCollectionView()
        setupTabBarView()
    }
    func callTrendingMovieAPI() {
        Utility.showLoader(on: self.view)
        trendingMovieViewModel = TrendingMoviesViewModel(delegate: self, component: self, category: .trending)
        nowPlayingViewModel = TrendingMoviesViewModel(delegate: self, component: self, category: .nowPlaying)
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.trendingMovieViewModel?.fetchTrendingMovies(endpoint: "/trending/movie/day")
        }
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.nowPlayingViewModel?.fetchTrendingMovies(endpoint: "/movie/now_playing")
        }
        
        group.notify(queue: .main) {
            self.trendingMoviesCollectionView?.reloadData()
            self.nowPlayingCollectionView?.reloadData()
            Utility.hideLoader()
            self.startAnimationTimer()
            self.showToast(message: "Movies loaded successfully")
        }
    }
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    func setupUI() {
        movieScrollView?.bounces = false
        movieScrollView?.showsVerticalScrollIndicator = false
        movieScrollView?.delegate = self
        scrollHeightConstraint?.constant = (UIScreen.main.bounds.height * 1.5)
        view.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 41/255.0, alpha: 1.0)
        backgroundView?.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 41/255.0, alpha: 1.0)
        trendingMoviesCollectionView?.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 41/255.0, alpha: 1.0)
        nowPlayingCollectionView?.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 41/255.0, alpha: 1.0)
        searchView?.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 41/255.0, alpha: 1.0)
        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(searchTapped))
        searchLabel?.text = "Search"
        searchLabel?.textColor = UIColor.gray
        searchLabel?.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        hintLabel?.text = "Movie, Actors, Directors..."
        hintLabel?.isUserInteractionEnabled = true
        hintLabel?.textColor = UIColor.gray
        hintLabel?.font = UIFont.systemFont(ofSize: 21, weight: .light)
        hintLabel?.addGestureRecognizer(searchTapGesture)
        separatorLine?.backgroundColor = UIColor.gray
        
        trendingLabel?.text = "Trending Movies"
        trendingLabel?.textColor = UIColor.white
        trendingLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        
        nowPlayingLabel?.text = "Now Playing"
        nowPlayingLabel?.textColor = UIColor.white
        nowPlayingLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
    }
    func startAnimationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true, block: { [weak self] _ in
            self?.updateHintLabel()
        })
        trendingtimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollToNextItem), userInfo: nil, repeats: true)
    }
    @objc func scrollToNextItem() {
        let itemCount = collectionView(trendingMoviesCollectionView ?? UICollectionView(), numberOfItemsInSection: 0)
        if itemCount == 0 { return }
        currentIndex = (currentIndex + 1) % itemCount
        let indexPath = IndexPath(item: currentIndex, section: 0)
        trendingMoviesCollectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    func updateHintLabel() {
        UIView.transition(with: hintLabel ?? UILabel(), duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.hintLabel?.text = self.hintArray.randomElement()
        }, completion: nil)
    }
    func stopAutoScroll() {
        trendingtimer?.invalidate()
        timer = nil
    }
    func setupCollectionView() {
        trendingMoviesCollectionView?.delegate = self
        trendingMoviesCollectionView?.dataSource = self
        trendingMoviesCollectionView?.tag = 0
        let nib = UINib(nibName: "TrendingMovieCell", bundle: nil)
        trendingMoviesCollectionView?.register(nib, forCellWithReuseIdentifier: "TrendingMovieCell")
        trendingMoviesCollectionView?.showsHorizontalScrollIndicator = false
        if let layout = trendingMoviesCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        nowPlayingCollectionView?.delegate = self
        nowPlayingCollectionView?.dataSource = self
        nowPlayingCollectionView?.tag = 1
        nowPlayingCollectionView?.register(nib, forCellWithReuseIdentifier: "TrendingMovieCell")
        nowPlayingCollectionView?.showsVerticalScrollIndicator = false
        nowPlayingCollectionView?.bounces = false
        nowPlayingCollectionView?.isScrollEnabled = true
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == trendingMoviesCollectionView {
            stopAutoScroll()
        }
      }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            if scrollView == movieScrollView {
//                let offsetY = scrollView.contentOffset.y
//                if offsetY >= (screeHeightY * 0.52) {
//                    movieScrollView?.isScrollEnabled = false
//                    nowPlayingCollectionView?.isScrollEnabled = true
//                    isMovieScrollEnabled = false
//                }
//            }
//            
//            if scrollView == nowPlayingCollectionView {
//                let offsetY = scrollView.contentOffset.y
//                if offsetY <= 0 && isMovieScrollEnabled == false {
//                    nowPlayingCollectionView?.isScrollEnabled = false
//                    movieScrollView?.isScrollEnabled = true
//                    isMovieScrollEnabled = true
//                }
//            }
//        }

}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let trendingCount = allTrendingMovies?.count ?? 0
        let nowPlayingCount = nowPlayingMovies?.count ?? 0

        guard trendingCount > 0 else { return 0 }
        guard nowPlayingCount > 0 else { return 0 }
        
        return collectionView.tag == 0 ? trendingCount : nowPlayingCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingMovieCell", for: indexPath) as? TrendingMovieCell
        movieCell?.movieImageView?.image = nil
        let titleText: String
        let subtitleText: String
        let genreIds: [Int] = allTrendingMovies?[indexPath.row].genreIds ?? []
        let genreNamesArr: [String] = Utility.getGenreNames(for: genreIds)
        let genres: String = genreNamesArr.joined(separator: ", ")
        
        let nowPlayingGenreIds: [Int] = nowPlayingMovies?[indexPath.row].genreIds ?? []
        let nowPlayingGenreNamesArr: [String] = Utility.getGenreNames(for: nowPlayingGenreIds)
        let nowPlayingGenres: String = nowPlayingGenreNamesArr.joined(separator: ", ")
        
        let posterPath = allTrendingMovies?[indexPath.row].posterPath ?? ""
        let posterFullPath = "https://image.tmdb.org/t/p/w500" + posterPath
        let posterURL = URL(string: posterFullPath)
        
        let nowPlayPosterPath = nowPlayingMovies?[indexPath.row].posterPath ?? ""
        let nowPlayPosterFullPath = "https://image.tmdb.org/t/p/w500" + nowPlayPosterPath
        let nowPlayPosterURL = URL(string: nowPlayPosterFullPath)
        
        if collectionView.tag == 0 {
            if let savedImage = MoviePersistenceManager.shared.getPosterImage(movieId: allTrendingMovies?[indexPath.row].id ?? -1) {
                movieCell?.movieImageView?.image = savedImage
            } else {
                movieCell?.movieImageView?.loadImage(from: posterURL)
            }
            titleText = allTrendingMovies?[indexPath.row].title ?? ""
            subtitleText = genres
            movieCell?.imgLeadingConstraint?.constant = 20
            movieCell?.imgTrailingConstraint?.constant = 10
        } else {
            if let savedImage = MoviePersistenceManager.shared.getPosterImage(movieId: nowPlayingMovies?[indexPath.row].id ?? -1) {
                movieCell?.movieImageView?.image = savedImage
            } else {
                movieCell?.movieImageView?.loadImage(from: posterURL)
            }
            titleText = nowPlayingMovies?[indexPath.row].title ?? ""
            subtitleText = nowPlayingGenres
            movieCell?.imgLeadingConstraint?.constant = 0
            movieCell?.imgTrailingConstraint?.constant = 0
        }
        movieCell?.movieTitleLabel?.text = titleText
        movieCell?.movieSubtitle?.text = subtitleText
        return movieCell ?? UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let deviceWidth = UIScreen.main.bounds.width
        let cellWidth: CGFloat = deviceWidth * 0.40
        let trendingSize: CGSize = CGSize(width: 320, height: 280)
        let nowPlayingSize: CGSize = CGSize(width: cellWidth, height: 260)
        
        return collectionView.tag == 0 ? trendingSize : nowPlayingSize
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedMovieID: Int? = -1
        var selectedMovieObj: MovieDataUIModel?
        if collectionView.tag == 0 {
            selectedMovieID =  allTrendingMovies?[indexPath.row].id
            selectedMovieObj = allTrendingMovies?[indexPath.row]
        } else {
            selectedMovieID =  nowPlayingMovies?[indexPath.row].id
            selectedMovieObj = nowPlayingMovies?[indexPath.row]
        }
        let isBookmarked = bookmarkedMovies?.contains(where: { obj in
             obj.id == selectedMovieID
        })
        
        let vc = MovieDetailsViewController(nibName: "MovieDetailsViewController", bundle: nil)
        vc.selectedMovieObj = selectedMovieObj.map({ obj in
            var genre: [GenreDataUIModel] = obj.genreIds.map { id in
                GenreDataUIModel(id: id, name: Utility.getGenreNames(for: [id]).first ?? "Unknown")
            }
            return MovieDetailsDataUIModel(id: obj.id, title: obj.title, genres: genre, originalLanguage: obj.originalLanguage ?? "", originalTitle: obj.title, overview: obj.overview, posterPath: obj.posterPath, releaseDate: obj.releaseDate ?? "", runtime: 0, rating: String(format: "%.1f", obj.voteAverage ?? 0.0), tagline: "")
        })
        vc.selectedMovieId = selectedMovieID
        vc.isBookmarked = isBookmarked ?? false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController {
    func setupTabBarView() {
        homeView?.backgroundColor = .clear
        searchTabView?.backgroundColor = .clear
        saveView?.backgroundColor = .clear
        tabBarView?.backgroundColor = UIColor(red: 36/255.0, green: 34/255.0, blue: 58/255.0, alpha: 1.0)
        tabBarView?.alpha = 0.95
        homeIcon?.image = UIImage(named: "home_icon_clicked")?.withTintColor(UIColor.white)
        searchIcon?.image = UIImage(named: "search_icon_uncliked")?.withTintColor(UIColor.white)
        saveIcon?.image = UIImage(named: "save_icon_unclicked")?.withTintColor(UIColor.white)
        addTapGestures()
    }
    func addTapGestures() {
        let homeTapGesture = UITapGestureRecognizer(target: self, action: #selector(homeTapped))
        homeView?.addGestureRecognizer(homeTapGesture)
        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(searchTapped))
        searchTabView?.addGestureRecognizer(searchTapGesture)
        let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveTapped))
        saveView?.addGestureRecognizer(saveTapGesture)
    }
    @objc func homeTapped() {
        print("Home")
        switchToTab(.home)
    }
    @objc func searchTapped() {
        print("search")
        switchToTab(.search)
    }
    @objc func saveTapped() {
        print("SAVE")
        switchToTab(.save)
    }
    private func switchToTab(_ tab: TabItems) {
        homeIcon?.image = UIImage(named: "home_icon_unclicked")?.withTintColor(UIColor.white)
        searchIcon?.image = UIImage(named: "search_icon_uncliked")?.withTintColor(UIColor.white)
        saveIcon?.image = UIImage(named: "save_icon_unclicked")?.withTintColor(UIColor.white)
        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        let newVC: UIViewController
        switch tab {
        case .home:
            movieScrollView?.isScrollEnabled = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                fatalError("HomeViewController not found in storyboard")
            }
            newVC = homeVC
            homeIcon?.image = UIImage(named: "home_icon_clicked")?.withTintColor(UIColor.white)
        case .search:
            newVC = SearchViewController()
            if let searchVC = newVC as? SearchViewController {
                searchVC.bookmarkedMovies = bookmarkedMovies
            }
            movieScrollView?.isScrollEnabled = false
            movieScrollView?.setContentOffset(.zero, animated: false)
            searchIcon?.image = UIImage(named: "search_icon_cliked")?.withTintColor(UIColor.white)
        case .save:
            newVC = SavedMoviesViewController()
            if let savedVC = newVC as? SavedMoviesViewController {
                savedVC.bookmarkedMovie = bookmarkedMovies
            }
            movieScrollView?.setContentOffset(.zero, animated: false)
            movieScrollView?.isScrollEnabled = false
            saveIcon?.image = UIImage(named: "save_icon_clicked")?.withTintColor(UIColor.white)
        }
        addChild(newVC)
        newVC.view.frame = backgroundView?.bounds ?? CGRect()
        backgroundView?.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        currentVC = newVC
    }

}

extension HomeViewController: TrendingMoviesDependency, TrendingMoviesFlowDelegate, BookmarkedListFlowDelegate {
    func actionBookmarkedListSuccessful(data: BookmarkedListDataUIModel) {
        print("list succcess!!")
        dump(data)
        bookmarkedMovies = data.items
        
        var posters: [Int: UIImage] = [:]
        let innerGroup = DispatchGroup()
        
        for movie in data.items {
            innerGroup.enter()
            let url = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")!
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    posters[movie.id] = image
                }
                innerGroup.leave()
            }.resume()
        }
        
        innerGroup.notify(queue: .main) {
            
            let savedMovies = data.items.map { obj in
                MovieDataUIModel(id: obj.id, title: obj.title, overview: obj.title, posterPath: obj.posterPath, releaseDate: "", voteAverage: 0.0, originalLanguage: "", genreIds: obj.genreIds)
            }
            print("Saved movies")
            MoviePersistenceManager.shared.saveMovies(savedMovies,
                                                      posterImages: posters,
                                                      category: .savedMovies)

        }
        group.leave()
    }
    
    func actionBookmarkedListFailed(error: BookmarkedListErrorUIModel) {
        print("list fail")
        dump(error)
        if error.statusCode == "NO_INTERNET" {
            DispatchQueue.main.async { [weak self] in
                self?.showToast(message: "No Internet Connection")
            }
        }
        let savedMovies = MoviePersistenceManager.shared.fetchMovies(for: .savedMovies)
        bookmarkedMovies = savedMovies.map({ obj in
            MovieItemDataUIModel(title: obj.title, posterPath: obj.posterPath, genreIds: obj.genreIds, id: obj.id)
        })
        group.leave()
    }
    
    func actionFetchTrendingMoviesSuccessful(data: TrendingMoviesDataUIModel, for category: MovieCategory) {
        //self.showToast(message: "Movies loaded successfully")
        print("muvv success")
        switch category {
        case .trending:
            print("Fetched trending")
            allTrendingMovies = []
            allTrendingMovies = data.results
            var posters: [Int: UIImage] = [:]
            let group = DispatchGroup()
            
            for movie in data.results {
                group.enter()
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")!
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        posters[movie.id] = image
                    }
                    group.leave()
                }.resume()
            }
            
            group.notify(queue: .main) {
                MoviePersistenceManager.shared.saveMovies(data.results,
                                                          posterImages: posters,
                                                          category: .trending)

            }
        case .nowPlaying:
            nowPlayingMovies = []
            print("Fetched now playing")
            nowPlayingMovies = data.results
            var posters: [Int: UIImage] = [:]
            let group = DispatchGroup()
            
            for movie in data.results {
                group.enter()
                let url = URL(string: "https://image.tmdb.org/t/p/w500\(movie.posterPath)")!
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        posters[movie.id] = image
                    }
                    group.leave()
                }.resume()
            }
            
            group.notify(queue: .main) {
                MoviePersistenceManager.shared.saveMovies(data.results,
                                                          posterImages: posters,
                                                          category: .nowPlaying)

            }
        case .savedMovies:
            debugPrint("Saved movies - should not be here")
        }
        group.leave()
    }
    
    func actionFetchTrendingMoviesFailed(error: TrendingMoviesErrorUIModel, for category: MovieCategory) {
        print("muvv fail")
        if error.statusCode == "NO_INTERNET" {
            DispatchQueue.main.async { [weak self] in
                self?.showToast(message: "No Internet Connection")
            }
        }
        
        allTrendingMovies = []
        nowPlayingMovies = []
        print("Error::", error.statusMessage)
        allTrendingMovies = MoviePersistenceManager.shared.fetchMovies(for: .trending)
        nowPlayingMovies = MoviePersistenceManager.shared.fetchMovies(for: .nowPlaying)
        DispatchQueue.main.async { [weak self] in
            self?.trendingMoviesCollectionView?.reloadData()
            self?.nowPlayingCollectionView?.reloadData()
        }
        group.leave()
    }
    
    func getLanguageCode() -> String? {
        return "en-US"
    }
}

extension HomeViewController {
    
}
