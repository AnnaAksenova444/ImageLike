import UIKit

final class OAuth2Service {
    
    // MARK: - Lifecycle
    
    static let shared = OAuth2Service()
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    // MARK: - Private functions
    
    private func makeUrlRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.unsplashTokenURLString) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Failed to create URL")
            print("[OAuth2Service.makeUrlRequest]: [Failed to create URL from components: \(urlComponents.string ?? "nil")]")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Functions
    
    func fetchOAuthToken (code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("[OAuth2Service.fetchOAuthToken]: [Authorization code was already used. lastCode = \(lastCode ?? "nil"), currentCode = \(code)]")
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeUrlRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            print("[OAuth2Service.fetchOAuthToken]:[Incorrect request]-[Error: \(AuthServiceError.invalidRequest)")
            return
        }
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                    let authToken = data.accessToken
                    guard let authToken else { return }
                    completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
                print("[OAuth2Service.fetchOAuthToken:[Incorrect token]-[Error: \(error.localizedDescription)]")
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}

// MARK: - unsplashTokenURLString

enum OAuth2ServiceConstants {
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
}

// MARK: - AuthServiceError

enum AuthServiceError: Error {
    case invalidRequest
}
