//
//  MovieDetailsViewController.swift
//  MovieApp
//
//  Created by Sayed on 23/08/25.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    @IBOutlet public var backImageIcon: UIImageView?
    @IBOutlet public var detailImage: UIImageView?
    private var movieDetailsViewModel: MovieDetailsViewModel?
    @IBOutlet public var detailsImageHeight: NSLayoutConstraint?
    private var movieDetailsDataUIModel: MovieDetailsDataUIModel?
     var selectedMovieObj: MovieDetailsDataUIModel?
    private var addRemoveMovieViewModel: AddMovieViewModel?
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    @IBOutlet public var movieTitleLang: UILabel?
    @IBOutlet public var yearLabel: UILabel?
    @IBOutlet public var detailStackView: UIStackView?
    @IBOutlet public var genreView: UIView?
    @IBOutlet public var durationView: UIView?
    @IBOutlet public var ratingsView: UIView?
    @IBOutlet public var genreImgView: UIImageView?
    @IBOutlet public var genreLabel: UILabel?
    @IBOutlet public var genreSeparator: UIView?
    @IBOutlet public var durationImgView: UIImageView?
    @IBOutlet public var durationLabel: UILabel?
    @IBOutlet public var durationSeparator: UIView?
    @IBOutlet public var ratingImgView: UIImageView?
    @IBOutlet public var ratingLabel: UILabel?
    @IBOutlet public var ratingSeparator: UIView?
    @IBOutlet public var bookmarkMovie: UIButton?
    @IBOutlet public var overviewTextView: UITextView?
     var selectedMovieId: Int?
    var isBookmarked: Bool = false
    var isInternetConnected: Bool = true
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let posterImageView = detailImage {
            addGradientToImageView(posterImageView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBackImage()
        view.backgroundColor = UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0)
        Utility.showLoader(on: self.view)
        if isInternetConnected {
            callMovieDetailAPI()
        } else {
            movieDetailsDataUIModel = selectedMovieObj
            DispatchQueue.main.async { [weak self] in
                self?.setupTitle()
                Utility.hideLoader()
            }
        }
    }
    
    func callMovieDetailAPI() {
        movieDetailsViewModel = MovieDetailsViewModel(delegate: self, component: self)
        addRemoveMovieViewModel = AddMovieViewModel(delegate: self, component: self)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.movieDetailsViewModel?.fetchTrendingMovies(endpoint: "/movie/")
            
        }
        
    }
    
    func setupBackImage() {
        let backImage = UIImage(named: "right-arrow")?.withHorizontallyFlippedOrientation().withTintColor(.white)
        backImageIcon?.image = backImage
        backImageIcon?.backgroundColor = .lightGray
        backImageIcon?.layer.cornerRadius = 12.0
        backImageIcon?.layer.masksToBounds = true
        backImageIcon?.clipsToBounds = true
        backImageIcon?.contentMode = .scaleAspectFit
        backImageIcon?.isUserInteractionEnabled = true
        let inset: CGFloat = 2
        let paddedImage = backImage?.withAlignmentRectInsets(
            UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        )

        backImageIcon?.image = paddedImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        backImageIcon?.addGestureRecognizer(tapGesture)
    }
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func bookmarkBtnAction(_ sender: Any) {
        print("Bookmark")
        Utility.showLoader(on: self.view)
        if !isBookmarked {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.addRemoveMovieViewModel?.addMovie(endpoint: "/list/8553268/add_item")
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.addRemoveMovieViewModel?.addMovie(endpoint: "/list/8553268/remove_item")
            }
        }
    }
    
    func setupUI() {
        detailsImageHeight?.constant = CGFloat(screenHeight * 0.5)
        view.backgroundColor = UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0)
        setupBookmarkButton()
        
    }
    func setupBookmarkButton() {
        if isBookmarked {
            bookmarkMovie?.setTitle("Bookmarked", for: .normal)
        } else {
            bookmarkMovie?.setTitle("Bookmark this movie", for: .normal)
        }
        bookmarkMovie?.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        bookmarkMovie?.setTitleColor(.white, for: .normal)
        bookmarkMovie?.backgroundColor = UIColor(red: 228/255.0, green: 1/255.0, blue: 2/255.0, alpha: 1.0)
        bookmarkMovie?.layer.cornerRadius = 8
    }
    func addGradientToImageView(_ imageView: UIImageView) {
        if let sublayers = imageView.layer.sublayers,
           sublayers.contains(where: { $0.name == "gradientLayer" }) {
            return
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientLayer"
        gradientLayer.frame = detailImage?.bounds ?? CGRect()
        gradientLayer.colors = [
            UIColor.clear.cgColor,   // Transparent at top
            UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0).withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.locations = [0.5, 1.0]  // Starts fading from middle to bottom
        detailImage?.layer.addSublayer(gradientLayer)
    }

    
    
}
extension MovieDetailsViewController: MovieDetailsDependency, MovieDetailsFlowDelegate {
    func getMovieID() -> Int? {
        return selectedMovieId
    }
    
    func actionMovieDetailsSuccessful(data: MovieDetailsDataUIModel) {
        movieDetailsDataUIModel = data
        DispatchQueue.main.async { [weak self] in
            self?.setupTitle()
            Utility.hideLoader()
        }
    }
    
    func actionMovieDetailsFailed(error: MovieDetailsErrorUIModel) {
        print("details faillll")
        if error.statusCode == "NO_INTERNET" {
            DispatchQueue.main.async { [weak self] in
                self?.showToast(message: "No Internet Connection")
            }
        }
        movieDetailsDataUIModel = selectedMovieObj
        DispatchQueue.main.async { [weak self] in
            self?.setupTitle()
            Utility.hideLoader()
        }
        
    }
    
    func setupTitle() {
        let title = movieDetailsDataUIModel?.title ?? ""
        var lang = movieDetailsDataUIModel?.originalLanguage ?? ""
        lang = languageName(for: lang)
        let yearArr = movieDetailsDataUIModel?.releaseDate.split(separator: "-") ?? []
        let year = yearArr.first ?? ""
        movieTitleLang?.text = "\(title) : \(lang)"
        movieTitleLang?.textColor = .white
        movieTitleLang?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        yearLabel?.text = String(year)
        yearLabel?.textColor = .white
        yearLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        setupDesc()
    }
    func languageName(for code: String) -> String {
        let locale = Locale.current
        return locale.localizedString(forLanguageCode: code) ?? code
    }
    func setupDesc() {
        detailStackView?.backgroundColor = UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0)
        genreView?.backgroundColor = UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0)
        durationView?.backgroundColor = UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0)
        ratingsView?.backgroundColor = UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0)
        genreImgView?.image = UIImage(systemName: "play.fill")
        genreImgView?.tintColor = .white
        genreLabel?.text = movieDetailsDataUIModel?.genres.first?.name
        genreLabel?.textColor = .white
        genreLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        durationImgView?.image = UIImage(systemName: "clock.fill")
        durationImgView?.tintColor = .white
        let runtime = movieDetailsDataUIModel?.runtime ?? 0
        let hour = (runtime / 60)
        let min = (runtime % 60)
        durationLabel?.text = "\(hour)h \(min)m"
        durationLabel?.textColor = .white
        durationLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        ratingImgView?.image = UIImage(systemName: "star.fill")
        ratingImgView?.tintColor = .white
        ratingLabel?.text = movieDetailsDataUIModel?.rating
        ratingLabel?.textColor = .white
        ratingLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        ratingSeparator?.isHidden = true
        setupOverview()
    }
    func setupOverview() {
        overviewTextView?.text = movieDetailsDataUIModel?.overview ?? ""
        overviewTextView?.textColor = .white
        overviewTextView?.backgroundColor = UIColor(red: 19/255.0, green: 8/255.0, blue: 24/255.0, alpha: 1.0)
        overviewTextView?.isEditable = false
        overviewTextView?.isScrollEnabled = true
        overviewTextView?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        setupDetailImage()
    }
    func setupDetailImage() {
        let posterPath = movieDetailsDataUIModel?.posterPath ?? ""
        let posterFullPath = "https://image.tmdb.org/t/p/w500" + posterPath
        let posterURL = URL(string: posterFullPath)
        
        detailImage?.contentMode = .scaleAspectFill
        detailImage?.clipsToBounds = true
        if isInternetConnected {
            detailImage?.loadImage(from: posterURL)
        } else {
            if let savedImage = MoviePersistenceManager.shared.getPosterImage(movieId: selectedMovieObj?.id ?? -1) {
                detailImage?.image = savedImage
            }
        }
    }

}
extension MovieDetailsViewController: AddMovieDependency, AddMovieFlowDelegate {
    func getMovieId() -> Int? {
        return selectedMovieId
    }
    
    func actionAddMovieSuccessful(data: AddMovieDataUIModel) {
        Utility.hideLoader()
        
        if data.statusCode == 12 {
            isBookmarked = true
            DispatchQueue.main.async { [weak self] in
                self?.bookmarkMovie?.setTitle("Bookmarked", for: .normal)
            }
        } else {
            isBookmarked = false
            DispatchQueue.main.async { [weak self] in
                self?.bookmarkMovie?.setTitle("Bookmark this movie", for: .normal)
            }
        }
        print("Success")
        dump(data)
    }
    
    func actionAddMovieFailed(error: AddMovieErrorUIModel) {
        isBookmarked = false
        print("Faill")
        dump(error)
        Utility.hideLoader()
        if error.statusCode == "NO_INTERNET" {
            DispatchQueue.main.async { [weak self] in
                self?.showToast(message: "No Internet Connection")
            }
        }
    }
    
    
    
}
