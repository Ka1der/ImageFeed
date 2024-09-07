//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Kaider on 05.09.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
}
