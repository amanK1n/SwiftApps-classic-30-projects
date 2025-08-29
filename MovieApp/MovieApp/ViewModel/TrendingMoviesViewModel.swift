//
//  TrendingMoviesViewModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
public enum MovieCategory: String {
    case trending = "trending"
    case nowPlaying = "nowPlaying"
    case savedMovies = "saved"
}

public protocol TrendingMoviesFlowDelegate: AnyObject {
    func actionFetchTrendingMoviesSuccessful(data: TrendingMoviesDataUIModel, for category: MovieCategory)
    func actionFetchTrendingMoviesFailed(error: TrendingMoviesErrorUIModel, for category: MovieCategory)
}

// MARK: - Dependency
public protocol TrendingMoviesDependency: AnyObject {
    func getLanguageCode() -> String?
   
}
// MARK: - ViewModel
public class TrendingMoviesViewModel {
    /// Flow Delegate
    public weak var delegate: TrendingMoviesFlowDelegate?

    /// Dependency
    public weak var component: TrendingMoviesDependency?
    let category: MovieCategory
    // MARK: - Init
    init(delegate: TrendingMoviesFlowDelegate?,
         component: TrendingMoviesDependency?,
         category: MovieCategory) {
        self.delegate = delegate
        self.component = component
        self.category = category
    }

    public func fetchTrendingMovies(endpoint: String) {
        let language = component?.getLanguageCode()

        callTrendingMoviesAPI(endpoint: endpoint, language: language,
                              successCallBack: { [weak self] response in
            let movies: [MovieDataUIModel] = response.results?.map { obj in
                
                MovieDataUIModel(id: obj.id ?? 0, title: obj.title ?? "", overview: obj.overview ?? "", posterPath: obj.posterPath ?? "", releaseDate: obj.releaseDate ?? "", voteAverage: obj.voteAverage ?? 0.0, originalLanguage: obj.originalLanguage ?? "", genreIds: obj.genreIds ?? [])
                
            } ?? []
            let movieUIModel = TrendingMoviesDataUIModel(results: movies)
            self?.delegate?.actionFetchTrendingMoviesSuccessful(data: movieUIModel, for: self?.category ?? .trending)
        }, failureCallBack: { [weak self] error in
            let errorModel: TrendingMoviesErrorUIModel
            if let apiError = error as? APIError {
                switch apiError {
                case .noInternet:
                    errorModel = TrendingMoviesErrorUIModel(
                        statusCode: "NO_INTERNET",
                        statusMessage: "No Internet Connection"
                    )
                default:
                    errorModel = TrendingMoviesErrorUIModel(
                        statusCode: "-1",
                        statusMessage: error.localizedDescription
                    )
                }
            } else {
                errorModel = TrendingMoviesErrorUIModel(
                    statusCode: "-1",
                    statusMessage: error.localizedDescription
                )
            }
            self?.delegate?.actionFetchTrendingMoviesFailed(error: errorModel, for: self?.category ?? .trending)
        })
    }
    
    private func callTrendingMoviesAPI(endpoint: String,
        language: String?,
                                       successCallBack: @escaping (TrendingMoviesResponseModel) -> Void,
                                       failureCallBack: @escaping (Error) -> Void) {

        var endpoint = endpoint
        var queryItems: [String] = []

        if let language = language {
            queryItems.append("language=\(language)")
        }

        if !queryItems.isEmpty {
            endpoint.append("?" + queryItems.joined(separator: "&"))
        }

        APIClient.shared.request(endpoint: endpoint) { (result: Result<TrendingMoviesResponseModel, APIError>) in
            switch result {
            case .success(let response):
                successCallBack(response)
            case .failure(let error):
                failureCallBack(error)
            }
        }
    }
}
