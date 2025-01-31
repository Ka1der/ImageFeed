//
//  SingleImageViewController.swift
//  Image Feed
//
//  Created by Kaider on 05.09.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Properties
    
    var image: UIImage! {
        
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private var largeImageURL: URL?
    
    // MARK: - Outlets
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        loadLargeImage()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else {return}
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Public Methods
    
    func setImageURL(_ url: URL) {
        largeImageURL = url
    }
    
    // MARK: - Private Methods
    
    private func loadLargeImage() {
        guard let largeImageURL = largeImageURL else { return }
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(
            with: largeImageURL,
            placeholder: UIImage(named: "placeholder")) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success(let imageResult):
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure(let error):
                    self.showError()
                    print("\(#file):\(#line)] \(#function) Ошибка загрузки изображения: \(error)")
                }
            }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let exitAction = UIAlertAction(
            title: "Не надо",
            style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            }
        
        let retryAction = UIAlertAction(
            title: "Повторить",
            style: .default) { [weak self] _ in
                self?.loadLargeImage()
            }
        
        alert.addAction(exitAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
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
        
        let scale = max(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        
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
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: offsetY,
            left: offsetX,
            bottom: offsetY,
            right: offsetX
        )
    }
}
