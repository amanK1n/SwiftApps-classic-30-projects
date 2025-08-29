//
//  AddMovieRequestModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
class AddMovieRequestModel: Encodable {
    let mediaId: Int?
    enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
    }
     func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mediaId, forKey: .mediaId)
    }
    internal init(mediaId: Int?) {
        self.mediaId = mediaId
    }
}
