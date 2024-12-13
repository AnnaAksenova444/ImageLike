import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private func makeUrlRequest(code: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.unsplashTokenURLString) else {
            preconditionFailure("Error URL")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            preconditionFailure("Error URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken (code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeUrlRequest(code: code)
        
        let task = URLSession.shared.data (for: request) { result in
            
            switch result {
            case .success(let data):
                do {
                    let authToken = try
                    JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    guard let authToken = authToken.accessToken else {return}
                    completion(.success(authToken))
                } catch {
                    completion (.failure(error))
                    
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task .resume()
    }
}

enum OAuth2ServiceConstants {
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
}
