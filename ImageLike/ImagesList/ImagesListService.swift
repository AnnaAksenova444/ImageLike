import UIKit

struct Photo {
    let id: String?
    let size: CGSize?
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool?
}

struct PhotoResult: Codable {
    let id: String?
    let width: Int
    let height: Int
    let createdAt: Date?
    let welcomeDescription: String?
    let imageURL: UrlsResult?
    let isLike: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case imageURL = "urls"
        case isLike = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let large: String?
    let thumb: String?
    
    enum CodingKeys: String, CodingKey {
        case thumb = "thumb"
        case large = "full"
    }
}

final class ImagesListService {
    private let shared = ImagesListService()
    private init() {}
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func loadPhotosRequest(_ token: String) -> URLRequest? {
        guard let url = URL(
            string: "/photos",
            relativeTo: Constants.defaultBaseURL)
        else {
            assertionFailure("Failed to create URL for load photos")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchPhotosNextPage (_ token: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        
        guard let request = loadPhotosRequest(token) else {
            print("Error: Load photos error")
            return
        }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photos):
                let newPhoto = Photo(id: photos.id,
                                     size: CGSize(width: photos.width, height: photos.height),
                                     createdAt: photos.createdAt,
                                     welcomeDescription: photos.welcomeDescription,
                                     thumbImageURL: photos.imageURL?.thumb,
                                     largeImageURL: photos.imageURL?.large,
                                     isLiked: photos.isLike)
                
                self.photos.append(newPhoto)
                let nextPage = (lastLoadedPage ?? 0) + 1
                self.lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self)
                
            case .failure(let error):
                completion(.failure(error))
                print("[ImagesListService.fetchPhotosNextPage]: [Not data available load photos]: [Error:\(error.localizedDescription)]")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
