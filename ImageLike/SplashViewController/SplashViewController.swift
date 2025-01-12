import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private var username: String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if storage.token != nil {
            guard let token = storage.token else { return }
            fetchProfile(token)
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Private functions
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

// MARK: - Prepare

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success (let data):
                storage.token = data
                self.switchToTabBarController()
            case .failure:
                print("Error: fetch oauth token")
                break
            }
        }
    }
    
    private func fetchProfile (_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.username = profile.username
                ProfileImageService.shared.fetchProfileImageURL(username, token) { _ in }
                self.switchToTabBarController()
            case .failure:
                print("Error: fetch profile")
                break
            }
        }
    }
}
