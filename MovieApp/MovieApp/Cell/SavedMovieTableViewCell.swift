//
//  SavedMovieTableViewCell.swift
//  MovieApp
//
//  Created by Sayed on 24/08/25.
//

import UIKit

class SavedMovieTableViewCell: UITableViewCell {
    @IBOutlet public var movieImgView: UIImageView?
    @IBOutlet public var movieTitle: UILabel?
    @IBOutlet public var movieGenreLabel: UILabel?
    @IBOutlet public var unsaveButton: UIButton?
    @IBOutlet public var customBackgroundView: UIView?
    var unsaveBtnClosure: (() -> Void)? = {}
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    func setupUI() {
        contentView.backgroundColor = UIColor(red: 6/255.0, green: 4/255.0, blue: 31/255.0, alpha: 1.0)
        customBackgroundView?.backgroundColor = UIColor(red: 36/255.0, green: 34/255.0, blue: 58/255.0, alpha: 1.0)
        customBackgroundView?.layer.cornerRadius = 8
        customBackgroundView?.clipsToBounds = true
        movieTitle?.textColor = UIColor.white
        movieTitle?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        movieGenreLabel?.textColor = UIColor.gray
        movieGenreLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        movieImgView?.layer.cornerRadius = 8
        movieImgView?.contentMode = .scaleAspectFill
        movieImgView?.clipsToBounds = true
        unsaveButton?.setTitle("Remove bookmark", for: .normal)
        unsaveButton?.setTitleColor(UIColor.white, for: .normal)
        unsaveButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        unsaveButton?.backgroundColor = UIColor(red: 223/255.0, green: 13/255.0, blue: 49/255.0, alpha: 1.0)
        unsaveButton?.layer.cornerRadius = 8
    }
    
    @IBAction func unsaveBtnAction(_ sender: Any) {
        print("Unsave button tapped")
        unsaveBtnClosure?()
    }
    
}
