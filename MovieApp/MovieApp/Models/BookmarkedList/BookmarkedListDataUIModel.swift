//
//  BookmarkedListDataUIModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
public struct BookmarkedListErrorUIModel {
    public let statusCode: String
    public let statusMessage: String
    public init(statusCode: String, statusMessage: String = "") {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }
}


public struct BookmarkedListDataUIModel {
    let items: [MovieItemDataUIModel]
    public init(items: [MovieItemDataUIModel]) {
        self.items = items
    }
}
public struct MovieItemDataUIModel {
    let title: String
    let posterPath: String
    let genreIds: [Int]
    let id: Int
    public init(title: String, posterPath: String, genreIds: [Int], id: Int) {
        self.title = title
        self.posterPath = posterPath
        self.genreIds = genreIds
        self.id = id
    }
}
