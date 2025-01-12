import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
            let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            let task = dataTask(with: request, completionHandler: { data, response, error in
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200..<300 ~= statusCode {
                        fulfillCompletionOnTheMainThread(.success(data))
                    } else {
                        print("Error: httpStatusCode")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    print("Error: urlRequestError")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                } else {
                    print("Error: urlSessionError")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                }
            })
            return task
        }
    
        func objectTask<T: Decodable>(
            for request: URLRequest,
            completion: @escaping (Result<T, Error>) -> Void
        ) -> URLSessionTask {
            let decoder = JSONDecoder()
            let task = data(for: request) { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    do {
                        let response = try decoder.decode(T.self, from: data)
                        completion (.success(response))
                    } catch {
                        print("Error: data not decode in objectTask")
                        completion (.failure(error))
                    }
                case .failure(let error):
                    print("Error: not data available in objectTask")
                    completion (.failure(error))
                }
            }
            return task
        }
    }

