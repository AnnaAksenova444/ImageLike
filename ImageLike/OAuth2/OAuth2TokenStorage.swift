import UIKit

protocol OAuth2TokenStorageProtocol {
    var token: String { get set }
}

final class OAuth2TokenStorage {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case token
    }
}

extension OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    var token: String {
        get {
            storage.string(forKey: Keys.token.rawValue) ?? ""
        }
        set {
            storage.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}

