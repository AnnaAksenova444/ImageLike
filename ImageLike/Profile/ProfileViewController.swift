import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    private let photoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let characteristicLabel = UILabel()
    private var exitButton = UIButton()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAvatar()
        createLabels()
        createButton()
        
        guard let profile = ProfileService.shared.profile else { return }
        updateLabels(profile: profile)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self,
                let userInfo = notification.userInfo,
                let urlString = userInfo ["URL"] as? String else {
                    return
                }
                self.updateAvatar(with: urlString)
            }
        if let avatarURL = ProfileImageService.shared.avatarURL {
            updateAvatar(with: avatarURL)
        } else {
            ProfileImageService.shared.fetchProfileImageURL(profile.userName ?? "", OAuth2TokenStorage().token ?? ""){_ in
            }
        }
    }
    
    // MARK: - Private functions
    
    private func createAvatar () {
        photoImageView.image = UIImage.photo
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImageView)
        
        NSLayoutConstraint.activate([
            photoImageView.heightAnchor.constraint(equalToConstant: 70),
            photoImageView.widthAnchor.constraint(equalToConstant: 70),
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            photoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func createLabels() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        loginLabel.text = "@ekaterina_nov"
        loginLabel.textColor = .ypWhiteAlpha50
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        characteristicLabel.text = "Hello, world!"
        characteristicLabel.textColor = .ypWhite
        characteristicLabel.font = UIFont.systemFont(ofSize: 13)
        characteristicLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(characteristicLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            nameLabel.leftAnchor.constraint(equalTo: photoImageView.leftAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            characteristicLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            characteristicLabel.leftAnchor.constraint(equalTo: loginLabel.leftAnchor)
        ])
    }
    
    private func createButton() {
        exitButton = UIButton.systemButton(
            with: UIImage.exit,
            target: self,
            action: #selector(Self.didTapLogoutButton))
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func updateAvatar(with urlString: String) {
        guard
            let url = URL(string: urlString)
        else {
            print("Error: Avatar not found or URL error")
            return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 36, backgroundColor: .clear)
        photoImageView.kf.indicatorType = .activity
        photoImageView.kf.setImage(with: url,
                                   placeholder: UIImage(named: "placeholder.jpeg"),
                                   options:[.processor(processor),
                                            .cacheSerializer(FormatIndicatedCacheSerializer.png)])
    }
    
    private func updateLabels(profile: Profile) {
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        characteristicLabel.text = profile.bio
    }
    
    @objc
    private func didTapLogoutButton() {
        // TODO: - Добавить действие при нажатии на кнопку
    }
}
