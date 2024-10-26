//
//  ProfileViewController.swift
//  Image Feed
//
//  Created by Kaider on 03.09.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    static let shared = ProfileViewController()
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
  
    
    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "Avatar")
        return imageView
    } ()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = UIColor(named: "YPWhite")
        return label
    } ()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "YPGray")
        return label
    } ()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "YPWhite")
        return label
    } ()
    
    private let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "log_out_button"), for: .normal)
        button.tintColor = UIColor(named: "YPRed")
        return button
    } ()
    
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        exitButton.addTarget(self, action: #selector (didTapLogOutButton), for: .touchUpInside)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        
        view.backgroundColor = UIColor(named: "background")
        
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(messageLabel)
        view.addSubview(exitButton)
        
        setupConstraints()
        updateProfile()
    }
    
    // MARK: - Setup Constrains
    
    private func setupConstraints() {
        // Аватар
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        // Имя
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
        ])
        // Ник
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
        // Сообщение
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
        ])
        // Кнопка выхода
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55),
            exitButton.widthAnchor.constraint(equalToConstant: (24)),
            exitButton.heightAnchor.constraint(equalToConstant: (24))
        ])
    }
    // MARK: - Actions
    
    @objc private func didTapLogOutButton() {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert)
        
        let yesTapAction = UIAlertAction(
            title: "Да",
            style: .destructive)
        { _ in print("Пользватель вышел")
        }
        yesTapAction.setValue(UIColor.blue, forKey: .init("titleTextColor"))
        
        let noTapAction = UIAlertAction(
            title: "Нет",
            style: .cancel)
        {_ in print("Пользователь отменил выход")
        }
        noTapAction.setValue(UIColor.blue, forKey: .init("titleTextColor"))
        
        alertController.addAction(yesTapAction)
        alertController.addAction(noTapAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func updateProfile() {
        guard let token = tokenStorage.token else {
            print("ProfileViewController: Токен отсутствует") // Лог ошибок
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.updateUI(with: profile)
                case .failure(let error):
                    print("ProfileViewController: Ошибка при получении профиля - \(error.localizedDescription)") // Лог ошибок
                }
            }
        }
    }
    
    private func updateProfileDetalis() {
        guard let profile = profileService.profile else {
            print("ProfileViewController: Профиль отсутствует") // Лог ошибок
            return
        }
        
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        messageLabel.text = profile.bio
        
        print("ProfileViewController: UI обновлен с данными профиля") // Лог ошибок
    }
    
    private func updateUI(with profile: ProfileModels.Profile) {
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        messageLabel.text = profile.bio
        print("ProfileViewController: UI обновлен с данными профиля") // Лог ошибок
    }
    
    private func updateAvatar() {
        guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
        else { return }
        print("ProfileViewController: Avatar image URL: \(url)") // Лог ошибок
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder.jpeg"), options: [.processor(processor)])
    }
}
