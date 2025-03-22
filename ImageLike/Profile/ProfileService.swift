import UIKit

struct ProfileResult: Codable {
    let username: String?
    let first_name: String?
    let last_name: String?
    let bio: String?
}

struct Profile {
    let userName: String?
    let name: String?
    let loginName: String?
    let bio: String?
}

final class ProfileService {
    
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() {}
    
    private func profileRequest(_ token: String) -> URLRequest? {
        guard let url = URL(
            string: "/me",
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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = profileRequest(token) else {
            print("Error: Profile request error")
            return
        }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                    self.profile = Profile(
                        userName: data.username ?? "",
                        name: "\(data.first_name ?? "")"+" "+"\(data.last_name ?? "")",
                        loginName: "@\(data.username ?? "")",
                        bio: data.bio ?? "")
                    guard let profile = self.profile else { return }
                    completion(.success(profile))
            case .failure(let error):
                print("Error: not data available profile")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
