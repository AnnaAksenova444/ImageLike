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
}
