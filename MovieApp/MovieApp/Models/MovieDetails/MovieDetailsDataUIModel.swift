//
//  MovieDetailsDataUIModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
public struct MovieDetailsErrorUIModel {
    public let statusCode: String
    public let statusMessage: String
    public init(statusCode: String, statusMessage: String = "") {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }
}
public struct MovieDetailsDataUIModel {
    let id: Int
    let title: String
    let genres: [GenreDataUIModel]
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let runtime: Int
    let rating: String
    let tagline: String?
    
    public init(id: Int, title: String, genres: [GenreDataUIModel], originalLanguage: String, originalTitle: String, overview: String, posterPath: String?, releaseDate: String, runtime: Int, rating: String, tagline: String?) {
        self.id = id
        self.title = title
        self.genres = genres
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.rating = rating
        self.tagline = tagline
    }
}
public struct GenreDataUIModel {
    let id: Int
    let name: String
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
