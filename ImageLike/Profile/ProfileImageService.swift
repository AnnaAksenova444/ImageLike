import UIKit

struct UserResult: Codable {
    let profile_image: ProfileImage
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    
    private init() {}
    
    private func profileImageUrlRequest (_ username: String, _ token: String) -> URLRequest? {
        guard let url = URL(
            string: "/users/\(username)" + "?client_id=\(Constants.accessKey)",
            relativeTo: Constants.defaultBaseURL)
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(_ username: String, _ token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = profileImageUrlRequest(username, token) else {
            print("Error: Profile_image request error")
            return
        }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                self.avatarURL = data.profile_image.large
                guard let avatarURL = self.avatarURL else {return}
                completion (.success(avatarURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
            case.failure(let error):
                print("Error: not data available profile image")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
