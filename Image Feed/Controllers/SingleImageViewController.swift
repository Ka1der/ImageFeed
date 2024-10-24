//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Kaider on 05.09.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties

    var image: UIImage? {
        
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self

        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Actions
        
        @IBAction private func didTapBackButton() {
            dismiss(animated: true, completion: nil)
        }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else {return}
        let share = UIActivityViewController(
            activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Resize Image
        
        private func rescaleAndCenterImageInScrollView(image: UIImage) {
            let minZoomScale = scrollView.minimumZoomScale
            let maxZoomScale = scrollView.maximumZoomScale
            view.layoutIfNeeded()
            let visibleRectSize = scrollView.bounds.size
            var imageSize = image.size
            
            if imageSize.width == 0 {
                imageSize.width = 1
            }
            
            if imageSize.height == 0 {
                imageSize.height = 1
            }
            
            let hScale = visibleRectSize.width / imageSize.width
            let vScale = visibleRectSize.height / imageSize.height
            let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
            scrollView.setZoomScale(scale, animated: false)
            scrollView.layoutIfNeeded()
            let newContentSize = scrollView.contentSize
            let x = (newContentSize.width - visibleRectSize.width) / 2
            let y = (newContentSize.height - visibleRectSize.height) / 2
            scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        }
    }

// MARK: - UIScrollViewDelegate
    
    extension SingleImageViewController: UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }
    }
