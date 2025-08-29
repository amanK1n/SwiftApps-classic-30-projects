//
//  MoviePersistenceManager.swift
//  MovieApp
//
//  Created by Sayed on 25/08/25.
//

import CoreData
import UIKit
class CachedImage {
    let image: UIImage
    let expiryDate: Date
    
    init(image: UIImage, ttl: TimeInterval) {
        self.image = image
        self.expiryDate = Date().addingTimeInterval(ttl)
    }
    
    var isExpired: Bool {
        return Date() > expiryDate
    }
}

class MoviePersistenceManager {
    static let shared = MoviePersistenceManager()
    private init() {}
    
    private lazy var context: NSManagedObjectContext = {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            var ctx: NSManagedObjectContext!
            DispatchQueue.main.sync {
                ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            }
            return ctx
        }
    }()

    private let imageCache = NSCache<NSNumber, CachedImage>()
    private let cacheTTL: TimeInterval = 86400
    func saveMovies(_ movies: [MovieDataUIModel], posterImages: [Int: UIImage], category: MovieCategory) {
        for movie in movies {
            let entity = MovieEntity(context: context)
            entity.id = Int64(movie.id)
            entity.title = movie.title
            entity.overview = movie.overview
            entity.genreIds = movie.genreIds.map { String($0) }.joined(separator: ",")
            entity.category = category.rawValue
            if let image = posterImages[movie.id] {
                let fileName = "\(movie.id).png"
                if let savedFile = FileStorage.saveImage(image, fileName: fileName) {
                    entity.posterFile = savedFile
                    let cached = CachedImage(image: image, ttl: cacheTTL)
                    imageCache.setObject(cached, forKey: NSNumber(value: movie.id))
                }
            } else {
                entity.posterFile = movie.posterPath // fallback: store URL if no image downloaded yet
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving movies:", error)
        }
    }
    func fetchMovies(for category: MovieCategory) -> [MovieDataUIModel] {
        
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category.rawValue)
        do {
            let movies = try context.fetch(fetchRequest)
            return movies.map { entity in
                let genres = entity.genreIds?.split(separator: ",").compactMap { Int($0) } ?? []
                return MovieDataUIModel(id: Int(entity.id), title: entity.title ?? "", overview: entity.overview ?? "", posterPath: entity.posterFile ?? "", releaseDate: entity.releaseDate, voteAverage: entity.voteAverage, originalLanguage: entity.originalLanguage, genreIds: genres)
            }
        } catch {
            return []
        }
    }
    
    func getPosterImage(movieId: Int) -> UIImage? {
        let key = NSNumber(value: movieId)
        if let cached = imageCache.object(forKey: key) {
            if !cached.isExpired {
                return cached.image
            } else {
                imageCache.removeObject(forKey: key)
            }
        }
        if let image = FileStorage.loadImage(fileName: "\(movieId).png") {
            let cached = CachedImage(image: image, ttl: cacheTTL)
            imageCache.setObject(cached, forKey: key)
            return image
        }
        return nil
    }
    
    
}
