//
//  DeepLinkManager.swift
//  MovieApp
//
//  Created by Sayed on 26/08/25.
//

import Foundation
import UIKit
class DeepLinkManager {
    static let shared = DeepLinkManager()
    
    func handle(url: URL) {
        let host = url.host // e.g., "movie"
        let pathComponents = url.pathComponents // e.g., ["/", "123"]
        
        if host == "movie", let movieId = pathComponents.last {
            navigateToMovieDetail(movieId: movieId)
        }
    }
    
    private func navigateToMovieDetail(movieId: String) {
        // Assuming you have a navigation controller
        if let rootVC = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
                fatalError("HomeViewController not found in storyboard")
            }
            rootVC.pushViewController(homeVC, animated: true)
        }
    }
}
