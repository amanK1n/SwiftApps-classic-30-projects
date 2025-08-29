//
//  Utility.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import Foundation
import UIKit

class Utility {
    
    private static let genreResolver: [Int: String] =
    [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
    
    static func getGenreNames(for ids: [Int]) -> [String] {
        return ids.map { genreResolver[$0] ?? "Unknown" }
    }
    // MARK: - Loader
    

        private static var loaderContainer: UIView?
        private static var loader: UIActivityIndicatorView?
    static let screenHeight = UIScreen.main.bounds.height
        static func showLoader(on view: UIView) {
            DispatchQueue.main.async {
                if loaderContainer == nil {
                    let container = UIView(frame: view.bounds)
                    container.backgroundColor = UIColor.black.withAlphaComponent(1)
                    container.translatesAutoresizingMaskIntoConstraints = false
                    container.isUserInteractionEnabled = false
                    loaderContainer = container
                    
                    let indicator = UIActivityIndicatorView(style: .large)
                    indicator.color = .blue
                    indicator.translatesAutoresizingMaskIntoConstraints = false
                    loader = indicator
                    
                    container.addSubview(indicator)
                    NSLayoutConstraint.activate([
                        indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                        indicator.centerYAnchor.constraint(equalTo: container.topAnchor, constant: screenHeight / 2)
                    ])
                }
                
                guard let loaderContainer = loaderContainer else { return }
                view.addSubview(loaderContainer)
                NSLayoutConstraint.activate([
                    loaderContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    loaderContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    loaderContainer.topAnchor.constraint(equalTo: view.topAnchor),
                    loaderContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
                
                loader?.startAnimating()
            }
        }

        // Hide loader
        static func hideLoader() {
            DispatchQueue.main.async {
                loader?.stopAnimating()
                loaderContainer?.removeFromSuperview()
                loader = nil
                loaderContainer = nil
            }
        }
    

}

class FileStorage {
    static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func saveImage(_ image: UIImage, fileName: String) -> String? {
        guard let data = image.pngData() else { return nil }
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return fileName
        } catch {
            return nil
        }
    }
    
    static func loadImage(fileName: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
}

// MARK: - UIImageView Extension inside Utility
extension UIImageView {
    func loadImage(from url: URL?) {
        guard let url = url else {
            self.image = UIImage(systemName: "photo") // fallback placeholder
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}

extension UIViewController {
    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 0.0
        
        let padding: CGFloat = 20
        let textSize = toastLabel.intrinsicContentSize
        toastLabel.frame = CGRect(
            x: (view.frame.width - textSize.width - padding) / 2,
            y: view.frame.height - 120,
            width: textSize.width + padding,
            height: textSize.height + 12
        )
        
        view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.3) {
            toastLabel.alpha = 1.0
        }
        
        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut) {
            toastLabel.alpha = 0.0
        } completion: { _ in
            toastLabel.removeFromSuperview()
        }
    }
}


extension UIApplication {
    class func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
