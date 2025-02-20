import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        setIsLiked(false)
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.imagesListCellDidTapLike(self)
    }
    
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
        
        likeButton.accessibilityIdentifier = "likeButton"
        likeButton.accessibilityValue = isLiked ? "liked" : "unliked"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if likeButton.frame.width < 44 {
            let x = likeButton.frame.origin.x
            let y = likeButton.frame.origin.y
            likeButton.frame = CGRect(x: x, y: y, width: 44, height: 44)
        }
    }
}
