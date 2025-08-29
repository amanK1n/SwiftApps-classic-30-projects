//
//  TrendingMoviesResponseModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
// MARK: - Response Models

public class MovieResponseModel: Decodable {
    let id: Int?
    let title: String?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let originalLanguage: String?
    let genreIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguage)
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds)
    }
}

public class TrendingMoviesResponseModel: Decodable {
    let results: [MovieResponseModel]?

    enum CodingKeys: String, CodingKey {
        case results
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        results = try container.decodeIfPresent([MovieResponseModel].self, forKey: .results)
    }
}
