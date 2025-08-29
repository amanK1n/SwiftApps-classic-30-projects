//
//  BookmarkedListResponseModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
class BookmarkedListResponseModel: Decodable {
    let items: [MovieItem]
    enum CodingKeys: String, CodingKey {
        case items
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([MovieItem].self, forKey: .items)
    }
}

class MovieItem: Decodable {
    let title: String
    let posterPath: String
    let genreIds: [Int]
    let id: Int
    enum CodingKeys: String, CodingKey {
        case title
        case posterPath = "poster_path"
        case genreIds = "genre_ids"
        case id
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        posterPath = try container.decode(String.self, forKey: .posterPath)
        genreIds = try container.decode([Int].self, forKey: .genreIds)
        id = try container.decode(Int.self, forKey: .id)
    }
}
