//
//  AddMovieViewModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
public protocol AddMovieFlowDelegate: AnyObject {
    func actionAddMovieSuccessful(data: AddMovieDataUIModel)
    func actionAddMovieFailed(error: AddMovieErrorUIModel)
}

// MARK: - Dependency
public protocol AddMovieDependency: AnyObject {
    func getMovieId() -> Int?
   
}
// MARK: - ViewModel
public class AddMovieViewModel {
    /// Flow Delegate
    public weak var delegate: AddMovieFlowDelegate?

    /// Dependency
    public weak var component: AddMovieDependency?
    
    // MARK: - Init
    init(delegate: AddMovieFlowDelegate?,
         component: AddMovieDependency?) {
        self.delegate = delegate
        self.component = component
    }

    public func addMovie(endpoint: String) {
        let movieID = Int(component?.getMovieId() ?? 0)
        
        let requestModel = AddMovieRequestModel(mediaId: movieID)
        
        callAddMovieAPI(endpoint: endpoint, requestModel: requestModel,
                              successCallBack: { [weak self] response in
            
            let addMovieDataUIModel = AddMovieDataUIModel(statusCode: response.statusCode, statusMessage: response.statusMessage)

            self?.delegate?.actionAddMovieSuccessful(data: addMovieDataUIModel)
        }, failureCallBack: { [weak self] error in
            
            let errorModel: AddMovieErrorUIModel
            if let apiError = error as? APIError {
                switch apiError {
                case .noInternet:
                    errorModel = AddMovieErrorUIModel(
                        statusCode: "NO_INTERNET",
                        statusMessage: "No Internet Connection"
                    )
                default:
                    errorModel = AddMovieErrorUIModel(
                        statusCode: "-1",
                        statusMessage: error.localizedDescription
                    )
                }
            } else {
                errorModel = AddMovieErrorUIModel(
                    statusCode: "-1",
                    statusMessage: error.localizedDescription
                )
            }
            self?.delegate?.actionAddMovieFailed(error: errorModel)
        })
    }
    
    private func callAddMovieAPI(endpoint: String,
                                 requestModel: AddMovieRequestModel,
                                 successCallBack: @escaping (AddMovieResponseModel) -> Void,
                                     failureCallBack: @escaping (Error) -> Void) {

        var endpoint = endpoint
        var queryItems: [String] = []
        let language: String? = "en-US"
        if let language = language {
            queryItems.append("language=\(language)")
        }

        if !queryItems.isEmpty {
            endpoint.append("?" + queryItems.joined(separator: "&"))
        }

        APIClient.shared.request(endpoint: endpoint, method: "POST", body: requestModel) { (result: Result<AddMovieResponseModel, APIError>) in
            switch result {
            case .success(let response):
                successCallBack(response)
            case .failure(let error):
                failureCallBack(error)
            }
        }
    }
}
