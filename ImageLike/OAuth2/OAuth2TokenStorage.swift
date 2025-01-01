import UIKit

final class OAuth2TokenStorage {
    private let storage: UserDefaults = .standard
    
    var token: String? {
        get {
            storage.string(forKey: "imageLike_token")
        }
        set {
            storage.set(newValue, forKey: "imageLike_token")
        }
    }
}

