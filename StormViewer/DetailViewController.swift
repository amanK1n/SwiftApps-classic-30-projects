//
//  DetailViewController.swift
//  StormViewer
//
//  Created by Sayed on 19/07/25.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet public var imageView: UIImageView?
    var selectedImage: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = self.selectedImage
        navigationItem.largeTitleDisplayMode = .never
     if let loadImage = selectedImage {
         imageView?.image = UIImage(named: loadImage)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
