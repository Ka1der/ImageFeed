import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController & ImageListViewControllerProtocol, ImagesListCellDelegate {
    private let showSingleImageSegueIdentifier: String = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Properties
    
    private var photos: [Photo] = []
    private var presenter: ImageListPresenterProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        let presenter = ImageListPresenter()
        self.presenter = presenter
        presenter.view = self
        presenter.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let destination = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photos = presenter?.photos
            else { return }
            
            let photo = photos[indexPath.row]
            destination.setImageURL(photo.largeImageURL)
        }
    }
    
    // MARK: - ImageListViewControllerProtocol
    
    func updateTableViewAnimated(withPhotos newPhotos: [Photo]) {
        let oldCount = photos.count
        photos.append(contentsOf: newPhotos)
        
        if oldCount == 0 {
            tableView.reloadData()
        } else {
            let indexPaths = (oldCount..<photos.count).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func showLikeError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось поставить/убрать лайк",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        print("Таблица настроена") // Добавляем для отладки
    }
    
    
    // MARK: - Private Methods
    
    private func configurateTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.cellImage.kf.cancelDownloadTask()
        cell.cellImage.image = nil
        
        cell.cellImage.kf.indicatorType = .activity
        cell.delegate = self
        
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.setIsLiked(photo.isLiked)
        
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        
        cell.cellImage.kf.setImage(
            with: photo.thumbImageURL,
            placeholder: UIImage(named: "stub"),
            options: [
                .processor(processor),
                .transition(.fade(0.25)),
                .cacheOriginalImage,
            ]
        )
    }
    
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            presenter?.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        guard photo.size.width > 0 else { return 200 }
        
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        guard cellHeight.isFinite && cellHeight > 0 else { return 200 }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        presenter?.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.presenter?.photos ?? []
                if let visibleCell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                    visibleCell.setIsLiked(self.photos[indexPath.row].isLiked)
                }
            case .failure(let error):
                print("Ошибка лайка/дизлайка: \(error)")
                self.showLikeErrorAlert()
            }
        }
    }
    
    private func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось поставить/убрать лайк",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
