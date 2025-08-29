//
//  SearchMovieViewModel.swift
//  MovieApp
//
//  Created by Sayed on 25/08/25.
//

import Foundation
public protocol SearchMovieFlowDelegate: AnyObject {
    func actionSearchMovieSuccessful(data: TrendingMoviesDataUIModel)
    func actionSearchMovieFailed(error: TrendingMoviesErrorUIModel)
}

// MARK: - ViewModel
public class SearchMovieViewModel {
    /// Flow Delegate
    public weak var delegate: SearchMovieFlowDelegate?
    // MARK: - Init
    init(delegate: SearchMovieFlowDelegate?) {
        self.delegate = delegate
    }

    public func searchMovies(endpoint: String) {
        callSearchMovieAPI(endpoint: endpoint,
                           successCallBack: { [weak self] response in
            
            let searchedMovie: [MovieDataUIModel] = response.results?.compactMap { obj in
                MovieDataUIModel(id: obj.id ?? 0, title: obj.title ?? "", overview: obj.overview ?? "", posterPath: obj.posterPath ?? "", releaseDate: obj.releaseDate, voteAverage: obj.voteAverage, originalLanguage: obj.originalLanguage, genreIds: obj.genreIds ?? [])
                
            } ?? []
            let searchResultUIModel = TrendingMoviesDataUIModel(results: searchedMovie)
            self?.delegate?.actionSearchMovieSuccessful(data: searchResultUIModel)
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
            self?.delegate?.actionSearchMovieFailed(error: errorModel)
        })
    }
    
    private func callSearchMovieAPI(endpoint: String,
                                       successCallBack: @escaping (TrendingMoviesResponseModel) -> Void,
                                       failureCallBack: @escaping (Error) -> Void) {

        let endpoint = endpoint
        
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
