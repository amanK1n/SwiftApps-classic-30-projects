//
//  MovieDetailsResponseModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation

class MovieDetailsResponseModel: Decodable {
    let id: Int
    let title: String
    let genres: [GenreResponseModel]
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let runtime: Int?
    let voteAverage: Double
    let tagline: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case genres
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case runtime
        case voteAverage = "vote_average"
        case tagline
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        genres = try container.decode([GenreResponseModel].self, forKey: .genres)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        originalTitle = try container.decode(String.self, forKey: .originalTitle)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        releaseDate = try container.decode(String.self, forKey: .releaseDate)
        runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        tagline = try container.decodeIfPresent(String.self, forKey: .tagline)
    }
}

class GenreResponseModel: Decodable {
    let id: Int
    let name: String
}





