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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
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
    @objc func shareTapped() {
        guard let image = imageView?.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }

        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
