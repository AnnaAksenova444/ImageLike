import UIKit

final class OAuth2TokenStorage {
    private let storage: UserDefaults = .standard
    
    var token: String? {
        get {
            storage.string(forKey: "token")
        }
        set {
            storage.set(newValue, forKey: "token")
        }
    }
}

