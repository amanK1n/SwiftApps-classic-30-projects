//
//  AddMovieDataUIModel.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
public struct AddMovieErrorUIModel {
    public let statusCode: String
    public let statusMessage: String
    public init(statusCode: String, statusMessage: String = "") {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }
}
public struct AddMovieDataUIModel {
    var statusCode: Int?
    var statusMessage: String?
    
    public init(statusCode: Int? = nil, statusMessage: String? = nil) {
        self.statusCode = statusCode
        self.statusMessage = statusMessage
    }
}
