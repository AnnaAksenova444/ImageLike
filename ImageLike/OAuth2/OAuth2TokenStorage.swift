import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: "imageLike_token")
        }
        set {
            if let newValue {
                keychainWrapper.set(newValue, forKey: "imageLike_token")
            } else {
                keychainWrapper.removeObject(forKey: "imageLike_token")
            }
        }
    }
}
