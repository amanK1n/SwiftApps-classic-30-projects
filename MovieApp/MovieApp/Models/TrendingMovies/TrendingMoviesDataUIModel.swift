//
//  TrendingMoviesModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation

public struct TrendingMoviesErrorUIModel {
    public let statusCode: String
    public let statusMessage: String
    public init(statusCode: String, statusMessage: String = "") {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }
}

public struct MovieDataUIModel {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let releaseDate: String?
    let voteAverage: Double?
    let originalLanguage: String?
    let genreIds: [Int]
    init(id: Int, title: String, overview: String, posterPath: String, releaseDate: String?, voteAverage: Double?, originalLanguage: String?, genreIds: [Int]) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.originalLanguage = originalLanguage
        self.genreIds = genreIds
    }
}
public struct TrendingMoviesDataUIModel {
    let results: [MovieDataUIModel]
    init(results: [MovieDataUIModel]) {
        self.results = results
    }
}
