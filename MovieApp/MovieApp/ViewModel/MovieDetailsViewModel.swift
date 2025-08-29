//
//  MovieDetailsViewModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
public protocol MovieDetailsFlowDelegate: AnyObject {
    func actionMovieDetailsSuccessful(data: MovieDetailsDataUIModel)
    func actionMovieDetailsFailed(error: MovieDetailsErrorUIModel)
}

// MARK: - Dependency
public protocol MovieDetailsDependency: AnyObject {
    func getMovieID() -> Int?
}
// MARK: - ViewModel
public class MovieDetailsViewModel {
    /// Flow Delegate
    public weak var delegate: MovieDetailsFlowDelegate?

    /// Dependency
    public weak var component: MovieDetailsDependency?
    
    // MARK: - Init
    init(delegate: MovieDetailsFlowDelegate?,
         component: MovieDetailsDependency?) {
        self.delegate = delegate
        self.component = component
    }

    public func fetchTrendingMovies(endpoint: String) {
        let movieID = String(component?.getMovieID() ?? 0)

        callMovieDetailsAPI(endpoint: endpoint, movieID: movieID,
                              successCallBack: { [weak self] response in
            
            
            let genreDataUIModel = response.genres.map { obj in
                GenreDataUIModel(id: obj.id, name: obj.name)
            }
            
            let movieDetailsDataUIModel = MovieDetailsDataUIModel(id: response.id,
                                                                  title: response.title,
                                                                  genres: genreDataUIModel,
                                                                  originalLanguage:
                                                                    response.originalLanguage,
                                                                  originalTitle: response.originalTitle,
                                                                  overview: response.overview,
                                                                  posterPath: response.posterPath,
                                                                  releaseDate: response.releaseDate,
                                                                  runtime: response.runtime ?? 0,
                                                                  rating: String(format: "%.1f", response.voteAverage),
                                                                  tagline: response.tagline)

            self?.delegate?.actionMovieDetailsSuccessful(data: movieDetailsDataUIModel)
        }, failureCallBack: { [weak self] error in
            let errorModel: MovieDetailsErrorUIModel
            if let apiError = error as? APIError {
                switch apiError {
                case .noInternet:
                    errorModel = MovieDetailsErrorUIModel(
                        statusCode: "NO_INTERNET",
                        statusMessage: "No Internet Connection"
                    )
                default:
                    errorModel = MovieDetailsErrorUIModel(
                        statusCode: "-1",
                        statusMessage: error.localizedDescription
                    )
                }
            } else {
                errorModel = MovieDetailsErrorUIModel(
                    statusCode: "-1",
                    statusMessage: error.localizedDescription
                )
            }
            self?.delegate?.actionMovieDetailsFailed(error: errorModel)
        })
    }
    
    private func callMovieDetailsAPI(endpoint: String,
                                     movieID: String?,
                                     successCallBack: @escaping (MovieDetailsResponseModel) -> Void,
                                     failureCallBack: @escaping (Error) -> Void) {

        var endpoint = endpoint + (movieID ?? "")
        var queryItems: [String] = []
        let language: String? = "language=en-US"
        if let language = language {
            queryItems.append("language=\(language)")
        }

        if !queryItems.isEmpty {
            endpoint.append("?" + queryItems.joined(separator: "&"))
        }

        APIClient.shared.request(endpoint: endpoint) { (result: Result<MovieDetailsResponseModel, APIError>) in
            switch result {
            case .success(let response):
                successCallBack(response)
            case .failure(let error):
                failureCallBack(error)
            }
        }
    }
}
