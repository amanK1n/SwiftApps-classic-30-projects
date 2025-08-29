//
//  BookmarkedListViewModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
public protocol BookmarkedListFlowDelegate: AnyObject {
    func actionBookmarkedListSuccessful(data: BookmarkedListDataUIModel)
    func actionBookmarkedListFailed(error: BookmarkedListErrorUIModel)
}


// MARK: - ViewModel
public class BookmarkedListViewModel {
    /// Flow Delegate
    public weak var delegate: BookmarkedListFlowDelegate?

    
    // MARK: - Init
    init(delegate: BookmarkedListFlowDelegate?) {
        self.delegate = delegate
    }

    public func fetchBookmarkedList(endpoint: String) {
        
        callBookmarkedListAPI(endpoint: endpoint,
                              successCallBack: { [weak self] response in
            let movieItemDataUIModel: [MovieItemDataUIModel] = response.items.map { obj in
                MovieItemDataUIModel(title: obj.title, posterPath: obj.posterPath, genreIds: obj.genreIds, id: obj.id)
            }
            let bookmarkedListDataUIModel = BookmarkedListDataUIModel(items: movieItemDataUIModel)

            self?.delegate?.actionBookmarkedListSuccessful(data: bookmarkedListDataUIModel)
        }, failureCallBack: { [weak self] error in
            let errorModel: BookmarkedListErrorUIModel
            if let apiError = error as? APIError {
                switch apiError {
                case .noInternet:
                    errorModel = BookmarkedListErrorUIModel(
                        statusCode: "NO_INTERNET",
                        statusMessage: "No Internet Connection"
                    )
                default:
                    errorModel = BookmarkedListErrorUIModel(
                        statusCode: "-1",
                        statusMessage: error.localizedDescription
                    )
                }
            } else {
                errorModel = BookmarkedListErrorUIModel(
                    statusCode: "-1",
                    statusMessage: error.localizedDescription
                )
            }
            self?.delegate?.actionBookmarkedListFailed(error: errorModel)
        })
    }
    
    private func callBookmarkedListAPI(endpoint: String,
                                 
                                 successCallBack: @escaping (BookmarkedListResponseModel) -> Void,
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

        APIClient.shared.request(endpoint: endpoint) { (result: Result<BookmarkedListResponseModel, APIError>) in
            switch result {
            case .success(let response):
                successCallBack(response)
            case .failure(let error):
                failureCallBack(error)
            }
        }
    }
}
