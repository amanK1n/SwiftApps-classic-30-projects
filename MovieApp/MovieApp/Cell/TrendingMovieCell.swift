//
//  TrendingMovieCell.swift
//  MovieApp
//
//  Created by Sayed on 22/08/25.
//

import UIKit

class TrendingMovieCell: UICollectionViewCell {
    @IBOutlet public var movieImageView: UIImageView?
    @IBOutlet public var movieTitleLabel: UILabel?
    @IBOutlet public var movieSubtitle: UILabel?
    @IBOutlet public var customBackgroundView: UIView?
    @IBOutlet public var imgLeadingConstraint: NSLayoutConstraint?
    @IBOutlet public var imgTrailingConstraint: NSLayoutConstraint?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        
        
    }
    func setupUI() {
        customBackgroundView?.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 41/255.0, alpha: 1.0)
        movieImageView?.layer.cornerRadius = 8
        movieImageView?.contentMode = .scaleAspectFill
        movieImageView?.clipsToBounds = true
        movieTitleLabel?.textColor = UIColor.white
        movieTitleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        movieSubtitle?.textColor = UIColor.gray
        movieSubtitle?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
    }
}
